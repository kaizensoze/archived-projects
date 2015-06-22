//
//  HBSTTileView.h
//  HBS Thrive
//
//  Created by Joe Gallo on 8/13/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBSTTileView : UIView

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIColor *color;

@end
