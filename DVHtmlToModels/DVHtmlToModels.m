//
//  DVHtmlToModels.m
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "DVHtmlToModels.h"

#import "DVContextObject.h"

#import <UIKit/UIKit.h>
#import <hpple/TFHpple.h>
#import <objc/runtime.h>

#pragma mark -
#pragma mark NSString+DVHtmlToModels_Private
@interface NSString(DVHtmlToModels_Private)
@end
@implementation NSString(DVHtmlToModels_Private)
- (NSString *)dv_encodeForUrl {
    const char *input_c = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSMutableString *result = [NSMutableString new];
    for (NSInteger i = 0, len = strlen(input_c); i < len; i++) {
        unsigned char c = input_c[i];
        if (
            (c >= '0' && c <= '9')
            || (c >= 'A' && c <= 'Z')
            || (c >= 'a' && c <= 'z')
            || c == '-' || c == '.' || c == '_' || c == '~'
            ) {
            [result appendFormat:@"%c", c];
        } else {
            [result appendFormat:@"%%%02X", c];
        }
    }
    return result;
}
- (NSString *)dv_replacingWithPattern:(NSString *)pattern template:(NSString *)template error:(NSError **)error {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:error];
    return [regex stringByReplacingMatchesInString:self
                                           options:0
                                             range:NSMakeRange(0, self.length)
                                      withTemplate:template];
}
- (NSString *)stringByDecodingXMLEntities {
    NSUInteger myLength = [self length];
    NSUInteger ampIndex = [self rangeOfString:@"&" options:NSLiteralSearch].location;

    // Short-circuit if there are no ampersands.
    if (ampIndex == NSNotFound) {
        return self;
    }
    // Make result string with some extra capacity.
    NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];

    // First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
    NSScanner *scanner = [NSScanner scannerWithString:self];

    [scanner setCharactersToBeSkipped:nil];

    NSCharacterSet *boundaryCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" \t\n\r;"];

    do {
        // Scan up to the next entity or the end of the string.
        NSString *nonEntityString;
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString]) {
            [result appendString:nonEntityString];
        }
        if ([scanner isAtEnd]) {
            goto finish;
        }
        // Scan either a HTML or numeric character entity reference.
        if ([scanner scanString:@"&amp;" intoString:NULL])
            [result appendString:@"&"];
        else if ([scanner scanString:@"&apos;" intoString:NULL])
            [result appendString:@"'"];
        else if ([scanner scanString:@"&quot;" intoString:NULL])
            [result appendString:@"\""];
        else if ([scanner scanString:@"&lt;" intoString:NULL])
            [result appendString:@"<"];
        else if ([scanner scanString:@"&gt;" intoString:NULL])
            [result appendString:@">"];
        else if ([scanner scanString:@"&#" intoString:NULL]) {
            BOOL gotNumber;
            unsigned charCode;
            NSString *xForHex = @"";

            // Is it hex or decimal?
            if ([scanner scanString:@"x" intoString:&xForHex]) {
                gotNumber = [scanner scanHexInt:&charCode];
            }
            else {
                gotNumber = [scanner scanInt:(int*)&charCode];
            }

            if (gotNumber) {
                [result appendFormat:@"%C", (unichar)charCode];

                [scanner scanString:@";" intoString:NULL];
            }
            else {
                NSString *unknownEntity = @"";

                [scanner scanUpToCharactersFromSet:boundaryCharacterSet intoString:&unknownEntity];


                [result appendFormat:@"&#%@%@", xForHex, unknownEntity];

                //[scanner scanUpToString:@";" intoString:&unknownEntity];
                //[result appendFormat:@"&#%@%@;", xForHex, unknownEntity];
                NSLog(@"Expected numeric character entity but got &#%@%@;", xForHex, unknownEntity);

            }

        }
        else {
            NSString *amp;

            [scanner scanString:@"&" intoString:&amp];  //an isolated & symbol
            [result appendString:amp];

            /*
            NSString *unknownEntity = @"";
            [scanner scanUpToString:@";" intoString:&unknownEntity];
            NSString *semicolon = @"";
            [scanner scanString:@";" intoString:&semicolon];
            [result appendFormat:@"%@%@", unknownEntity, semicolon];
            NSLog(@"Unsupported XML character entity %@%@", unknownEntity, semicolon);
             */
        }

    }
    while (![scanner isAtEnd]);

finish:
    return result;
}
@end

