//
//  DVContextCondition.h
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVContextCondition : NSObject
- (instancetype)initWithData:(NSDictionary *)data;

@property (nonatomic, strong, readonly) NSString *regex;
@property (nonatomic, readonly) BOOL negative;
@end
