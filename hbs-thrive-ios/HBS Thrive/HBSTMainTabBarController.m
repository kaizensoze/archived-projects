//
//  HBSTMainTabBarController.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/11/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTMainTabBarController.h"

@interface HBSTMainTabBarController ()

@end

@implementation HBSTMainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // bar color
    self.tabBar.barTintColor = [HBSTUtil colorFromHex:@"64964b"];
    
    // selected
    self.tabBar.tintColor = [UIColor whiteColor];
    [UITabBarItem.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}
                                             forState:UIControlStateSelected];
    [UITabBar.appearance setSelectedImageTintColor:[UIColor whiteColor]];
    
    // unselected
    UIColor *unselectedColor = [HBSTUtil colorFromHex:@"b2cba5"];
    [UITabBarItem.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName : unselectedColor}
                                           forState:UIControlStateNormal];
    for (UITabBarItem *item in self.tabBar.items) {
        UIImage *selectedImage = item.selectedImage;
        UIImage *coloredSelectedImage = [selectedImage imageWithColor:unselectedColor];
        item.image = [coloredSelectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    self.tabBar.translucent = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
