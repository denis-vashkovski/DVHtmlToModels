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
#import <TFHpple.h>
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
@end

#pragma mark -
#pragma mark NSObject+DVHtmlToModels_Private
@interface NSObject(DVHtmlToModels_Private)
@end
@implementation NSObject(DVHtmlToModels_Private)
- (NSString *)dv_getTypeAttributePropertyByName:(NSString *)propertyName {
    if (propertyName && (propertyName.length > 0)) {
        objc_property_t propTitle = class_getProperty([self class], [propertyName UTF8String]);
        
        if (propTitle) {
            const char *type = property_getAttributes(propTitle);
            NSString *typeString = [NSString stringWithUTF8String:type];
            NSArray *attributes = [typeString componentsSeparatedByString:@","];
            
            return [attributes objectAtIndex:0];
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
        unsigned int count;
        objc_property_t *props = class_copyPropertyList([self class], &count);
        for (int i = 0; i < count; i++) {
            if (strcmp(propertyName.UTF8String, property_getName(props[i])) == 0) {
                free(props);
                return YES;
            }
        }
        free(props);
    }
    
    return NO;
}

- (void)dv_setValue:(id)value forPropertyName:(NSString *)propertyName {
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

#define URL_KEY @"url"
#define DATA_KEY @"data"
- (instancetype)initWithContextByName:(NSString *)contextName {
    if ((self = [super init]) && valid(contextName)) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:contextName ofType:@"plist"];
        
        if (valid(filePath)) {
            NSDictionary *context = [NSDictionary dictionaryWithContentsOfFile:filePath];
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
    }
    return self;
}

- (NSDictionary *)loadDataWithUrlParameters:(NSArray<NSString *> *)parameters {
    if (!valid(_url)) return nil;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self preparedUrlWithParams:parameters]]];
    TFHpple *htmlParser = [TFHpple hppleWithHTMLData:htmlData];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    if (!htmlParser) return nil;
    
    NSMutableDictionary<NSString *, NSArray *> *preparedData = [NSMutableDictionary new];
    for (DVContextObject *object in _objects) {
        NSArray *dataArray = [self prepareContextObject:object parser:htmlParser];
        
        if (valid(dataArray)) {
            [preparedData setObject:dataArray forKey:object.className];
        }
    }
    
    return preparedData.count > 0 ? [NSDictionary dictionaryWithDictionary:preparedData] : nil;
}

- (NSDictionary *)loadData {
    return [self loadDataWithUrlParameters:nil];
}

- (NSArray *)prepareContextObject:(DVContextObject *)object parser:(id)parser {
    NSArray<TFHppleElement *> *elements = valid(object.xPathRoot) ? [parser searchWithXPathQuery:object.xPathRoot] : nil;
    if (!valid(elements)) return nil;
    
    NSMutableArray *dataArray = [NSMutableArray new];
    for (TFHppleElement *element in elements) {
        id modelObject = [objc_getClass(object.className.UTF8String) new];
        
        for (DVContextField *field in object.fields) {
            for (DVContextResult *result in field.result) {
                if (result.object) {
                    id valueObjectArray = [self prepareContextObject:result.object parser:element];
                    if (valid(valueObjectArray)) {
                        if (![[modelObject dv_getTypeClassOfPropertyByName:field.name] isSubclassOfClass:[NSArray class]]) {
                            valueObjectArray = ((NSArray *)valueObjectArray).firstObject;
                        }
                        
                        [modelObject dv_setValue:valueObjectArray forPropertyName:field.name];
                        
                        break;
                    }
                } else {
                    TFHppleElement *resultElement = [element searchWithXPathQuery:result.xPath].firstObject;
                    
                    if (resultElement) {
                        NSString *resultValue = (valid(result.attribute)
                                                 ? [resultElement objectForKey:result.attribute]
                                                 : (result.isAllText
                                                    ? [self removeRegexPattern:@"(<[^>]+>|\n|  +)" fromString:resultElement.raw]
                                                    : resultElement.text));
                        
                        if (resultValue) {
                            if (valid(result.regex)) {
                                resultValue = [self prepareRegexPattern:result.regex forString:resultValue];
                            }
                            
                            if (valid(resultValue)) {
                                for (DVContextFormat *format in result.formats) {
                                    BOOL executeFormat = YES;
                                    for (DVContextCondition *condition in format.conditions) {
                                        NSString *prepareString = [self prepareRegexPattern:condition.regex forString:resultValue];
                                        
                                        if (!valid(prepareString) && !condition.negative) {
                                            executeFormat = NO;
                                            break;
                                        }
                                    }
                                    
                                    if (executeFormat) {
                                        switch (format.type) {
                                            case DVContextFormatTypeDate:{
                                                if ([[modelObject dv_getTypeClassOfPropertyByName:field.name] isSubclassOfClass:[NSDate class]]) {
                                                    NSDateFormatter *df = [NSDateFormatter new];
                                                    [df setDateFormat:format.format];
                                                    
                                                    [modelObject dv_setValue:[df dateFromString:resultValue] forPropertyName:field.name];
                                                    resultValue = nil;
                                                }
                                                break;
                                            }
                                            default:{
                                                resultValue = [NSString stringWithFormat:format.format, resultValue];
                                                break;
                                            }
                                        }
                                    }
                                    
                                    if (!resultValue) break;
                                }
                                
                                if (valid(resultValue)) {
                                    if (valid(result.value)) {
                                        resultValue = result.value;
                                    }
                                    [modelObject dv_setValue:resultValue forPropertyName:field.name];
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
        
        [dataArray addObject:modelObject];
    }
    
    return (dataArray.count > 0) ? [NSArray arrayWithArray:dataArray] : nil;
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
               : NO));
}

- (NSString *)preparedUrlWithParams:(NSArray<NSString *> *)parameters {
    NSString *preparedUrl = [NSString stringWithFormat:@"%@", _url];
    
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
