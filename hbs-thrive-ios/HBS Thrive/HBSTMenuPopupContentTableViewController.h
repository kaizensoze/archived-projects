//
//  HBSTMenuPopupContentViewController.h
//  HBS Thrive
//
//  Created by Joe Gallo on 8/14/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBSTMenu.h"

@interface HBSTMenuPopupContentTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) HBSTMenu *menu;

@end
