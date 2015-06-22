//
//  ILUDetailsViewController.m
//  illuminex
//
//  Created by Joe Gallo on 10/26/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUDetailsViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ILUBookmarkedItem.h"

@interface ILUDetailsViewController ()
    @property (weak, nonatomic) IBOutlet UILabel *titleLabel;
    @property (weak, nonatomic) IBOutlet UIButton *searchButton;

    @property (weak, nonatomic) IBOutlet UIView *infoView;
    @property (weak, nonatomic) IBOutlet UITableView *infoTableView;
    @property (strong, nonatomic) NSArray *sectionTitles;
    @property (strong, nonatomic) NSDictionary *rowTitles;

    @property (weak, nonatomic) IBOutlet UIView *imageView;
    @property (weak, nonatomic) IBOutlet UIImageView *currentImageView;
    @property (weak, nonatomic) IBOutlet UIButton *prevImageButton;
    @property (weak, nonatomic) IBOutlet UIButton *nextImageButton;

    @property (weak, nonatomic) IBOutlet UIView *videoView;
    @property (weak, nonatomic) IBOutlet UIView *videoPlayerView;
    @property (strong, nonatomic) MPMoviePlayerController *videoPlayer;

    @property (weak, nonatomic) IBOutlet UIView *giaView;
    @property (weak, nonatomic) IBOutlet UIWebView *giaDocumentWebView;

    @property (weak, nonatomic) IBOutlet UIButton *infoButton;
    @property (weak, nonatomic) IBOutlet UIButton *imageButton;
    @property (weak, nonatomic) IBOutlet UIButton *videoButton;
    @property (weak, nonatomic) IBOutlet UIButton *giaButton;
    @property (weak, nonatomic) IBOutlet UIButton *fingerprintButton;
@end

@implementation ILUDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = self.item.title;
    
    [ILUCustomStyler styleButton:self.searchButton];
    
    // info
    self.sectionTitles = @[@"Identification", @"Description"];
    self.rowTitles = @{
                       @"Identification": @[
                               @"Stock #",
                               @"Cert #",
                               @"Status"
                               ],
                       @"Description": @[
                               @"Price",
                               @"Carat",
                               @"Shape",
                               @"Color",
                               @"Clarity",
                               @"Certificate", // lab
                               @"Cut",
                               @"Polish",
                               @"Symmetry",
                               @"Depth %",
                               @"Table %",
                               @"Culet Condition",
                               @"Culet Size",
                               @"Fancy Color Dom. Color",
                               @"Fancy Color Sec. Color",
                               @"Fancy Color Intensity",
                               @"Fancy Color Overtone",
                               @"Fluor. Color",
                               @"Fluor. Intensity",
                               @"Girdle Condition",
                               @"Girdle Min",
                               @"Girdle Max",
                               @"Depth",
                               @"Length",
                               @"Width"
                               ]
                       };
    self.infoTableView.tableHeaderView = [self infoTableViewHeaderView];
    self.infoTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // video
//    NSURL *sampleURL = [NSURL URLWithString:@"https://ia600505.us.archive.org/3/items/Windows7WildlifeSampleVideo/Wildlife_512kb.mp4"];
    NSURL *sampleURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp4"]];
    
    self.videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:sampleURL];
    self.videoPlayer.controlStyle = MPMovieControlStyleEmbedded;
    self.videoPlayer.scalingMode = MPMovieScalingModeFill;
    self.videoPlayer.shouldAutoplay = NO;
    [self.videoPlayer prepareToPlay];
    [self.videoPlayer.view setFrame:self.videoPlayerView.bounds];
    [self.videoPlayerView addSubview:self.videoPlayer.view];
//    [self.videoPlayer play];
    
    // GIA document
//    NSString *urlString = @"http://eurecaproject.eu/files/4613/9886/3802/report3.pdf";
    NSString *urlString = @"http://www.gia.edu/cs/Satellite?blobcol=gfile&blobheader=image%2Fpng&blobkey=id&blobtable=GIA_MediaFile&blobwhere=1355957637795&ssbinary=true";
    NSURL *documentURL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:documentURL];
    [self.giaDocumentWebView loadRequest:request];
    
    // bottom dashboard
    [ILUCustomStyler adjustButton:self.infoButton];
    [ILUCustomStyler adjustButton:self.imageButton];
    [ILUCustomStyler adjustButton:self.videoButton];
    [ILUCustomStyler adjustButton:self.giaButton];
    [ILUCustomStyler adjustButton:self.fingerprintButton];
    
    // initialize center views to hidden
    self.infoView.hidden = YES;
    self.imageView.hidden = YES;
    self.videoView.hidden = YES;
    self.giaView.hidden = YES;
    
    [self toggleImages:nil];
    [self toggleVideo:nil];
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [self checkVideoPlayerSubviews:self.videoPlayer.view];
//}