#pragma mark -
#pragma mark NSObject+DVHtmlToModels_Private
@interface NSObject(DVHtmlToModels_Private)
@end
@implementation NSObject(DVHtmlToModels_Private)
- (NSString *)dv_getTypeAttributePropertyByName:(NSString *)propertyName {
    if (propertyName && (propertyName.length > 0)) {
        Class observedClass = self.class;
        while (observedClass) {
            objc_property_t propTitle = class_getProperty(observedClass, [propertyName UTF8String]);
            if (propTitle) {
                const char *type = property_getAttributes(propTitle);
                NSString *typeString = [NSString stringWithUTF8String:type];
                NSArray *attributes = [typeString componentsSeparatedByString:@","];
                
                return [attributes objectAtIndex:0];
            }
            
            observedClass = [observedClass superclass];
        }
    }
    
    return nil;
}

- (Class)dv_getTypeClassOfPropertyByName:(NSString *)propertyName {
    NSString *typeAttribute = [self dv_getTypeAttributePropertyByName:propertyName];
    if (typeAttribute && [typeAttribute hasPrefix:@"T@"]) {
        NSString *typeClassName = [typeAttribute substringWithRange:NSMakeRange(3, [typeAttribute length] - 4)];
        return NSClassFromString(typeClassName);
    }
    
    return nil;
}

- (BOOL)dv_hasPropertyByName:(NSString *)propertyName {
    if (propertyName && (propertyName.length > 0)) {
        Class observedClass = self.class;
        while (observedClass) {
            unsigned int count;
            objc_property_t *props = class_copyPropertyList(observedClass, &count);
            for (int i = 0; i < count; i++) {
                if (strcmp(propertyName.UTF8String, property_getName(props[i])) == 0) {
                    free(props);
                    return YES;
                }
            }
            free(props);
            
            observedClass = [observedClass superclass];
        }
    }
    
    return NO;
}

- (void)dv_setValue:(id)value forPropertyName:(NSString *)propertyName {
    if ([self isKindOfClass:[NSMutableDictionary class]]) {
        [((NSMutableDictionary *)self) setObject:value forKey:propertyName];
        return;
    }
    
    if (![self dv_hasPropertyByName:propertyName]) {
        return;
    }
    
    id valuePrepared = value;
    Class propertyClass = [self dv_getTypeClassOfPropertyByName:propertyName];
    
    if (propertyClass && valuePrepared && ![valuePrepared isKindOfClass:propertyClass]) {
        if ([valuePrepared isKindOfClass:[NSArray class]]) {
            valuePrepared = ((NSArray *)valuePrepared).firstObject;
        } else if (propertyClass == [NSArray class]) {
            valuePrepared = @[valuePrepared];
        }
    } else if (!propertyClass) {
        NSString *typeAttribute = [self dv_getTypeAttributePropertyByName:propertyName];
        
        if (typeAttribute) {
            NSString *propertyType = [typeAttribute substringFromIndex:1];
            const char * rawPropertyType = [propertyType UTF8String];
            
            if (strcmp(rawPropertyType, @encode(float)) == 0) {
                valuePrepared = @([valuePrepared floatValue]);
            } else if (strcmp(rawPropertyType, @encode(int)) == 0) {
                valuePrepared = @([valuePrepared intValue]);
            } else if (strcmp(rawPropertyType, @encode(long)) == 0) {
                valuePrepared = @([valuePrepared longLongValue]);
            } else if (strcmp(rawPropertyType, @encode(unsigned long)) == 0) {
                valuePrepared = @([valuePrepared unsignedLongLongValue]);
            } else if (strcmp(rawPropertyType, @encode(double)) == 0) {
                valuePrepared = @([valuePrepared doubleValue]);
            } else if (strcmp(rawPropertyType, @encode(BOOL)) == 0) {
                valuePrepared = @([valuePrepared boolValue]);
            } else if (strcmp(rawPropertyType, @encode(unsigned int)) == 0) {
                valuePrepared = @([valuePrepared unsignedIntValue]);
            } else if (strcmp(rawPropertyType, @encode(short)) == 0) {
                valuePrepared = @([valuePrepared shortValue]);
            } else if (strcmp(rawPropertyType, @encode(char)) == 0) {
                valuePrepared = @([valuePrepared charValue]);
            }
        }
    }
    
    [self setValue:valuePrepared forKey:propertyName];
}
@end

#pragma mark -
#pragma mark DVHtmlToModels
@interface DVHtmlToModels()
@property (nonatomic, strong) NSArray<DVContextObject *> *objects;
@end

