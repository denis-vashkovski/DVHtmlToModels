//
//  DVContextCondition.m
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "DVContextCondition.h"

static NSString * const DVContextConditionRegexKey = @"regex";
static NSString * const DVContextConditionNegativeKey = @"negative";

@implementation DVContextCondition

- (instancetype)initWithData:(NSDictionary *)data {
    if ((self = [super init]) && data.count) {
        _regex = data[DVContextConditionRegexKey];
        _negative = [data[DVContextConditionNegativeKey] boolValue];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"regex: %@\nnegative: %@",
            self.regex,
            (self.negative ? @"true" : @"false")];
}

@end
