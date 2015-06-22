//
//  HBSTPopupViewController.h
//  HBS Thrive
//
//  Created by Joe Gallo on 8/14/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HBSTPopupDelegate
- (void)popupClosed;
@end

@interface HBSTPopupViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property id<HBSTPopupDelegate> delegate;
@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSArray *contentViewControllers;
@property (strong, nonatomic) NSString *emptyMessage;

- (IBAction)close:(id)sender;

@end
