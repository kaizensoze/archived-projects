//
//  BFKIntro1ViewController.m
//  Mosaic
//
//  Created by Joe Gallo on 2/1/15.
//  Copyright (c) 2015 Baron Fig. All rights reserved.
//

#import "BFKIntroViewController.h"
#import "BFKAppDelegate.h"

@interface BFKIntroViewController ()

@end

@implementation BFKIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)advance:(id)sender {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mosaic" bundle:nil];
    appDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"Intro1"];
}

@end
