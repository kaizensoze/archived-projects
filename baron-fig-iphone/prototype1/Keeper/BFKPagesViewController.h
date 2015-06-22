//
//  BFKPagesViewController.h
//  Keeper
//
//  Created by Joe Gallo on 11/23/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BFKSection.h"
#import "UICollectionView+Draggable.h"

@interface BFKPagesViewController : UIViewController <
    UICollectionViewDataSource_Draggable,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UIAlertViewDelegate,
    UITextFieldDelegate,
    UITextViewDelegate,
    UIScrollViewDelegate,
    UITableViewDataSource,
    UITableViewDelegate
>

enum {
    BFKPagesGridMode = 1,
    BFKPagesSingleMode = 2,
};
typedef UInt32 BFKPagesMode;

@property (strong, nonatomic) BFKSection *section;

@property (strong, nonatomic) NSNumber *goToLastItem;

@end
