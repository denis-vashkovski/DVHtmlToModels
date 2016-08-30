//
//  ProductsTVC.h
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 30/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProductObject;

@interface ProductsTVC : UITableViewController
@property (nonatomic, strong) NSArray<ProductObject *> *products;
@end
