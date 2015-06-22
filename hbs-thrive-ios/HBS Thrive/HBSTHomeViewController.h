//
//  HBSTHomeViewController.h
//  HBS Thrive
//
//  Created by Joe Gallo on 8/4/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBSTPopupViewController.h"

@interface HBSTHomeViewController : UIViewController <HBSTPopupDelegate, UIAlertViewDelegate>

- (IBAction)showPopup:(id)sender;

@end
