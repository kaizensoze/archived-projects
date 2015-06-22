//
//  BFKNewNoteViewController.h
//  Keeper
//
//  Created by Joe Gallo on 11/17/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BFKCaptureViewController.h"

@interface BFKNewNoteViewController : UIViewController <
    UITextFieldDelegate,
    UITableViewDataSource,
    UITableViewDelegate
>

@property (strong, nonatomic) BFKCaptureViewController *delegate;

@end
