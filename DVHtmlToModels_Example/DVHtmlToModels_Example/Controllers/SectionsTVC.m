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
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) NSArray<SectionObject *> *sections;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@end

@implementation SectionsTVC

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.color = [UIColor grayColor];
        _activityIndicatorView.hidesWhenStopped = YES;
        _activityIndicatorView.center = self.tableView.center;
        
        self.tableView.backgroundView = _activityIndicatorView;
    }
    return _activityIndicatorView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.activityIndicatorView startAnimating];
    
    DVHtmlToModels *htmlToModels = [DVHtmlToModels htmlToModelsWithContextByName:@"context_example"];
    [htmlToModels loadDataWithReplacingURLParameters:nil
                                  queryURLParameters:nil
                                              asJSON:NO
                                   completionHandler:
     ^(NSDictionary *data, NSData *htmlData) {

        if (data) {
            self.sections = data[NSStringFromClass([SectionObject class])];
            [self.tableView reloadData];
        }

        [self.activityIndicatorView stopAnimating];
    }];
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
