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
#import "HomeMap.h"
#import "SoundEngine.h"

@implementation HomeBuildingMenu

@synthesize titleLabel, incomeLabel, rankLabel;

- (void) updateForUserStruct:(UserStruct *)us {
  if (us == nil) {
    return;
  }
  
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
@synthesize timer, userStruct;

- (void) updateForUserStruct:(UserStruct *)us {
  if (us == nil) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullStructureProto *fsp = [gs structWithId:us.structId];
  coinsLabel.text = [NSString stringWithFormat:@"%d", [gl calculateIncomeForUserStruct:us]];
  
  self.userStruct = us;
  
  [self updateMenu];
  
  NSDate *retrieveDate = [us.lastRetrieved dateByAddingTimeInterval:fsp.minutesToGain*60];
  progressBar.percentage = 1.f - retrieveDate.timeIntervalSinceNow/(fsp.minutesToGain*60);
  [UIView animateWithDuration:retrieveDate.timeIntervalSinceNow animations:^{
    progressBar.percentage = 1.f;
  }];
  
  self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateMenu) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void) updateMenu {
  GameState *gs = [GameState sharedGameState];
  UserStruct *us = self.userStruct;
  FullStructureProto *fsp = [gs structWithId:us.structId];
  
  NSDate *retrieveDate = [us.lastRetrieved dateByAddingTimeInterval:fsp.minutesToGain*60];
  timeLabel.text = [Globals convertTimeToString:retrieveDate.timeIntervalSinceNow];
}

- (void) setTimer:(NSTimer *)t {
  if (timer != t) {
    [timer invalidate];
    [timer release];
    timer = [t retain];
  }
}

- (void) setAlpha:(CGFloat)alpha {
  [super setAlpha:alpha];
  if (alpha == 0.f) {
    [self.progressBar.layer removeAllAnimations];
    self.timer = nil;
    self.userStruct = nil;
  }
}

- (void) dealloc {
  self.userStruct = nil;
  self.timer = nil;
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
  if (us == nil) {
    return;
  }
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullStructureProto *fsp = [gs structWithId:us.structId];
  
  titleLabel.text = fsp.name;
  
  if (us.state == kBuilding) {
    currentIncomeLabel.text = @"No Current Income";
    upgradedIncomeLabel.text = [NSString stringWithFormat:@"%d in %@", [gl calculateIncomeForUserStruct:us], [Globals convertTimeToString:fsp.minutesToGain*60]];
  } else {
    currentIncomeLabel.text = [NSString stringWithFormat:@"%d in %@", [gl calculateIncomeForUserStruct:us], [Globals convertTimeToString:fsp.minutesToGain*60]];
    upgradedIncomeLabel.text = [NSString stringWithFormat:@"%d in %@", [gl calculateIncomeForUserStructAfterLevelUp:us], [Globals convertTimeToString:fsp.minutesToGain*60]];
  }
  
  self.userStruct = us;
  
  if (us.state == kWaitingForIncome) {
    self.timer = nil;
    
    upgradeTimeLabel.text = [Globals convertTimeToString:[gl calculateMinutesToUpgrade:us]*60];
    upgradePriceLabel.text = [Globals commafyNumber:[gl calculateUpgradeCost:us]];
    
    hazardSign.hidden = YES;
    upgradingBottomView.hidden = YES;
    upgradingMiddleView.hidden = YES;
    notUpgradingBottomView.hidden = NO;
    notUpgradingMiddleView.hidden = NO;
  } else if (us.state == kUpgrading || us.state == kBuilding) {
    [self updateMenu];
    
    self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateMenu) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    hazardSign.hidden = NO;
    upgradingBottomView.hidden = NO;
    upgradingMiddleView.hidden = NO;
    notUpgradingBottomView.hidden = YES;
    notUpgradingMiddleView.hidden = YES;
  }
  
  [Globals loadImageForStruct:fsp.structId toView:structIcon masked:NO indicator:UIActivityIndicatorViewStyleWhiteLarge];
  
  if (!self.superview) {
    [Globals displayUIView:self];
    [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  }
}

- (void) updateMenu {
  UserStruct *us = self.userStruct;
  if (us.state == kWaitingForIncome) {
    self.timer = nil;
    [self displayForUserStruct:us];
  } else {
    GameState *gs = [GameState sharedGameState];
    Globals *gl = [Globals sharedGlobals];
    FullStructureProto *fsp = [gs structWithId:us.structId];
    
    NSDate *startTime = nil;
    int secsToUpgrade = 0;
    
    if (us.state == kUpgrading) {
      startTime = us.lastUpgradeTime;
      secsToUpgrade = [gl calculateMinutesToUpgrade:us]*60;
    } else {
      startTime = us.purchaseTime;
      secsToUpgrade = fsp.minutesToBuild*60;
    }
    NSDate *date = [startTime dateByAddingTimeInterval:secsToUpgrade];;
    timeLeftLabel.text = [Globals convertTimeToString:date.timeIntervalSinceNow];
    progressBar.percentage = 1.f - date.timeIntervalSinceNow/secsToUpgrade;
  }
}

- (void) finishNow:(void(^)(void))completed {
  // Called from home map to move bar to end
  self.timer = nil;
  float secs = PROGRESS_BAR_SPEED*(1.f-progressBar.percentage);
  self.mainView.userInteractionEnabled = NO;
  [UIView animateWithDuration:secs animations:^{
    progressBar.percentage = 1.f;
  } completion:^(BOOL finished) {
    self.mainView.userInteractionEnabled = YES;
    
    [[SoundEngine sharedSoundEngine] carpenterComplete];
    
    Globals *gl = [Globals sharedGlobals];
    if (userStruct.level < gl.maxLevelForStruct) {
      [self displayForUserStruct:self.userStruct];
    } else {
      [self closeClicked:nil];
    }
    
    if (completed) {
      completed();
    }
  }];
}

- (IBAction)closeClicked:(id)sender {
  if (self.superview) {
    self.timer = nil;
    self.userStruct = nil;
    [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
      [self removeFromSuperview];
      [[HomeMap sharedHomeMap] upgradeMenuClosed];
    }];
    
  }
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