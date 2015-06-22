//
//  HBSTPollPopupContentViewController.h
//  HBS Thrive
//
//  Created by Joe Gallo on 9/4/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBSTPollPopupContentViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSDictionary *pollJSON;

@end
