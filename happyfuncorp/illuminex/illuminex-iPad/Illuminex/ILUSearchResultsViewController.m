//
//  ILUSearchResultsViewController.m
//  Illuminex
//
//  Created by Joe Gallo on 10/15/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUSearchResultsViewController.h"
#import "ILUSearchResultCollectionViewCell.h"
#import "ILUDetailsViewController.h"
#import "ILUItem.h"
#import "ILUSavedSearch.h"

@interface ILUSearchResultsViewController ()
    @property (weak, nonatomic) IBOutlet UILabel *searchResultsLabel;
    @property (weak, nonatomic) IBOutlet UIButton *saveSearchButton;
    @property (weak, nonatomic) IBOutlet UIButton *searchButton;

    @property (weak, nonatomic) IBOutlet UIView *searchFiltersView;
    @property (weak, nonatomic) IBOutlet UIView *searchFiltersContent1View;
    @property (weak, nonatomic) IBOutlet UIView *searchFiltersContent2View;

    // budget
    @property (weak, nonatomic) IBOutlet UILabel *budgetLabel;
    @property (weak, nonatomic) IBOutlet UILabel *minBudgetLabel;
    @property (weak, nonatomic) IBOutlet UILabel *maxBudgetLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *minBudgetSliderHandleImageView;
    @property (weak, nonatomic) IBOutlet UIImageView *maxBudgetSliderHandleImageView;
    @property (weak, nonatomic) IBOutlet UIView *budgetScaleTintRangeView;

    @property (nonatomic) float BUDGET_SCALE_MIN_X;
    @property (nonatomic) float BUDGET_SCALE_MAX_X;
    @property (nonatomic) float BUDGET_SCALE_MIN_VALUE;
    @property (nonatomic) float BUDGET_SCALE_MAX_VALUE;
    @property (nonatomic) float BUDGET_SCALE_UNIT_WIDTH;

    // shape
    @property (weak, nonatomic) IBOutlet UILabel *shapeLabel;
    @property (strong, nonatomic) NSDictionary *shapeLabelToButtons;
    @property (weak, nonatomic) IBOutlet UIButton *roundButton;
    @property (weak, nonatomic) IBOutlet UIButton *princessButton;
    @property (weak, nonatomic) IBOutlet UIButton *emeraldButton;
    @property (weak, nonatomic) IBOutlet UIButton *asscherButton;
    @property (weak, nonatomic) IBOutlet UIButton *ovalButton;
    @property (weak, nonatomic) IBOutlet UIButton *radiantButton;
    @property (weak, nonatomic) IBOutlet UIButton *pearButton;
    @property (weak, nonatomic) IBOutlet UIButton *heartButton;
    @property (weak, nonatomic) IBOutlet UIButton *marquiseButton;
    @property (weak, nonatomic) IBOutlet UIButton *cushionButton;

    // carat
    @property (weak, nonatomic) IBOutlet UILabel *caratLabel;
    @property (weak, nonatomic) IBOutlet UILabel *minCaratLabel;
    @property (weak, nonatomic) IBOutlet UILabel *maxCaratLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *minCaratSliderHandleImageView;
    @property (weak, nonatomic) IBOutlet UIImageView *maxCaratSliderHandleImageView;
    @property (weak, nonatomic) IBOutlet UIView *caratScaleTintRangeView;

    @property (nonatomic) float CARAT_SCALE_MIN_X;
    @property (nonatomic) float CARAT_SCALE_MAX_X;
    @property (nonatomic) float CARAT_SCALE_UNIT_WIDTH;
    @property (nonatomic) float CARAT_SCALE_MIN_VALUE;
    @property (nonatomic) float CARAT_SCALE_MAX_VALUE;

    // clarity
    @property (weak, nonatomic) IBOutlet UILabel *clarityLabel;
    @property (strong, nonatomic) NSDictionary *clarityLabelToButtons;
    @property (weak, nonatomic) IBOutlet UIButton *ifButton;
    @property (weak, nonatomic) IBOutlet UIButton *vvs1Button;
    @property (weak, nonatomic) IBOutlet UIButton *vvs2Button;
    @property (weak, nonatomic) IBOutlet UIButton *vs1Button;
    @property (weak, nonatomic) IBOutlet UIButton *vs2Button;
    @property (weak, nonatomic) IBOutlet UIButton *si1Button;
    @property (weak, nonatomic) IBOutlet UIButton *si2Button;
    @property (weak, nonatomic) IBOutlet UIButton *i1Button;

    @property (weak, nonatomic) IBOutlet UILabel *colorLabel;

    // simple color
    @property (weak, nonatomic) IBOutlet UIView *simpleColorView;

    @property (weak, nonatomic) IBOutlet UILabel *colorMinLabel;
    @property (weak, nonatomic) IBOutlet UILabel *colorMaxLabel;

    @property (weak, nonatomic) IBOutlet UIButton *dButton;
    @property (weak, nonatomic) IBOutlet UIButton *eButton;
    @property (weak, nonatomic) IBOutlet UIButton *fButton;
    @property (weak, nonatomic) IBOutlet UIButton *gButton;
    @property (weak, nonatomic) IBOutlet UIButton *hButton;
    @property (weak, nonatomic) IBOutlet UIButton *iButton;
    @property (weak, nonatomic) IBOutlet UIButton *jButton;
    @property (weak, nonatomic) IBOutlet UIButton *kButton;

    @property (strong, nonatomic) NSArray *colorScaleButtons;
    @property (strong, nonatomic) NSArray *colorScalePositions;

    @property (weak, nonatomic) IBOutlet UIImageView *minColorSliderHandleImageView;
    @property (weak, nonatomic) IBOutlet UIImageView *maxColorSliderHandleImageView;

    @property (nonatomic) float COLOR_SCALE_MIN_X;
    @property (nonatomic) float COLOR_SCALE_MAX_X;
    @property (nonatomic) float COLOR_SCALE_UNIT_WIDTH;

    // fancy color
    @property (weak, nonatomic) IBOutlet UIView *fancyColorView;

    @property (strong, nonatomic) NSArray *fancyColor1Buttons;
    @property (strong, nonatomic) NSDictionary *fancyColor1LabelToButtons;
    @property (weak, nonatomic) IBOutlet UIButton *yellowButton;
    @property (weak, nonatomic) IBOutlet UIButton *pinkButton;
    @property (weak, nonatomic) IBOutlet UIButton *blueButton;
    @property (weak, nonatomic) IBOutlet UIButton *greenButton;
    @property (weak, nonatomic) IBOutlet UIButton *orangeButton;
    @property (weak, nonatomic) IBOutlet UIButton *brownButton;

    @property (strong, nonatomic) NSArray *fancyColor2Buttons;
    @property (strong, nonatomic) NSDictionary *fancyColor2LabelToButtons;
    @property (weak, nonatomic) IBOutlet UIButton *fancyLightButton;
    @property (weak, nonatomic) IBOutlet UIButton *fancyButton;
    @property (weak, nonatomic) IBOutlet UIButton *fancyIntenseButton;
    @property (weak, nonatomic) IBOutlet UIButton *fancyVividButton;

    @property (weak, nonatomic) IBOutlet UIButton *simpleColorButton;
    @property (weak, nonatomic) IBOutlet UIButton *fancyColorButton;

    @property (weak, nonatomic) IBOutlet UIButton *moreButton;

    @property (weak, nonatomic) IBOutlet UIButton *lessButton;

    // polish/symetry/cut grade
    @property (weak, nonatomic) IBOutlet UIButton *polishButton;
    @property (weak, nonatomic) IBOutlet UIButton *symmetryButton;
    @property (weak, nonatomic) IBOutlet UIButton *cutGradeButton;

    @property (weak, nonatomic) IBOutlet UIView *polishView;
    @property (strong, nonatomic) NSDictionary *polishLabelToButtons;
    @property (weak, nonatomic) IBOutlet UIButton *polishGoodButton;
    @property (weak, nonatomic) IBOutlet UIButton *polishVeryGoodButton;
    @property (weak, nonatomic) IBOutlet UIButton *polishExcellentButton;

    @property (weak, nonatomic) IBOutlet UIView *symmetryView;
    @property (strong, nonatomic) NSDictionary *symmetryLabelToButtons;
    @property (weak, nonatomic) IBOutlet UIButton *symmetryGoodButton;
    @property (weak, nonatomic) IBOutlet UIButton *symmetryVeryGoodButton;
    @property (weak, nonatomic) IBOutlet UIButton *symmetryExcellentButton;

    @property (weak, nonatomic) IBOutlet UIView *cutGradeView;
    @property (strong, nonatomic) NSDictionary *cutGradeLabelToButtons;
    @property (weak, nonatomic) IBOutlet UIButton *cutGradeGoodButton;
    @property (weak, nonatomic) IBOutlet UIButton *cutGradeVeryGoodButton;
    @property (weak, nonatomic) IBOutlet UIButton *cutGradeExcellentButton;

    // fluorescence
    @property (weak, nonatomic) IBOutlet UILabel *fluorescenceLabel;
    @property (strong, nonatomic) NSDictionary *fluorescenceLabelToButtons;
    @property (weak, nonatomic) IBOutlet UIButton *noneButton;
    @property (weak, nonatomic) IBOutlet UIButton *faintButton;
    @property (weak, nonatomic) IBOutlet UIButton *mediumButton;
    @property (weak, nonatomic) IBOutlet UIButton *strongButton;

    // depth
    @property (weak, nonatomic) IBOutlet UILabel *depthLabel;
    @property (weak, nonatomic) IBOutlet UILabel *minDepthLabel;
    @property (weak, nonatomic) IBOutlet UILabel *maxDepthLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *minDepthSliderHandleImageView;
    @property (weak, nonatomic) IBOutlet UIImageView *maxDepthSliderHandleImageView;
    @property (weak, nonatomic) IBOutlet UIView *depthScaleTintRangeView;

    @property (nonatomic) float DEPTH_SCALE_MIN_X;
    @property (nonatomic) float DEPTH_SCALE_MAX_X;
    @property (nonatomic) float DEPTH_SCALE_UNIT_WIDTH;
    @property (nonatomic) float DEPTH_SCALE_MIN_VALUE;
    @property (nonatomic) float DEPTH_SCALE_MAX_VALUE;

    // lab
    @property (weak, nonatomic) IBOutlet UILabel *labLabel;
    @property (strong, nonatomic) NSDictionary *labLabelToButtons;
    @property (weak, nonatomic) IBOutlet UIButton *giaButton;
    @property (weak, nonatomic) IBOutlet UIButton *agsButton;
    @property (weak, nonatomic) IBOutlet UIButton *igiButton;

    // table
    @property (weak, nonatomic) IBOutlet UILabel *tableLabel;
    @property (weak, nonatomic) IBOutlet UILabel *minTableLabel;
    @property (weak, nonatomic) IBOutlet UILabel *maxTableLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *minTableSliderHandleImageView;
    @property (weak, nonatomic) IBOutlet UIImageView *maxTableSliderHandleImageView;
    @property (weak, nonatomic) IBOutlet UIView *tableScaleTintRangeView;

    @property (nonatomic) float TABLE_SCALE_MIN_X;
    @property (nonatomic) float TABLE_SCALE_MAX_X;
    @property (nonatomic) float TABLE_SCALE_UNIT_WIDTH;
    @property (nonatomic) float TABLE_SCALE_MIN_VALUE;
    @property (nonatomic) float TABLE_SCALE_MAX_VALUE;

    @property (strong, nonatomic) NSMutableArray *searchResults;
    @property (weak, nonatomic) IBOutlet UICollectionView *searchResultsCollectionView;

    @property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@end

