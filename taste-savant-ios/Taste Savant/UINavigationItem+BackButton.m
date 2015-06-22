//
//  UINavigationItem+BackButton.m
//  Taste Savant
//
//  Created by Joe Gallo on 9/4/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "UINavigationItem+BackButton.h"

@implementation UINavigationItem (BackButton)

- (UIBarButtonItem *)backBarButtonItem {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:nil action:nil];
    return backButton;
}

@end
