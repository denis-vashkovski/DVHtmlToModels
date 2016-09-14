//
//  DVContextResult.h
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DVContextFormat.h"

@class DVContextObject;

typedef enum {
    DVTextTypeDefault,
    DVTextTypeAll,
    DVTextTypeRaw
} DVTextType;

@interface DVContextResult : NSObject
- (instancetype)initWithData:(NSDictionary *)data;

@property (nonatomic, strong, readonly) NSString *xPath;
@property (nonatomic, strong, readonly) NSString *attribute;
@property (nonatomic, strong, readonly) NSString *regex;
@property (nonatomic, strong, readonly) NSArray<DVContextFormat *> *formats;
@property (nonatomic, strong, readonly) DVContextObject *object;
@property (nonatomic, strong, readonly) NSString *value;
@property (nonatomic, assign, readonly) DVTextType textType;

- (BOOL)isObject;
@end
