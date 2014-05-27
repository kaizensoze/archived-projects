//
//  InboxMessageDetailViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 6/12/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "InboxMessageDetailViewController.h"
#import "InboxMessage.h"

@interface InboxMessageDetailViewController ()
    @property (weak, nonatomic) IBOutlet UILabel *messageDetail;
@end

@implementation InboxMessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messageDetail.text = self.message.message;
    [self.messageDetail sizeToFit];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
