//
//  DVContextObject.m
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "DVContextObject.h"

@implementation DVContextObject

#define XPATH_ROOT_KEY @"xPathRoot"
#define CLASS_NAME_KEY @"className"
#define FIELDS_KEY @"fields"
- (instancetype)initWithContext:(NSDictionary *)context {
    if (!context || (context.count <= 0)) {
        return nil;
    }
    if (self = [super init]) {
        _xPathRoot = context[XPATH_ROOT_KEY];
        _className = context[CLASS_NAME_KEY];
        NSAssert((_className && (_className.length > 0)), @"ClassName can't be blank");
        
        id fieldsData = context[FIELDS_KEY];
        if (fieldsData && [fieldsData isKindOfClass:[NSArray class]]) {
            NSMutableArray<DVContextField *> *array = [NSMutableArray array];
            
            for (NSDictionary *fieldData in fieldsData) {
                DVContextField *field = [[DVContextField alloc] initWithData:fieldData];
                
                if (field) {
                    [array addObject:field];
                }
            }
            
            _fields = (array.count > 0) ? [NSArray arrayWithArray:array] : nil;
        }
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"xPathRoot: %@ \n className: %@ \n fields: %@",
            _xPathRoot,
            _className,
            _fields];
}

@end
