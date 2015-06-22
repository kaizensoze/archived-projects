//
//  HBSTConfirmationViewController.h
//  HBS Thrive
//
//  Created by Joe Gallo on 8/15/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageUI/MessageUI.h"

@interface HBSTConfirmationViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSString *email;

@end
