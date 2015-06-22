//
//  GroupInviteViewController.h
//  GroupSlots
//
//  Created by Joe Gallo on 6/13/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface GroupInviteViewController : UIViewController <SocketIODelegate, UITextFieldDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@end