@implementation ILUSearchResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIPanGestureRecognizer *panGR;
    
    // search label
    self.searchResultsLabel.font = [UIFont fontWithName:@"PlayfairDisplay-BoldItalic" size:25];
    self.searchResultsLabel.textColor = [UIColor whiteColor];
    
    // save search button
    [ILUCustomStyler styleButton:self.saveSearchButton];
    
    // new search button
    [ILUCustomStyler styleButton:self.searchButton];
    
    // search filters view
    self.searchFiltersContent1View.hidden = NO;
    self.searchFiltersContent2View.hidden = YES;
    
    // budget
    self.budgetLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:16];
    self.budgetLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.minBudgetLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:10];
    self.minBudgetLabel.textColor = [UIColor whiteColor];
    
    self.maxBudgetLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:10];
    self.maxBudgetLabel.textColor = [UIColor whiteColor];
    
    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateBudgetScale:)];
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.minBudgetSliderHandleImageView addGestureRecognizer:panGR];
    
    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateBudgetScale:)];
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.maxBudgetSliderHandleImageView addGestureRecognizer:panGR];
    
    self.budgetScaleTintRangeView.backgroundColor = [ILUUtil colorFromHex:@"9f90da"];
    self.budgetScaleTintRangeView.alpha = 0.5;
    
    self.BUDGET_SCALE_MIN_X = 86;
    self.BUDGET_SCALE_MAX_X = 490;
    self.BUDGET_SCALE_MIN_VALUE = 0;
    self.BUDGET_SCALE_MAX_VALUE = 1000000;
    self.BUDGET_SCALE_UNIT_WIDTH = 6.87;
    
    self.minBudgetSliderHandleImageView.center = CGPointMake(self.BUDGET_SCALE_MIN_X, 54.5);
    self.maxBudgetSliderHandleImageView.center = CGPointMake(self.BUDGET_SCALE_MAX_X, 54.5);
    
    [self updateBudgetLabels];
    
    // shape
    self.shapeLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:16];
    self.shapeLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.shapeLabelToButtons = @{
                                 @"Round": self.roundButton,
                                 @"Princess": self.princessButton,
                                 @"Emerald": self.emeraldButton,
                                 @"Asscher": self.asscherButton,
                                 @"Oval": self.ovalButton,
                                 @"Radiant": self.radiantButton,
                                 @"Pear": self.pearButton,
                                 @"Heart": self.heartButton,
                                 @"Marquise": self.marquiseButton,
                                 @"Cushion": self.cushionButton
                                 };
    
    [ILUCustomStyler adjustButton:self.roundButton];
    [ILUCustomStyler adjustButton:self.princessButton];
    [ILUCustomStyler adjustButton:self.emeraldButton];
    [ILUCustomStyler adjustButton:self.asscherButton];
    [ILUCustomStyler adjustButton:self.ovalButton];
    [ILUCustomStyler adjustButton:self.radiantButton];
    [ILUCustomStyler adjustButton:self.pearButton];
    [ILUCustomStyler adjustButton:self.heartButton];
    [ILUCustomStyler adjustButton:self.marquiseButton];
    [ILUCustomStyler adjustButton:self.cushionButton];
    
    // carat
    self.caratLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:16];
    self.caratLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.minCaratLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:10];
    self.minCaratLabel.textColor = [UIColor whiteColor];
    
    self.maxCaratLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:10];
    self.maxCaratLabel.textColor = [UIColor whiteColor];
    
    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateCaratScale:)];
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.minCaratSliderHandleImageView addGestureRecognizer:panGR];
    
    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateCaratScale:)];
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.maxCaratSliderHandleImageView addGestureRecognizer:panGR];
    
    self.caratScaleTintRangeView.backgroundColor = [ILUUtil colorFromHex:@"9f90da"];
    self.caratScaleTintRangeView.alpha = 0.5;
    
    self.CARAT_SCALE_MIN_X = 86;
    self.CARAT_SCALE_MAX_X = 490;
    self.CARAT_SCALE_UNIT_WIDTH = 6.87;
    self.CARAT_SCALE_MIN_VALUE = 0.25;
    self.CARAT_SCALE_MAX_VALUE = 15;
    
    self.minCaratSliderHandleImageView.center = CGPointMake(self.CARAT_SCALE_MIN_X, 184.5);
    self.maxCaratSliderHandleImageView.center = CGPointMake(self.CARAT_SCALE_MAX_X, 184.5);
    
    [self updateCaratLabels];
    
    // clarity
    self.clarityLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:16];
    self.clarityLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.clarityLabelToButtons = @{
                                   @"IF": self.ifButton,
                                   @"VVS1": self.vvs1Button,
                                   @"VVS2": self.vvs2Button,
                                   @"VS1": self.vs1Button,
                                   @"VS2": self.vs2Button,
                                   @"SI1": self.si1Button,
                                   @"SI2": self.si2Button,
                                   @"I1": self.i1Button
                                   };
    
    [ILUCustomStyler styleSmallToggleButton:self.ifButton side:@"left" fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.vvs1Button side:nil fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.vvs2Button side:nil fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.vs1Button side:nil fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.vs2Button side:nil fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.si1Button side:nil fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.si2Button side:nil fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.i1Button side:@"right" fontSize:12];
    
    // color
    self.colorLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:16];
    self.colorLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    // simple color
    self.colorMinLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:10];
    self.colorMinLabel.textColor = [UIColor whiteColor];
    
    self.colorMaxLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:10];
    self.colorMaxLabel.textColor = [UIColor whiteColor];
    
    [ILUCustomStyler styleSmallToggleButton:self.dButton side:@"left" fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.eButton side:nil fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.fButton side:nil fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.gButton side:nil fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.hButton side:nil fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.iButton side:nil fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.jButton side:nil fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.kButton side:@"right" fontSize:12];

    self.colorScaleButtons = @[
                               self.dButton,
                               self.eButton,
                               self.fButton,
                               self.gButton,
                               self.hButton,
                               self.iButton,
                               self.jButton,
                               self.kButton];
    self.colorScalePositions = @[@17, @67, @117, @167, @217, @267, @317, @367, @417];

    for (UIButton *button in self.colorScaleButtons) {
        button.selected = YES;
    }

    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateColorScale:)];
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.minColorSliderHandleImageView addGestureRecognizer:panGR];
    
    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateColorScale:)];
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.maxColorSliderHandleImageView addGestureRecognizer:panGR];
    
    // adjust color slider handles so they match color scale positions exactly
    self.minColorSliderHandleImageView.center = CGPointMake(17, 44);
    self.maxColorSliderHandleImageView.center = CGPointMake(417, 44);

    self.COLOR_SCALE_MIN_X = [[self.colorScalePositions firstObject] intValue];
    self.COLOR_SCALE_MAX_X = [[self.colorScalePositions lastObject] intValue];
    self.COLOR_SCALE_UNIT_WIDTH = 50;
    
    // fancy color
    
    self.fancyColor1Buttons = @[self.yellowButton,
                                self.pinkButton,
                                self.blueButton,
                                self.greenButton,
                                self.orangeButton,
                                self.brownButton];
    
    self.fancyColor1LabelToButtons = @{
                                       @"Yellow": self.yellowButton,
                                       @"Pink": self.pinkButton,
                                       @"Blue": self.blueButton,
                                       @"Green": self.greenButton,
                                       @"Orange": self.orangeButton,
                                       @"Brown": self.brownButton
                                       };
    
    [ILUCustomStyler adjustButton:self.yellowButton];
    [ILUCustomStyler adjustButton:self.pinkButton];
    [ILUCustomStyler adjustButton:self.blueButton];
    [ILUCustomStyler adjustButton:self.greenButton];
    [ILUCustomStyler adjustButton:self.orangeButton];
    [ILUCustomStyler adjustButton:self.brownButton];
    
    self.fancyColor2Buttons = @[self.fancyLightButton,
                                self.fancyButton,
                                self.fancyIntenseButton,
                                self.fancyVividButton];

    self.fancyColor2LabelToButtons = @{
                                       @"Fancy Light": self.fancyLightButton,
                                       @"Fancy": self.fancyButton,
                                       @"Fancy Intense": self.fancyIntenseButton,
                                       @"Fancy Vivid": self.fancyVividButton
                                       };
    
    [ILUCustomStyler styleSmallToggleButton:self.fancyLightButton side:@"left" fontSize:9];
    [ILUCustomStyler styleSmallToggleButton:self.fancyButton side:nil fontSize:9];
    [ILUCustomStyler styleSmallToggleButton:self.fancyIntenseButton side:nil fontSize:9];
    [ILUCustomStyler styleSmallToggleButton:self.fancyVividButton side:@"right" fontSize:9];
    
    [ILUCustomStyler styleSmallButton:self.simpleColorButton];
    [ILUCustomStyler styleSmallButton:self.fancyColorButton];
    
    [self selectColorTypeView:self.simpleColorButton];
    
    // more button
    [ILUCustomStyler styleButton:self.moreButton];
    
    // less button
    [ILUCustomStyler styleButton:self.lessButton];
    
    // polish/symmetry/cut grade
    [ILUCustomStyler styleSmallButton:self.polishButton];
    [ILUCustomStyler styleSmallButton:self.symmetryButton];
    [ILUCustomStyler styleSmallButton:self.cutGradeButton];
    
    [self selectPolSymView:self.polishButton];
    
    self.polishLabelToButtons = @{
                                  @"Good": self.polishGoodButton,
                                  @"Very Good": self.polishVeryGoodButton,
                                  @"Excellent": self.polishExcellentButton
                                  };
    
    [ILUCustomStyler styleSmallToggleButton:self.polishGoodButton side:@"left" fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.polishVeryGoodButton side:nil fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.polishExcellentButton side:@"right" fontSize:12];
    
    self.symmetryLabelToButtons = @{
                                    @"Good": self.symmetryGoodButton,
                                    @"Very Good": self.symmetryVeryGoodButton,
                                    @"Excellent": self.symmetryExcellentButton
                                  };
    
    [ILUCustomStyler styleSmallToggleButton:self.symmetryGoodButton side:@"left" fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.symmetryVeryGoodButton side:nil fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.symmetryExcellentButton side:@"right" fontSize:12];
    
    self.cutGradeLabelToButtons = @{
                                    @"Good": self.cutGradeGoodButton,
                                    @"Very Good": self.cutGradeVeryGoodButton,
                                    @"Excellent": self.cutGradeExcellentButton
                                    };
    
    [ILUCustomStyler styleSmallToggleButton:self.cutGradeGoodButton side:@"left" fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.cutGradeVeryGoodButton side:nil fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.cutGradeExcellentButton side:@"right" fontSize:12];
    
    // fluorescence
    self.fluorescenceLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:16];
    self.fluorescenceLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.fluorescenceLabelToButtons = @{
                                        @"None": self.noneButton,
                                        @"Faint": self.faintButton,
                                        @"Medium": self.mediumButton,
                                        @"Strong": self.strongButton
                                        };
    
    [ILUCustomStyler styleSmallToggleButton:self.noneButton side:@"left" fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.faintButton side:nil fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.mediumButton side:nil fontSize:12];
    [ILUCustomStyler styleSmallToggleButton:self.strongButton side:@"right" fontSize:12];
    
    // depth
    self.depthLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:16];
    self.depthLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.minDepthLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:10];
    self.minDepthLabel.textColor = [UIColor whiteColor];
    
    self.maxDepthLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:10];
    self.maxDepthLabel.textColor = [UIColor whiteColor];
    
    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateDepthScale:)];
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.minDepthSliderHandleImageView addGestureRecognizer:panGR];
    
    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateDepthScale:)];
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.maxDepthSliderHandleImageView addGestureRecognizer:panGR];
    
    self.depthScaleTintRangeView.backgroundColor = [ILUUtil colorFromHex:@"9f90da"];
    self.depthScaleTintRangeView.alpha = 0.5;
    
    self.DEPTH_SCALE_MIN_X = 600;
    self.DEPTH_SCALE_MAX_X = 1004;
    self.DEPTH_SCALE_UNIT_WIDTH = 6.38;
    self.DEPTH_SCALE_MIN_VALUE = 45;
    self.DEPTH_SCALE_MAX_VALUE = 80;
    
    self.minDepthSliderHandleImageView.center = CGPointMake(self.DEPTH_SCALE_MIN_X, 53.5);
    self.maxDepthSliderHandleImageView.center = CGPointMake(self.DEPTH_SCALE_MAX_X, 53.5);
    
    [self updateDepthLabels];
    
    // lab
    self.labLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:16];
    self.labLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.labLabelToButtons = @{
                               @"GIA": self.giaButton,
                               @"AGS": self.agsButton,
                               @"IGI": self.igiButton
                               };
    
    [ILUCustomStyler adjustButton:self.giaButton];
    [ILUCustomStyler adjustButton:self.agsButton];
    [ILUCustomStyler adjustButton:self.igiButton];

    // table
    self.tableLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:16];
    self.tableLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.minTableLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:10];
    self.minTableLabel.textColor = [UIColor whiteColor];
    
    self.maxTableLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:10];
    self.maxTableLabel.textColor = [UIColor whiteColor];
    
    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateTableScale:)];
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.minTableSliderHandleImageView addGestureRecognizer:panGR];
    
    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateTableScale:)];
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.maxTableSliderHandleImageView addGestureRecognizer:panGR];
    
    self.tableScaleTintRangeView.backgroundColor = [ILUUtil colorFromHex:@"9f90da"];
    self.tableScaleTintRangeView.alpha = 0.5;
    
    self.TABLE_SCALE_MIN_X = 600;
    self.TABLE_SCALE_MAX_X = 1004;
    self.TABLE_SCALE_UNIT_WIDTH = 6.38;
    self.TABLE_SCALE_MIN_VALUE = 45;
    self.TABLE_SCALE_MAX_VALUE = 80;
    
    self.minTableSliderHandleImageView.center = CGPointMake(self.TABLE_SCALE_MIN_X, 183.5);
    self.maxTableSliderHandleImageView.center = CGPointMake(self.TABLE_SCALE_MAX_X, 183.5);
    
    [self updateTableLabels];
    
    // sync widgets to search params
    [self syncWidgetsToSearchParams];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSearchResults];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)syncWidgetsToSearchParams {
    // budget
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSString *minBudgetLabelText = [numberFormatter stringFromNumber:self.searchParams.minBudget];
    minBudgetLabelText = [NSString stringWithFormat:@"$%@", minBudgetLabelText];
    self.minBudgetLabel.text = minBudgetLabelText;
//    self.minBudgetLabel.text = @"$50,000";
    
    NSString *maxBudgetLabelText = [numberFormatter stringFromNumber:self.searchParams.maxBudget];
    maxBudgetLabelText = [NSString stringWithFormat:@"$%@", maxBudgetLabelText];
    self.maxBudgetLabel.text = maxBudgetLabelText;
//    self.maxBudgetLabel.text = @"$930,000";
    
    [self updateBudgetSliders:nil];
    
    // shape
    for (NSString *shapeLabel in self.searchParams.shapes) {
        UIButton *shapeButton = (UIButton *)self.shapeLabelToButtons[shapeLabel];
        shapeButton.selected = YES;
    }
    
    // carat
    self.minCaratLabel.text = [NSString stringWithFormat:@"%.02fct.", self.searchParams.minCarat];
    self.maxCaratLabel.text = [NSString stringWithFormat:@"%.02fct.", self.searchParams.maxCarat];
    [self updateCaratSliders:nil];
    
    // clarity
    for (NSString *clarityLabel in self.searchParams.clarities) {
        UIButton *clarityButton = (UIButton *)self.clarityLabelToButtons[clarityLabel];
        clarityButton.selected = YES;
    }
    
    // color
    if (self.searchParams.simpleColors.count > 0) {
        self.colorMinLabel.text = self.searchParams.simpleColors.firstObject;
        self.colorMaxLabel.text = self.searchParams.simpleColors.lastObject;
        [self updateSimpleColorSliders:nil];
    }
    
    for (NSString *fancyColor1Label in self.searchParams.fancyColors1) {
        UIButton *fancyColor1Button = (UIButton *)self.fancyColor1LabelToButtons[fancyColor1Label];
        fancyColor1Button.selected = YES;
    }
    
    for (NSString *fancyColor2Label in self.searchParams.fancyColors2) {
        UIButton *fancyColor2Button = (UIButton *)self.fancyColor2LabelToButtons[fancyColor2Label];
        fancyColor2Button.selected = YES;
    }
    
    // polish
    for (NSString *polishLabel in self.searchParams.polishes) {
        UIButton *polishButton = (UIButton *)self.polishLabelToButtons[polishLabel];
        polishButton.selected = YES;
    }
    
    // symmetry
    for (NSString *symmetryLabel in self.searchParams.symmetries) {
        UIButton *symmetryButton = (UIButton *)self.symmetryLabelToButtons[symmetryLabel];
        symmetryButton.selected = YES;
    }
    
    // cut grade
    for (NSString *cutGradeLabel in self.searchParams.cutGrades) {
        UIButton *cutGradeButton = (UIButton *)self.cutGradeLabelToButtons[cutGradeLabel];
        cutGradeButton.selected = YES;
    }
    
    // fluorescence
    for (NSString *fluorescenceLabel in self.searchParams.fluorescences) {
        UIButton *fluorescenceButton = (UIButton *)self.fluorescenceLabelToButtons[fluorescenceLabel];
        fluorescenceButton.selected = YES;
    }
    
    // depth
    self.minDepthLabel.text = [NSString stringWithFormat:@"%d%%", self.searchParams.minDepth];
    self.maxDepthLabel.text = [NSString stringWithFormat:@"%d%%", self.searchParams.maxDepth];
    [self updateDepthSliders:nil];
    
    // lab
    for (NSString *labLabel in self.searchParams.labs) {
        UIButton *labButton = (UIButton *)self.labLabelToButtons[labLabel];
        labButton.selected = YES;
    }
    
    // table
    self.minTableLabel.text = [NSString stringWithFormat:@"%d%%", self.searchParams.minTable];
    self.maxTableLabel.text = [NSString stringWithFormat:@"%d%%", self.searchParams.maxTable];
    [self updateTableSliders:nil];
}

