//
//  HBSTMenuPopupContentViewController.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/14/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTMenuPopupContentTableViewController.h"
#import "HBSTMenuDateTableViewCell.h"
#import "HBSTMenuSummaryTableViewCell.h"
#import "HBSTMenuBodyTableViewCell.h"
#import "HBSTWebOverlayViewController.h"

@interface HBSTMenuPopupContentTableViewController ()
    @property (strong, nonatomic) NSMutableArray *rows;
@end

@implementation HBSTMenuPopupContentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    self.rows = [[NSMutableArray alloc] initWithArray:@[@"date", @"summary", @"body"]];
    if ([HBSTUtil isEmpty:self.menu.displayDate]) {
        [self.rows removeObject:@"date"];
    }
    if ([HBSTUtil isEmpty:self.menu.summary]) {
        [self.rows removeObject:@"summary"];
    }
    if ([HBSTUtil isEmpty:self.menu.body]) {
        [self.rows removeObject:@"body"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *thisCell;
    static NSString *cellIdentifier;
    
    NSUInteger index = indexPath.row;
    NSString *rowType = self.rows[index];
    if ([rowType isEqualToString:@"date"]) {
        cellIdentifier = @"MenuDateCell";
        HBSTMenuDateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[HBSTMenuDateTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        cell.dateLabel.text = self.menu.displayDate;
        
        thisCell = cell;
    } else if ([rowType isEqualToString:@"summary"]) {
        cellIdentifier = @"MenuSummaryCell";
        HBSTMenuSummaryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[HBSTMenuSummaryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        cell.summaryLabel.text = self.menu.summary;
        
        thisCell = cell;
    } else {
        cellIdentifier = @"MenuBodyCell";
        HBSTMenuBodyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[HBSTMenuBodyTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        cell.bodyTextView.text = self.menu.body;
        cell.bodyTextView.delegate = self;
        
        thisCell = cell;
    }
    
    return thisCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = indexPath.row;
    NSString *rowType = self.rows[index];
    if ([rowType isEqualToString:@"date"]) {
        return 67;
    } else if ([rowType isEqualToString:@"summary"]) {
        return 40;
    } else if ([rowType isEqualToString:@"body"]) {
        // get height of body textview
        CGSize textSize = [HBSTUtil textSize:self.menu.body font:[UIFont fontWithName:@"HelveticaNeue" size:14]
                                       width:241 height:MAXFLOAT];
        float height = textSize.height;
        float padding = 30;
        
        return height + padding;
    } else {
        return 0;
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([URL.absoluteString hasPrefix:@"mailto:"]) {
        NSString *email = [URL.absoluteString stringByReplacingOccurrencesOfString:@"mailto:" withString:@""];
        appDelegate.mailVC = nil;
        appDelegate.mailVC = [[MFMailComposeViewController alloc] init];
        appDelegate.mailVC.mailComposeDelegate = appDelegate;
        [appDelegate.mailVC setToRecipients:@[email]];
        [appDelegate.window.rootViewController presentViewController:appDelegate.mailVC animated:YES completion:nil];
        return NO;
    } else if ([URL.absoluteString hasPrefix:@"tel:"]) {
        return YES;
    } else {
        UINavigationController *nc = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"WebOverlayNav"];
        HBSTWebOverlayViewController *webOverlayVC = (HBSTWebOverlayViewController *)nc.viewControllers[0];
        webOverlayVC.url = URL;
        [appDelegate.window.rootViewController presentViewController:nc animated:YES completion:nil];
        return NO;
    }
}

@end