@implementation DVHtmlToModels

#define valid(value) [self validValue:(value)]

+ (instancetype)htmlToModelsWithContextByName:(NSString *)contextName {
    return [[super alloc] initWithContextByName:contextName];
}

+ (instancetype)htmlToModelsWithContextOfFile:(NSString *)path {
    return [[super alloc] initWithContextOfFile:path];
}

+ (instancetype)htmlToModelsWithContext:(NSDictionary *)context {
    return [[super alloc] initWithContext:context];
}

- (instancetype)initWithContextByName:(NSString *)contextName {
    return valid(contextName) ?  [self initWithContextOfFile:[[NSBundle mainBundle] pathForResource:contextName ofType:@"plist"]] : [super init];
}

- (instancetype)initWithContextOfFile:(NSString *)path {
    return valid(path) ? [self initWithContext:[NSDictionary dictionaryWithContentsOfFile:path]] : [super init];
}

#define URL_KEY @"url"
#define DATA_KEY @"data"
- (instancetype)initWithContext:(NSDictionary *)context {
    if ((self = [super init]) && valid(context)) {
        _url = context[URL_KEY];
        
        id objectsData = context[DATA_KEY];
        if (objectsData && [objectsData isKindOfClass:[NSArray class]]) {
            NSMutableArray<DVContextObject *> *array = [NSMutableArray array];
            
            for (NSDictionary *objectData in objectsData) {
                DVContextObject *object = [[DVContextObject alloc] initWithContext:objectData];
                
                if (object) {
                    [array addObject:object];
                }
            }
            
            _objects = (array.count > 0) ? [NSArray arrayWithArray:array] : nil;
        }
    }
    return self;
}

- (void)loadDataWithReplacingURLParameters:(NSArray<NSString *> *)replacingURLParameters
                        queryURLParameters:(NSDictionary *)queryURLParameters
                                    asJSON:(BOOL)asJSON
                         completionHandler:(DVHtmlToModelsCompletionBlock)completionHandler {
    if (!valid(self.url)) {
        if (completionHandler) {
            completionHandler(nil, nil);
        }
        return;
    }
    
    [[NSOperationQueue new] addOperationWithBlock:^{
        NSDate *currentTime = [NSDate date];
        
        NSString *preparedUrlString = [self preparedUrlWithReplacingParameters:replacingURLParameters];
        if (valid(queryURLParameters)) {
            preparedUrlString = [self preparedUrlWithQueryParameters:queryURLParameters];
        }
        
        NSLog(@"DVHtmlToModels: Start load %@", preparedUrlString);
        NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:preparedUrlString]];
        NSTimeInterval loadDuration = ABS(currentTime.timeIntervalSinceNow) * 1000;
        NSLog(@"DVHtmlToModels: End load, duration %.0fms.", loadDuration);
        
        currentTime = [NSDate date];
        
        TFHpple *htmlParser = [TFHpple hppleWithHTMLData:htmlData];
        
        if (htmlParser) {
            NSMutableDictionary<NSString *, NSArray *> *preparedData = [NSMutableDictionary new];
            for (DVContextObject *object in self.objects) {
                NSArray *dataArray = [self prepareContextObject:object
                                                         parser:htmlParser
                                                     asJSONData:asJSON];
                
                if (valid(dataArray)) {
                    [preparedData setObject:dataArray forKey:object.className];
                }
            }
            
            NSTimeInterval parseDuration = ABS(currentTime.timeIntervalSinceNow) * 1000;
            NSLog(@"DVHtmlToModels: End parse, duration %.0fms.", parseDuration);
            NSLog(@"DVHtmlToModels: Total duration %.0fms.", (loadDuration + parseDuration));
            
            if (completionHandler) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    completionHandler((preparedData.count > 0 ? preparedData.copy : nil), htmlData);
                }];
            }
        }
    }];
}

- (void)loadDataWithCompletionHandler:(DVHtmlToModelsCompletionBlock)completionHandler {
    [self loadDataWithReplacingURLParameters:nil
                          queryURLParameters:nil
                                      asJSON:NO
                           completionHandler:completionHandler];
}

