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
#import "RefillMenuController.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"

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
  incomeLabel.text = [NSString stringWithFormat:@"%d in %@", [gl calculateIncomeForUserStruct:us], [Globals convertTimeToString:fsp.minutesToGain*60 withDays:YES]];
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
  timeLabel.text = [Globals convertTimeToString:retrieveDate.timeIntervalSinceNow withDays:YES];
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
@synthesize structIcon, coinIcon, coinLabel;
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
    upgradedIncomeLabel.text = [NSString stringWithFormat:@"%d in %@", [gl calculateIncomeForUserStruct:us], [Globals convertTimeToString:fsp.minutesToGain*60 withDays:YES]];
  } else {
    currentIncomeLabel.text = [NSString stringWithFormat:@"%d in %@", [gl calculateIncomeForUserStruct:us], [Globals convertTimeToString:fsp.minutesToGain*60 withDays:YES]];
    upgradedIncomeLabel.text = [NSString stringWithFormat:@"%d in %@", [gl calculateIncomeForUserStructAfterLevelUp:us], [Globals convertTimeToString:fsp.minutesToGain*60 withDays:YES]];
  }
  
  self.userStruct = us;
  
  if (us.state == kWaitingForIncome) {
    self.timer = nil;
    
    upgradeTimeLabel.text = [Globals convertTimeToString:[gl calculateMinutesToUpgrade:us]*60 withDays:YES];
    upgradePriceLabel.text = [Globals commafyNumber:[gl calculateUpgradeCost:us]];
    coinIcon.highlighted = fsp.diamondPrice > 0;
    
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
    int goldCost = 0;
    int timeLeft = 0;
    
    if (us.state == kUpgrading) {
      startTime = us.lastUpgradeTime;
      secsToUpgrade = [gl calculateMinutesToUpgrade:us]*60;
      timeLeft = startTime.timeIntervalSinceNow + secsToUpgrade;
      goldCost = [gl calculateDiamondCostForInstaUpgrade:us timeLeft:timeLeft];
    } else {
      startTime = us.purchaseTime;
      secsToUpgrade = fsp.minutesToUpgradeBase*60;
      timeLeft = startTime.timeIntervalSinceNow + secsToUpgrade;
      goldCost = [gl calculateDiamondCostForInstaBuild:us timeLeft:timeLeft];
    }
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:timeLeft];
    timeLeftLabel.text = [Globals convertTimeToString:timeLeft withDays:YES];
    progressBar.percentage = 1.f - date.timeIntervalSinceNow/secsToUpgrade;
    coinLabel.text = [Globals commafyNumber:goldCost];
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
  self.coinIcon = nil;
  self.coinLabel = nil;
  [super dealloc];
}

@end

@implementation ExpansionView

@synthesize mainView, bgdView;
@synthesize farLeftArrow, farRightArrow, nearLeftArrow, nearRightArrow;
@synthesize expandingSign, progressBar;
@synthesize titleLabel, buttonLabel, timeLeftLabel, totalTimeLabel, costLabel;
@synthesize expandingView, cantExpandView, expandNowView;
@synthesize timer;

- (void) awakeFromNib {
  self.expandNowView.center = expandingView.center;
  [self.mainView addSubview:self.expandNowView];
  
  self.cantExpandView.center = expandingView.center;
  [self.mainView addSubview:cantExpandView];
}

- (void) setTimer:(NSTimer *)t {
  if (timer != t) {
    [timer invalidate];
    [timer release];
    timer = [t retain];
  }
}

- (UIImageView *) arrowForDirection:(ExpansionDirection)direction {
  if (direction == ExpansionDirectionNearLeft) {
    return nearLeftArrow;
  } else if (direction == ExpansionDirectionNearRight) {
    return nearRightArrow;
  } else if (direction == ExpansionDirectionFarLeft) {
    return farLeftArrow;
  } else if (direction == ExpansionDirectionFarRight) {
    return farRightArrow;
  }
  return nil;
}

