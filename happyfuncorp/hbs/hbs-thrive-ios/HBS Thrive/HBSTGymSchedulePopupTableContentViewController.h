//
//  HBSTGymSchedulePopupContentViewController.h
//  HBS Thrive
//
//  Created by Joe Gallo on 8/14/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBSTGymSchedule.h"

@interface HBSTGymSchedulePopupTableContentViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) HBSTGymSchedule *gymSchedule;

@end
