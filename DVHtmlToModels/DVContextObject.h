//
//  DVContextObject.h
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DVContextField.h"

@interface DVContextObject : NSObject
- (instancetype)initWithContext:(NSDictionary *)context;

@property (nonatomic, strong, readonly) NSString *xPathRoot;
@property (nonatomic, strong, readonly) NSString *className;
@property (nonatomic, strong, readonly) NSArray<DVContextField *> *fields;
@end
