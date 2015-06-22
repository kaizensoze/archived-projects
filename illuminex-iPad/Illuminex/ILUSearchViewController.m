//
//  ViewController.m
//  Illuminex
//
//  Created by Joe Gallo on 9/23/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUSearchViewController.h"
#import "ILUSearchResultsViewController.h"
#import "ILUSearchParams.h"

@interface ILUSearchViewController ()
    @property (weak, nonatomic) IBOutlet UILabel *searchLabel;

    @property (weak, nonatomic) IBOutlet UILabel *searchTypeLabel;
    @property (nonatomic) CGPoint desiredSearchTypeLabelCenter;

    @property (weak, nonatomic) IBOutlet UIButton *resetFiltersButton;

    // search type buttons
    @property (weak, nonatomic) IBOutlet UIView *buttonSet1View;
    @property (weak, nonatomic) IBOutlet UIButton *budgetButton;
    @property (weak, nonatomic) IBOutlet UIButton *shapeButton;
    @property (weak, nonatomic) IBOutlet UIButton *caratButton;
    @property (weak, nonatomic) IBOutlet UIButton *colorButton;
    @property (weak, nonatomic) IBOutlet UIButton *clarityButton;
    @property (weak, nonatomic) IBOutlet UIButton *moreButton;

    @property (weak, nonatomic) IBOutlet UIView *buttonSet2View;
    @property (weak, nonatomic) IBOutlet UIButton *lessButton;
    @property (weak, nonatomic) IBOutlet UIButton *polSymButton;
    @property (weak, nonatomic) IBOutlet UIButton *labButton;
    @property (weak, nonatomic) IBOutlet UIButton *depthButton;
    @property (weak, nonatomic) IBOutlet UIButton *tableButton;
    @property (weak, nonatomic) IBOutlet UIButton *fluorescenceButton;

    @property (strong, nonatomic) NSArray *searchTypeButtons;
    @property (strong, nonatomic) UIButton *lastSelectedSearchTypeButton;
    @property (strong, nonatomic) NSDictionary *searchTypeButtonTagToLabels;

    // search type views
    @property (strong, nonatomic) NSArray *searchTypeViews;
    @property (weak, nonatomic) IBOutlet UIView *budgetView;
    @property (weak, nonatomic) IBOutlet UIView *shapeView;
    @property (weak, nonatomic) IBOutlet UIView *caratView;
    @property (weak, nonatomic) IBOutlet UIView *colorView;
    @property (weak, nonatomic) IBOutlet UIView *clarityView;
    @property (weak, nonatomic) IBOutlet UIView *polSymView;
    @property (weak, nonatomic) IBOutlet UIView *labView;
    @property (weak, nonatomic) IBOutlet UIView *depthView;
    @property (weak, nonatomic) IBOutlet UIView *tableView;
    @property (weak, nonatomic) IBOutlet UIView *fluorescenceView;
    @property (weak, nonatomic) IBOutlet UIView *lastShownSearchTypeView;
    @property (strong, nonatomic) NSDictionary *searchTypeToSearchTypeView;

    // budget
    @property (weak, nonatomic) IBOutlet UIView *minBudgetDialView;
    @property (weak, nonatomic) IBOutlet UILabel *minBudgetLabel;
    @property (weak, nonatomic) IBOutlet UITextField *minBudgetAmountTextField;
    @property (weak, nonatomic) IBOutlet UIImageView *minBudgetDialPieceImageView;

    @property (weak, nonatomic) IBOutlet UIView *maxBudgetDialView;
    @property (weak, nonatomic) IBOutlet UILabel *maxBudgetLabel;
    @property (weak, nonatomic) IBOutlet UITextField *maxBudgetAmountTextField;
    @property (weak, nonatomic) IBOutlet UIImageView *maxBudgetDialPieceImageView;

    // shape
    @property (strong, nonatomic) NSArray *shapeButtons;
    @property (strong, nonatomic) NSDictionary *shapeButtonTagToLabels;
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
    @property (weak, nonatomic) IBOutlet UITextField *minCaratTextField;
    @property (weak, nonatomic) IBOutlet UILabel *minCaratTapLabel;

    @property (weak, nonatomic) IBOutlet UITextField *maxCaratTextField;
    @property (weak, nonatomic) IBOutlet UILabel *maxCaratTapLabel;

    @property (weak, nonatomic) IBOutlet UILabel *caratToLabel;

    @property (weak, nonatomic) IBOutlet UIImageView *minCaratSliderHandleImageView;
    @property (weak, nonatomic) IBOutlet UIImageView *maxCaratSliderHandleImageView;
    @property (weak, nonatomic) IBOutlet UIView *caratScaleTintRangeView;

    @property (nonatomic) float CARAT_SCALE_MIN_X;
    @property (nonatomic) float CARAT_SCALE_MAX_X;
    @property (nonatomic) float CARAT_SCALE_UNIT_WIDTH;
    @property (nonatomic) float CARAT_SCALE_MIN_VALUE;
    @property (nonatomic) float CARAT_SCALE_MAX_VALUE;

    // color

    // simple
    @property (weak, nonatomic) IBOutlet UIView *simpleColorView;

    @property (weak, nonatomic) IBOutlet UILabel *colorToLabel;
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

    // fancy
    @property (weak, nonatomic) IBOutlet UIView *fancyColorView;
    @property (weak, nonatomic) IBOutlet UILabel *fancyColorLabel1;
    @property (weak, nonatomic) IBOutlet UILabel *fancyColorLabel2;

    @property (strong, nonatomic) NSArray *fancyColor1Buttons;
    @property (strong, nonatomic) NSDictionary *fancyColor1ButtonTagToLabels;
    @property (weak, nonatomic) IBOutlet UIButton *yellowButton;
    @property (weak, nonatomic) IBOutlet UIButton *pinkButton;
    @property (weak, nonatomic) IBOutlet UIButton *blueButton;
    @property (weak, nonatomic) IBOutlet UIButton *greenButton;
    @property (weak, nonatomic) IBOutlet UIButton *orangeButton;
    @property (weak, nonatomic) IBOutlet UIButton *brownButton;

    @property (strong, nonatomic) NSArray *fancyColor2Buttons;
    @property (strong, nonatomic) NSDictionary *fancyColor2ButtonTagToLabels;
    @property (weak, nonatomic) IBOutlet UIButton *fancyLightButton;
    @property (weak, nonatomic) IBOutlet UIButton *fancyButton;
    @property (weak, nonatomic) IBOutlet UIButton *fancyIntenseButton;
    @property (weak, nonatomic) IBOutlet UIButton *fancyVividButton;

    @property (weak, nonatomic) IBOutlet UIButton *simpleColorButton;
    @property (weak, nonatomic) IBOutlet UIButton *fancyColorButton;

    // clarity
    @property (weak, nonatomic) IBOutlet UILabel *leftClarityLabel;
    @property (weak, nonatomic) IBOutlet UILabel *rightClarityLabel;
    @property (weak, nonatomic) IBOutlet UILabel *clarityToLabel;

    @property (strong, nonatomic) NSArray *clarityButtons;
    @property (strong, nonatomic) NSDictionary *clarityButtonTagToLabels;
    @property (weak, nonatomic) IBOutlet UIButton *clarityIFButton;
    @property (weak, nonatomic) IBOutlet UIButton *clarityVVS1Button;
    @property (weak, nonatomic) IBOutlet UIButton *clarityVVS2Button;
    @property (weak, nonatomic) IBOutlet UIButton *clarityVS1Button;
    @property (weak, nonatomic) IBOutlet UIButton *clarityVS2Button;
    @property (weak, nonatomic) IBOutlet UIButton *claritySI1Button;
    @property (weak, nonatomic) IBOutlet UIButton *claritySI2Button;
    @property (weak, nonatomic) IBOutlet UIButton *clarityI1Button;

    // pol/sym

    @property (weak, nonatomic) IBOutlet UIView *polishView;
    @property (weak, nonatomic) IBOutlet UIView *symmetryView;
    @property (weak, nonatomic) IBOutlet UIView *cutGradeView;

    @property (weak, nonatomic) IBOutlet UIButton *polishButton;
    @property (weak, nonatomic) IBOutlet UIButton *symmetryButton;
    @property (weak, nonatomic) IBOutlet UIButton *cutGradeButton;

    // polish
    @property (weak, nonatomic) IBOutlet UILabel *leftPolishLabel;
    @property (weak, nonatomic) IBOutlet UILabel *rightPolishLabel;
    @property (weak, nonatomic) IBOutlet UILabel *polishToLabel;

    @property (strong, nonatomic) NSArray *polishButtons;
    @property (strong, nonatomic) NSDictionary *polishButtonTagToLabels;
    @property (weak, nonatomic) IBOutlet UIButton *polishGoodButton;
    @property (weak, nonatomic) IBOutlet UIButton *polishVeryGoodButton;
    @property (weak, nonatomic) IBOutlet UIButton *polishExcellentButton;

    // symmetry
    @property (weak, nonatomic) IBOutlet UILabel *leftSymmetryLabel;
    @property (weak, nonatomic) IBOutlet UILabel *rightSymmetryLabel;
    @property (weak, nonatomic) IBOutlet UILabel *symmetryToLabel;

    @property (strong, nonatomic) NSArray *symmetryButtons;
    @property (strong, nonatomic) NSDictionary *symmetryButtonTagToLabels;
    @property (weak, nonatomic) IBOutlet UIButton *symmetryGoodButton;
    @property (weak, nonatomic) IBOutlet UIButton *symmetryVeryGoodButton;
    @property (weak, nonatomic) IBOutlet UIButton *symmetryExcellentButton;

    // cut grade
    @property (weak, nonatomic) IBOutlet UILabel *leftCutGradeLabel;
    @property (weak, nonatomic) IBOutlet UILabel *rightCutGradeLabel;
    @property (weak, nonatomic) IBOutlet UILabel *cutGradeToLabel;

    @property (strong, nonatomic) NSArray *cutGradeButtons;
    @property (strong, nonatomic) NSDictionary *cutGradeButtonTagToLabels;
    @property (weak, nonatomic) IBOutlet UIButton *cutGradeGoodButton;
    @property (weak, nonatomic) IBOutlet UIButton *cutGradeVeryGoodButton;
    @property (weak, nonatomic) IBOutlet UIButton *cutGradeExcellentButton;

    // lab
    @property (strong, nonatomic) NSArray *labButtons;
    @property (strong, nonatomic) NSDictionary *labButtonTagToLabels;
    @property (weak, nonatomic) IBOutlet UIButton *giaButton;
    @property (weak, nonatomic) IBOutlet UIButton *agsButton;
    @property (weak, nonatomic) IBOutlet UIButton *igiButton;

    // depth
    @property (weak, nonatomic) IBOutlet UILabel *minDepthLabel;
    @property (weak, nonatomic) IBOutlet UILabel *maxDepthLabel;
    @property (weak, nonatomic) IBOutlet UILabel *depthToLabel;

    @property (weak, nonatomic) IBOutlet UIImageView *minDepthSliderHandleImageView;
    @property (weak, nonatomic) IBOutlet UIImageView *maxDepthSliderHandleImageView;
    @property (weak, nonatomic) IBOutlet UIView *depthScaleTintRangeView;

    @property (nonatomic) float DEPTH_SCALE_MIN_X;
    @property (nonatomic) float DEPTH_SCALE_MAX_X;
    @property (nonatomic) float DEPTH_SCALE_UNIT_WIDTH;
    @property (nonatomic) float DEPTH_SCALE_MIN_VALUE;
    @property (nonatomic) float DEPTH_SCALE_MAX_VALUE;

    // table
    @property (weak, nonatomic) IBOutlet UILabel *minTableLabel;
    @property (weak, nonatomic) IBOutlet UILabel *maxTableLabel;
    @property (weak, nonatomic) IBOutlet UILabel *tableToLabel;

    @property (weak, nonatomic) IBOutlet UIImageView *minTableSliderHandleImageView;
    @property (weak, nonatomic) IBOutlet UIImageView *maxTableSliderHandleImageView;
    @property (weak, nonatomic) IBOutlet UIView *tableScaleTintRangeView;

    @property (nonatomic) float TABLE_SCALE_MIN_X;
    @property (nonatomic) float TABLE_SCALE_MAX_X;
    @property (nonatomic) float TABLE_SCALE_UNIT_WIDTH;
    @property (nonatomic) float TABLE_SCALE_MIN_VALUE;
    @property (nonatomic) float TABLE_SCALE_MAX_VALUE;

    // fluorescence

    @property (weak, nonatomic) IBOutlet UILabel *leftFluorescenceLabel;
    @property (weak, nonatomic) IBOutlet UILabel *rightFluorescenceLabel;
    @property (weak, nonatomic) IBOutlet UILabel *fluorescenceToLabel;

    @property (strong, nonatomic) NSArray *fluorescenceButtons;
    @property (strong, nonatomic) NSDictionary *fluorescenceButtonTagToLabels;
    @property (weak, nonatomic) IBOutlet UIButton *noneButton;
    @property (weak, nonatomic) IBOutlet UIButton *faintButton;
    @property (weak, nonatomic) IBOutlet UIButton *mediumButton;
    @property (weak, nonatomic) IBOutlet UIButton *strongButton;

    @property (weak, nonatomic) IBOutlet UIButton *searchButton;
