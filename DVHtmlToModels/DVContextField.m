//
//  DVContextField.m
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "DVContextField.h"

static NSString * const DVContextFieldNameKey = @"name";
static NSString * const DVContextFieldResultKey = @"result";

@implementation DVContextField

- (instancetype)initWithData:(NSDictionary *)data {
    if ((self = [super init]) && data.count) {
        _name = data[DVContextFieldNameKey];
        
        id resultsData = data[DVContextFieldResultKey];
        if (resultsData && [resultsData isKindOfClass:[NSArray class]]) {
            NSMutableArray<DVContextResult *> *array = [NSMutableArray array];
            
            for (NSDictionary *resultData in resultsData) {
                DVContextResult *result = [[DVContextResult alloc] initWithData:resultData];
                
                if (result) {
                    [array addObject:result];
                }
            }
            
            _result = (array.count > 0) ? array.copy : nil;
        }
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"name: %@\nresults: %@",
            self.name,
            self.result];
}

@end
