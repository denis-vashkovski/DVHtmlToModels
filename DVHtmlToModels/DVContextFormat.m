//
//  DVContextFormat.m
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "DVContextFormat.h"

@implementation DVContextFormat

#define CONDITIONS_KEY @"conditions"
#define FORMAT_KEY @"format"
- (instancetype)initWithData:(NSDictionary *)data {
    if (!data || (data.count <= 0)) {
        return nil;
    }
    if (self = [super init]) {
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
