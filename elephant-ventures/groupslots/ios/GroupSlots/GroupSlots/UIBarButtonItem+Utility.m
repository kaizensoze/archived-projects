//
//  UIBarButtonItem+Utility.m
//  GroupSlots
//
//  Created by Joe Gallo on 9/11/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import "UIBarButtonItem+Utility.h"

@implementation UIBarButtonItem (Utility)

+ (UIBarButtonItem *)barItemWithImage:(UIImage*)image target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

@end
