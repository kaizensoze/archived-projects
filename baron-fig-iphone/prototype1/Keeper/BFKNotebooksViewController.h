//
//  BFKNotebooksViewController.h
//  Keeper
//
//  Created by Joe Gallo on 10/22/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICollectionView+Draggable.h"

@interface BFKNotebooksViewController : UIViewController <
    UICollectionViewDataSource_Draggable,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UIAlertViewDelegate,
    UITextFieldDelegate
>

@end

