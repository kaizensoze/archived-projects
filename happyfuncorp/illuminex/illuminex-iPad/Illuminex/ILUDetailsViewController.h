//
//  ILUDetailsViewController.h
//  illuminex
//
//  Created by Joe Gallo on 10/26/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILUItem.h"

@interface ILUDetailsViewController : UIViewController <
    UITableViewDataSource,
    UITableViewDelegate,
    UIWebViewDelegate
>

@property (strong, nonatomic) ILUItem *item;

@end
