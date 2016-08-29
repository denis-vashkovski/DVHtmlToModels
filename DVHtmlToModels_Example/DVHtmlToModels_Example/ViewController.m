//
//  ViewController.m
//  DVHtmlToModels_Example
//
//  Created by Denis Vashkovski on 29/08/16.
//  Copyright © 2016 Denis Vashkovski. All rights reserved.
//

#import "ViewController.h"

#import "DVHtmlToModels.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DVHtmlToModels *htmlToModels = [DVHtmlToModels new];
    [htmlToModels prepareContextByName:@"context_example"];
    
    NSDictionary *data = [htmlToModels loadData];
    if (data) {
        
    }
}

@end
