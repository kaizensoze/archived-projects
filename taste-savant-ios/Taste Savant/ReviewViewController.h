//
//  ReviewViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 10/26/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ReviewViewController : UIViewController <
    UITableViewDelegate,
    UITableViewDataSource,
    UISearchBarDelegate,
    MFMailComposeViewControllerDelegate
>

@end
