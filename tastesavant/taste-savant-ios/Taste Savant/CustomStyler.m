//
//  CustomStyler.m
//  TasteSavant
//
//  Created by Joe Gallo on 10/30/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "CustomStyler.h"
#import "Restaurant.h"

@implementation CustomStyler

#pragma mark - UIButton toggle

+ (void)setViewEnabled:(UIView *)view enabled:(BOOL)enabled {
    view.userInteractionEnabled = enabled;
    
    if (enabled) {
        view.alpha = 1;
    } else {
        view.alpha = 0.5;
    }
}

#pragma mark - Title view label

+ (UILabel *)createTitleViewLabel:(NSString *)titleText {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 36.0)];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.shadowColor = [UIColor darkGrayColor];
    label.shadowOffset = CGSizeMake(0, -1);
    label.text = titleText;
    label.lineBreakMode = kCTLineBreakByTruncatingMiddle;
    return label;
}

#pragma mark - Style buttons

+ (void)styleButton:(UIButton *)button {
    // background image
    NSString *filename = @"button.png";
    if ([button.titleLabel.text isEqualToString:@"Unfollow"]) {
        filename = @"button-gray.png";
    }
    
    UIImage *backgroundImage = [[UIImage imageNamed:filename]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    // active background image
    UIImage *activeBackgroundImage = [[UIImage imageNamed:@"button-active.png"]
                                      resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    
    [button setBackgroundImage:activeBackgroundImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:activeBackgroundImage forState:UIControlStateSelected];
    
    // font
    if ([button.titleLabel.text isEqualToString:@"Follow"]
        || [button.titleLabel.text isEqualToString:@"Unfollow"]) {
        button.titleLabel.font = [UIFont fontWithName:@"Georgia" size:12];
    } else {
        button.titleLabel.font = [UIFont fontWithName:@"Georgia" size:18];
    }
    
    // font color
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

+ (void)styleButton2:(UIButton *)button {
    // background image
    UIImage *backgroundImage = [[UIImage imageNamed:@"button2.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    // active background image
    UIImage *activeBackgroundImage = [[UIImage imageNamed:@"button2-active.png"]
                                      resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    
    [button setBackgroundImage:activeBackgroundImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:activeBackgroundImage forState:UIControlStateSelected];
    
    // font
    button.titleLabel.font = [UIFont fontWithName:@"Georgia" size:18];
    
    // font color
    [button setTitleColor:[Util colorFromHex:@"f26c4f"] forState:UIControlStateNormal];
}

+ (void)styleSelectButton:(UIButton *)button corners:(int)corners {
    // font
    button.titleLabel.font = [UIFont fontWithName:@"Georgia" size:18];
    
    // font color
    [button setTitleColor:[Util colorFromHex:@"f26c4f"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    // background color
    UIImage *selectedImage = [self imageWithColor:[Util colorFromHex:@"f26c4f"] size:button.frame.size];
    [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
    [button setBackgroundImage:selectedImage forState:UIControlStateSelected];
    
    // border
    [self setBorder:button width:1 color:[Util colorFromHex:@"cccccc"]];
    
    // rounded corners for end buttons
    if (corners != -1) {
        [self roundSelectCorners:button corners:corners radius:2];
    }
}

+ (void)customizeDistanceButton:(UIButton *)button {
    NSString *text = button.titleLabel.text;
    NSArray *parts = [text componentsSeparatedByString:@" "];
    NSAttributedString *normalAttrStr = [self createAttributedStringForDistanceButton:parts[0] and:parts[1]
                                                                                color:[Util colorFromHex:@"f26c4f"]];
    NSAttributedString *selectedAttrStr = [self createAttributedStringForDistanceButton:parts[0] and:parts[1]
                                                                                  color:[UIColor whiteColor]];
    
    [button setAttributedTitle:normalAttrStr forState:UIControlStateNormal];
    [button setAttributedTitle:selectedAttrStr forState:UIControlStateHighlighted];
    [button setAttributedTitle:selectedAttrStr forState:UIControlStateSelected];
}

+ (NSAttributedString *)createAttributedStringForDistanceButton:(NSString *)part1 and:(NSString *)part2 color:(UIColor *)color {
    UIFont *font1 = [UIFont fontWithName:@"Georgia" size:18.0];
    
    UIFont *font2 = [UIFont fontWithName:@"Georgia" size:12.0];
    
    NSString *str = [NSString stringWithFormat:@"%@ %@", part1, part2];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    [attrStr addAttribute:NSFontAttributeName value:font1 range:(NSMakeRange(0, part1.length))];
    [attrStr addAttribute:NSForegroundColorAttributeName value:color range:(NSMakeRange(0, part1.length))];
    [attrStr addAttribute:NSFontAttributeName value:font2 range:(NSMakeRange(part1.length+1, part2.length))];
    [attrStr addAttribute:NSForegroundColorAttributeName value:color range:(NSMakeRange(part1.length+1, part2.length))];
    
    return [attrStr copy];
}

#pragma mark - Style text field

+ (void)styleTextField:(UITextField *)textField {
    // change height
    CGRect frameRect = textField.frame;
    frameRect.size.height = 43;
    textField.frame = frameRect;
    
    // background image
    UIImage *backgroundImage = [[UIImage imageNamed:@"textfield.png"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    textField.background = backgroundImage;
    
    // font
    textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    
    // placeholder color
    [textField setValue:[Util colorFromHex:@"b9b9b9"] forKeyPath:@"_placeholderLabel.textColor"];
    
    // border style
    textField.borderStyle = UITextBorderStyleNone;
    
    // left padding to compensate for border style none
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

+ (void)styleDisclosureTextField:(UITextField *)textField {
    [self styleTextField:textField];
    
    textField.rightViewMode = UITextFieldViewModeAlways;
    UIImageView *rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure-icon"]];
    rightView.contentMode = UIViewContentModeScaleAspectFit;
    rightView.frame = CGRectMake(0, 0, 25, 12);
    textField.rightView = rightView;
}

#pragma mark - Style segmented control

+ (void)styleSegmentedControl:(UISegmentedControl *)segmentedControl {
    // adjust height
    CGRect frame = segmentedControl.frame;
    frame.size.height = 44;
    segmentedControl.frame = frame;
    
    // font
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"HelveticaNeue" size:12], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName,
                                shadow, NSShadowAttributeName,
                                nil];
    [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
    [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateSelected];
    
    // background image
    UIImage *normalImage = [self imageWithColor:[Util colorFromHex:@"534741"] size:CGSizeMake(64, 10)]; // 41
    [segmentedControl setBackgroundImage:normalImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UIImage *selectedImage = [self imageWithColor:[Util colorFromHex:@"f26c4f"] size:CGSizeMake(64, 10)]; // 41
    [segmentedControl setBackgroundImage:selectedImage forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [segmentedControl setBackgroundImage:selectedImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    // divider image
    UIImage *dividerImage = [self imageWithColor:[Util colorFromHex:@"8e8179"] size:CGSizeMake(1, segmentedControl.frame.size.height)];
    [segmentedControl setDividerImage:dividerImage forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [self setBorder:segmentedControl width:1 color:[Util colorFromHex:@"b2b2b2"]];
}

#pragma mark - Style option cell

+ (void)styleOptionCell:(UITableViewCell *)cell {
    float fontSize = 20;
    if (cell.tag == 2) {
        fontSize = 18;
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:fontSize];
    cell.textLabel.textColor = [Util colorFromHex:@"f26522"];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = [Util colorFromHex:@"f7f7f7"];
}

#pragma mark - Set/style restaurant info

+ (void)setAndStyleRestaurantInfo:(Restaurant *)restaurant
                             vc:(UIViewController *)vc
                 linkToRestaurant:(BOOL)linkToRestaurant {
    
    UIView *view = vc.view;
    if ([view isKindOfClass:[UIScrollView class]]) {
        view = view.subviews[0];
    }
    
    // image
    NSURL *imageURL = [NSURL URLWithString:restaurant.imageURL];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 21, 100, 100)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"restaurant-placeholder.png"]];
    imageView.backgroundColor = [UIColor blackColor];
    [view addSubview:imageView];
    
    UIColor *textColor = [Util colorFromHex:@"362f2d"];
    
    // name label
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 24, 190, 21)];
    nameLabel.text = restaurant.name;
    nameLabel.font = [UIFont fontWithName:@"Georgia" size:18];
    nameLabel.textColor = textColor;
    [view addSubview:nameLabel];
    
    // price label
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 45, 190, 21)];
    priceLabel.text = [NSString stringWithFormat:@"%@", restaurant.price];
    priceLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    priceLabel.textColor = textColor;
//    [Util adjustText:priceLabel width:190 height:21];
    [view addSubview:priceLabel];
    
    // cuisine label
    NSArray *cuisineNames = [restaurant.cuisines valueForKey:@"name"];
    UILabel *cuisineLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 64, 190, 21)];
    cuisineLabel.text = [NSString stringWithFormat:@"%@", [cuisineNames componentsJoinedByString:@", "]];
    cuisineLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    cuisineLabel.textColor = textColor;
//    [Util adjustText:cuisineLabel width:190 height:21];
    [view addSubview:cuisineLabel];
    
    // address1 label
    UILabel *address1Label = [[UILabel alloc] initWithFrame:CGRectMake(120, 83, 190, 21)];
    address1Label.text = restaurant.address;
    address1Label.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    address1Label.textColor = textColor;
//    [Util adjustText:address1Label width:190 height:21];
    [view addSubview:address1Label];
    
    // address2 label
    UILabel *address2Label = [[UILabel alloc] initWithFrame:CGRectMake(120, 102, 190, 21)];
    address2Label.text = [NSString stringWithFormat:@"%@, %@ %@",
                          restaurant.city, restaurant.state, restaurant.zipCode];
    address2Label.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    address2Label.textColor = textColor;
    [Util adjustText:address2Label width:190 height:21];
    [view addSubview:address2Label];
    
    // phone number label
    UILabel *phoneNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 121, 105, 21)];
    phoneNumberLabel.text = restaurant.phoneNumber;
    phoneNumberLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    [Util adjustText:phoneNumberLabel width:105 height:21];
    [self makePhoneNumberLink:phoneNumberLabel];
    [view addSubview:phoneNumberLabel];
    
    // open/closed image
    UIImage *openClosedImage;
    if (restaurant.isOpen) {
        openClosedImage = [UIImage imageNamed:@"open.png"];
    } else {
        openClosedImage = [UIImage imageNamed:@"closed.png"];
    }
    UIImageView *openClosedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(238, 121, 72, 20)];
    openClosedImageView.contentMode = UIViewContentModeScaleAspectFit;
    openClosedImageView.image = openClosedImage;
    [view addSubview:openClosedImageView];
    
    // gesture recognizers
    if (linkToRestaurant) {
        NSArray *properties = @[imageView, nameLabel, priceLabel, cuisineLabel, address1Label, address2Label];
        for (UIView *fieldView in properties) {
            UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:vc
                                                                                    action:@selector(goToRestaurant:)];
            fieldView.userInteractionEnabled = YES;
            [fieldView addGestureRecognizer:tapGR];
        }
    }
}

#pragma mark - Create table header view

+ (UIView *)createTableHeaderView:(UITableView *)tableView str:(NSString *)str {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.sectionHeaderHeight)];
    view.backgroundColor = [Util colorFromHex:@"534741"];
    
    int labelWidth = tableView.frame.size.width - 11;
    int labelHeight = 23;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 3, labelWidth, labelHeight)];
    headerLabel.text = str;
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.backgroundColor = [UIColor clearColor];
    
    [view addSubview:headerLabel];
    
    return view;
}

