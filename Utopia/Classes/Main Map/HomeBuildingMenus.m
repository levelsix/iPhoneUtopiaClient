//
//  HomeBuildingMenus.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/24/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "HomeBuildingMenus.h"
#import "GameState.h"
#import "Globals.h"

@implementation HomeBuildingMenu

@synthesize titleLabel, incomeLabel, rankLabel;

- (void) updateForUserStruct:(UserStruct *)us {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullStructureProto *fsp = [gs structWithId:us.structId];
  
  titleLabel.text = fsp.name;
  incomeLabel.text = [NSString stringWithFormat:@"%d in %@", [gl calculateIncomeForUserStruct:us], [Globals convertTimeToString:fsp.minutesToGain*60]];
  rankLabel.text = [NSString stringWithFormat:@"%d", us.level];
}

- (void) dealloc {
  self.titleLabel = nil;
  self.incomeLabel = nil;
  self.rankLabel = nil;
  
  [super dealloc];
}

@end

@implementation HomeBuildingCollectMenu

@synthesize coinsLabel, timeLabel, progressBar;

- (void) updateForUserStruct:(UserStruct *)us {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  FullStructureProto *fsp = [gs structWithId:us.structId];
  coinsLabel = [NSString stringWithFormat:@"%d", [gl calculateIncomeForUserStruct:us]];
  
  NSDate *retrieveDate = [us.lastRetrieved dateByAddingTimeInterval:fsp.minutesToGain*60];
  timeLabel.text = [Globals convertTimeToString:retrieveDate.timeIntervalSinceNow];
  
  progressBar.percentage = retrieveDate.timeIntervalSinceNow / (fsp.minutesToGain*60);
}

- (void) dealloc {
  self.coinsLabel = nil;
  self.timeLabel = nil;
  self.progressBar = nil;
  [super dealloc];
}

@end

@implementation UpgradeBuildingMenu

@synthesize titleLabel;
@synthesize currentIncomeLabel, upgradedIncomeLabel;
@synthesize upgradeTimeLabel, upgradePriceLabel;
@synthesize structIcon;
@synthesize mainView, bgdView;
@synthesize upgradingBottomView, upgradingMiddleView;
@synthesize progressBar, hazardSign, timeLeftLabel;
@synthesize notUpgradingBottomView, notUpgradingMiddleView;
@synthesize timer, userStruct;

- (void) awakeFromNib {
  [self.mainView addSubview:notUpgradingBottomView];
  notUpgradingBottomView.frame = upgradingBottomView.frame;
  
  [self.mainView addSubview:notUpgradingMiddleView];
  notUpgradingMiddleView.frame = upgradingMiddleView.frame;
}

- (void) setTimer:(NSTimer *)t {
  if (timer != t) {
    [timer invalidate];
    [timer release];
    timer = [t retain];
  }
}

- (void) displayForUserStruct:(UserStruct *)us {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullStructureProto *fsp = [gs structWithId:us.structId];
  
  titleLabel.text = fsp.name;
  currentIncomeLabel.text = [NSString stringWithFormat:@"%d in %@", [gl calculateIncomeForUserStruct:us], [Globals convertTimeToString:fsp.minutesToGain*60]];
  upgradedIncomeLabel.text = [NSString stringWithFormat:@"%d in %@", [gl calculateIncomeForUserStructAfterLevelUp:us], [Globals convertTimeToString:fsp.minutesToGain*60]];
  
  if (us.state == kWaitingForIncome) {
    upgradeTimeLabel.text = [Globals convertTimeToString:[gl calculateMinutesToUpgrade:us]*60];
    upgradePriceLabel.text = [Globals commafyNumber:[gl calculateUpgradeCost:us]];
    
    hazardSign.hidden = YES;
    upgradingBottomView.hidden = YES;
    upgradingMiddleView.hidden = YES;
    notUpgradingBottomView.hidden = NO;
    notUpgradingMiddleView.hidden = NO;
  } else if (us.state == kUpgrading || us.state == kBuilding) {
    NSDate *date = us.state == kUpgrading ? [us.lastUpgradeTime dateByAddingTimeInterval:[gl calculateMinutesToUpgrade:us]*60] : [us.purchaseTime dateByAddingTimeInterval:fsp.minutesToBuild*60];
    timeLeftLabel.text = [Globals convertTimeToString:date.timeIntervalSinceNow];
    
#warning schedule timers
    self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateMenu) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    hazardSign.hidden = NO;
    upgradingBottomView.hidden = NO;
    upgradingMiddleView.hidden = NO;
    notUpgradingBottomView.hidden = YES;
    notUpgradingMiddleView.hidden = YES;
  }
  
  [Globals loadImageForStruct:fsp.structId toView:structIcon masked:NO];
  
  if (!self.superview) {
    [Globals displayUIView:self];
    [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  }
}

- (IBAction)closeClicked:(id)sender {
  self.timer = nil;
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self removeFromSuperview];
  }];
}

- (IBAction)upgradeClicked:(id)sender {
  
}

- (IBAction)finishNowClicked:(id)sender {
  
}

- (IBAction)moveClicked:(id)sender {
  
}

- (void) dealloc {
  self.titleLabel = nil;
  self.currentIncomeLabel = nil;
  self.upgradedIncomeLabel = nil;
  self.upgradeTimeLabel = nil;
  self.upgradePriceLabel = nil;
  self.structIcon = nil;
  self.mainView = nil;
  self.bgdView = nil;
  self.upgradingMiddleView = nil;
  self.upgradingBottomView = nil;
  self.progressBar = nil;
  self.hazardSign = nil;
  self.timeLeftLabel = nil;
  self.notUpgradingBottomView = nil;
  self.notUpgradingMiddleView = nil;
  self.timer = nil;
  self.userStruct = nil;
  [super dealloc];
}

@end