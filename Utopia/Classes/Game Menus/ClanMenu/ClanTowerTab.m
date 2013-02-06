//
//  ClanTowerTab.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/5/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ClanTowerTab.h"
#import "GameState.h"
#import "ClanMenuController.h"
#import "OutgoingEventController.h"
#import "GenericPopupController.h"

#define TOWER_VIEW_SPACING 9.f

@implementation ClanTowerInfoView

- (void) awakeFromNib {
  self.notWarView.frame = self.warView.frame;
  [self addSubview:self.notWarView];
}

- (void) updateForTower:(ClanTowerProto *)t {
  GameState *gs = [GameState sharedGameState];
  if (!t.hasTowerOwner) {
    self.warView.hidden = YES;
    self.notWarView.hidden = NO;
    
    self.middleLabel.text = @"This tower is unclaimed.";
    self.buttonLabel.text = @"Claim";
    self.ownerLabel.text = @"Uncontrolled";
    self.ownerLabel.textColor = [Globals creamColor];
    
    [Globals adjustViewForCentering:self.ownerLabel.superview withLabel:self.ownerLabel];
    
    self.claimButtonView.hidden = NO;
    self.sameSideLabel.hidden = YES;
  } else if (!t.hasTowerAttacker) {
    self.warView.hidden = YES;
    self.notWarView.hidden = NO;
    
    self.middleLabel.text = @"This tower is not engaged in war.";
    self.buttonLabel.text = @"Wage War";
    
    self.ownerLabel.text = t.towerOwner.name;
    self.ownerLabel.textColor = t.towerOwner.isGood ? [Globals blueColor] : [Globals redColor];
    
    [Globals adjustViewForCentering:self.ownerLabel.superview withLabel:self.ownerLabel];
    
    BOOL canWageWar = (gs.clan.isGood != t.towerOwner.isGood);
    self.claimButtonView.hidden = !canWageWar;
    self.sameSideLabel.hidden = canWageWar;
  } else {
    // In a war
    self.ownerNameLabel.text = t.towerOwner.name;
    self.ownerNameLabel.textColor = t.towerOwner.isGood ? [Globals blueColor] : [Globals redColor];
    self.attackerNameLabel.text = t.towerAttacker.name;
    self.attackerNameLabel.textColor = t.towerAttacker.isGood ? [Globals blueColor] : [Globals redColor];
    
    self.ownerWinsLabel.text = [Globals commafyNumber:t.ownerBattlesWin];
    self.attackerWinsLabel.text = [Globals commafyNumber:t.attackerBattlesWin];
    
    double percent = 0.5;
    if (t.ownerBattlesWin + t.attackerBattlesWin > 0) {
      percent = t.ownerBattlesWin/(double)(t.ownerBattlesWin+t.attackerBattlesWin);
    }
    
    ProgressBar *front = t.towerOwner.isGood ? self.goodProgressBar : self.badProgressBar;
    ProgressBar *back = !t.towerOwner.isGood ? self.goodProgressBar : self.badProgressBar;
    back.percentage = 1.f;
    front.percentage = percent;
    
    [self.warView bringSubviewToFront:front];
    [self.warView bringSubviewToFront:self.ownerPercentLabel];
    [self.warView bringSubviewToFront:self.attackerPercentLabel];
    
    double roundedPercent = round(percent*1000)/10.;
    self.ownerPercentLabel.text = [NSString stringWithFormat:@"%.1f%%", roundedPercent];
    self.attackerPercentLabel.text = [NSString stringWithFormat:@"%.1f%%", 100.-roundedPercent];
    
    self.bottomLabel.text = [NSString stringWithFormat:@"%@ has  controlled the %@ for:", t.towerOwner.name, t.towerName];
    
    self.warView.hidden = NO;
    self.notWarView.hidden = YES;
    
    [Globals adjustViewForCentering:self.ownerNameLabel.superview withLabel:self.ownerNameLabel];
    
    if (gs.userId == t.towerOwner.ownerId || gs.userId == t.towerAttacker.ownerId) {
      self.concedeView.hidden = NO;
    } else {
      self.concedeView.hidden = YES;
    }
  }
  
  [self updateTimeForTower:t];
}

