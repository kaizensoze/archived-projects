//
//  HowManyHelpViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/14/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "HowManyHelpViewController.h"

@interface HowManyHelpViewController ()

@end

@implementation HowManyHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer:tapGR];
}

- (IBAction)tap:(id)sender {
    [self.view removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
