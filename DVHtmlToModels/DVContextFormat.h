//
//  DVContextFormat.h
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DVContextCondition.h"

typedef enum {
    DVContextFormatTypeDefault,
    DVContextFormatTypeDate,
    DVContextFormatTypeReplace,
    DVContextFormatTypeEncoding
} DVContextFormatType;

@interface DVContextFormat : NSObject
- (instancetype)initWithData:(NSDictionary *)data;

@property (nonatomic, assign, readonly) DVContextFormatType type;
@property (nonatomic, strong, readonly) NSArray<DVContextCondition *> *conditions;
@property (nonatomic, strong, readonly) NSString *regex;
@property (nonatomic, strong, readonly) NSString *format;
@end
