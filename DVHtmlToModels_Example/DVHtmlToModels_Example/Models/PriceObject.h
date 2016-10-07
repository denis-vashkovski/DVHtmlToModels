//
//  PriceObject.h
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PriceObject : NSObject
@property (nonatomic) int discount;
@property (nonatomic) double price;
@property (nonatomic, strong) NSString *currency;
@end