- (void)updateSearchResults {
    self.searchResultsCollectionView.hidden = YES;
    self.activityIndicatorView.hidden = NO;
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/rapaport/search_diamonds", SITE_DOMAIN, API_PATH];
    NSDictionary *parameters = [self createRapaportSearchParams];
    [appDelegate.requestManager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
//        DDLogInfo(@"%@", JSON);
        
        self.searchResults = [[NSMutableArray alloc] init];
        
        NSArray *searchResults = JSON[@"response"][@"body"][@"diamonds"];
        for (NSDictionary *searchResult in searchResults) {
            ILUItem *item = [[ILUItem alloc] init];
            [item import:searchResult];
            [self.searchResults addObject:item];
        }
        self.activityIndicatorView.hidden = YES;
        [self.searchResultsCollectionView reloadData];
        self.searchResultsCollectionView.hidden = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"%@ %@", error, operation.responseString);
    }];
}

- (NSMutableDictionary *)createRapaportSearchParams {
//    DDLogInfo(@"%@", self.searchParams);
    
    NSString *searchType = @"White";
    if (self.searchParams.fancyColors1.count > 0 || self.searchParams.fancyColors2.count > 0) {
        searchType = @"Fancy";
    }
    
    NSMutableDictionary *params = [@{
                                     @"rapaport[search_type]": searchType,
                                     @"rapaport[size_from]": [NSNumber numberWithFloat:self.searchParams.minCarat],
                                     @"rapaport[size_to]": [NSNumber numberWithFloat:self.searchParams.maxCarat],
                                     @"rapaport[color_from]": self.searchParams.simpleColors.firstObject,
                                     @"rapaport[color_to]": self.searchParams.simpleColors.lastObject,
                                     @"rapaport[price_total_from]": self.searchParams.minBudget,
                                     @"rapaport[price_total_to]": self.searchParams.maxBudget,
                                     @"rapaport[depth_percent_from]": [NSNumber numberWithInt:self.searchParams.minDepth],
                                     @"rapaport[depth_percent_to]": [NSNumber numberWithInt:self.searchParams.maxDepth],
                                     @"rapaport[table_percent_from]": [NSNumber numberWithInt:self.searchParams.minTable],
                                     @"rapaport[table_percent_to]": [NSNumber numberWithInt:self.searchParams.maxTable],
                                     @"rapaport[page_number]": @"1",
                                     @"rapaport[page_size]": @"50",
//                                     @"rapaport[sort_by]": @"Price",
//                                     @"rapaport[sort_direction]": @"Desc"
                                    } mutableCopy];
    
    if (self.searchParams.shapes.count > 0) {
        params[@"rapaport[shapes]"] = self.searchParams.shapes;
    }
    
    if (self.searchParams.fancyColors1.count > 0) {
        params[@"rapaport[fancy_colors]"] = self.searchParams.fancyColors1;
    }
    
    if (self.searchParams.fancyColors2.count > 0) {
        params[@"rapaport[fancy_color_intensity_from]"] = self.searchParams.fancyColors2.firstObject;
        params[@"rapaport[fancy_color_intensity_to]"] = self.searchParams.fancyColors2.lastObject;
    }
    
    if (self.searchParams.clarities.count > 0) {
        params[@"rapaport[clarity_from]"] = self.searchParams.clarities.firstObject;
        params[@"rapaport[clarity_to]"] = self.searchParams.clarities.lastObject;
    }
    
    if (self.searchParams.cutGrades.count > 0) {
        params[@"rapaport[cut_from]"] = self.searchParams.cutGrades.firstObject;
        params[@"rapaport[cut_to]"] = self.searchParams.cutGrades.lastObject;
    }
    
    if (self.searchParams.polishes.count > 0) {
        params[@"rapaport[polish_from]"] = self.searchParams.polishes.firstObject;
        params[@"rapaport[polish_to]"] = self.searchParams.polishes.lastObject;
    }
    
    if (self.searchParams.symmetries.count > 0) {
        params[@"rapaport[symmetry_from]"] = self.searchParams.symmetries.firstObject;
        params[@"rapaport[symmetry_to]"] = self.searchParams.symmetries.lastObject;
    }
    
    if (self.searchParams.labs.count > 0) {
        params[@"rapaport[labs]"] = self.searchParams.labs;
    }
    
    NSMutableArray *adjustedFluorescences = [self.searchParams.fluorescences mutableCopy];
    [adjustedFluorescences removeObject:@"None"];
    if (adjustedFluorescences.count > 0) {
        params[@"rapaport[fluorescence_intensities]"] = adjustedFluorescences;
    }
    
    return params;
}