@end

@implementation ILUSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // reset filters button
    [ILUCustomStyler styleButton:self.resetFiltersButton];
    
    // search label
    self.searchLabel.font = [UIFont fontWithName:@"PlayfairDisplay-BoldItalic" size:25];
    self.searchLabel.textColor = [UIColor whiteColor];
    
    // search type label
    self.searchTypeLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:21];
    self.searchTypeLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    self.desiredSearchTypeLabelCenter = self.searchTypeLabel.center;
    
    // search type button set views
    self.buttonSet1View.hidden = NO;
    self.buttonSet2View.hidden = YES;
    
    // search type buttons
    self.searchTypeButtons = @[
                               self.budgetButton,
                               self.shapeButton,
                               self.caratButton,
                               self.colorButton,
                               self.clarityButton,
                               self.moreButton,
                               self.lessButton,
                               self.polSymButton,
                               self.labButton,
                               self.depthButton,
                               self.tableButton,
                               self.fluorescenceButton
                               ];
    
    self.searchTypeButtonTagToLabels = @{
                                         @1: @"Budget",
                                         @2: @"Shape",
                                         @3: @"Carat",
                                         @4: @"Color",
                                         @5: @"Clarity",
                                         @6: @"Polish",
                                         @7: @"Lab",
                                         @8: @"Depth",
                                         @9: @"Table",
                                         @10: @"Fluorescence",
                                         
                                         @11: @"Polish",
                                         @12: @"Symmetry",
                                         @13: @"Cut Grade",
                                         
                                         @14: @"Color",
                                         @15: @"Fancy Color",
                                         };
    
    for (UIButton *searchTypeButton in self.searchTypeButtons) {
        [ILUCustomStyler styleSearchTypeButton:searchTypeButton];
    }
    
    // search type views
    self.searchTypeViews = @[
                             self.budgetView,
                             self.shapeView,
                             self.caratView,
                             self.colorView,
                             self.clarityView,
                             self.labView,
                             self.depthView,
                             self.tableView,
                             self.fluorescenceView,
                             ];
    
    self.searchTypeToSearchTypeView = @{
                                        @"Budget": self.budgetView,
                                        @"Shape": self.shapeView,
                                        @"Carat": self.caratView,
                                        @"Color": self.colorView,
                                        @"Clarity": self.clarityView,
                                        @"Polish": self.polSymView,
                                        @"Lab": self.labView,
                                        @"Depth": self.depthView,
                                        @"Table": self.tableView,
                                        @"Fluorescence": self.fluorescenceView,
                                        };
    
    // initialize all search type views to hidden
    for (UIView *searchTypeView in self.searchTypeViews) {
        searchTypeView.hidden = YES;
    }
    
    // budget
    
    // min budget dial
    self.minBudgetLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:30];
    self.minBudgetLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    [ILUCustomStyler styleTextField:self.minBudgetAmountTextField height:50];
    
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(rotateBudgetDial:)];
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.minBudgetDialPieceImageView addGestureRecognizer:panGR];
    
    // max budget dial
    self.maxBudgetLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:30];
    self.maxBudgetLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    [ILUCustomStyler styleTextField:self.maxBudgetAmountTextField height:50];
    
    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rotateBudgetDial:)];
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.maxBudgetDialPieceImageView addGestureRecognizer:panGR];
    
    // shape
    self.shapeButtons = @[
                          self.roundButton,
                          self.princessButton,
                          self.emeraldButton,
                          self.asscherButton,
                          self.ovalButton,
                          self.radiantButton,
                          self.pearButton,
                          self.heartButton,
                          self.marquiseButton,
                          self.cushionButton
                          ];
    
    self.shapeButtonTagToLabels = @{
                                    @71: @"Round",
                                    @72: @"Princess",
                                    @73: @"Emerald",
                                    @74: @"Asscher",
                                    @75: @"Oval",
                                    @76: @"Radiant",
                                    @77: @"Pear",
                                    @78: @"Heart",
                                    @79: @"Marquise",
                                    @80: @"Cushion"
                                    };
    
    for (UIButton *shapeButton in self.shapeButtons) {
        [ILUCustomStyler adjustButton:shapeButton];
    }
    
    // carat
    
    self.CARAT_SCALE_MIN_X = 25.5;
    self.CARAT_SCALE_MAX_X = 919;
    self.CARAT_SCALE_UNIT_WIDTH = 15.15;
    self.CARAT_SCALE_MIN_VALUE = 0.25;
    self.CARAT_SCALE_MAX_VALUE = 15;
    
    // min
    self.minCaratTextField.text = [NSString stringWithFormat:@"%.02fct.", self.CARAT_SCALE_MIN_VALUE];
    [ILUCustomStyler styleTextField:self.minCaratTextField height:50];
    
    self.minCaratTapLabel.font = [UIFont fontWithName:@"RobotoCondensed-Italic" size:16];
    self.minCaratTapLabel.textColor = [ILUUtil colorFromHex:@"d7d7d7"];

    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateCaratScale:)];
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.minCaratSliderHandleImageView addGestureRecognizer:panGR];
    
    // max
    self.maxCaratTextField.text = [NSString stringWithFormat:@"%.02fct.", self.CARAT_SCALE_MAX_VALUE];
    [ILUCustomStyler styleTextField:self.maxCaratTextField height:50];
    
    self.maxCaratTapLabel.font = [UIFont fontWithName:@"RobotoCondensed-Italic" size:16];
    self.maxCaratTapLabel.textColor = [ILUUtil colorFromHex:@"d7d7d7"];
    
    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateCaratScale:)];
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.maxCaratSliderHandleImageView addGestureRecognizer:panGR];
    
    self.caratScaleTintRangeView.backgroundColor = [ILUUtil colorFromHex:@"9f90da"];
    self.caratScaleTintRangeView.alpha = 0.5;
    
    self.caratToLabel.font = [UIFont fontWithName:@"RobotoCondensed-Italic" size:16];
    self.caratToLabel.textColor = [ILUUtil colorFromHex:@"ebebeb"];
    
    // color
    
    // simple color
    
    self.colorToLabel.font = [UIFont fontWithName:@"RobotoCondensed-Italic" size:16];
    self.colorToLabel.textColor = [ILUUtil colorFromHex:@"ebebeb"];
    
    self.colorMinLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:30];
    self.colorMinLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.colorMaxLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:30];
    self.colorMaxLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    [ILUCustomStyler styleToggleButton:self.dButton side:@"left" fontSize:30];
    [ILUCustomStyler styleToggleButton:self.eButton side:nil fontSize:30];
    [ILUCustomStyler styleToggleButton:self.fButton side:nil fontSize:30];
    [ILUCustomStyler styleToggleButton:self.gButton side:nil fontSize:30];
    [ILUCustomStyler styleToggleButton:self.hButton side:nil fontSize:30];
    [ILUCustomStyler styleToggleButton:self.iButton side:nil fontSize:30];
    [ILUCustomStyler styleToggleButton:self.jButton side:nil fontSize:30];
    [ILUCustomStyler styleToggleButton:self.kButton side:@"right" fontSize:30];
    
    self.colorScaleButtons = @[
                               self.dButton,
                               self.eButton,
                               self.fButton,
                               self.gButton,
                               self.hButton,
                               self.iButton,
                               self.jButton,
                               self.kButton];
    self.colorScalePositions = @[@67, @166, @268, @370, @472, @574, @676, @778, @877];
    
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
    self.minColorSliderHandleImageView.center = CGPointMake(67, 234);
    self.maxColorSliderHandleImageView.center = CGPointMake(877, 234);
    
    self.COLOR_SCALE_MIN_X = [[self.colorScalePositions firstObject] intValue];
    self.COLOR_SCALE_MAX_X = [[self.colorScalePositions lastObject] intValue];
    self.COLOR_SCALE_UNIT_WIDTH = 102;
    
    // fancy color
    
    self.fancyColorLabel1.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:30];
    self.fancyColorLabel1.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.fancyColorLabel2.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:30];
    self.fancyColorLabel2.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.fancyColor1Buttons = @[
                                self.yellowButton,
                                self.pinkButton,
                                self.blueButton,
                                self.greenButton,
                                self.orangeButton,
                                self.brownButton
                                ];
    
    self.fancyColor1ButtonTagToLabels = @{
                                          @40: @"Yellow",
                                          @41: @"Pink",
                                          @42: @"Blue",
                                          @43: @"Green",
                                          @44: @"Orange",
                                          @45: @"Brown",
                                         };
    
    [ILUCustomStyler adjustButton:self.yellowButton];
    [ILUCustomStyler adjustButton:self.pinkButton];
    [ILUCustomStyler adjustButton:self.blueButton];
    [ILUCustomStyler adjustButton:self.greenButton];
    [ILUCustomStyler adjustButton:self.orangeButton];
    [ILUCustomStyler adjustButton:self.brownButton];
    
    self.fancyColor2Buttons = @[
                                self.fancyLightButton,
                                self.fancyButton,
                                self.fancyIntenseButton,
                                self.fancyVividButton
                                ];
    
    self.fancyColor2ButtonTagToLabels = @{
                                          @46: @"Fancy Light",
                                          @47: @"Fancy",
                                          @48: @"Fancy Intense",
                                          @49: @"Fancy Vivid",
                                          };
    
    [ILUCustomStyler styleToggleButton:self.fancyLightButton side:@"left" fontSize:20];
    [ILUCustomStyler styleToggleButton:self.fancyButton side:nil fontSize:20];
    [ILUCustomStyler styleToggleButton:self.fancyIntenseButton side:nil fontSize:20];
    [ILUCustomStyler styleToggleButton:self.fancyVividButton side:@"right" fontSize:20];
    
    [ILUCustomStyler styleButton:self.simpleColorButton];
    [ILUCustomStyler styleButton:self.fancyColorButton];
    
    self.simpleColorButton.selected = YES;
    self.simpleColorView.hidden = NO;
    
    // clarity
    
    self.leftClarityLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:50];
    self.leftClarityLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.rightClarityLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:50];
    self.rightClarityLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.clarityToLabel.font = [UIFont fontWithName:@"RobotoCondensed-Italic" size:16];
    self.clarityToLabel.textColor = [ILUUtil colorFromHex:@"ebebeb"];
    
    self.clarityButtons = @[
                            self.clarityIFButton,
                            self.clarityVVS1Button,
                            self.clarityVVS2Button,
                            self.clarityVS1Button,
                            self.clarityVS2Button,
                            self.claritySI1Button,
                            self.claritySI2Button,
                            self.clarityI1Button
                            ];
    
    self.clarityButtonTagToLabels = @{
                                      @50: @"IF",
                                      @51: @"VVS1",
                                      @52: @"VVS2",
                                      @53: @"VS1",
                                      @54: @"VS2",
                                      @55: @"SI1",
                                      @56: @"SI2",
                                      @57: @"I1",
                                      };
    
    [ILUCustomStyler styleCustomToggleButton:self.clarityIFButton side:@"left" subtitleText:@"Internally\nFlawless"];
    [ILUCustomStyler styleCustomToggleButton:self.clarityVVS1Button side:nil subtitleText:@"Very, Very,\nSlightly\nIncluded"];
    [ILUCustomStyler styleCustomToggleButton:self.clarityVVS2Button side:nil subtitleText:@"Very, Very,\nSlightly\nIncluded"];
    [ILUCustomStyler styleCustomToggleButton:self.clarityVS1Button side:nil subtitleText:@"Very Slightly\nIncluded"];
    [ILUCustomStyler styleCustomToggleButton:self.clarityVS2Button side:nil subtitleText:@"Very Slightly\nIncluded"];
    [ILUCustomStyler styleCustomToggleButton:self.claritySI1Button side:nil subtitleText:@"Slightly\nIncluded"];
    [ILUCustomStyler styleCustomToggleButton:self.claritySI2Button side:nil subtitleText:@"Slightly\nIncluded"];
    [ILUCustomStyler styleCustomToggleButton:self.clarityI1Button side:@"right" subtitleText:@"Included"];
    
    // pol/sym
    
    // polish
    self.leftPolishLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:50];
    self.leftPolishLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.rightPolishLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:50];
    self.rightPolishLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.polishToLabel.font = [UIFont fontWithName:@"RobotoCondensed-Italic" size:16];
    self.polishToLabel.textColor = [ILUUtil colorFromHex:@"ebebeb"];
    
    self.polishButtons = @[self.polishGoodButton,
                           self.polishVeryGoodButton,
                           self.polishExcellentButton];
    
    self.polishButtonTagToLabels = @{
                                     @58: @"Good",
                                     @59: @"Very Good",
                                     @60: @"Excellent",
                                     };
    
    [ILUCustomStyler styleToggleButton:self.polishGoodButton side:@"left" fontSize:30];
    [ILUCustomStyler styleToggleButton:self.polishVeryGoodButton side:nil fontSize:30];
    [ILUCustomStyler styleToggleButton:self.polishExcellentButton side:@"right" fontSize:30];
    
    // symmetry
    self.leftSymmetryLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:50];
    self.leftSymmetryLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.rightSymmetryLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:50];
    self.rightSymmetryLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.symmetryToLabel.font = [UIFont fontWithName:@"RobotoCondensed-Italic" size:16];
    self.symmetryToLabel.textColor = [ILUUtil colorFromHex:@"ebebeb"];
    
    self.symmetryButtons = @[self.symmetryGoodButton,
                             self.symmetryVeryGoodButton,
                             self.symmetryExcellentButton];
    
    self.symmetryButtonTagToLabels = @{
                                       @61: @"Good",
                                       @62: @"Very Good",
                                       @63: @"Excellent",
                                       };
    
    [ILUCustomStyler styleToggleButton:self.symmetryGoodButton side:@"left" fontSize:30];
    [ILUCustomStyler styleToggleButton:self.symmetryVeryGoodButton side:nil fontSize:30];
    [ILUCustomStyler styleToggleButton:self.symmetryExcellentButton side:@"right" fontSize:30];
    
    // cut grade
    self.leftCutGradeLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:50];
    self.leftCutGradeLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.rightCutGradeLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:50];
    self.rightCutGradeLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.cutGradeToLabel.font = [UIFont fontWithName:@"RobotoCondensed-Italic" size:16];
    self.cutGradeToLabel.textColor = [ILUUtil colorFromHex:@"ebebeb"];
    
    self.cutGradeButtons = @[self.cutGradeGoodButton,
                             self.cutGradeVeryGoodButton,
                             self.cutGradeExcellentButton];
    
    self.cutGradeButtonTagToLabels = @{
                                       @64: @"Good",
                                       @65: @"Very Good",
                                       @66: @"Excellent",
                                       };
    
    [ILUCustomStyler styleToggleButton:self.cutGradeGoodButton side:@"left" fontSize:30];
    [ILUCustomStyler styleToggleButton:self.cutGradeVeryGoodButton side:nil fontSize:30];
    [ILUCustomStyler styleToggleButton:self.cutGradeExcellentButton side:@"right" fontSize:30];
    
    [ILUCustomStyler styleButton:self.polishButton];
    [ILUCustomStyler styleButton:self.symmetryButton];
    [ILUCustomStyler styleButton:self.cutGradeButton];
    
    self.polishButton.selected = YES;
    self.polishView.hidden = NO;
    
    // lab
    
    self.labButtons = @[
                        self.giaButton,
                        self.agsButton,
                        self.igiButton
                        ];
    
    self.labButtonTagToLabels = @{
                                  @81: @"GIA",
                                  @82: @"AGS",
                                  @83: @"IGI"
                                  };
    
    for (UIButton *labButton in self.labButtons) {
        [ILUCustomStyler adjustButton:labButton];
    }
    
    // depth
    
    self.DEPTH_SCALE_MIN_X = 28;
    self.DEPTH_SCALE_MAX_X = 921;
    self.DEPTH_SCALE_UNIT_WIDTH = 25.5;
    self.DEPTH_SCALE_MIN_VALUE = 45;
    self.DEPTH_SCALE_MAX_VALUE = 80;
    
    // min
    self.minDepthLabel.text = [NSString stringWithFormat:@"%d%%", (int)self.DEPTH_SCALE_MIN_VALUE];
    self.minDepthLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:50];
    self.minDepthLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateDepthScale:)];
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.minDepthSliderHandleImageView addGestureRecognizer:panGR];
    
    // max
    self.maxDepthLabel.text = [NSString stringWithFormat:@"%d%%", (int)self.DEPTH_SCALE_MAX_VALUE];
    self.maxDepthLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:50];
    self.maxDepthLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateDepthScale:)];
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.maxDepthSliderHandleImageView addGestureRecognizer:panGR];
    
    self.depthScaleTintRangeView.backgroundColor = [ILUUtil colorFromHex:@"9f90da"];
    self.depthScaleTintRangeView.alpha = 0.5;
    
    self.depthToLabel.font = [UIFont fontWithName:@"RobotoCondensed-Italic" size:16];
    self.depthToLabel.textColor = [ILUUtil colorFromHex:@"ebebeb"];
    
    // table
    
    self.TABLE_SCALE_MIN_X = 28;
    self.TABLE_SCALE_MAX_X = 921;
    self.TABLE_SCALE_UNIT_WIDTH = 27;
    self.TABLE_SCALE_MIN_VALUE = 50;
    self.TABLE_SCALE_MAX_VALUE = 83;
    
    // min
    self.minTableLabel.text = [NSString stringWithFormat:@"%d%%", (int)self.TABLE_SCALE_MIN_VALUE];
    self.minTableLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:50];
    self.minTableLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateTableScale:)];
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.minTableSliderHandleImageView addGestureRecognizer:panGR];
    
    // max
    self.maxTableLabel.text = [NSString stringWithFormat:@"%d%%", (int)self.TABLE_SCALE_MAX_VALUE];
    self.maxTableLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:50];
    self.maxTableLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updateTableScale:)];
    panGR.minimumNumberOfTouches = 1;
    panGR.maximumNumberOfTouches = 1;
    panGR.delegate = self;
    [self.maxTableSliderHandleImageView addGestureRecognizer:panGR];
    
    self.tableScaleTintRangeView.backgroundColor = [ILUUtil colorFromHex:@"9f90da"];
    self.tableScaleTintRangeView.alpha = 0.5;
    
    self.tableToLabel.font = [UIFont fontWithName:@"RobotoCondensed-Italic" size:16];
    self.tableToLabel.textColor = [ILUUtil colorFromHex:@"ebebeb"];
    
    // fluorescence
    
    self.leftFluorescenceLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:50];
    self.leftFluorescenceLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.rightFluorescenceLabel.font = [UIFont fontWithName:@"RobotoCondensed-Regular" size:50];
    self.rightFluorescenceLabel.textColor = [ILUUtil colorFromHex:@"7e69cd"];
    
    self.fluorescenceToLabel.font = [UIFont fontWithName:@"RobotoCondensed-Italic" size:16];
    self.fluorescenceToLabel.textColor = [ILUUtil colorFromHex:@"ebebeb"];
    
    self.fluorescenceButtons = @[self.noneButton,
                                 self.faintButton,
                                 self.mediumButton,
                                 self.strongButton];
    
    self.fluorescenceButtonTagToLabels = @{
                                           @67: @"None",
                                           @68: @"Faint",
                                           @69: @"Medium",
                                           @70: @"Strong",
                                           };
    
    [ILUCustomStyler styleToggleButton:self.noneButton side:@"left" fontSize:30];
    [ILUCustomStyler styleToggleButton:self.faintButton side:nil fontSize:30];
    [ILUCustomStyler styleToggleButton:self.mediumButton side:nil fontSize:30];
    [ILUCustomStyler styleToggleButton:self.strongButton side:@"right" fontSize:30];
    
    // initialize search type to Budget
    [self selectSearchType:self.budgetButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Open flyout menu

- (IBAction)openFlyoutMenu:(id)sender {
    [appDelegate.viewDeckController toggleLeftView];
}

#pragma mark - Select search type

- (IBAction)selectSearchType:(id)sender {
    UIButton *button = (UIButton *)sender;
    
    // ignore for more/less buttons
    if (button == self.moreButton || button == self.lessButton) {
        return;
    }
    
    // unselect previously selected button
    if (self.lastSelectedSearchTypeButton != button) {
        self.lastSelectedSearchTypeButton.selected = NO;
        self.lastSelectedSearchTypeButton = button;
    }
    
    button.selected = YES;
    
    [self updateSearchTypeLabel:button.tag];
    [self updateSearchTypeView:button.tag];
}

#pragma mark - Update search type label

- (void)updateSearchTypeLabel:(long)key {
    NSString *searchType = self.searchTypeButtonTagToLabels[@(key)];
    if (searchType) {
        self.searchTypeLabel.text = searchType;
        
        // resize label
        NSDictionary *attributes = @{NSFontAttributeName: self.searchTypeLabel.font};
        CGFloat newWidth = [self.searchTypeLabel.text sizeWithAttributes:attributes].width;
        self.searchTypeLabel.frame = CGRectMake(self.searchTypeLabel.frame.origin.x,
                                                self.searchTypeLabel.frame.origin.y,
                                                newWidth,
                                                self.searchTypeLabel.frame.size.height);
        
        // re-center
        self.searchTypeLabel.center = self.desiredSearchTypeLabelCenter;
        
        // update top/bottom border
        self.searchTypeLabel.layer.sublayers = nil;
        
        CALayer *borderLayer = [CALayer layer];
        borderLayer.frame = CGRectMake(0, 0, self.searchTypeLabel.frame.size.width, 1);
        borderLayer.backgroundColor = [ILUUtil colorFromHex:@"7e69cd"].CGColor;
        [self.searchTypeLabel.layer addSublayer:borderLayer];
        
        borderLayer = [CALayer layer];
        borderLayer.frame = CGRectMake(0, self.searchTypeLabel.frame.size.height, self.searchTypeLabel.frame.size.width, 1);
        borderLayer.backgroundColor = [ILUUtil colorFromHex:@"7e69cd"].CGColor;
        [self.searchTypeLabel.layer addSublayer:borderLayer];
    }
}

#pragma mark - Update search type view

- (void)updateSearchTypeView:(long)key {
    NSString *searchType = self.searchTypeButtonTagToLabels[@(key)];
    UIView *searchTypeView = self.searchTypeToSearchTypeView[searchType];
    
    // hide previously shown view
    if (self.lastShownSearchTypeView != searchTypeView) {
        self.lastShownSearchTypeView.hidden = YES;
        self.lastShownSearchTypeView = searchTypeView;
    }
    
    searchTypeView.hidden = NO;
}

#pragma mark - Budget dial

- (IBAction)rotateBudgetDial:(id)sender {
    DDLogInfo(@"rotate budget dial");
    
    UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *)sender;
    
    CGPoint startPoint;
    
    if (panGR.state == UIGestureRecognizerStateBegan) {
        startPoint = [panGR locationInView:panGR.view];
    } else if (panGR.state == UIGestureRecognizerStateChanged) {
        float xDelta = [panGR locationInView:panGR.view].x - startPoint.x;
        float yDelta = [panGR locationInView:panGR.view].y - startPoint.y;
        
        float angle = atan2f(yDelta, xDelta) * 0.5;
        
        CGPoint vel = [panGR velocityInView:panGR.view];
        if (vel.x < 0) {
            angle *= -1;
        }
        
        DDLogInfo(@"%f", angle);
        
        panGR.view.transform = CGAffineTransformRotate(panGR.view.transform, angle);
    }
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
    
    // snap to tick mark on release
    if (panGR.state == UIGestureRecognizerStateEnded) {
        float snapX = self.CARAT_SCALE_MIN_X + roundf((panGR.view.center.x - self.CARAT_SCALE_MIN_X) / self.CARAT_SCALE_UNIT_WIDTH) * self.CARAT_SCALE_UNIT_WIDTH;
        panGR.view.center = CGPointMake(snapX, panGR.view.center.y);
        [panGR setTranslation:CGPointMake(0, 0) inView:panGR.view.superview];
//        DDLogInfo(@"%f %f", newX, snapX);
    }
    
    [self updateCaratTextFields];
}

