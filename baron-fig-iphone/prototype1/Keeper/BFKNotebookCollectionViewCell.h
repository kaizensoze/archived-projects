//
//  BFKNotebookCollectionViewCell.h
//  Keeper
//
//  Created by Joe Gallo on 11/22/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BFKNotebookCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end
