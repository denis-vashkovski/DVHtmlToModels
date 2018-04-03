//
//  DVContextResult.m
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "DVContextResult.h"

#import "DVContextObject.h"

static NSString * const DVContextResultXPathKey = @"xPath";
static NSString * const DVContextResultAttributeKey = @"attribute";
static NSString * const DVContextResultRegexKey = @"regex";
static NSString * const DVContextResultFormatsKey = @"formats";
static NSString * const DVContextResultDataKey = @"data";
static NSString * const DVContextResultValueKey = @"value";
static NSString * const DVContextResultTextTypeKey = @"textType";
static NSString * const DVContextResultResultsKey = @"results";
static NSString * const DVContextResultSeparatorKey = @"separator";

static NSString * const DVContextResultSeparatorDefault = @"";

@implementation DVContextResult

- (DVTextType)textTypeByString:(NSString *)string {
    if ([string isEqualToString:@"all"]) {
        return DVTextTypeAll;
    } else if ([string isEqualToString:@"raw"]) {
        return DVTextTypeRaw;
    } else {
        return DVTextTypeDefault;
    }
}

- (instancetype)initWithData:(NSDictionary *)data {
    if ((self = [super init]) && data.count) {
        _xPath = data[DVContextResultXPathKey];
        _attribute = data[DVContextResultAttributeKey];
        _regex = data[DVContextResultRegexKey];
        
        id formatsData = data[DVContextResultFormatsKey];
        if (formatsData && [formatsData isKindOfClass:[NSArray class]]) {
            NSMutableArray<DVContextFormat *> *array = [NSMutableArray array];
            
            for (NSDictionary *formatData in formatsData) {
                DVContextFormat *format = [[DVContextFormat alloc] initWithData:formatData];
                
                if (format) {
                    [array addObject:format];
                }
            }
            
            _formats = (array.count > 0) ? array.copy : nil;
        }
        
        id contextResultData = data[DVContextResultDataKey];
        if (contextResultData) {
            _object = [[DVContextObject alloc] initWithContext:contextResultData];
        }
        
        _value = data[DVContextResultValueKey];
        _textType = [self textTypeByString:data[DVContextResultTextTypeKey]];
        
        id resultsData = data[DVContextResultResultsKey];
        if (resultsData && [resultsData isKindOfClass:[NSArray class]]) {
            NSMutableArray<DVContextResult *> *array = [NSMutableArray array];
            
            for (NSDictionary *resultData in resultsData) {
                DVContextResult *result = [[DVContextResult alloc] initWithData:resultData];
                
                if (result) {
                    [array addObject:result];
                }
            }
            
            _results = (array.count > 0) ? array.copy : nil;
        }
        
        _separator = data[DVContextResultSeparatorKey];
        if (!_separator) _separator = DVContextResultSeparatorDefault;
    }
    return self;
}

- (BOOL)isObject {
    return self.object != nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"xPath: %@\nattribute: %@\nregex: %@\nformats: %@\nobject: %@",
            self.xPath,
            self.attribute,
            self.regex,
            self.formats,
            self.object];
}

@end
