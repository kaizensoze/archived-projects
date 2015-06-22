//
//  MainTabBarController.h
//  Taste Savant
//
//  Created by Joe Gallo on 11/12/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTabBarController : UITabBarController <UITabBarControllerDelegate, UITabBarDelegate>

@property (strong, nonatomic) NSString *requestedTabLabel;

- (void)goToTab:(NSString *)tabLabel;
- (UIViewController *)getViewControllerAtTab:(NSString *)tabLabel;

@end
