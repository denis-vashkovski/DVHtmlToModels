//
//  SectionsTVC.m
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 30/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "SectionsTVC.h"

#import "DVHtmlToModels.h"
#import "SectionObject.h"

#import "ProductsTVC.h"

@interface SectionsTVC ()
@property(nonatomic, strong) NSArray<SectionObject *> *sections;
@property(nonatomic, strong) NSIndexPath *selectedIndexPath;
@end

@implementation SectionsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DVHtmlToModels *htmlToModels = [DVHtmlToModels htmlToModelsWithContextByName:@"context_example"];
    NSDictionary *data = [htmlToModels loadData];
    if (data) {
        self.sections = data[NSStringFromClass([SectionObject class])];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Title Cell ID" forIndexPath:indexPath];
    
    SectionObject *sectionObject = self.sections[indexPath.row];
    
    [cell.textLabel setText:sectionObject.title];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%ld", sectionObject.products.count]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedIndexPath = indexPath;
    
    [self performSegueWithIdentifier:@"Product Segue ID" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *vc = segue.destinationViewController;
    if (!vc) return;
    
    if ([vc isKindOfClass:[ProductsTVC class]]) {
        [((ProductsTVC *)vc) setProducts:self.sections[self.selectedIndexPath.row].products];
    }
}

@end
