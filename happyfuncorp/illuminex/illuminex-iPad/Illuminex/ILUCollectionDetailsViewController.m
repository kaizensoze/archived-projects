//
//  ILUCollectionDetailsViewController.m
//  illuminex
//
//  Created by Joe Gallo on 11/11/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUCollectionDetailsViewController.h"
#import "ILUItemImagesCollectionViewCell.h"
#import "ILUItemVideoCollectionViewCell.h"
#import "ILUItem.h"

@interface ILUCollectionDetailsViewController()
    @property (weak, nonatomic) IBOutlet UITextField *collectionNameTextField;
    @property (weak, nonatomic) IBOutlet UICollectionView *imageCollectionView;
    @property (weak, nonatomic) IBOutlet UICollectionView *videoCollectionView;
    @property (weak, nonatomic) IBOutlet UIButton *imagesButton;
    @property (weak, nonatomic) IBOutlet UIButton *videoButton;
@end

@implementation ILUCollectionDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionNameTextField.text = self.collection.name;
    
    [ILUCustomStyler adjustButton:self.imagesButton];
    [ILUCustomStyler adjustButton:self.videoButton];
    
    // default to images
    self.imagesButton.selected = YES;
    self.videoCollectionView.hidden = YES;
    
    DDLogInfo(@"%@", self.collection.items);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Open flyout menu

- (IBAction)openFlyoutMenu:(id)sender {
    [appDelegate.viewDeckController toggleLeftView];
}

#pragma mark - Share

- (IBAction)share:(id)sender {
    
}

#pragma mark - Show images

- (IBAction)showImages:(id)sender {
    self.videoButton.selected = NO;
    self.imagesButton.selected = YES;
    
    self.videoCollectionView.hidden = YES;
    self.imageCollectionView.hidden = NO;
    
    [self.imageCollectionView reloadData];
    [self.videoCollectionView reloadData];
}

#pragma mark - Show videos

- (IBAction)showVideos:(id)sender {
    self.imagesButton.selected = NO;
    self.videoButton.selected = YES;
    
    self.imageCollectionView.hidden = YES;
    self.videoCollectionView.hidden = NO;
    
    [self.imageCollectionView reloadData];
    [self.videoCollectionView reloadData];
}

#pragma mark - Request to examine collection

- (IBAction)requestToExamineCollection:(id)sender {
    
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    DDLogInfo(@"%d", self.collection.id);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/collections/%d",
                     SITE_DOMAIN, API_PATH, self.collection.id];
    NSDictionary *parameters = @{
                                 @"collection[name]": textField.text
                                 };
    [appDelegate.requestManager PUT:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        self.collection.id = [JSON[@"collection"][@"id"] intValue];
        self.collection.name = JSON[@"collection"][@"name"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"%@ %@", error, operation.responseString);
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collection.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ILUItem *item = self.collection.items[indexPath.item];
    
    UICollectionViewCell *cell;
    if (collectionView == self.imageCollectionView) {
        ILUItemImagesCollectionViewCell *thisCell = (ILUItemImagesCollectionViewCell *)
        [collectionView dequeueReusableCellWithReuseIdentifier:@"ItemImagesCell" forIndexPath:indexPath];
        if (item.onHand) {
            thisCell.onHandImageView.image = [UIImage imageNamed:@"diamond-status-on-hand"];
        } else {
            thisCell.onHandImageView.image = [UIImage imageNamed:@"diamond-status-not-on-hand"];
        }
        thisCell.titleLabel.text = item.title;
//        thisCell.itemImageView.image = item.image;
        
        cell = thisCell;
    } else {
        ILUItemVideoCollectionViewCell *thisCell = (ILUItemVideoCollectionViewCell *)
        [collectionView dequeueReusableCellWithReuseIdentifier:@"ItemVideoCell" forIndexPath:indexPath];
        if (item.onHand) {
            thisCell.onHandImageView.image = [UIImage imageNamed:@"diamond-status-on-hand"];
        } else {
            thisCell.onHandImageView.image = [UIImage imageNamed:@"diamond-status-not-on-hand"];
        }
        thisCell.titleLabel.text = item.title;
        
        // video player
        [thisCell.videoPlayerView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *sampleURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp4"]];
            AVAsset *asset = [AVAsset assetWithURL:sampleURL];
            AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
            
            thisCell.videoPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
            
            AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:thisCell.videoPlayer];
            playerLayer.videoGravity = AVLayerVideoGravityResize;
            playerLayer.frame = thisCell.videoPlayerView.bounds;
            [thisCell.videoPlayerView.layer addSublayer:playerLayer];
            
            //        [thisCell.videoPlayer seekToTime:kCMTimeZero];
            [thisCell.videoPlayer play];
            
            if (!self.videoButton.selected) {
                [thisCell.videoPlayer pause];
            }
        });
        
        cell = thisCell;
    }
    
    return cell;
}

#pragma mark - Remove item from collection

- (IBAction)removeItemFromCollection:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    UICollectionView *collectionView;
    if (!self.imageCollectionView.hidden) {
        collectionView = self.imageCollectionView;
    } else {
        collectionView = self.videoCollectionView;
    }
    
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:collectionView];
    NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:buttonPosition];
    
    ILUItem *item = self.collection.items[indexPath.item];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/collections/%d/remove_diamond",
                     SITE_DOMAIN, API_PATH, self.collection.id];
    NSDictionary *parameters = @{
                                 @"collection[diamond_id]": [NSNumber numberWithInt:item.id]
                                 };
    [appDelegate.requestManager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        [self.collection.items removeObjectAtIndex:indexPath.item];
        
        [self.imageCollectionView reloadData];
        [self.videoCollectionView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"%@ %@", error, operation.responseString);
    }];
}

#pragma mark - Prev/next item image

- (IBAction)showPrevItemImage:(id)sender {
    
}

- (IBAction)showNextItemImage:(id)sender {
    
}

#pragma mark - Touches ended

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
