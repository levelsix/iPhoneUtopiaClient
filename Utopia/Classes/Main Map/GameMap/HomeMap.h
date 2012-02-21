//
//  HomeMap.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GameMap.h"

typedef enum {
  kNormalState = 1,
  kSellState,
  kUpgradeState,
  kProgressState,
  kMoveState
} HomeBuildingState;

@interface UpgradeButtonOverlay : UIView 

@property (nonatomic, retain) UIImage *fullStar;
@property (nonatomic, retain) UIImage *emptyStar;

@property (nonatomic, assign) int level;

@end

@interface HomeBuildingInfoView : UIView 

@property (nonatomic, retain) IBOutlet UIView *sellView;
@property (nonatomic, retain) IBOutlet UIView *incomeView;
@property (nonatomic, retain) IBOutlet UIButton *upgradeButton;
@property (nonatomic, retain) IBOutlet UILabel *sellCostLabel;
@property (nonatomic, retain) IBOutlet UIImageView *sellCoinImageView;

@property (nonatomic, retain) UpgradeButtonOverlay *starView;

- (void) setSellCostString:(NSString *)s;

@end

@interface HomeBuildingUpgradeView : UIView 

@property (nonatomic, retain) IBOutlet UIView *costView;
@property (nonatomic, retain) IBOutlet UILabel *costLabel;

- (void) setUpgradeCostString:(NSString *)s;

@end

@interface HomeBuildingMenu : UIView <UIScrollViewDelegate> {
  HomeBuildingState _state;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet LabelButton *blueButton;
@property (nonatomic, retain) IBOutlet LabelButton *redButton;
@property (nonatomic, retain) IBOutlet LabelButton *greenButton;
@property (nonatomic, retain) IBOutlet HomeBuildingInfoView *infoView;
@property (nonatomic, retain) IBOutlet HomeBuildingUpgradeView *upgradeView;
@property (nonatomic, retain) IBOutlet UIView *progressView;
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *moveView;
@property (nonatomic, retain) IBOutlet UIButton *finishNowButton;

@property (nonatomic, retain) IBOutlet UILabel *incomeLabel;
@property (nonatomic, retain) IBOutlet UILabel *retrieveTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *upgradeCurIncomeLabel;
@property (nonatomic, retain) IBOutlet UILabel *upgradeNewIncomeLabel;

@property (nonatomic, retain) IBOutlet UIImageView *progressBar;
@property (nonatomic, retain) IBOutlet UILabel *finishTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *instaFinishCostLabel;

@property (nonatomic, assign) HomeBuildingState state;

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) NSDate *retrievalTime;
@property (nonatomic, retain) NSDate *upgradeTime;
@property (nonatomic, assign) NSTimeInterval totalUpgradeTime;

- (void) setFrameForPoint:(CGPoint)pt;
- (void) setProgressBarProgress:(float)val;
- (float) progressBarProgress;
- (void) startTimer;

@end

@interface HomeMap : GameMap {
  NSMutableArray *_buildableData;
  BOOL _isMoving;
  BOOL _canMove;
  BOOL _loading;
  
  HomeBuilding *_constructing;
  HomeBuilding *_upgrading;
}

@property (nonatomic, retain) NSMutableArray *buildableData;

@property (nonatomic, retain) IBOutlet HomeBuildingMenu *hbMenu;

@property (nonatomic, assign, readonly) BOOL loading;

+ (HomeMap *)sharedHomeMap;

- (void) changeTiles: (CGRect) buildBlock toBuildable:(BOOL)canBuild;
- (BOOL) isBlockBuildable: (CGRect) buildBlock;
- (void) updateHomeBuildingMenu;
- (void) refresh;
- (int) baseTagForStructId:(int)structId;

- (IBAction)leftButtonClicked:(id)sender;
- (IBAction)moveCheckClicked:(id)sender;
- (IBAction)rotateClicked:(id)sender;
- (IBAction)redButtonClicked:(id)sender;
- (IBAction)bigUpgradeClicked:(id)sender;
- (IBAction)littleUpgradeClicked:(id)sender;
- (IBAction)finishNowClicked:(id)sender;

@end