#pragma mark - Open flyout menu

- (IBAction)openFlyoutMenu:(id)sender {
    [appDelegate.viewDeckController toggleLeftView];
}

#pragma mark - Save search

- (IBAction)saveSearch:(id)sender {
    // save search
    ILUSavedSearch *savedSearch = [[ILUSavedSearch alloc] initWithSearchParams:self.searchParams];
    
    NSMutableArray *savedSearches = (NSMutableArray *)[appDelegate objectForKey:@"savedSearches"];
    if (!savedSearches) {
        savedSearches = [[NSMutableArray alloc] init];
    }
    [savedSearches addObject:savedSearch];
    [appDelegate saveObject:savedSearches forKey:@"savedSearches"];
    
    // go to saved searches page
    UIViewController *savedSearchesVC = [storyboard instantiateViewControllerWithIdentifier:@"SavedSearches"];
    appDelegate.viewDeckController.centerController = savedSearchesVC;
}

#pragma mark - New search

- (IBAction)newSearch:(id)sender {
    [self updateSearchResults];
}

#pragma mark - Budget scale

- (IBAction)updateBudgetScale:(id)sender {
    UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *)sender;
    CGPoint translation = [panGR translationInView:panGR.view.superview];
    
    float newX = panGR.view.center.x + translation.x;
    newX = MAX(self.BUDGET_SCALE_MIN_X, newX); // min mark
    newX = MIN(newX, self.BUDGET_SCALE_MAX_X); // max mark
    
    // keep min <= max
    if (panGR.view == self.minBudgetSliderHandleImageView) {
        newX = MIN(newX, self.maxBudgetSliderHandleImageView.center.x);
    } else {
        newX = MAX(self.minBudgetSliderHandleImageView.center.x, newX);
    }
    
    panGR.view.center = CGPointMake(newX, panGR.view.center.y);
    [panGR setTranslation:CGPointMake(0, 0) inView:panGR.view.superview];
    
    //    DDLogInfo(@"%f", newX);
    
    // snap to tick mark on release
