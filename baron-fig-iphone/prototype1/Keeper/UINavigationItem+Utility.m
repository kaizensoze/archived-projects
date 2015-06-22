//
//  UINavigationItem+Utility.m
//  Keeper
//
//  Created by Joe Gallo on 11/6/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "UINavigationItem+Utility.h"

@implementation UINavigationItem (Utility)

- (UIBarButtonItem *)backBarButtonItem {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                       style:UIBarButtonItemStylePlain
                                                      target:nil action:nil];
    
    return backButton;
}

@end