//
//  LoadingViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 11/28/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "LoadingViewController.h"

@interface LoadingViewController ()
    @property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation LoadingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.spinner.color = [Util colorFromHex:@"362f2d"];
    [self.spinner startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