- (void)updateCaratTextFields {
    float minNumQuarterCarats = 1 + roundf( (self.minCaratSliderHandleImageView.center.x - self.CARAT_SCALE_MIN_X) / self.CARAT_SCALE_UNIT_WIDTH );
    float newMinValue = minNumQuarterCarats * 0.25;
    
    NSString *formattedNewMinValue;
    if (newMinValue == floorf(newMinValue)) {
        formattedNewMinValue = [NSString stringWithFormat:@"%dct.", (int)newMinValue];
    } else {
        formattedNewMinValue = [NSString stringWithFormat:@"%.02fct.", newMinValue];
    }
    self.minCaratTextField.text = formattedNewMinValue;
    
    float maxNumQuarterCarats = 1 + roundf( (self.maxCaratSliderHandleImageView.center.x - self.CARAT_SCALE_MIN_X) / self.CARAT_SCALE_UNIT_WIDTH );
    float newMaxValue = maxNumQuarterCarats * 0.25;
    NSString *formattedNewMaxValue;
    if (newMaxValue == floorf(newMaxValue)) {
        formattedNewMaxValue = [NSString stringWithFormat:@"%dct.", (int)newMaxValue];
    } else {
        formattedNewMaxValue = [NSString stringWithFormat:@"%.02fct.", newMaxValue];
    }
    self.maxCaratTextField.text = formattedNewMaxValue;
    
    [self updateCaratScaleTintRange];
}