+ (UIView *)createTableHeaderView2:(UITableView *)tableView attrStr:(NSAttributedString *)attrStr {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.sectionHeaderHeight)];
    view.backgroundColor = [Util colorFromHex:@"534741"];
    
    int labelWidth = tableView.frame.size.width - 11;
    int labelHeight = 23;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 3, labelWidth, labelHeight)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.attributedText = attrStr;
    
    [view addSubview:headerLabel];
    
    return view;
}

+ (NSAttributedString *)createAttributedStringForTableHeaderView:(NSString *)part1 and:(NSString *)part2 {
    UIFont *font1 = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    UIColor *color1 = [UIColor whiteColor];
    
    UIFont *font2 = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    UIColor *color2 = [Util colorFromHex:@"f68e56"];
    
    NSString *str = [NSString stringWithFormat:@"%@ %@", part1, part2];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    [attrStr addAttribute:NSFontAttributeName value:font1 range:(NSMakeRange(0, part1.length))];
    [attrStr addAttribute:NSForegroundColorAttributeName value:color1 range:(NSMakeRange(0, part1.length))];
    [attrStr addAttribute:NSFontAttributeName value:font2 range:(NSMakeRange(part1.length+1, part2.length))];
    [attrStr addAttribute:NSForegroundColorAttributeName value:color2 range:(NSMakeRange(part1.length+1, part2.length))];
    
    return [attrStr copy];
}