- (void) updateTimeForTower:(ClanTowerProto *)t {
  if (t.hasTowerOwner && t.hasTowerAttacker) {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:t.ownedStartTime/1000.];
    NSString *ts = [Globals convertTimeToString:-date.timeIntervalSinceNow withDays:YES];
    NSString *rev = [ts reverseString];
    
    self.rightSecondLabel.text = [rev substringWithRange:NSMakeRange(0, 1)];
    self.leftSecondLabel.text = [rev substringWithRange:NSMakeRange(1, 1)];
    self.rightMinuteLabel.text = [rev substringWithRange:NSMakeRange(3, 1)];
    self.leftMinuteLabel.text = [rev substringWithRange:NSMakeRange(4, 1)];
    self.rightHourLabel.text = [rev substringWithRange:NSMakeRange(6, 1)];
    self.leftHourLabel.text = [rev substringWithRange:NSMakeRange(7, 1)];
    
    if (rev.length > 8) {
      if (rev.length == 10) rev = [rev stringByAppendingString:@"0"];
      self.rightDayLabel.text = [rev substringWithRange:NSMakeRange(9, 1)];
      self.leftDayLabel.text = [rev substringWithRange:NSMakeRange(10, 1)];
      
      if (self.dayLabelsView.hidden) {
        self.dayLabelsView.hidden = NO;
        
        CGRect r = self.otherTimeLabelsView.frame;
        r.origin.x = CGRectGetMaxX(self.dayLabelsView.frame);
        self.otherTimeLabelsView.frame = r;
        
        r = self.timeLabelsContainerView.frame;
        r.size.width = CGRectGetMaxX(self.otherTimeLabelsView.frame);
        self.timeLabelsContainerView.frame = r;
        
        self.timeLabelsContainerView.center = CGPointMake(self.timeLabelsContainerView.superview.frame.size.width/2, self.timeLabelsContainerView.center.y);
      }
    } else {
      if (!self.dayLabelsView.hidden) {
        self.dayLabelsView.hidden = YES;
        
        CGRect r = self.otherTimeLabelsView.frame;
        r.origin.x = 0;
        self.otherTimeLabelsView.frame = r;
        
        r = self.timeLabelsContainerView.frame;
        r.size.width = CGRectGetMaxX(self.otherTimeLabelsView.frame);
        self.timeLabelsContainerView.frame = r;
        
        self.timeLabelsContainerView.center = CGPointMake(self.timeLabelsContainerView.superview.frame.size.width/2, self.timeLabelsContainerView.center.y);
      }
    }
  }
}

- (void) dealloc {
  self.ownerNameLabel = nil;
  self.attackerNameLabel = nil;
  self.ownerWinsLabel = nil;
  self.attackerWinsLabel = nil;
  self.ownerPercentLabel = nil;
  self.attackerPercentLabel = nil;
  self.badProgressBar = nil;
  self.goodProgressBar = nil;
  self.warView = nil;
  self.notWarView = nil;
  self.middleLabel = nil;
  self.buttonLabel = nil;
  self.ownerLabel = nil;
  self.bottomLabel = nil;
  self.concedeView = nil;
  self.sameSideLabel = nil;
  self.claimButtonView = nil;
  self.rightDayLabel = nil;
  self.leftDayLabel = nil;
  self.rightHourLabel = nil;
  self.leftHourLabel = nil;
  self.rightMinuteLabel = nil;
  self.leftMinuteLabel = nil;
  self.rightSecondLabel = nil;
  self.leftSecondLabel = nil;
  self.dayLabelsView = nil;
  self.otherTimeLabelsView = nil;
  self.timeLabelsContainerView = nil;
  [super dealloc];
}

@end

@implementation ClanTowerView

- (void) awakeFromNib {
  self.peaceView.frame = self.warView.frame;
  [self addSubview:self.peaceView];
}

- (void) updateForTower:(ClanTowerProto *)t {
  self.nameLabel.text = t.towerName;
  
  UIColor *c = [Globals colorForColorProto:t.titleColor];
  self.nameLabel.textColor = c;
  
  UIImage *img = [Globals imageNamed:t.towerImageName];
  [self.bgdButton setImage:img forState:UIControlStateNormal];
  
  if (t.hasTowerAttacker) {
    self.ownerWarLabel.text = t.towerOwner.name;
    self.ownerWarLabel.textColor = t.towerOwner.isGood ? [Globals blueColor] : [Globals redColor];
    self.attackerLabel.text = t.towerAttacker.name;
    self.attackerLabel.textColor = t.towerAttacker.isGood ? [Globals blueColor] : [Globals redColor];
    
    self.aboveTickerLabel.text = @"war ends in:";
    
    self.warView.hidden = NO;
    self.peaceView.hidden = YES;
    
    [Globals adjustViewForCentering:self.ownerWarLabel.superview withLabel:self.ownerWarLabel];
  } else {
    if (t.hasTowerOwner) {
      self.ownerPeaceLabel.text = t.towerOwner.name;
      self.ownerPeaceLabel.textColor = t.towerOwner.isGood ? [Globals blueColor] : [Globals redColor];
    } else {
      self.ownerPeaceLabel.text = @"Uncontrolled";
      self.ownerPeaceLabel.textColor = [Globals creamColor];
    }
    
    self.aboveTickerLabel.text = @"time controlled:";
    
    self.warView.hidden = YES;
    self.peaceView.hidden = NO;
    
    [Globals adjustViewForCentering:self.ownerPeaceLabel.superview withLabel:self.ownerPeaceLabel];
  }
  
  [self updateTimeForTower:t];
}

