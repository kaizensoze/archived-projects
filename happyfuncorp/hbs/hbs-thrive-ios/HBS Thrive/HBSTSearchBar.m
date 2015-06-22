//
//  HBSTSearchBar.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/29/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTSearchBar.h"

@implementation HBSTSearchBar

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        // ORDER MATTERS!
        //   initWithCoder: setImage, barTintColor
        //   layoutSubviews: backgroundImage, backgroundColor
        
        // search icon
        [self setImage:[UIImage imageNamed:@"search.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        
        // bar tint color
        self.barTintColor = [HBSTUtil colorFromHex:@"f5f5f5"];
        
        // clear icon
        [self setImage:[UIImage imageNamed:@"clear.png"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // background
    self.backgroundImage = [UIImage new];
    self.backgroundColor = [HBSTUtil colorFromHex:@"f5f5f5"];
    
    for (UIView *subview in self.subviews) {
        for (UIView *subsubview in subview.subviews) {
            if ([subsubview isKindOfClass:[UITextField class]]) {
                UITextField *textField = (UITextField *)subsubview;
                textField.backgroundColor = [UIColor clearColor];
            }
            
//            if ([subsubview isKindOfClass:[UIButton class]]) {
//                for (UIView *blah in subsubview.subviews) {
//                    DDLogInfo(@"%@", blah);
//                }
//            }
        }
    }
    
    // cancel button
    [self setShowsCancelButton:NO animated:NO];
}

//- (BOOL)textFieldShouldClear:(UITextField *)textField {
//    [self.delegate searchBarCancelButtonClicked:self];
//    return YES;
//}

@end