#pragma mark - Add search result index view to restaurant image

+ (void)addSearchResultIndexView:(UIImageView *)imageView index:(NSInteger)index {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    view.backgroundColor = [Util colorFromHex:@"f26522"];
    view.tag = 42;
    
    float labelHeight = 15;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, view.frame.size.width, labelHeight)];
    label.text = [NSString stringWithFormat:@"%ld", (long)index];
    label.font = [UIFont fontWithName:@"Georgia" size:11];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
//    [imageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [[imageView viewWithTag:42] removeFromSuperview];
    [imageView addSubview:view];
}

#pragma mark - Create load more table view cell

+ (UITableViewCell *)createLoadMoreTableCell:(UITableView *)tableView vc:(UIViewController *)vc {
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIButton *loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loadMoreButton setTitle:@"Load More" forState:UIControlStateNormal];
    [loadMoreButton addTarget:vc action:@selector(loadMore:) forControlEvents:UIControlEventTouchUpInside];
    loadMoreButton.tag = 42;
    [self styleButton2:loadMoreButton];
    
    int leftPadding = 10;
    int topPadding = 13;
    
    int buttonWidth = 320 - leftPadding*2;
    int buttonHeight = 43;
    
    loadMoreButton.frame = CGRectMake(leftPadding, topPadding, buttonWidth, buttonHeight);
    
    [cell.contentView addSubview:loadMoreButton];
    
    return cell;
}

