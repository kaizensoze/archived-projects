//
//  BFKIntro3ViewController.m
//  Mosaic
//
//  Created by Joe Gallo on 2/1/15.
//  Copyright (c) 2015 Baron Fig. All rights reserved.
//

#import "BFKIntro2ViewController.h"
#import "BFKAppDelegate.h"

@interface BFKIntro2ViewController ()

@end

@implementation BFKIntro2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)next:(id)sender {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mosaic" bundle:nil];
    appDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"Intro3"];
}

- (IBAction)prev:(id)sender {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mosaic" bundle:nil];
    appDelegate.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"Intro1"];
}

@end