//    if (panGR.state == UIGestureRecognizerStateEnded) {
//        float snapX = self.BUDGET_SCALE_MIN_X + roundf((panGR.view.center.x - self.BUDGET_SCALE_MIN_X) / self.BUDGET_SCALE_UNIT_WIDTH) * self.BUDGET_SCALE_UNIT_WIDTH;
//        panGR.view.center = CGPointMake(snapX, panGR.view.center.y);
//        [panGR setTranslation:CGPointMake(0, 0) inView:panGR.view.superview];
//        //        DDLogInfo(@"%f %f", newX, snapX);
//    }
    
    [self updateBudgetLabels];
}

- (void)updateBudgetLabels {
    float BUDGET_SCALE_UNIT_AMOUNT = 16949.152542;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    // min
    float minNumberOfUnits = (self.minBudgetSliderHandleImageView.center.x - self.BUDGET_SCALE_MIN_X)
                              / self.BUDGET_SCALE_UNIT_WIDTH;
    float newMinValue = minNumberOfUnits * BUDGET_SCALE_UNIT_AMOUNT;
    
    NSString *formattedNewMinValue = [NSString stringWithFormat:@"%d", (int)newMinValue];
    formattedNewMinValue = [numberFormatter stringFromNumber:[NSNumber numberWithInt:(int)newMinValue]];
    self.minBudgetLabel.text = [NSString stringWithFormat:@"$%@", formattedNewMinValue];
    
    // max
    float maxNumberOfUnits = (self.maxBudgetSliderHandleImageView.center.x - self.BUDGET_SCALE_MIN_X)
                              / self.BUDGET_SCALE_UNIT_WIDTH;
    float newMaxValue = maxNumberOfUnits * BUDGET_SCALE_UNIT_AMOUNT;
    
    NSString *formattedNewMaxValue = [NSString stringWithFormat:@"$%d", (int)newMaxValue];
    formattedNewMaxValue = [numberFormatter stringFromNumber:[NSNumber numberWithInt:(int)newMaxValue]];
    self.maxBudgetLabel.text = [NSString stringWithFormat:@"$%@", formattedNewMaxValue];
    
    [self updateBudgetScaleTintRange];
}

