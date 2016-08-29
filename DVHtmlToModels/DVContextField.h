//
//  DVContextField.h
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DVContextResult.h"

@interface DVContextField : NSObject
- (instancetype)initWithData:(NSDictionary *)data;

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSArray<DVContextResult *> *result;
@end