- (IBAction)updateCaratSliders:(id)sender {
    UITextField *textField = (UITextField *)sender;
    
    // check if there's a carat value to get
    if (textField.text.length > @"ct.".length) {
        // get carat value
        NSRange range = [textField.text rangeOfString:@"ct."];
        if (range.location != NSNotFound) {
            unsigned long suffixIndex = (unsigned long)range.location;
            NSString *caratSubstring = [textField.text substringToIndex:suffixIndex];
            
            @try {
                float caratVal = [caratSubstring floatValue];
                float numUnits = (caratVal / 0.25) - 1;
                float scaleX = self.CARAT_SCALE_MIN_X + self.CARAT_SCALE_UNIT_WIDTH * numUnits;
                
                if (textField == self.minCaratTextField) {
                    self.minCaratSliderHandleImageView.center = CGPointMake(scaleX, self.minCaratSliderHandleImageView.center.y);
                } else if (textField == self.maxCaratTextField) {
                    self.maxCaratSliderHandleImageView.center = CGPointMake(scaleX, self.maxCaratSliderHandleImageView.center.y);
                }
                
                [self updateCaratScaleTintRange];
            }
            @catch (NSException *e) {
            }
        }
    }
}

- (void)updateCaratScaleTintRange {
    float x = self.minCaratSliderHandleImageView.center.x;
    float y = self.caratScaleTintRangeView.frame.origin.y;
    float width = self.maxCaratSliderHandleImageView.center.x - self.minCaratSliderHandleImageView.center.x;
    float height = self.caratScaleTintRangeView.frame.size.height;
    
    self.caratScaleTintRangeView.frame = CGRectMake(x, y, width, height);
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
}

