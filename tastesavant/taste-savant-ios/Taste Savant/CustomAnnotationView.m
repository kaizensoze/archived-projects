//
//  CustomAnnotationView.m
//  TasteSavant
//
//  Created by Joe Gallo on 11/2/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "CustomAnnotationView.h"
#import "Restaurant.h"


@interface CustomAnnotationView ()
    @property (strong, nonatomic) UILabel *indexLabel;
@end

@implementation CustomAnnotationView

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        // adjust positioning of callout
        CGRect frame = self.callout.frame;
        frame.origin.x = -frame.size.width/2 + 13;
        frame.origin.y = -frame.size.height - 3;
        self.callout.frame = frame;
        
        [self addSubview:self.callout];
    } else {
        [self.callout removeFromSuperview];
    }
}

- (void)addIndexLabel {
    UILabel *indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 20, 9)];
    indexLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.index];
    indexLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
    indexLabel.textColor = [Util colorFromHex:@"362f2d"];
    indexLabel.backgroundColor = [UIColor clearColor];
    indexLabel.textAlignment = NSTextAlignmentCenter;
    self.indexLabel = indexLabel;
    [self addSubview:indexLabel];
}

- (void)createCallout {
    // create custom callout
    CustomCalloutView *callout = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, 270, 77)];
    callout.contentMode = UIViewContentModeScaleToFill;
    callout.image = [UIImage imageNamed:@"callout-background"];
    callout.userInteractionEnabled = YES;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 60, 60)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor blackColor];
    [imageView setImageWithURL:[NSURL URLWithString:self.restaurant.imageURL]
              placeholderImage:[UIImage imageNamed:@"restaurant-placeholder.png"]];
    [callout addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(75, 5, 130, 60)];
    label.text = self.restaurant.name;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    label.textColor = [Util colorFromHex:@"362f2d"];
    label.backgroundColor = [UIColor clearColor];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    [callout addSubview:label];
    
    self.callout = callout;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(self.bounds, point) ||
        CGRectContainsPoint(self.callout.frame, point)) {
        return YES;
    }
    return NO;
}

@end
