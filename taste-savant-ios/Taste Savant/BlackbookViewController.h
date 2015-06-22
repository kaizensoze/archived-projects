//
//  BlackbookViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 10/26/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlackbookViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate, UITextFieldDelegate>

- (void)addBlackbookEntry:(NSString *)restaurantSlug;

@end