#pragma mark - Select simple color

- (IBAction)selectSimpleColor:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (!button.selected) {
        button.layer.zPosition = MAXFLOAT;
    } else {
        button.layer.zPosition = 0;
    }
    button.selected = !button.selected;
}

#pragma mark - Select fancy color 1

- (IBAction)selectFancyColor1:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    [self updateFancyColor1Label];
}

# pragma mark - Update fancy color 1 label

- (void)updateFancyColor1Label {
    NSMutableArray *activeColors = [[NSMutableArray alloc] init];
    for (UIButton *button in self.fancyColor1Buttons) {
        if (button.selected) {
            NSString *activeColor = self.fancyColor1ButtonTagToLabels[@(button.tag)];
            [activeColors addObject:activeColor];
        }
    }
    
    self.fancyColorLabel1.text = [activeColors componentsJoinedByString:@", "];
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
    
    [self updateFancyColor2Label];
}

# pragma mark - Update fancy color 2 label

- (void)updateFancyColor2Label {
    NSMutableArray *activeColors = [[NSMutableArray alloc] init];
    for (UIButton *button in self.fancyColor2Buttons) {
        if (button.selected) {
            NSString *activeColor = self.fancyColor2ButtonTagToLabels[@(button.tag)];
            [activeColors addObject:activeColor];
        }
    }
    
    self.fancyColorLabel2.text = [activeColors componentsJoinedByString:@", "];
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
    
    [self updateSearchTypeLabel:button.tag];
}

