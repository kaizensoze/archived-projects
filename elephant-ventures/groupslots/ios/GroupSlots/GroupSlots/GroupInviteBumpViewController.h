//
//  GroupInviteBumpViewController.h
//  GroupSlots
//
//  Created by Joe Gallo on 6/20/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BumpAPI.h"
//#import "Bumper.h"

@interface GroupInviteBumpViewController : UIViewController <BumpAPIDelegate>

- (id)initWithParent:(UIViewController *)parentController;
- (void)startBumpSession;
- (void)endBumpSession;

@end
