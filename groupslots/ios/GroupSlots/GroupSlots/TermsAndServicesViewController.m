//
//  TermsAndServicesViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/16/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "TermsAndServicesViewController.h"

@interface TermsAndServicesViewController ()

@end

@implementation TermsAndServicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [appDelegate useMainNav:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
