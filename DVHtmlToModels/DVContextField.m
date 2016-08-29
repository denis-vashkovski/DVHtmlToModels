//
//  DVContextField.m
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "DVContextField.h"

@implementation DVContextField

#define NAME_KEY @"name"
#define RESULT_KEY @"result"
- (instancetype)initWithData:(NSDictionary *)data {
    if (!data || (data.count <= 0)) {
        return nil;
    }
    if (self = [super init]) {
        _name = data[NAME_KEY];
        
        id resultsData = data[RESULT_KEY];
        if (resultsData && [resultsData isKindOfClass:[NSArray class]]) {
            NSMutableArray<DVContextResult *> *array = [NSMutableArray array];
            
            for (NSDictionary *resultData in resultsData) {
                DVContextResult *result = [[DVContextResult alloc] initWithData:resultData];
                
                if (result) {
                    [array addObject:result];
                }
            }
            
            _result = (array.count > 0) ? [NSArray arrayWithArray:array] : nil;
        }
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"name: %@\nresults: %@",
            _name,
            _result];
}

@end