- (void) updateTimeForTower:(ClanTowerProto *)t {
  if (t.hasTowerAttacker) {
    NSDate *attackEnd = [NSDate dateWithTimeIntervalSince1970:t.attackStartTime/1000.+t.numHoursForBattle*3600];
    self.tickerLabel.text = [Globals convertTimeToString:attackEnd.timeIntervalSinceNow withDays:YES];
  } else if (t.hasTowerOwner) {
    NSDate *ownedStart = [NSDate dateWithTimeIntervalSince1970:t.ownedStartTime/1000.];
    self.tickerLabel.text = [Globals convertTimeToString:-ownedStart.timeIntervalSinceNow withDays:YES];
  } else {
    self.tickerLabel.text = @"00:00:00";
  }
}

- (void) dealloc {
  self.nameLabel = nil;
  self.bgdButton = nil;
  self.tickerLabel = nil;
  self.aboveTickerLabel = nil;
  self.ownerWarLabel = nil;
  self.ownerPeaceLabel = nil;
  self.attackerLabel = nil;
  self.peaceView = nil;
  self.warView = nil;
  [super dealloc] ;
}

@end

@implementation ClanTowerTab

- (ClanTowerView *) getTowerViewForIndex:(int)index {
  if (!self.towerViews) {
    self.towerViews = [NSMutableArray array];
  }
  
  while (index >= self.towerViews.count) {
    [[NSBundle mainBundle] loadNibNamed:@"ClanTowerView" owner:self options:nil];
    [self.towerViews addObject:self.nibView];
  }
  
  return [self.towerViews objectAtIndex:index];
}

- (void) setTimer:(NSTimer *)timer {
  if (_timer != timer) {
    [_timer invalidate];
    [_timer release];
    _timer = [timer retain];
  }
}

- (void) setHidden:(BOOL)hidden {
  [super setHidden:hidden];
  
  if (!hidden) {
    self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateTimes) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
  } else {
    self.timer = nil;
  }
}

- (void) updateTimes {
  GameState *gs = [GameState sharedGameState];
  for (int i = 0; i < self.towerViews.count; i++) {
    ClanTowerView *tv = [self getTowerViewForIndex:i];
    ClanTowerProto *ctp = [gs.clanTowers objectAtIndex:i];
    
    [tv updateTimeForTower:ctp];
  }
  
  if (_currentTowerId > 0) {
    [self.infoView updateTimeForTower:[gs clanTowerWithId:_currentTowerId]];
  }
}

- (void) loadClanTowerList:(BOOL)animated {
  ClanTowerView *v = _selectedView;
  _currentTowerId = 0;
  if (animated) {
    [UIView animateWithDuration:0.3f animations:^{
      [self updateForCurrentTowers];
    } completion:^(BOOL finished) {
      v.frame = [self.scrollView convertRect:v.frame fromView:self];
      [self.scrollView addSubview:v];
    }];
  } else {
    if (_selectedView) {
      [self.scrollView addSubview:_selectedView];
    }
    [self updateForCurrentTowers];
  }
  
  _selectedView = nil;
}

- (void) updateForCurrentTowers {
  GameState *gs = [GameState sharedGameState];
  
  if (_currentTowerId == 0) {
    NSArray *towers = gs.clanTowers;
    
    CGPoint pt;
    for (int i = 0; i < towers.count; i++) {
      ClanTowerView *tv = [self getTowerViewForIndex:i];
      ClanTowerProto *ctp = [towers objectAtIndex:i];
      [tv updateForTower:ctp];
      
      pt = CGPointMake((TOWER_VIEW_SPACING+tv.frame.size.width)*(i+0.5), self.scrollView.frame.size.height/2);
      if (tv.superview == self) {
        tv.center = [self convertPoint:pt fromView:self.scrollView];
      } else {
        [self.scrollView addSubview:tv];
        tv.center = pt;
      }
      
      tv.bgdButton.tag = i;
      
      tv.userInteractionEnabled = YES;
    }
    
    ClanTowerView *tv = [self.towerViews lastObject];
    self.scrollView.contentSize = CGSizeMake(pt.x+tv.frame.size.width/2+TOWER_VIEW_SPACING/2, self.scrollView.frame.size.height);
    
    if (towers.count < self.towerViews.count) {
      [self.towerViews removeObjectsInRange:NSMakeRange(towers.count, self.towerViews.count-towers.count)];
    }
    
    self.scrollView.alpha = 1.f;
    self.infoView.alpha = 0.f;
  } else {
    ClanTowerProto *ctp = [gs clanTowerWithId:_currentTowerId];
    if (!ctp) {
      [self loadClanTowerList:NO];
    } else {
      ClanTowerProto *ctp = [gs clanTowerWithId:_currentTowerId];
      [self.infoView updateForTower:ctp];
      [_selectedView updateForTower:ctp];
      
      [[ClanMenuController sharedClanMenuController] towerClicked:ctp];
    }
  }
}

