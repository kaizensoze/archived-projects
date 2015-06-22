//
//  ConferenceDetailViewController.h
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/1/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "NoteViewDelegate.h"

@class Conference;

@interface ConferenceDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, NoteViewDelegate>

@property (strong, nonatomic) Conference *conference;

@end
