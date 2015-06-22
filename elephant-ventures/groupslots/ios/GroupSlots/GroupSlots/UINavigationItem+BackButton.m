//
//  UINavigationItem+BackButton.m
//  GroupSlots
//
//  Created by Joe Gallo on 9/12/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import "UINavigationItem+BackButton.h"

@implementation UINavigationItem (BackButton)

- (UIBarButtonItem *)backBarButtonItem {
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:nil action:nil];
    return backButton;
}

@end
