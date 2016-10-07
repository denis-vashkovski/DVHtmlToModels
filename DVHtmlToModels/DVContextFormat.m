//
//  DVContextFormat.m
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "DVContextFormat.h"

@implementation DVContextFormat

- (DVContextFormatType)typeByString:(NSString *)typeStr {
    if ([typeStr isEqualToString:@"date"]) {
        return DVContextFormatTypeDate;
    } else if ([typeStr isEqualToString:@"replace"]) {
        return DVContextFormatTypeReplace;
    } else {
        return DVContextFormatTypeDefault;
    }
}

#define TYPE_KEY @"type"
#define CONDITIONS_KEY @"conditions"
#define REGEX_KEY @"regex"
#define FORMAT_KEY @"format"
- (instancetype)initWithData:(NSDictionary *)data {
    if (!data || (data.count <= 0)) {
        return nil;
    }
    if (self = [super init]) {
        _type = [self typeByString:data[TYPE_KEY]];
        
        id conditionsData = data[CONDITIONS_KEY];
        if (conditionsData && [conditionsData isKindOfClass:[NSArray class]]) {
            NSMutableArray<DVContextCondition *> *array = [NSMutableArray array];
            
            for (NSDictionary *conditionData in conditionsData) {
                DVContextCondition *condition = [[DVContextCondition alloc] initWithData:conditionData];
                
                if (condition) {
                    [array addObject:condition];
                }
            }
            
            _conditions = (array.count > 0) ? [NSArray arrayWithArray:array] : nil;
        }
        
        _regex = data[REGEX_KEY];
        _format = data[FORMAT_KEY];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"conditions: %@\nformat: %@",
            _conditions,
            _format];
}

@end