- (NSArray *)prepareContextObject:(DVContextObject *)object
                           parser:(id)parser
                       asJSONData:(BOOL)asJSONData {
    
    NSArray<TFHppleElement *> *elements = valid(object.xPathRoot) ? [parser searchWithXPathQuery:object.xPathRoot] : nil;
    if (!valid(elements)) return nil;
    
    NSMutableArray *dataArray = [NSMutableArray new];
    for (TFHppleElement *element in elements) {
        id modelObject = (asJSONData
                          ? [NSMutableDictionary new]
                          : [objc_getClass(object.className.UTF8String) new]);
        
        for (DVContextField *field in object.fields) {
            for (DVContextResult *result in field.result) {
                if (result.object) {
                    NSArray *valueObjectArray = [self prepareContextObject:result.object
                                                                    parser:element
                                                                asJSONData:asJSONData];
                    
                    if (valid(valueObjectArray)) {
                        if (!asJSONData) {
                            Class propertyClass = [modelObject dv_getTypeClassOfPropertyByName:field.name];
                            if (![propertyClass isSubclassOfClass:[NSArray class]]) {
                                valueObjectArray = ((NSArray *)valueObjectArray).firstObject;
                            }
                        }
                        
                        [modelObject dv_setValue:valueObjectArray forPropertyName:field.name];
                        
                        break;
                    }
                } else {
                    id resultValue = nil;
                    
                    if (valid(result.results)) {
                        NSMutableArray<NSString *> *results = [NSMutableArray new];
                        for (DVContextResult *subResult in result.results) {
                            id subResultValue = [self resultValueWithDomElement:element resultObject:subResult fieldObject:field];
                            
                            if (subResultValue && [subResultValue isKindOfClass:[NSString class]]) {
                                [results addObject:subResultValue];
                            }
                        }
                        
                        if (results.count > 0) {
                            resultValue = [results componentsJoinedByString:result.separator];
                            resultValue = [self prepareFormating:result.formats forResultValue:resultValue];
                        }
                    } else {
                        resultValue = [self resultValueWithDomElement:element resultObject:result fieldObject:field];
                    }
                    
                    if (resultValue) {
                        [modelObject dv_setValue:resultValue forPropertyName:field.name];
                        break;
                    }
                }
            }
        }
        
        if (asJSONData) {
            modelObject = ((NSMutableDictionary *)modelObject).copy;
        }
        
        [dataArray addObject:modelObject];
    }
    
    return (dataArray.count > 0) ? dataArray.copy : nil;
}

- (id)resultValueWithDomElement:(TFHppleElement *)element
                   resultObject:(DVContextResult *)result
                    fieldObject:(DVContextField *)field {
    id resultValue = nil;
    
    TFHppleElement *resultElement = [element searchWithXPathQuery:result.xPath].firstObject;
    if (resultElement) {
        if (valid(result.attribute)) {
            resultValue = [resultElement objectForKey:result.attribute];
        } else {
            switch (result.textType) {
                case DVTextTypeAll:
                    resultValue = [self removeRegexPattern:@"(<[^>]+>|\n|  +)" fromString:resultElement.raw];
                    break;
                case DVTextTypeRaw:
                    resultValue = [self removeRegexPattern:@"(^<[^>]+>|<[^>]+>$)" fromString:resultElement.raw];
                    break;
                default:
                    resultValue = resultElement.text;
                    break;
            }
        }
        
        if (resultValue) {
            resultValue = [resultValue stringByDecodingXMLEntities];
            
            if (result.textType != DVTextTypeRaw) {
                resultValue = [self removeRegexPattern:@"[\\n\\t\\r]+" fromString:resultValue];
            }
            
            if (valid(result.regex)) {
                resultValue = [self prepareRegexPattern:result.regex forString:resultValue];
            }
            
            if (valid(resultValue) && valid(result.formats)) {
                resultValue = [self prepareFormating:result.formats forResultValue:resultValue];
            }
            
            if (valid(resultValue) && valid(result.value)) {
                resultValue = result.value;
            }
        }
    }
    
    return resultValue;
}