- (IBAction)updateBudgetSliders:(id)sender {
    float unitWidthPct = self.BUDGET_SCALE_UNIT_WIDTH / (self.BUDGET_SCALE_MAX_X - self.BUDGET_SCALE_MIN_X);
    float unitValue = (self.BUDGET_SCALE_MAX_VALUE - self.BUDGET_SCALE_MIN_VALUE) * unitWidthPct;
    
    // min
    NSString *minBudgetText = self.minBudgetLabel.text;
    minBudgetText = [minBudgetText substringWithRange:NSMakeRange(1, minBudgetText.length-1)];
    minBudgetText = [minBudgetText stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    int minBudgetVal = [minBudgetText intValue];
    float minNumUnits = (minBudgetVal - self.BUDGET_SCALE_MIN_VALUE) / unitValue;
    float minScaleX = self.BUDGET_SCALE_MIN_X + self.BUDGET_SCALE_UNIT_WIDTH * minNumUnits;
    
    self.minBudgetSliderHandleImageView.center = CGPointMake(minScaleX, self.minBudgetSliderHandleImageView.center.y);

    // max
    NSString *maxBudgetText = self.maxBudgetLabel.text;
    maxBudgetText = [maxBudgetText substringWithRange:NSMakeRange(1, maxBudgetText.length-1)];
    maxBudgetText = [maxBudgetText stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    int maxBudgetVal = [maxBudgetText intValue];
    float maxNumUnits = (maxBudgetVal - self.BUDGET_SCALE_MIN_VALUE) / unitValue;
    float maxScaleX = self.BUDGET_SCALE_MIN_X + self.BUDGET_SCALE_UNIT_WIDTH * maxNumUnits;
    self.maxBudgetSliderHandleImageView.center = CGPointMake(maxScaleX, self.maxBudgetSliderHandleImageView.center.y);

    [self updateBudgetScaleTintRange];
}

- (void)updateBudgetScaleTintRange {
    float x = self.minBudgetSliderHandleImageView.center.x;
    float y = self.budgetScaleTintRangeView.frame.origin.y;
    float width = self.maxBudgetSliderHandleImageView.center.x - self.minBudgetSliderHandleImageView.center.x;
    float height = self.budgetScaleTintRangeView.frame.size.height;
    
    self.budgetScaleTintRangeView.frame = CGRectMake(x, y, width, height);
}

#pragma mark - Select shape

- (IBAction)selectShape:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
}

#pragma mark - Carat scale

- (IBAction)updateCaratScale:(id)sender {
    UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *)sender;
    CGPoint translation = [panGR translationInView:panGR.view.superview];
    
    float newX = panGR.view.center.x + translation.x;
    newX = MAX(self.CARAT_SCALE_MIN_X, newX); // min mark
    newX = MIN(newX, self.CARAT_SCALE_MAX_X); // max mark
    
    // keep min <= max
    if (panGR.view == self.minCaratSliderHandleImageView) {
        newX = MIN(newX, self.maxCaratSliderHandleImageView.center.x);
    } else {
        newX = MAX(self.minCaratSliderHandleImageView.center.x, newX);
    }
    
    panGR.view.center = CGPointMake(newX, panGR.view.center.y);
    [panGR setTranslation:CGPointMake(0, 0) inView:panGR.view.superview];
    
//    DDLogInfo(@"%f", newX);
    
    // snap to tick mark on release
    if (panGR.state == UIGestureRecognizerStateEnded) {
        float snapX = self.CARAT_SCALE_MIN_X + roundf((panGR.view.center.x - self.CARAT_SCALE_MIN_X) / self.CARAT_SCALE_UNIT_WIDTH) * self.CARAT_SCALE_UNIT_WIDTH;
        panGR.view.center = CGPointMake(snapX, panGR.view.center.y);
        [panGR setTranslation:CGPointMake(0, 0) inView:panGR.view.superview];
        //        DDLogInfo(@"%f %f", newX, snapX);
    }
    
    [self updateCaratLabels];
}

- (void)updateCaratLabels {
    float CARAT_SCALE_UNIT_AMOUNT = 0.25;
    
    float minNumQuarterCarats = 1 + roundf( (self.minCaratSliderHandleImageView.center.x - self.CARAT_SCALE_MIN_X) / self.CARAT_SCALE_UNIT_WIDTH );
    float newMinValue = minNumQuarterCarats * CARAT_SCALE_UNIT_AMOUNT;
    
    NSString *formattedNewMinValue;
    if (newMinValue == floorf(newMinValue)) {
        formattedNewMinValue = [NSString stringWithFormat:@"%dct.", (int)newMinValue];
    } else {
        formattedNewMinValue = [NSString stringWithFormat:@"%.02fct.", newMinValue];
    }
    self.minCaratLabel.text = formattedNewMinValue;
    
    float maxNumQuarterCarats = 1 + roundf( (self.maxCaratSliderHandleImageView.center.x - self.CARAT_SCALE_MIN_X) / self.CARAT_SCALE_UNIT_WIDTH );
    float newMaxValue = maxNumQuarterCarats * CARAT_SCALE_UNIT_AMOUNT;
    NSString *formattedNewMaxValue;
    if (newMaxValue == floorf(newMaxValue)) {
        formattedNewMaxValue = [NSString stringWithFormat:@"%dct.", (int)newMaxValue];
    } else {
        formattedNewMaxValue = [NSString stringWithFormat:@"%.02fct.", newMaxValue];
    }
    self.maxCaratLabel.text = formattedNewMaxValue;
    
    [self updateCaratScaleTintRange];
}

- (IBAction)updateCaratSliders:(id)sender {
    // min
    NSString *minCaratText = self.minCaratLabel.text;
    minCaratText = [minCaratText substringWithRange:NSMakeRange(0, minCaratText.length-3)];
    
    float minCaratVal = [minCaratText floatValue];
    float minNumUnits = (minCaratVal / 0.25) - 1;
    float minScaleX = self.CARAT_SCALE_MIN_X + self.CARAT_SCALE_UNIT_WIDTH * minNumUnits;
    self.minCaratSliderHandleImageView.center = CGPointMake(minScaleX, self.minCaratSliderHandleImageView.center.y);

    // max
    NSString *maxCaratText = self.maxCaratLabel.text;
    maxCaratText = [maxCaratText substringWithRange:NSMakeRange(0, maxCaratText.length-3)];
    
    float maxCaratVal = [maxCaratText floatValue];
    float maxNumUnits = (maxCaratVal / 0.25) - 1;
    float maxScaleX = self.CARAT_SCALE_MIN_X + self.CARAT_SCALE_UNIT_WIDTH * maxNumUnits;
    self.maxCaratSliderHandleImageView.center = CGPointMake(maxScaleX, self.maxCaratSliderHandleImageView.center.y);

    [self updateCaratScaleTintRange];
}

- (void)updateCaratScaleTintRange {
    float x = self.minCaratSliderHandleImageView.center.x;
    float y = self.caratScaleTintRangeView.frame.origin.y;
    float width = self.maxCaratSliderHandleImageView.center.x - self.minCaratSliderHandleImageView.center.x;
    float height = self.caratScaleTintRangeView.frame.size.height;
    
    self.caratScaleTintRangeView.frame = CGRectMake(x, y, width, height);
}

#pragma mark - Select clarity

- (IBAction)selectClarity:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (!button.selected) {
        button.layer.zPosition = MAXFLOAT;
    } else {
        button.layer.zPosition = 0;
    }
    button.selected = !button.selected;
}

#pragma mark - Select color type view

- (IBAction)selectColorTypeView:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    if (button == self.simpleColorButton) {
        self.simpleColorButton.selected = YES;
        self.fancyColorButton.selected = NO;
        
        self.simpleColorView.hidden = NO;
        self.fancyColorView.hidden = YES;
    } else {
        self.simpleColorButton.selected = NO;
        self.fancyColorButton.selected = YES;
        
        self.fancyColorView.hidden = NO;
        self.simpleColorView.hidden = YES;
    }
}

