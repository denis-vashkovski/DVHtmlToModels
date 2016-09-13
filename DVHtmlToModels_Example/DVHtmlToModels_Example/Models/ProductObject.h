//
//  ProductObject.h
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UniqueObject.h"
#import "PriceObject.h"

@interface ProductObject : UniqueObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *photoUrl;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) PriceObject *price;

@property (nonatomic) BOOL isNew;
@end
