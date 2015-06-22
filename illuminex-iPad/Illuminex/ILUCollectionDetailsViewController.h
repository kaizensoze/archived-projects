//
//  ILUCollectionDetailsViewController.h
//  illuminex
//
//  Created by Joe Gallo on 11/11/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILUCollection.h"

@interface ILUCollectionDetailsViewController : UIViewController <
    UITextFieldDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
>

@property (strong, nonatomic) ILUCollection *collection;

@end