- (void) displayTowerWithId:(int)towerId {
  GameState *gs = [GameState sharedGameState];
  int index = [gs.clanTowers indexOfObject:[gs clanTowerWithId:towerId]];
  UIView *fake = [[[UIView alloc] init] autorelease];
  fake.tag = index;
  [self towerViewClicked:fake];
}

- (IBAction)towerViewClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  int tag = [(UIView *)sender tag];
  ClanTowerProto *ctp = [gs.clanTowers objectAtIndex:tag];
  ClanTowerView *tv = [self.towerViews objectAtIndex:tag];
  
  if (tv.superview == self) {
    return;
  }
  
  if (_currentTowerId == 0) {
    [self.infoView updateForTower:ctp];
    
    // Can tell if its faked or not by the superview
    BOOL animated = ((UIView *)sender).superview != nil;
    [self moveTowerView:tv animated:animated];
    _currentTowerId = ctp.towerId;
    _selectedView = tv;
    [[ClanMenuController sharedClanMenuController] towerClicked:ctp];
    
    tv.userInteractionEnabled = NO;
  }
}

- (IBAction)redButtonClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  ClanTowerProto *ctp = [gs clanTowerWithId:_currentTowerId];
  
  if (!ctp.hasTowerOwner) {
    int tag = [[OutgoingEventController sharedOutgoingEventController] claimTower:_currentTowerId];
    [[ClanMenuController sharedClanMenuController] beginLoading:tag];
  } else if (!ctp.hasTowerAttacker) {
    int tag = [[OutgoingEventController sharedOutgoingEventController] beginTowerWar:_currentTowerId];
    [[ClanMenuController sharedClanMenuController] beginLoading:tag];
  } else {
    [Globals popupMessage:@"Something went wrong. It seems a war has already been started!"];
  }
}

- (IBAction)concedeClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  ClanTowerProto *ctp = [gs clanTowerWithId:_currentTowerId];
  
  if (ctp.hasTowerAttacker && (gs.userId == ctp.towerAttacker.ownerId || gs.userId == ctp.towerOwner.ownerId)) {
    [GenericPopupController displayConfirmationWithDescription:@"Would you like to concede this tower?" title:@"Concede Tower?" okayButton:@"Concede" cancelButton:@"Cancel" target:self selector:@selector(concedeTowerConfirmed)];
  } else {
    [Globals popupMessage:@"Something went wrong. You cannot concede this tower war."];
  }
}

- (void) concedeTowerConfirmed {
  int tag = [[OutgoingEventController sharedOutgoingEventController] concedeClanTower:_currentTowerId];
  [[ClanMenuController sharedClanMenuController] beginLoading:tag];
}

- (void) moveTowerView:(ClanTowerView *)tv animated:(BOOL)animated {
  [self addSubview:self.infoView];
  self.infoView.center = CGPointMake(CGRectGetMaxX(self.scrollView.frame)-self.infoView.frame.size.width/2-12.f,
                                     CGRectGetMidY(self.scrollView.frame));
  self.infoView.alpha = 0.f;
  
  CGRect newFrame = [self convertRect:tv.frame fromView:self.scrollView];
  [self addSubview:tv];
  tv.frame = newFrame;
  
  void (^changes)(void) = ^{
    self.scrollView.alpha = 0.f;
    self.infoView.alpha = 1.f;
    tv.center = CGPointMake(CGRectGetMinX(self.scrollView.frame)+(TOWER_VIEW_SPACING+tv.frame.size.width)/2.f,
                            CGRectGetMidY(self.scrollView.frame));
  };
  
  if (animated) {
    [UIView animateWithDuration:0.3f animations:changes];
  } else {
    changes();
  }
}

- (void) dealloc {
  self.scrollView = nil;
  self.towerViews = nil;
  self.nibView = nil;
  self.timer = nil;
  [super dealloc];
}

@end

@implementation NSString (ReverseString)

-(NSString *) reverseString
{
  NSMutableString *reversedStr;
  int len = [self length];
  
  // Auto released string
  reversedStr = [NSMutableString stringWithCapacity:len];
  
  // Probably woefully inefficient...
  while (len > 0)
    [reversedStr appendString:
     [NSString stringWithFormat:@"%C", [self characterAtIndex:--len]]];
  
  return reversedStr;
}

@end