#pragma mark - Color scale

- (IBAction)updateColorScale:(id)sender {
    UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *)sender;
    CGPoint translation = [panGR translationInView:panGR.view.superview];
    
    float newX = panGR.view.center.x + translation.x;
    newX = MAX(self.COLOR_SCALE_MIN_X, newX); // min mark
    newX = MIN(newX, self.COLOR_SCALE_MAX_X); // max mark
    
    //    DDLogInfo(@"%f", newX);
    
    // keep min <= max
    if (panGR.view == self.minColorSliderHandleImageView) {
        newX = MIN(newX, self.maxColorSliderHandleImageView.center.x);
    } else {
        newX = MAX(self.minColorSliderHandleImageView.center.x, newX);
    }
    
    // snap to position between color buttons
    //    DDLogInfo(@"%f", newX);
    
    if (abs(translation.x) >= self.COLOR_SCALE_UNIT_WIDTH/2) {
        for (NSNumber *position in self.colorScalePositions) {
            float xDiff = abs(newX - position.floatValue);
            if (xDiff <= self.COLOR_SCALE_UNIT_WIDTH/2) {
                //                DDLogInfo(@"%lu", (unsigned long)([positions indexOfObject:position] + 1));
                //            DDLogInfo(@"%f %f %f", newX, position.floatValue, xDiff);
                panGR.view.center = CGPointMake(position.floatValue, panGR.view.center.y);
                [panGR setTranslation:CGPointMake(0, 0) inView:panGR.view.superview];
                [self updateColorScaleButtons];
                break;
            }
        }
    }
}

- (IBAction)updateSimpleColorSliders:(id)sender {
    // min
    int minSimpleColor = (int)[self.searchParams.simpleColors.firstObject characterAtIndex:0];
    int minNumUnits = minSimpleColor -= (int)'D';
    float minScaleX = self.COLOR_SCALE_MIN_X + self.COLOR_SCALE_UNIT_WIDTH * minNumUnits;
    self.minColorSliderHandleImageView.center = CGPointMake(minScaleX, self.minColorSliderHandleImageView.center.y);
    
    
    // max
    int maxSimpleColor = (int)[self.searchParams.simpleColors.lastObject characterAtIndex:0];
    int maxNumUnits = maxSimpleColor -= (int)'D';
    float maxScaleX = self.COLOR_SCALE_MIN_X + self.COLOR_SCALE_UNIT_WIDTH * (maxNumUnits + 1);
    self.maxColorSliderHandleImageView.center = CGPointMake(maxScaleX, self.maxColorSliderHandleImageView.center.y);
    
    [self updateColorScaleButtons];
}

- (void)updateColorScaleButtons {
    for (UIButton *button in self.colorScaleButtons) {
        button.selected = NO;
    }
    
    float xMin = self.minColorSliderHandleImageView.center.x;
    NSNumber *xMinNumber = [NSNumber numberWithFloat:xMin];
    NSUInteger minIndex = [self.colorScalePositions indexOfObject:xMinNumber];
    
    float xMax = self.maxColorSliderHandleImageView.center.x;
    NSNumber *xMaxNumber = [NSNumber numberWithFloat:xMax];
    NSUInteger maxIndex = [self.colorScalePositions indexOfObject:xMaxNumber];
    
    NSUInteger count = maxIndex - minIndex;
    
    //    DDLogInfo(@"%ul %ul %lul", minIndex, maxIndex, (unsigned long)count);
    
    NSArray *selectedColorScaleButtons = [self.colorScaleButtons subarrayWithRange:NSMakeRange(minIndex, count)];
    
    for (UIButton *button in selectedColorScaleButtons) {
        button.selected = YES;
    }
    
    self.colorMinLabel.text = ((UIButton *)[selectedColorScaleButtons firstObject]).currentTitle;
    self.colorMaxLabel.text = ((UIButton *)[selectedColorScaleButtons lastObject]).currentTitle;
}

#pragma mark - Select fancy color 1

- (IBAction)selectFancyColor1:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
}

#pragma mark - Select fancy color 2

- (IBAction)selectFancyColor2:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (!button.selected) {
        button.layer.zPosition = MAXFLOAT;
    } else {
        button.layer.zPosition = 0;
    }
    button.selected = !button.selected;
}

#pragma mark - More

- (IBAction)more:(id)sender {
    self.searchFiltersContent1View.hidden = YES;
    self.searchFiltersContent2View.hidden = NO;
}

#pragma mark - Less

- (IBAction)less:(id)sender {
    self.searchFiltersContent2View.hidden = YES;
    self.searchFiltersContent1View.hidden = NO;
}

#pragma mark - Select pol/sym view

- (IBAction)selectPolSymView:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    if (button == self.polishButton) {
        self.polishButton.selected = YES;
        self.symmetryButton.selected = NO;
        self.cutGradeButton.selected = NO;
        
        self.polishView.hidden = NO;
        self.symmetryView.hidden = YES;
        self.cutGradeView.hidden = YES;
    } else if (button == self.symmetryButton) {
        self.polishButton.selected = NO;
        self.symmetryButton.selected = YES;
        self.cutGradeButton.selected = NO;
        
        self.polishView.hidden = YES;
        self.symmetryView.hidden = NO;
        self.cutGradeView.hidden = YES;
    } else {
        self.polishButton.selected = NO;
        self.symmetryButton.selected = NO;
        self.cutGradeButton.selected = YES;
        
        self.polishView.hidden = YES;
        self.symmetryView.hidden = YES;
        self.cutGradeView.hidden = NO;
    }
}

#pragma mark - Select polish

- (IBAction)selectPolish:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (!button.selected) {
        button.layer.zPosition = MAXFLOAT;
    } else {
        button.layer.zPosition = 0;
    }
    button.selected = !button.selected;
}

#pragma mark - Select symmetry

- (IBAction)selectSymmetry:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (!button.selected) {
        button.layer.zPosition = MAXFLOAT;
    } else {
        button.layer.zPosition = 0;
    }
    button.selected = !button.selected;
}

#pragma mark - Select cut grade

- (IBAction)selectCutGrade:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (!button.selected) {
        button.layer.zPosition = MAXFLOAT;
    } else {
        button.layer.zPosition = 0;
    }
    button.selected = !button.selected;
}

#pragma mark - Select fluorescence

- (IBAction)selectFluorescence:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (!button.selected) {
        button.layer.zPosition = MAXFLOAT;
    } else {
        button.layer.zPosition = 0;
    }
    button.selected = !button.selected;
}

#pragma mark - Depth scale

- (IBAction)updateDepthScale:(id)sender {
    UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *)sender;
    CGPoint translation = [panGR translationInView:panGR.view.superview];
    
    float newX = panGR.view.center.x + translation.x;
    newX = MAX(self.DEPTH_SCALE_MIN_X, newX); // min mark
    newX = MIN(newX, self.DEPTH_SCALE_MAX_X); // max mark
    
    // keep min <= max
    if (panGR.view == self.minDepthSliderHandleImageView) {
        newX = MIN(newX, self.maxDepthSliderHandleImageView.center.x);
    } else {
        newX = MAX(self.minDepthSliderHandleImageView.center.x, newX);
    }
    
    panGR.view.center = CGPointMake(newX, panGR.view.center.y);
    [panGR setTranslation:CGPointMake(0, 0) inView:panGR.view.superview];
    
    // snap to tick mark on release
    if (panGR.state == UIGestureRecognizerStateEnded) {
        float snapX = self.DEPTH_SCALE_MIN_X + roundf((panGR.view.center.x - self.DEPTH_SCALE_MIN_X) / self.DEPTH_SCALE_UNIT_WIDTH) * self.DEPTH_SCALE_UNIT_WIDTH;
        panGR.view.center = CGPointMake(snapX, panGR.view.center.y);
        //        DDLogInfo(@"%f %f", newX, snapX);
    }
    
    [self updateDepthLabels];
}

