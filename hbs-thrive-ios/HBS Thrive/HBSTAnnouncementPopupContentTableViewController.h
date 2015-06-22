//
//  HBSTAnnouncementPopupContentViewController.h
//  HBS Thrive
//
//  Created by Joe Gallo on 8/15/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBSTAnnouncement.h"

@interface HBSTAnnouncementPopupContentTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) HBSTAnnouncement *announcement;

@end
