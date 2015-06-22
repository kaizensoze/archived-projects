//
//  OptionsViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 11/23/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionsViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *options;
@property (nonatomic) SEL displayFunction;
@property (nonatomic) SEL methodToCallOnSelect;

@end
