//
//  MainTabBarController.m
//  Taste Savant
//
//  Created by Joe Gallo on 11/12/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "MainTabBarController.h"
#import "SearchViewController.h"

@interface MainTabBarController ()
    @property (strong, nonatomic) NSArray *tabLabels;
    @property (nonatomic) BOOL initialLoad;
    @property (strong, nonatomic) NSString *currentTabLabel;
    @property (nonatomic) BOOL resetSearch;
@end

@implementation MainTabBarController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.initialLoad = YES;
        self.currentTabLabel = nil;
        self.resetSearch = NO;
        
        NSMutableArray *tempLabels = [[NSMutableArray alloc] init];
        for (UIViewController *vc in self.viewControllers) {
            [tempLabels addObject:vc.tabBarItem.title];
        }
        self.tabLabels = [tempLabels copy];
        
        self.requestedTabLabel = nil;
        
        self.tabBar.tintColor = [Util colorFromHex:@"f57a3d"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar.translucent = NO;
    
    if (self.requestedTabLabel == nil) {
        [self goToTab:@"Search"];
        self.currentTabLabel = @"Search";
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.initialLoad) {
        [appDelegate setRootViewController:self];
        self.delegate = self;
        self.initialLoad = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.requestedTabLabel != nil) {
        [self goToTab:self.requestedTabLabel];
    } else {
        [self forceRefresh:self.selectedIndex];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIViewController *)getViewControllerAtTab:(NSString *)tabLabel {
    NSUInteger viewControllerAtTabIndex = [self.tabLabels indexOfObject:tabLabel];
    UIViewController *viewController = self.viewControllers[viewControllerAtTabIndex];
    return viewController;
}

- (void)goToTab:(NSString *)tabLabel {
    // save current tabIndex
    NSUInteger oldSelectedIndex = self.selectedIndex;
    
    // change to desired tab
    if (tabLabel != nil) {  // if nil, stay on current tab
        NSUInteger tabIndex = [self.tabLabels indexOfObject:tabLabel];
        [self setSelectedIndex:tabIndex];
        self.requestedTabLabel = nil;
    }
    
    // force refresh
    [self forceRefresh:oldSelectedIndex];
}

- (void)forceRefresh:(NSUInteger)oldSelectedIndex {
    NSUInteger newSelectedIndex = self.selectedIndex;
    if (newSelectedIndex == oldSelectedIndex) {
        // Hack.
        [self.selectedViewController viewWillDisappear:NO];
        [self.selectedViewController viewWillAppear:NO];
        [self.selectedViewController viewDidAppear:NO];
    }
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    UINavigationController *nc = (UINavigationController *)viewController;
    if (nc.viewControllers.count == 1
        && [nc.viewControllers[0] isKindOfClass:[SearchViewController class]]
        && [self.currentTabLabel isEqualToString:@"Search"]) {
        self.resetSearch = YES;
    } else {
        self.resetSearch = NO;
    }
    
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    // if already at search results and user taps search tab, clear search results
    if (self.resetSearch) {
        SearchViewController *vc = (SearchViewController *)((UINavigationController *)viewController).viewControllers[0];
        [vc clearSearch];
        self.resetSearch = NO;
    }
    self.currentTabLabel = self.tabLabels[self.selectedIndex];
}

@end
