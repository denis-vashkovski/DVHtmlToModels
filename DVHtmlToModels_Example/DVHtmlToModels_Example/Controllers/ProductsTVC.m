//
//  ProductsTVC.m
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 30/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "ProductsTVC.h"

#import "ProductObject.h"

@interface ProductsTVC ()

@end

@implementation ProductsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 160.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Product Cell ID" forIndexPath:indexPath];
    
    ProductObject *product = self.products[indexPath.row];
    [cell.textLabel setText:[NSString stringWithFormat:@"%ld\n%@\n%@\n%@\n%@\n%d\n%d\n%@",
                             product.uniqueId,
                             product.title,
                             product.photoUrl,
                             product.author,
                             product.createdAt,
                             product.price.discount,
                             product.price.price,
                             product.price.currency]];
    
    return cell;
}

@end
