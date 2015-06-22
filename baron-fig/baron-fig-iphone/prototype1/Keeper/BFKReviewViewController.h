//
//  BFKReviewViewController.h
//  Keeper
//
//  Created by Joe Gallo on 11/6/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BFKReviewViewController : UIViewController <
    UITextViewDelegate,
    UITextFieldDelegate,
    UIScrollViewDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UIDocumentInteractionControllerDelegate
>

@property (strong, nonatomic) NSArray *capturedItems;

@end
