//
//  HBSTApprovedViewController.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/17/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTLoadingViewController.h"

@interface HBSTLoadingViewController ()
    @property (weak, nonatomic) IBOutlet UIImageView *activityImageView;
@end

@implementation HBSTLoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [HBSTUtil colorFromHex:@"64964b"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self spin];
}

- (void)spin {
    [HBSTUtil rotateLayerInfinite:self.activityImageView.layer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