- (void)checkVideoPlayerSubviews:(UIView *)view {
    for (UIView *subview in view.subviews) {
        // prevent pinch to fullscreen
        if (subview.gestureRecognizers.count > 0) {
//            subview.userInteractionEnabled = NO;
        }
        
//        if (subview.tag == 1000) {
//            subview.hidden = YES;
//        }
        
        [self checkVideoPlayerSubviews:subview];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Open flyout menu

- (IBAction)openFlyoutMenu:(id)sender {
    [appDelegate.viewDeckController toggleLeftView];
}

#pragma mark - New search

- (IBAction)newSearch:(id)sender {
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Search"];
    appDelegate.viewDeckController.centerController = vc;
}

#pragma mark - Share

- (IBAction)share:(id)sender {
    
}

#pragma mark - Toggle info

- (IBAction)toggleInfo:(id)sender {
    self.infoButton.selected = !self.infoButton.selected;
    self.infoView.hidden = !self.infoView.hidden;
}

#pragma mark - Toggle images

- (IBAction)toggleImages:(id)sender {
    self.imageButton.selected = !self.imageButton.selected;
    self.imageView.hidden = !self.imageView.hidden;
}

#pragma mark - Previous image

- (IBAction)showPreviousImage:(id)sender {
}

#pragma mark - Next image

- (IBAction)showNextImage:(id)sender {
}

#pragma mark - Toggle video

- (IBAction)toggleVideo:(id)sender {
    self.videoButton.selected = !self.videoButton.selected;
    self.videoView.hidden = !self.videoView.hidden;
    
    if (!self.videoView.hidden) {
        [self.videoPlayer play];
    } else {
        [self.videoPlayer pause];
    }
}

#pragma mark - Toggle GIA

- (IBAction)toggleGIA:(id)sender {
    self.giaButton.selected = !self.giaButton.selected;
    self.giaView.hidden = !self.giaView.hidden;
}

#pragma mark - Expand GIA document

- (IBAction)expandGIADocument:(id)sender {
//    self.giaDocumentWebView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

#pragma mark - Toggle fingerprint

- (IBAction)toggleFingerprint:(id)sender {
    self.fingerprintButton.selected = !self.fingerprintButton.selected;
}

#pragma mark - Love

- (IBAction)love:(id)sender {
    ILUBookmarkedItem *bookmarkedItem = [[ILUBookmarkedItem alloc] initWithItem:self.item];
    
    NSMutableArray *bookmarkedItems = (NSMutableArray *)[appDelegate objectForKey:@"bookmarkedItems"];
    if (!bookmarkedItems) {
        bookmarkedItems = [[NSMutableArray alloc] init];
    }
    if (![bookmarkedItems containsObject:bookmarkedItem]) {
        [bookmarkedItems addObject:bookmarkedItem];
        [appDelegate saveObject:bookmarkedItems forKey:@"bookmarkedItems"];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionTitle = self.sectionTitles[section];
    NSInteger rowCount = ((NSArray *)self.rowTitles[sectionTitle]).count;
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
//    }
    cell.backgroundColor = [UIColor clearColor];
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        cell.preservesSuperviewLayoutMargins = NO;
    }
    
    // text label
    NSString *sectionTitle = self.sectionTitles[indexPath.section];
    NSString *rowTitle = self.rowTitles[sectionTitle][indexPath.row];
    cell.textLabel.text = rowTitle;
    cell.textLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:16];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    // detail text label
    NSString *detailTextLabelText;
    switch (indexPath.section) {
        case 0:
            if ([rowTitle isEqualToString:@"Stock #"]) {
                detailTextLabelText = self.item.stockNumber;
            } else if ([rowTitle isEqualToString:@"Cert #"]) {
                detailTextLabelText = self.item.certNumber;
            } else if ([rowTitle isEqualToString:@"Status"]) {
                detailTextLabelText = self.item.status;
            }
            break;
        case 1:
            if ([rowTitle isEqualToString:@"Price"]) {
                detailTextLabelText = self.item.formattedPrice;
            } else if ([rowTitle isEqualToString:@"Carat"]) {
                detailTextLabelText = [NSString stringWithFormat:@"%0.2f", self.item.carat];
            } else if ([rowTitle isEqualToString:@"Shape"]) {
                detailTextLabelText = self.item.shape;
            } else if ([rowTitle isEqualToString:@"Color"]) {
                detailTextLabelText = self.item.color;
            } else if ([rowTitle isEqualToString:@"Clarity"]) {
                detailTextLabelText = self.item.clarity;
            } else if ([rowTitle isEqualToString:@"Certificate"]) {
                detailTextLabelText = self.item.lab;
            } else if ([rowTitle isEqualToString:@"Cut"]) {
                detailTextLabelText = self.item.cutGrade;
            } else if ([rowTitle isEqualToString:@"Polish"]) {
                detailTextLabelText = self.item.polish;
            } else if ([rowTitle isEqualToString:@"Symmetry"]) {
                detailTextLabelText = self.item.symmetry;
            } else if ([rowTitle isEqualToString:@"Depth %"]) {
                detailTextLabelText = [NSString stringWithFormat:@"%0.2f", self.item.depthPercent];
            } else if ([rowTitle isEqualToString:@"Table %"]) {
                detailTextLabelText = [NSString stringWithFormat:@"%0.2f", self.item.tablePercent];
            } else if ([rowTitle isEqualToString:@"Culet Condition"]) {
                detailTextLabelText = self.item.culetCondition;
            } else if ([rowTitle isEqualToString:@"Culet Size"]) {
                detailTextLabelText = self.item.culetSize;
            } else if ([rowTitle isEqualToString:@"Fancy Color 1st Color"]) {
                detailTextLabelText = self.item.fancyColorDominantColor;
            } else if ([rowTitle isEqualToString:@"Fancy Color 2nd Color"]) {
                detailTextLabelText = self.item.fancyColorSecondaryColor;
            } else if ([rowTitle isEqualToString:@"Fancy Color Intensity"]) {
                detailTextLabelText = self.item.fancyColorIntensity;
            } else if ([rowTitle isEqualToString:@"Fancy Color Overtone"]) {
                detailTextLabelText = self.item.fancyColorOvertone;
            } else if ([rowTitle isEqualToString:@"Fluor. Color"]) {
                detailTextLabelText = self.item.fluorescenceColor;
            } else if ([rowTitle isEqualToString:@"Fluor. Intensity"]) {
                detailTextLabelText = self.item.fluorescenceIntensity;
            } else if ([rowTitle isEqualToString:@"Girdle Condition"]) {
                detailTextLabelText = self.item.girdleCondition;
            } else if ([rowTitle isEqualToString:@"Girdle Min"]) {
                detailTextLabelText = self.item.girdleMin;
            } else if ([rowTitle isEqualToString:@"Girdle Max"]) {
                detailTextLabelText = self.item.girdleMax;
            } else if ([rowTitle isEqualToString:@"Depth"]) {
                detailTextLabelText = [NSString stringWithFormat:@"%0.2f", self.item.measuredDepth];
            } else if ([rowTitle isEqualToString:@"Length"]) {
                detailTextLabelText = [NSString stringWithFormat:@"%0.2f", self.item.measuredLength];
            } else if ([rowTitle isEqualToString:@"Width"]) {
                detailTextLabelText = [NSString stringWithFormat:@"%0.2f", self.item.measuredWidth];
            }
            break;
        default:
            break;
    }
    cell.detailTextLabel.text = detailTextLabelText;
    cell.detailTextLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:16];
    cell.detailTextLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    DDLogInfo(@"%lud %lud %@ %@ %@",
//              (unsigned long)indexPath.section,
//              (unsigned long)indexPath.row,
//              sectionTitle,
//              rowTitle,
//              detailTextLabelText);
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 34;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    float headerHeight = 45;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.contentSize.width, headerHeight)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, headerView.frame.size.width, 18)];
    label.text = self.sectionTitles[section];
    label.font = [UIFont fontWithName:@"RobotoCondensed-Bold" size:16];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:label];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset = UIEdgeInsetsMake(0, 33, 0, 33);
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsMake(0, 33, 0, 33);
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if ([self.infoTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.infoTableView.separatorInset = UIEdgeInsetsMake(0, 33, 0, 33);
    }

    if ([self.infoTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.infoTableView.layoutMargins = UIEdgeInsetsMake(0, 33, 0, 33);
    }
}

- (UIView *)infoTableViewHeaderView {
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.infoTableView.frame.size.width, 36)];
    
    // label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, tableHeaderView.frame.size.width, 28)];
    label.text = self.item.shortTitle;
    label.font = [UIFont fontWithName:@"PlayfairDisplay-BoldItalic" size:21];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [tableHeaderView addSubview:label];
    
    // status image
    CGRect textRect = [label.text boundingRectWithSize:label.frame.size
                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                      attributes:@{NSFontAttributeName:label.font}
                                         context:nil];
    float imageViewX = label.center.x + textRect.size.width/2 + 6;
    float imageViewY = label.center.y;
    
    UIImageView *statusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewX, imageViewY, 10, 10)];
    if (self.item.onHand) {
        statusImageView.image = [UIImage imageNamed:@"diamond-status-on-hand"];
    } else {
        statusImageView.image = [UIImage imageNamed:@"diamond-status-not-on-hand"];
    }
    [tableHeaderView addSubview:statusImageView];
    
//    [ILUUtil setBorder:label];
//    [ILUUtil setBorder:tableHeaderView width:1 color:[UIColor greenColor]];
    
    return tableHeaderView;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self performSelector:@selector(clearPDFBlackBackground) withObject:nil afterDelay:0.1];
    }
}

- (void)clearPDFBlackBackground {
    UIView *v = self.giaDocumentWebView;
    while (v) {
        v = [v.subviews firstObject];
        
        if ([NSStringFromClass([v class]) isEqualToString:@"UIWebPDFView"]) {
            [v setBackgroundColor:[UIColor clearColor]];
            return;
        }
    }
}

@end