- (id)prepareFormating:(NSArray<DVContextFormat *> *)formats forResultValue:(id)resultValue {
    for (DVContextFormat *format in formats) {
        BOOL needToExecuteFormat = YES;
        for (DVContextCondition *condition in format.conditions) {
            NSString *prepareString = [self prepareRegexPattern:condition.regex forString:resultValue];
            
            if (!(condition.negative ^ valid(prepareString))) {
                needToExecuteFormat = NO;
                break;
            }
        }
        
        if (needToExecuteFormat) {
            switch (format.type) {
                case DVContextFormatTypeDate:{
                    NSDateFormatter *df = [NSDateFormatter new];
                    [df setDateFormat:format.format];
                    
                    return [df dateFromString:resultValue];
                }
                case DVContextFormatTypeReplace:{
                    NSError *error = nil;
                    resultValue = [resultValue dv_replacingWithPattern:format.regex template:format.format error:&error];
                    
                    if (error) {
                        NSLog(@"%@", error);
                    }
                    break;
                }
                case DVContextFormatTypeEncoding:{
                    resultValue = [resultValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                    break;
                }
                case DVContextFormatTypeNumber:{
                    NSNumberFormatter *numberFormat = [NSNumberFormatter new];
                    numberFormat.numberStyle = NSNumberFormatterDecimalStyle;
                    return [numberFormat numberFromString:resultValue];
                }
                default:{
                    resultValue = [NSString stringWithFormat:format.format, resultValue];
                    break;
                }
            }
        }
        
        if (!resultValue) break;
    }
    
    return resultValue;
}

#pragma mark Utils
- (NSString *)prepareRegexPattern:(NSString *)pattern forString:(NSString *)string {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSString *result = @"";
    
    NSArray<NSTextCheckingResult *> *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    for (NSTextCheckingResult *match in matches) {
        result = [result stringByAppendingString:
                  [string substringWithRange:
                   [match rangeAtIndex:((match.numberOfRanges > 1) ? 1 : 0)]]];
    }
    
    return (result.length == 0) ? nil : result;
}

- (BOOL)validValue:(id)value {
    return ([value isKindOfClass:[NSString class]]
            ? (value && [value isKindOfClass:[NSString class]] && [value length])
            : ([value isKindOfClass:[NSArray class]]
               ? (value && [value isKindOfClass:[NSArray class]] && [((NSArray *)value) count])
               : ([value isKindOfClass:[NSDictionary class]]
                  ? (value && [value isKindOfClass:[NSDictionary class]] && [((NSDictionary *)value) count])
                  : (value != nil))));
}

- (NSString *)preparedUrlWithReplacingParameters:(NSArray<NSString *> *)parameters {
    NSString *preparedUrl = [NSString stringWithFormat:@"%@", self.url];
    
    if (valid(preparedUrl) && valid(parameters)) {
        for (NSString *parameter in parameters) {
            NSRange rangeForParameter = [preparedUrl rangeOfString:@"%@"];
            if (NSNotFound != rangeForParameter.location) {
                preparedUrl = [preparedUrl stringByReplacingCharactersInRange:rangeForParameter withString:parameter];
            }
        }
    }
    
    return preparedUrl;
}

- (NSString *)preparedUrlWithQueryParameters:(NSDictionary *)parameters {
    NSMutableString *preparedUrl = self.url.mutableCopy;
    
    if (parameters && parameters.count > 0) {
        BOOL first = YES;
        for (NSString *key in parameters) {
            [preparedUrl appendString:(first ? @"?" : @"&")];
            [preparedUrl appendString:[self prepareParameterWithKey:key value:parameters[key]]];
            first = NO;
        }
    }
    
    return preparedUrl.copy;
}

- (NSString *)prepareParameterWithKey:(NSString *)key value:(id)value {
    if (!valid(key) || !value) {
        return nil;
    }
    
    NSMutableString *parameter = [NSMutableString new];
    
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray *valueArray = (NSArray *)value;
        if (!valueArray.count) {
            valueArray = @[ @"" ];
        }
        
        NSString *preparedKey = [key stringByAppendingString:@"[]"];
        for (NSString *v in valueArray) {
            [parameter appendString:[self prepareParameterWithKey:preparedKey value:v]];
            [parameter appendString:@"&"];
        }
        
        return [parameter substringToIndex:(parameter.length - 1)];
    }
    
    [parameter appendString:key.dv_encodeForUrl];
    [parameter appendString:@"="];
    
    NSString *parameterValueStr = @"";
    if ([value isKindOfClass:[NSString class]]) {
        parameterValueStr = value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        parameterValueStr = ((NSNumber *)value).stringValue;
    }
    
    [parameter appendString:[parameterValueStr dv_encodeForUrl]];
    
    return parameter;
}

- (NSString *)removeRegexPattern:(NSString *)pattern fromString:(NSString *)string {
    NSString *prepareString = [NSString stringWithFormat:@"%@", string];
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    prepareString = [regex stringByReplacingMatchesInString:prepareString
                                                    options:0
                                                      range:NSMakeRange(0, [prepareString length])
                                               withTemplate:@""];
    prepareString = [prepareString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return prepareString;
}

@end
