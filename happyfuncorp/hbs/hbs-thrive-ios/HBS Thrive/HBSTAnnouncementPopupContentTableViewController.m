//
//  HBSTAnnouncementPopupContentViewController.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/15/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTAnnouncementPopupContentTableViewController.h"
#import "HBSTWebOverlayViewController.h"
#import "HBSTAnnouncementSummaryTableViewCell.h"
#import "HBSTAnnouncementHeadlineTableViewCell.h"
#import "HBSTAnnouncementImageTableViewCell.h"
#import "HBSTAnnouncementBodyTableViewCell.h"
#import "HBSTAnnouncementLocationTableViewCell.h"
#import "HBSTAnnouncementDateTableViewCell.h"
#import "HBSTAnnouncementTimeTableViewCell.h"
#import "HBSTAnnouncementButtonTableViewCell.h"
#import "HBSTWebOverlayViewController.h"

@interface HBSTAnnouncementPopupContentTableViewController ()
    @property (strong, nonatomic) NSMutableArray *rows;
@end

@implementation HBSTAnnouncementPopupContentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    self.rows = [[NSMutableArray alloc] initWithArray:@[@"summary", @"headline", @"image", @"body",
                                                        @"location", @"start_date", @"start_time",
                                                        @"end_date", @"end_time", @"button"]];
    if ([HBSTUtil isEmpty:self.announcement.summary]) {
        [self.rows removeObject:@"summary"];
    }
    if ([HBSTUtil isEmpty:self.announcement.headline]) {
        [self.rows removeObject:@"headline"];
    }
    if (!self.announcement.imageURL) {
        [self.rows removeObject:@"image"];
    }
    if ([HBSTUtil isEmpty:self.announcement.body]) {
        [self.rows removeObject:@"body"];
    }
    if ([HBSTUtil isEmpty:self.announcement.location]) {
        [self.rows removeObject:@"location"];
    }
    if (self.announcement.displayStartDate.length == 0) {
        [self.rows removeObject:@"start_date"];
    }
    if (self.announcement.displayStartTime.length == 0) {
        [self.rows removeObject:@"start_time"];
    }
    if (self.announcement.displayEndDate.length == 0) {
        [self.rows removeObject:@"end_date"];
    }
    if (self.announcement.displayEndTime.length == 0) {
        [self.rows removeObject:@"end_time"];
    }
    if (!self.announcement.hasButton) {
        [self.rows removeObject:@"button"];
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
    if ([rowType isEqualToString:@"summary"]) {
        cellIdentifier = @"AnnouncementSummaryCell";
        HBSTAnnouncementSummaryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[HBSTAnnouncementSummaryTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                               reuseIdentifier:cellIdentifier];
        }
        cell.summaryLabel.text = self.announcement.summary;
        
        thisCell = cell;
    } else if ([rowType isEqualToString:@"headline"]) {
        cellIdentifier = @"AnnouncementHeadlineCell";
        HBSTAnnouncementHeadlineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[HBSTAnnouncementHeadlineTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                                reuseIdentifier:cellIdentifier];
        }
        cell.headlineLabel.text = self.announcement.headline;
        
        thisCell = cell;
    } else if ([rowType isEqualToString:@"image"]) {
        cellIdentifier = @"AnnouncementImageCell";
        HBSTAnnouncementImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[HBSTAnnouncementImageTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                             reuseIdentifier:cellIdentifier];
        }
        cell.theImageView.image = self.announcement.image;
        
        thisCell = cell;
    } else if ([rowType isEqualToString:@"body"]) {
        cellIdentifier = @"AnnouncementBodyCell";
        HBSTAnnouncementBodyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[HBSTAnnouncementBodyTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                            reuseIdentifier:cellIdentifier];
        }
        cell.bodyTextView.text = self.announcement.body;
        cell.bodyTextView.delegate = self;
        
        thisCell = cell;
    } else if ([rowType isEqualToString:@"location"]) {
        cellIdentifier = @"AnnouncementLocationCell";
        HBSTAnnouncementLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[HBSTAnnouncementLocationTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                                reuseIdentifier:cellIdentifier];
        }
        cell.locationLabel.text = self.announcement.location;
        
        thisCell = cell;
    } else if ([rowType isEqualToString:@"start_date"]) {
        cellIdentifier = @"AnnouncementDateCell";
        HBSTAnnouncementDateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[HBSTAnnouncementDateTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                            reuseIdentifier:cellIdentifier];
        }
        cell.startEndLabel.text = @"Start Time";
        cell.dateLabel.text = self.announcement.displayStartDate;
        
        thisCell = cell;
    } else if ([rowType isEqualToString:@"start_time"]) {
        cellIdentifier = @"AnnouncementTimeCell";
        HBSTAnnouncementTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[HBSTAnnouncementTimeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                            reuseIdentifier:cellIdentifier];
        }
        cell.timeLabel.text = self.announcement.displayStartTime;
        
        thisCell = cell;
    } else if ([rowType isEqualToString:@"end_date"]) {
        cellIdentifier = @"AnnouncementDateCell";
        HBSTAnnouncementDateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[HBSTAnnouncementDateTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                            reuseIdentifier:cellIdentifier];
        }
        cell.startEndLabel.text = @"End Time";
        cell.dateLabel.text = self.announcement.displayEndDate;
        
        thisCell = cell;
    } else if ([rowType isEqualToString:@"end_time"]) {
        cellIdentifier = @"AnnouncementTimeCell";
        HBSTAnnouncementTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[HBSTAnnouncementTimeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                            reuseIdentifier:cellIdentifier];
        }
        cell.timeLabel.text = self.announcement.displayEndTime;
        
        thisCell = cell;
    } else if ([rowType isEqualToString:@"button"]) {
        cellIdentifier = @"AnnouncementButtonCell";
        HBSTAnnouncementButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[HBSTAnnouncementButtonTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                              reuseIdentifier:cellIdentifier];
        }
        [cell.button setTitle:self.announcement.buttonText forState:UIControlStateNormal];
        
        thisCell = cell;
    }
    
    return thisCell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = indexPath.row;
    NSString *rowType = self.rows[index];
    if ([rowType isEqualToString:@"summary"]) {
        CGSize textSize = [HBSTUtil textSize:self.announcement.summary font:[UIFont fontWithName:@"HelveticaNeue-Light" size:25]
                                       width:240 height:MAXFLOAT];
        return 31 + textSize.height;
    } else if ([rowType isEqualToString:@"headline"]) {
        // get height of headline label
        CGSize textSize = [HBSTUtil textSize:self.announcement.headline font:[UIFont fontWithName:@"HelveticaNeue-Bold" size:17]
                                       width:240 height:MAXFLOAT];
        float height = textSize.height;
        float padding = 27;
        
        return height + padding;
    } else if ([rowType isEqualToString:@"image"]) {
        return 150;
    } else if ([rowType isEqualToString:@"body"]) {
        // get height of body textview
        CGSize textSize = [HBSTUtil textSize:self.announcement.body font:[UIFont fontWithName:@"HelveticaNeue" size:14]
                                       width:241 height:MAXFLOAT];
        float height = textSize.height;
        float padding = 20;
        
        return height + padding;
    } else if ([rowType isEqualToString:@"location"]) {
        return 27;
    } else if ([rowType isEqualToString:@"start_date"] || [rowType isEqualToString:@"end_date"]) {
        return 49;
    } else if ([rowType isEqualToString:@"start_time"] || [rowType isEqualToString:@"end_time"]) {
        return 23;
    } else if ([rowType isEqualToString:@"button"]) {
        return 80;
    } else {
        return 0;
    }
}

- (IBAction)buttonClicked:(id)sender {
    UINavigationController *nc = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"WebOverlayNav"];
    HBSTWebOverlayViewController *webOverlayVC = (HBSTWebOverlayViewController *)nc.viewControllers[0];
    webOverlayVC.url = self.announcement.buttonLinkURL;
    [appDelegate.window.rootViewController presentViewController:nc animated:YES completion:nil];
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
