//
//  DVContextObject.m
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "DVContextObject.h"

static NSString * const DVContextObjectXPathRootKey = @"xPathRoot";
static NSString * const DVContextObjectClassNameKey = @"className";
static NSString * const DVContextObjectFieldsKey = @"fields";

@implementation DVContextObject

- (instancetype)initWithContext:(NSDictionary *)context {
    if ((self = [super init]) && context.count) {
        _xPathRoot = context[DVContextObjectXPathRootKey];
        _className = context[DVContextObjectClassNameKey];
        
        NSAssert((_className && (_className.length > 0)), @"ClassName can't be blank");
        
        id fieldsData = context[DVContextObjectFieldsKey];
        if (fieldsData && [fieldsData isKindOfClass:[NSArray class]]) {
            NSMutableArray<DVContextField *> *array = [NSMutableArray array];
            
            for (NSDictionary *fieldData in fieldsData) {
                DVContextField *field = [[DVContextField alloc] initWithData:fieldData];
                
                if (field) {
                    [array addObject:field];
                }
            }
            
            _fields = (array.count > 0) ? array.copy : nil;
        }
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"xPathRoot: %@ \n className: %@ \n fields: %@",
            self.xPathRoot,
            self.className,
            self.fields];
}

@end
