//
//  WebViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 4/29/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
    @property (weak, nonatomic) IBOutlet UIWebView *webview;
@end

@implementation WebViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = NO;
    
    [appDelegate showLoadingScreen:self.view];
    
    self.webview.delegate = self;
    
    NSURL *url = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest:request];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"Restaurant Seamless/OpenTable Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    self.webview.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [appDelegate removeLoadingScreen:self];
}

@end
