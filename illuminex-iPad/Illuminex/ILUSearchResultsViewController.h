//
//  ILUSearchResultsViewController.h
//  Illuminex
//
//  Created by Joe Gallo on 10/15/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILUSearchParams.h"

@interface ILUSearchResultsViewController : UIViewController <
    UIGestureRecognizerDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
>

@property (strong, nonatomic) ILUSearchParams *searchParams;

@end
