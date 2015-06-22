//
//  ILUCollectionsViewController.h
//  illuminex
//
//  Created by Joe Gallo on 11/11/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "I3DragBetweenHelper.h"

@interface ILUCollectionsViewController : UIViewController <
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    UITableViewDataSource,
    UITableViewDelegate,
    I3DragBetweenDelegate
>

@end