- (void) displayForDirection:(ExpansionDirection)direction {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  UserExpansion *ue = gs.userExpansion;
  
  UIImageView *visibleArrow = nil;
  
  _direction = direction;
  
  self.timer = nil;
  
  if (!ue || !ue.isExpanding) {
    expandingSign.hidden = YES;
    expandingView.hidden = YES;
    cantExpandView.hidden = YES;
    expandNowView.hidden = NO;
    
    visibleArrow = [self arrowForDirection:direction];
    
    buttonLabel.text = @"EXPAND KINGDOM";
    titleLabel.text = @"Expand Now!";
    
    costLabel.text = [Globals commafyNumber:[gl calculateSilverCostForNewExpansion:ue]];
    totalTimeLabel.text = [NSString stringWithFormat:@"%d Hours", [gl calculateNumMinutesForNewExpansion:ue]/60];
  } else {
    expandingSign.hidden = NO;
    expandNowView.hidden = YES;
    
    visibleArrow = [self arrowForDirection:ue.lastExpandDirection];
    
    buttonLabel.text = @"FINISH NOW";
    titleLabel.text = @"Expanding";
    
    if (direction == ue.lastExpandDirection) {
      expandingView.hidden = NO;
      cantExpandView.hidden = YES;
      
      [self updateMenu];
      self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateMenu) userInfo:nil repeats:YES];
      [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    } else {
      expandingView.hidden = YES;
      cantExpandView.hidden = NO;
    }
  }
  
  farLeftArrow.hidden = (farLeftArrow != visibleArrow);
  farRightArrow.hidden = (farRightArrow != visibleArrow);
  nearLeftArrow.hidden = (nearLeftArrow != visibleArrow);
  nearRightArrow.hidden = (nearRightArrow != visibleArrow);
  
  if (!self.superview) {
    [Globals displayUIView:self];
    [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  }
}

- (void) updateMenu {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSDate *startTime = nil;
  int secsToExpand = 0;
  
  startTime = gs.userExpansion.lastExpandTime;
  secsToExpand = 60*[gl calculateNumMinutesForNewExpansion:gs.userExpansion];
  
  NSDate *date = [startTime dateByAddingTimeInterval:secsToExpand];
  if ([date compare:[NSDate date]] == NSOrderedAscending) {
    [self closeClicked:nil];
  } else {
    timeLeftLabel.text = [Globals convertTimeToString:date.timeIntervalSinceNow withDays:YES];
    progressBar.percentage = 1.f - date.timeIntervalSinceNow/secsToExpand;
  }
}

- (IBAction)bottomButtonClicked:(id)sender {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  UserExpansion *ue = gs.userExpansion;
  
  if (!ue || !ue.isExpanding) {
    int silverCost = [gl calculateSilverCostForNewExpansion:ue];
    if (gs.silver < silverCost) {
      [[RefillMenuController sharedRefillMenuController] displayBuySilverView:silverCost];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] purchaseCityExpansion:_direction];
      [self displayForDirection:_direction];
      [[HomeMap sharedHomeMap] refresh];
    }
  } else {
    int timeLeft = ue.lastExpandTime.timeIntervalSinceNow + [gl calculateNumMinutesForNewExpansion:ue]*60;
    int goldCost = [gl calculateGoldCostToSpeedUpExpansion:ue timeLeft:timeLeft];
    NSString *desc = [NSString stringWithFormat:@"Would you like to speed up this expansion for %d gold?", goldCost];
    [GenericPopupController displayConfirmationWithDescription:desc title:@"Speed Up?" okayButton:@"Speed Up" cancelButton:nil target:self selector:@selector(speedUp)];
  }
}

- (void) speedUp {
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  UserExpansion *ue = gs.userExpansion;
  
  int timeLeft = ue.lastExpandTime.timeIntervalSinceNow + [gl calculateNumMinutesForNewExpansion:ue]*60;
  int goldCost = [gl calculateGoldCostToSpeedUpExpansion:ue timeLeft:timeLeft];
  if (gs.gold < goldCost) {
    [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:goldCost];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] expansionWaitComplete:YES];
    
    self.timer = nil;
    float secs = PROGRESS_BAR_SPEED*(1.f-progressBar.percentage);
    [UIView animateWithDuration:secs animations:^{
      progressBar.percentage = 1.f;
    } completion:^(BOOL finished) {
      [[HomeMap sharedHomeMap] refresh];
      [self closeClicked:nil];
    }];
  }
}

- (IBAction)closeClicked:(id)sender {
  if (self.superview) {
    self.timer = nil;
    [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
      [self removeFromSuperview];
    }];
  }
}

- (void) dealloc {
  self.mainView = nil;
  self.bgdView = nil;
  self.farLeftArrow = nil;
  self.farRightArrow = nil;
  self.nearLeftArrow = nil;
  self.nearRightArrow = nil;
  self.expandingView = nil;
  self.expandingSign = nil;
  self.progressBar = nil;
  self.titleLabel = nil;
  self.buttonLabel = nil;
  self.timeLeftLabel = nil;
  self.totalTimeLabel = nil;
  self.costLabel = nil;
  self.cantExpandView = nil;
  self.expandNowView = nil;
  self.timer = nil;
  [super dealloc];
}

@end
