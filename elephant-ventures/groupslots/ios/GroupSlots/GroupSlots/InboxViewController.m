//
//  InboxViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 6/11/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "InboxViewController.h"
#import "User.h"
#import "InboxMessage.h"
#import "InboxCell.h"
#import "InboxMessageDetailViewController.h"

@interface InboxViewController ()
    @property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation InboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [appDelegate useMainNav:self];
    
    UIColor *backgroundColor = [Util colorFromHex:@"3f3f3f"];
    
    // background color
    self.view.backgroundColor = backgroundColor;
    
    // table view
    self.tableView.backgroundColor = backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return appDelegate.loggedInUser.inboxMessages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"InboxCell";
    InboxCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[InboxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    InboxMessage *message = [appDelegate.loggedInUser.inboxMessages objectAtIndex:indexPath.row];
    
    // icon
    UIImage *iconImage = [UIImage imageNamed:message.iconPath];
    cell.iconImageView.image = iconImage;
    
    // label
    cell.label.text = message.message;
    [Util adjustText:cell.label width:225 height:30];
    cell.label.font = [UIFont fontWithName:@"Helvetica" size:13];
    cell.label.textColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // bottom separator
    [Util addSeparator:cell];
    
    if (indexPath.row == 0) {
        // top separator
        [Util addTopSeparator:cell];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    InboxMessage *message = [appDelegate.loggedInUser.inboxMessages objectAtIndex:indexPath.row];
//    InboxMessageDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InboxMessageDetail"];
//    vc.message = message;
//    [self presentViewController:vc animated:YES completion:nil];
}

@end
