//
//  SectionObject.h
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ProductObject.h"

@interface SectionObject : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray<ProductObject *> *products;
@end
