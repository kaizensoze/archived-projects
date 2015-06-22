//
//  BFKSectionsViewController.h
//  Keeper
//
//  Created by Joe Gallo on 11/20/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BFKNotebook.h"
#import "UICollectionView+Draggable.h"

@interface BFKSectionsViewController : UIViewController <
    UICollectionViewDataSource_Draggable,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UIAlertViewDelegate,
    UITextFieldDelegate
>

@property (strong, nonatomic) BFKNotebook *notebook;

@end
