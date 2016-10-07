//
//  DVContextResult.m
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "DVContextResult.h"

#import "DVContextObject.h"

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

#define SEPARATOR_DEFAULT @""

#define XPATH_KEY @"xPath"
#define ATTRIBUTE_KEY @"attribute"
#define REGEX_KEY @"regex"
#define FORMATS_KEY @"formats"
#define DATA_KEY @"data"
#define VALUE_KEY @"value"
#define TEXT_TYPE_KEY @"textType"
#define RESULTS_KEY @"results"
#define SEPARATOR_KEY @"separator"
- (instancetype)initWithData:(NSDictionary *)data {
    if (!data || (data.count <= 0)) {
        return nil;
    }
    if (self = [super init]) {
        _xPath = data[XPATH_KEY];
        _attribute = data[ATTRIBUTE_KEY];
        _regex = data[REGEX_KEY];
        
        id formatsData = data[FORMATS_KEY];
        if (formatsData && [formatsData isKindOfClass:[NSArray class]]) {
            NSMutableArray<DVContextFormat *> *array = [NSMutableArray array];
            
            for (NSDictionary *formatData in formatsData) {
                DVContextFormat *format = [[DVContextFormat alloc] initWithData:formatData];
                
                if (format) {
                    [array addObject:format];
                }
            }
            
            _formats = (array.count > 0) ? [NSArray arrayWithArray:array] : nil;
        }
        
        _object = [[DVContextObject alloc] initWithContext:data[DATA_KEY]];
        _value = data[VALUE_KEY];
        _textType = [self textTypeByString:data[TEXT_TYPE_KEY]];
        
        id resultsData = data[RESULTS_KEY];
        if (resultsData && [resultsData isKindOfClass:[NSArray class]]) {
            NSMutableArray<DVContextResult *> *array = [NSMutableArray array];
            
            for (NSDictionary *resultData in resultsData) {
                DVContextResult *result = [[DVContextResult alloc] initWithData:resultData];
                
                if (result) {
                    [array addObject:result];
                }
            }
            
            _results = (array.count > 0) ? [NSArray arrayWithArray:array] : nil;
        }
        
        _separator = data[SEPARATOR_KEY];
        if (!_separator) _separator = SEPARATOR_DEFAULT;
    }
    return self;
}

- (BOOL)isObject {
    return _object;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"xPath: %@\nattribute: %@\nregex: %@\nformats: %@\nobject: %@",
            _xPath,
            _attribute,
            _regex,
            _formats,
            _object];
}

@end