#pragma mark - More

- (IBAction)more:(id)sender {
    self.buttonSet1View.hidden = YES;
    self.buttonSet2View.hidden = NO;
}

#pragma mark - Less

- (IBAction)less:(id)sender {
    self.buttonSet1View.hidden = NO;
    self.buttonSet2View.hidden = YES;
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
    
    // update custom button labels
    if (button.selected) {
        for (UIView *subview in button.subviews) {
            if ([subview isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)subview;
                label.textColor = [ILUUtil colorFromHex:@"7e69cd"];
            }
        }
    } else {
        for (UIView *subview in button.subviews) {
            if ([subview isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)subview;
                label.textColor = [UIColor whiteColor];
            }
        }
    }
    
    [self updateClarityLabels];
}

# pragma mark - Update clarity labels

- (void)updateClarityLabels {
    NSMutableArray *activeButtons = [[NSMutableArray alloc] init];
    for (UIButton *button in self.clarityButtons) {
        if (button.selected) {
            [activeButtons addObject:button];
        }
    }
    
    if (activeButtons.count > 0) {
        UIButton *leftButton = activeButtons[0];
        NSString *leftString = self.clarityButtonTagToLabels[@(leftButton.tag)];
        self.leftClarityLabel.text = leftString;
        
        if (activeButtons.count > 1) {
            UIButton *rightButton = [activeButtons lastObject];
            NSString *rightString = self.clarityButtonTagToLabels[@(rightButton.tag)];
            self.rightClarityLabel.text = rightString;
        } else {
            self.rightClarityLabel.text = self.leftClarityLabel.text;
        }
    }
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
    
    [self updateSearchTypeLabel:button.tag];
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
    
    [self updatePolishLabels];
}

