//
//  DVContextFormat.m
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "DVContextFormat.h"

static NSString * const DVContextFormatTypeKey = @"type";
static NSString * const DVContextFormatConditionsKey = @"conditions";
static NSString * const DVContextFormatRegexKey = @"regex";
static NSString * const DVContextFormatFormatKey = @"format";

@implementation DVContextFormat

- (DVContextFormatType)typeByString:(NSString *)typeStr {
    if ([typeStr isEqualToString:@"date"]) {
        return DVContextFormatTypeDate;
    } else if ([typeStr isEqualToString:@"replace"]) {
        return DVContextFormatTypeReplace;
    } else if ([typeStr isEqualToString:@"encoding"]) {
        return DVContextFormatTypeEncoding;
    } else if ([typeStr isEqualToString:@"number"]) {
        return DVContextFormatTypeNumber;
    } else {
        return DVContextFormatTypeDefault;
    }
}

- (instancetype)initWithData:(NSDictionary *)data {
    if ((self = [super init]) && data.count) {
        _type = [self typeByString:data[DVContextFormatTypeKey]];
        
        id conditionsData = data[DVContextFormatConditionsKey];
        if (conditionsData && [conditionsData isKindOfClass:[NSArray class]]) {
            NSMutableArray<DVContextCondition *> *array = [NSMutableArray array];
            
            for (NSDictionary *conditionData in conditionsData) {
                DVContextCondition *condition = [[DVContextCondition alloc] initWithData:conditionData];
                
                if (condition) {
                    [array addObject:condition];
                }
            }
            
            _conditions = (array.count > 0) ? array.copy : nil;
        }
        
        _regex = data[DVContextFormatRegexKey];
        _format = data[DVContextFormatFormatKey];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"conditions: %@\nformat: %@",
            self.conditions,
            self.format];
}

@end
