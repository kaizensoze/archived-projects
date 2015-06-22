//
//  MyActivityLogViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/16/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "ActivityLogViewController.h"
#import "ActivityLogEvent.h"
#import "User.h"

@interface ActivityLogViewController ()

@end

@implementation ActivityLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [appDelegate useMainNav:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return appDelegate.loggedInUser.activityLog.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ActivityLogEvent *event = [appDelegate.loggedInUser.activityLog objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"ActivityLogCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [[event formattedTimestamp] stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
    cell.detailTextLabel.text = event.eventDescription;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ActivityLogEvent *event = [appDelegate.loggedInUser.activityLog objectAtIndex:indexPath.row];
    
    CGSize labelSize = [event.eventDescription sizeWithFont:[UIFont fontWithName:@"Helvetica" size:13.0]
                                   constrainedToSize:CGSizeMake(203.0f, MAXFLOAT)
                                       lineBreakMode:NSLineBreakByWordWrapping];
    return labelSize.height + 25;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
