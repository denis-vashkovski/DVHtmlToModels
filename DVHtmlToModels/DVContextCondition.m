//
//  DVContextCondition.m
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "DVContextCondition.h"

@implementation DVContextCondition

#define REGEX_KEY @"regex"
#define NEGATIVE_KEY @"negative"
- (instancetype)initWithData:(NSDictionary *)data {
    if (!data || (data.count <= 0)) {
        return nil;
    }
    if (self = [super init]) {
        _regex = data[REGEX_KEY];
        _negative = [data[NEGATIVE_KEY] boolValue];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"regex: %@\nnegative: %@",
            _regex,
            (_negative ? @"true" : @"false")];
}

@end