# pragma mark - Update polish labels

- (void)updatePolishLabels {
    NSMutableArray *activeButtons = [[NSMutableArray alloc] init];
    for (UIButton *button in self.polishButtons) {
        if (button.selected) {
            [activeButtons addObject:button];
        }
    }
    
    self.leftPolishLabel.text = @"";
    self.rightPolishLabel.text = @"";
    
    if (activeButtons.count > 0) {
        UIButton *leftButton = activeButtons[0];
        NSString *leftString = self.polishButtonTagToLabels[@(leftButton.tag)];
        self.leftPolishLabel.text = leftString;
        
        if (activeButtons.count > 1) {
            UIButton *rightButton = [activeButtons lastObject];
            NSString *rightString = self.polishButtonTagToLabels[@(rightButton.tag)];
            self.rightPolishLabel.text = rightString;
        } else {
            self.rightPolishLabel.text = self.leftPolishLabel.text;
        }
    }
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
    
    [self updateSymmetryLabels];
}

# pragma mark - Update symmetry labels

- (void)updateSymmetryLabels {
    NSMutableArray *activeButtons = [[NSMutableArray alloc] init];
    for (UIButton *button in self.symmetryButtons) {
        if (button.selected) {
            [activeButtons addObject:button];
        }
    }
    
    self.leftSymmetryLabel.text = @"";
    self.rightSymmetryLabel.text = @"";
    
    if (activeButtons.count > 0) {
        UIButton *leftButton = activeButtons[0];
        NSString *leftString = self.symmetryButtonTagToLabels[@(leftButton.tag)];
        self.leftSymmetryLabel.text = leftString;
        
        if (activeButtons.count > 1) {
            UIButton *rightButton = [activeButtons lastObject];
            NSString *rightString = self.symmetryButtonTagToLabels[@(rightButton.tag)];
            self.rightSymmetryLabel.text = rightString;
        } else {
            self.rightSymmetryLabel.text = self.leftSymmetryLabel.text;
        }
    }
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
    
    [self updateCutGradeLabels];
}

# pragma mark - Update cut grade labels

- (void)updateCutGradeLabels {
    NSMutableArray *activeButtons = [[NSMutableArray alloc] init];
    for (UIButton *button in self.cutGradeButtons) {
        if (button.selected) {
            [activeButtons addObject:button];
        }
    }
    
    self.leftCutGradeLabel.text = @"";
    self.rightCutGradeLabel.text = @"";
    
    if (activeButtons.count > 0) {
        UIButton *leftButton = activeButtons[0];
        NSString *leftString = self.cutGradeButtonTagToLabels[@(leftButton.tag)];
        self.leftCutGradeLabel.text = leftString;
        
        if (activeButtons.count > 1) {
            UIButton *rightButton = [activeButtons lastObject];
            NSString *rightString = self.cutGradeButtonTagToLabels[@(rightButton.tag)];
            self.rightCutGradeLabel.text = rightString;
        } else {
            self.rightCutGradeLabel.text = self.leftCutGradeLabel.text;
        }
    }
}

#pragma mark - Select lab