- (void)updateDepthLabels {
    int minDepth = round(self.DEPTH_SCALE_MIN_VALUE + (self.minDepthSliderHandleImageView.center.x - self.DEPTH_SCALE_MIN_X) / self.DEPTH_SCALE_UNIT_WIDTH);
    
    self.minDepthLabel.text = [NSString stringWithFormat:@"%d%%", minDepth];
    
    int maxDepth = round(self.DEPTH_SCALE_MIN_VALUE + (self.maxDepthSliderHandleImageView.center.x - self.DEPTH_SCALE_MIN_X) / self.DEPTH_SCALE_UNIT_WIDTH);
    self.maxDepthLabel.text = [NSString stringWithFormat:@"%d%%", maxDepth];
    
    [self updateDepthScaleTintRange];
}

- (IBAction)updateDepthSliders:(id)sender {
    // min
    NSString *minDepthText = self.minDepthLabel.text;
    minDepthText = [minDepthText substringWithRange:NSMakeRange(0, minDepthText.length-1)];
    
    float minDepthVal = [minDepthText intValue];
    float minNumUnits = minDepthVal - self.DEPTH_SCALE_MIN_VALUE;
    float minScaleX = self.DEPTH_SCALE_MIN_X + self.DEPTH_SCALE_UNIT_WIDTH * minNumUnits;
    self.minDepthSliderHandleImageView.center = CGPointMake(minScaleX, self.minDepthSliderHandleImageView.center.y);
    
    // max
    NSString *maxDepthText = self.maxDepthLabel.text;
    maxDepthText = [maxDepthText substringWithRange:NSMakeRange(0, maxDepthText.length-1)];
    
    float maxDepthVal = [maxDepthText floatValue];
    float maxNumUnits = maxDepthVal - self.DEPTH_SCALE_MIN_VALUE;
    float maxScaleX = self.DEPTH_SCALE_MIN_X + self.DEPTH_SCALE_UNIT_WIDTH * maxNumUnits;
    self.maxDepthSliderHandleImageView.center = CGPointMake(maxScaleX, self.maxDepthSliderHandleImageView.center.y);
    
    [self updateDepthScaleTintRange];
}

- (void)updateDepthScaleTintRange {
    float x = self.minDepthSliderHandleImageView.center.x;
    float y = self.depthScaleTintRangeView.frame.origin.y;
    float width = self.maxDepthSliderHandleImageView.center.x - self.minDepthSliderHandleImageView.center.x;
    float height = self.depthScaleTintRangeView.frame.size.height;
    
    self.depthScaleTintRangeView.frame = CGRectMake(x, y, width, height);
}

#pragma mark - Select lab

- (IBAction)selectLab:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
}

#pragma mark - Table scale

- (IBAction)updateTableScale:(id)sender {
    UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *)sender;
    CGPoint translation = [panGR translationInView:panGR.view.superview];
    
    float newX = panGR.view.center.x + translation.x;
    newX = MAX(self.TABLE_SCALE_MIN_X, newX); // min mark
    newX = MIN(newX, self.TABLE_SCALE_MAX_X); // max mark
    
    // keep min <= max
    if (panGR.view == self.minTableSliderHandleImageView) {
        newX = MIN(newX, self.maxTableSliderHandleImageView.center.x);
    } else {
        newX = MAX(self.minTableSliderHandleImageView.center.x, newX);
    }
    
    panGR.view.center = CGPointMake(newX, panGR.view.center.y);
    [panGR setTranslation:CGPointMake(0, 0) inView:panGR.view.superview];
    
    // snap to tick mark on release
    if (panGR.state == UIGestureRecognizerStateEnded) {
        float snapX = self.TABLE_SCALE_MIN_X + roundf((panGR.view.center.x - self.TABLE_SCALE_MIN_X) / self.TABLE_SCALE_UNIT_WIDTH) * self.TABLE_SCALE_UNIT_WIDTH;
        panGR.view.center = CGPointMake(snapX, panGR.view.center.y);
        //        DDLogInfo(@"%f %f", newX, snapX);
    }
    
    [self updateTableLabels];
}

- (void)updateTableLabels {
    int minTable = round(self.TABLE_SCALE_MIN_VALUE + (self.minTableSliderHandleImageView.center.x - self.TABLE_SCALE_MIN_X) / self.TABLE_SCALE_UNIT_WIDTH);
    
    self.minTableLabel.text = [NSString stringWithFormat:@"%d%%", minTable];
    
    int maxTable = round(self.TABLE_SCALE_MIN_VALUE + (self.maxTableSliderHandleImageView.center.x - self.TABLE_SCALE_MIN_X) / self.TABLE_SCALE_UNIT_WIDTH);
    self.maxTableLabel.text = [NSString stringWithFormat:@"%d%%", maxTable];
    
    [self updateTableScaleTintRange];
}

- (IBAction)updateTableSliders:(id)sender {
    // min
    NSString *minTableText = self.minTableLabel.text;
    minTableText = [minTableText substringWithRange:NSMakeRange(0, minTableText.length-1)];
    
    float minTableVal = [minTableText intValue];
    float minNumUnits = minTableVal - self.TABLE_SCALE_MIN_VALUE;
    float minScaleX = self.TABLE_SCALE_MIN_X + self.TABLE_SCALE_UNIT_WIDTH * minNumUnits;
    self.minTableSliderHandleImageView.center = CGPointMake(minScaleX, self.minTableSliderHandleImageView.center.y);
    
    // max
    NSString *maxTableText = self.maxTableLabel.text;
    maxTableText = [maxTableText substringWithRange:NSMakeRange(0, maxTableText.length-1)];
    
    float maxTableVal = [maxTableText floatValue];
    float maxNumUnits = maxTableVal - self.TABLE_SCALE_MIN_VALUE;
    float maxScaleX = self.TABLE_SCALE_MIN_X + self.TABLE_SCALE_UNIT_WIDTH * maxNumUnits;
    self.maxTableSliderHandleImageView.center = CGPointMake(maxScaleX, self.maxTableSliderHandleImageView.center.y);
    
    [self updateTableScaleTintRange];
}

- (void)updateTableScaleTintRange {
    float x = self.minTableSliderHandleImageView.center.x;
    float y = self.tableScaleTintRangeView.frame.origin.y;
    float width = self.maxTableSliderHandleImageView.center.x - self.minTableSliderHandleImageView.center.x;
    float height = self.tableScaleTintRangeView.frame.size.height;
    
    self.tableScaleTintRangeView.frame = CGRectMake(x, y, width, height);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ILUItem *item = self.searchResults[indexPath.item];
    
    ILUSearchResultCollectionViewCell *cell = (ILUSearchResultCollectionViewCell *)
                                              [collectionView dequeueReusableCellWithReuseIdentifier:@"SearchResultCell"
                                                                                        forIndexPath:indexPath];
    cell.itemImageView.image = item.image;
    cell.itemLabel.text = item.title;
    cell.priceLabel.text = item.formattedPrice;
    
    if (indexPath.row % 4 == 3) {
        cell.rightBorderView.hidden = YES;
    } else {
        cell.rightBorderView.hidden = NO;
    }
    
    if (indexPath.row >= [collectionView numberOfItemsInSection:indexPath.section] - 4) {
        cell.bottomBorderView.hidden = YES;
    } else {
        cell.bottomBorderView.hidden = NO;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ILUDetailsViewController *detailsVC = (ILUDetailsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"Details"];
    
    ILUItem *item = self.searchResults[indexPath.item];
    detailsVC.item = item;
    
    appDelegate.viewDeckController.centerController = detailsVC;
}

#pragma mark - UICollectionViewDelegateFlowLayout


@end