+ (void)showLoadMoreSpinner:(UITableViewCell *)loadMoreTableCell {
    // Remove button.
    [[loadMoreTableCell.contentView viewWithTag:42] removeFromSuperview];
    
    // Add spinner.
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.color = [Util colorFromHex:@"362f2d"];
    float spinnerX = loadMoreTableCell.frame.size.width/2 - spinner.frame.size.width/2;
    float spinnerY = loadMoreTableCell.frame.size.height/2 - spinner.frame.size.height/2;
    spinner.frame = CGRectMake(spinnerX, spinnerY, spinner.frame.size.width, spinner.frame.size.height);
    [loadMoreTableCell.contentView addSubview:spinner];
    [spinner startAnimating];
}

#pragma mark - Style search bar

+ (void)customizeSearchBar:(UISearchBar *)searchBar {
    searchBar.translucent = NO;
    
    // add top border
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, searchBar.frame.size.width, 1)];
    view.backgroundColor = [Util colorFromHex:@"e9e9e9"];
    [searchBar addSubview:view];
    
    [self alwaysEnableSearchButtonInKeyboard:searchBar];
}

+ (void)alwaysEnableSearchButtonInKeyboard:(UISearchBar *)searchBar {
    UITextField *searchTextField = [searchBar valueForKey:@"_searchField"];
    [searchTextField setEnablesReturnKeyAutomatically:NO];
}

+ (void)customizeLocationSearchBar:(UISearchBar *)searchBar neighborhood:(Neighborhood *)neighborhood {
    UITextField *searchTextField = [searchBar valueForKey:@"_searchField"];
    
    // remove x
    searchTextField.clearButtonMode = UITextFieldViewModeNever;
    
    // make text blue
    UIColor *textColor;
    if ([neighborhood isEqual:[Neighborhood currentLocation]]) {
        textColor = [UIColor blueColor];
    } else {
        textColor = [UIColor blackColor];
    }
    searchTextField.textColor = textColor;
}

+ (void)setSearchBarIcon:(UISearchBar *)searchBar {
    UIImage *image = [UIImage imageNamed:@"location-search-icon"];
    [searchBar setImage:image forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
}

#pragma mark - Phone number link

+ (void)makePhoneNumberLink:(UILabel *)label {
    if (label.text.length < 7) {
        return;
    }
    
    // underline
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @1};
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:label.text
                                                                  attributes:underlineAttribute];
    label.attributedText = attrStr;
    
    // color
    label.textColor = [Util colorFromHex:@"f26c4f"];
    
    [label sizeToFit];

    // allow user interaction
    label.userInteractionEnabled = YES;
    
    // show call prompt on click
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(promptToCall:)];
    [label addGestureRecognizer:tapGR];
}

+ (IBAction)promptToCall:(UITapGestureRecognizer *)tapGR {
    UILabel *label = (UILabel *)tapGR.view;
    NSString *phoneNumber = label.text;
    NSString *cleanNumber = [self cleanedPhoneNumber:phoneNumber];
    NSURL *tel = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@", cleanNumber]];
    [[UIApplication sharedApplication] openURL:tel];
}

+ (NSString *)cleanedPhoneNumber:(NSString *)phoneNumber {
    NSMutableString *strippedString = [NSMutableString stringWithCapacity:phoneNumber.length];
    
    NSScanner *scanner = [NSScanner scannerWithString:phoneNumber];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    while ([scanner isAtEnd] == NO) {
        NSString *buffer;
        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
            [strippedString appendString:buffer];
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    
    return strippedString;
}

#pragma mark - Round corners

+ (void)roundCorners:(UIView *)view radius:(float)radius {
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
}

+ (void)roundSelectCorners:(UIView *)view corners:(UIRectCorner)corners radius:(float)radius {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    
    view.layer.mask = maskLayer;
}

#pragma mark - Set border

+ (void)setBorder:(UIView *)view {
    [self setBorder:view width:1.0 color:[UIColor greenColor]];
}

+ (void)setBorder:(UIView *)view width:(float)width color:(UIColor *)color {
    view.layer.borderWidth = width;
    view.layer.borderColor = color.CGColor;
}

#pragma mark - Image with color

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    UIBezierPath *rPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
    [color setFill];
    [rPath fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