- (IBAction)selectLab:(id)sender {
    UIButton *button = (UIButton *)sender;
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

- (void)updateDepthScaleTintRange {
    float x = self.minDepthSliderHandleImageView.center.x;
    float y = self.depthScaleTintRangeView.frame.origin.y;
    float width = self.maxDepthSliderHandleImageView.center.x - self.minDepthSliderHandleImageView.center.x;
    float height = self.depthScaleTintRangeView.frame.size.height;
    
    self.depthScaleTintRangeView.frame = CGRectMake(x, y, width, height);
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

- (void)updateTableScaleTintRange {
    float x = self.minTableSliderHandleImageView.center.x;
    float y = self.tableScaleTintRangeView.frame.origin.y;
    float width = self.maxTableSliderHandleImageView.center.x - self.minTableSliderHandleImageView.center.x;
    float height = self.tableScaleTintRangeView.frame.size.height;
    
    self.tableScaleTintRangeView.frame = CGRectMake(x, y, width, height);
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
    
    [self updateFluorescenceLabels];
}

# pragma mark - Update fluorescence labels

- (void)updateFluorescenceLabels {
    NSMutableArray *activeButtons = [[NSMutableArray alloc] init];
    for (UIButton *button in self.fluorescenceButtons) {
        if (button.selected) {
            [activeButtons addObject:button];
        }
    }
    
    if (activeButtons.count > 0) {
        UIButton *leftButton = activeButtons[0];
        NSString *leftString = self.fluorescenceButtonTagToLabels[@(leftButton.tag)];
        self.leftFluorescenceLabel.text = leftString;
        
        if (activeButtons.count > 1) {
            UIButton *rightButton = [activeButtons lastObject];
            NSString *rightString = self.fluorescenceButtonTagToLabels[@(rightButton.tag)];
            self.rightFluorescenceLabel.text = rightString;
        } else {
            self.rightFluorescenceLabel.text = self.leftFluorescenceLabel.text;
        }
    }
}

#pragma mark - Reset search filters

- (IBAction)resetSearchFilters:(id)sender {
}

#pragma mark - Search

- (IBAction)search:(id)sender {
    ILUSearchParams *searchParams = [self getSearchParams];
    
    ILUSearchResultsViewController *searchResultsVC = (ILUSearchResultsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"SearchResults"];
    searchResultsVC.searchParams = searchParams;
    appDelegate.viewDeckController.centerController = searchResultsVC;
}

- (ILUSearchParams *)getSearchParams {
    ILUSearchParams *searchParams = [[ILUSearchParams alloc] init];
    
    // budget
    NSString *minBudgetText = self.minBudgetAmountTextField.text;
    minBudgetText = [minBudgetText substringWithRange:NSMakeRange(1, minBudgetText.length-1)];
    minBudgetText = [minBudgetText stringByReplacingOccurrencesOfString:@"," withString:@""];
    searchParams.minBudget = [NSDecimalNumber decimalNumberWithString:minBudgetText];
    
    NSString *maxBudgetText = self.maxBudgetAmountTextField.text;
    maxBudgetText = [maxBudgetText substringWithRange:NSMakeRange(1, maxBudgetText.length-1)];
    maxBudgetText = [maxBudgetText stringByReplacingOccurrencesOfString:@"," withString:@""];
    searchParams.maxBudget = [NSDecimalNumber decimalNumberWithString:maxBudgetText];
    
    // shape
    for (UIButton *shapeButton in self.shapeButtons) {
        if (shapeButton.selected) {
            NSString *shapeButtonLabel = self.shapeButtonTagToLabels[@(shapeButton.tag)];
            [searchParams.shapes addObject:shapeButtonLabel];
        }
    }
    
    // carat
    NSString *minCaratText = self.minCaratTextField.text;
    minCaratText = [minCaratText substringWithRange:NSMakeRange(0, minCaratText.length-3)];
    searchParams.minCarat = [minCaratText floatValue];
    
    NSString *maxCaratText = self.maxCaratTextField.text;
    maxCaratText = [maxCaratText substringWithRange:NSMakeRange(0, maxCaratText.length-3)];
    searchParams.maxCarat = [maxCaratText floatValue];
    
    // color
    for (UIButton *simpleColorButton in self.colorScaleButtons) {
        if (simpleColorButton.selected) {
            [searchParams.simpleColors addObject:simpleColorButton.titleLabel.text];
        }
    }
    
    for (UIButton *fancyColor1Button in self.fancyColor1Buttons) {
        if (fancyColor1Button.selected) {
            NSString *fancyColor1ButtonLabel = self.fancyColor1ButtonTagToLabels[@(fancyColor1Button.tag)];
            [searchParams.fancyColors1 addObject:fancyColor1ButtonLabel];
        }
    }
    
    for (UIButton *fancyColor2Button in self.fancyColor2Buttons) {
        if (fancyColor2Button.selected) {
            NSString *fancyColor2ButtonLabel = self.fancyColor2ButtonTagToLabels[@(fancyColor2Button.tag)];
            [searchParams.fancyColors2 addObject:fancyColor2ButtonLabel];
        }
    }
    
    // clarity
    for (UIButton *clarityButton in self.clarityButtons) {
        if (clarityButton.selected) {
            NSString *clarityButtonLabel = self.clarityButtonTagToLabels[@(clarityButton.tag)];
            [searchParams.clarities addObject:clarityButtonLabel];
        }
    }
    
    // polish
    for (UIButton *polishButton in self.polishButtons) {
        if (polishButton.selected) {
            NSString *polishButtonLabel = self.polishButtonTagToLabels[@(polishButton.tag)];
            [searchParams.polishes addObject:polishButtonLabel];
        }
    }
    
    // symmetry
    for (UIButton *symmetryButton in self.symmetryButtons) {
        if (symmetryButton.selected) {
            NSString *symmetryButtonLabel = self.symmetryButtonTagToLabels[@(symmetryButton.tag)];
            [searchParams.symmetries addObject:symmetryButtonLabel];
        }
    }
    
    // cut grade
    for (UIButton *cutGradeButton in self.cutGradeButtons) {
        if (cutGradeButton.selected) {
            NSString *cutGradeButtonLabel = self.cutGradeButtonTagToLabels[@(cutGradeButton.tag)];
            [searchParams.cutGrades addObject:cutGradeButtonLabel];
        }
    }
    
    // lab
    for (UIButton *labButton in self.labButtons) {
        if (labButton.selected) {
            NSString *labButtonLabel = self.labButtonTagToLabels[@(labButton.tag)];
            [searchParams.labs addObject:labButtonLabel];
        }
    }
    
    // depth
    NSString *minDepthText = self.minDepthLabel.text;
    minDepthText = [minDepthText substringWithRange:NSMakeRange(0, minDepthText.length-1)];
    searchParams.minDepth = [minDepthText intValue];
    
    NSString *maxDepthText = self.maxDepthLabel.text;
    maxDepthText = [maxDepthText substringWithRange:NSMakeRange(0, maxDepthText.length-1)];
    searchParams.maxDepth = [maxDepthText intValue];
    
    // table
    NSString *minTableText = self.minTableLabel.text;
    minTableText = [minTableText substringWithRange:NSMakeRange(0, minTableText.length-1)];
    searchParams.minTable = [minTableText intValue];
    
    NSString *maxTableText = self.maxTableLabel.text;
    maxTableText = [maxTableText substringWithRange:NSMakeRange(0, maxTableText.length-1)];
    searchParams.maxTable = [maxTableText intValue];
    
    // fluorescence
    for (UIButton *fluorescenceButton in self.fluorescenceButtons) {
        if (fluorescenceButton.selected) {
            NSString *fluorescenceButtonLabel = self.fluorescenceButtonTagToLabels[@(fluorescenceButton.tag)];
            [searchParams.fluorescences addObject:fluorescenceButtonLabel];
        }
    }
    
    return searchParams;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.minBudgetAmountTextField || textField == self.maxBudgetAmountTextField) {
        textField.text = @"$";
    } else if (textField == self.minCaratTextField || textField == self.maxCaratTextField) {
        textField.text = @"ct.";
        dispatch_async(dispatch_get_main_queue(), ^{
            textField.selectedTextRange = [textField textRangeFromPosition:textField.beginningOfDocument
                                                                toPosition:textField.beginningOfDocument];
        });
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.minBudgetAmountTextField || textField == self.maxBudgetAmountTextField) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        
        // test for invalid number to set to 0
        @try {
            NSNumber *number = [numberFormatter numberFromString:[textField.text substringFromIndex:1]];
            if (!number) {
                textField.text = @"$0";
            }
        }
        @catch (NSException *e) {
            textField.text = @"$0";
        }
    }
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.minBudgetAmountTextField || textField == self.maxBudgetAmountTextField) {
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        
        // only allow numbers and commas
        NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789,"] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
        
    //    if ([string isEqualToString:filtered] && newLength >= 1 && newLength <= 10) {
    //        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    //        numberFormatter.locale = [NSLocale currentLocale];
    //        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    //        numberFormatter.usesGroupingSeparator = YES;
    //        textField.text = [NSString stringWithFormat:@"$%@", [numberFormatter stringForObjectValue:textField.text]];
    //    }
        
        return ([string isEqualToString:filtered] && newLength >= 1 && newLength <= 10) || returnKey;
    }
    
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
