//
//  BossViews.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/13/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "BossViews.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "Globals.h"

@implementation BossUnlockedView

- (void) displayForBoss:(FullBossProto *)boss {
  GameState *gs = [GameState sharedGameState];
  
  self.tutGirlImage.image = [Globals imageNamed:[Globals userTypeIsGood:gs.type] ? @"bigruby2.png" : @"bigadriana2.png"];
  self.timeLabel.text = [NSString stringWithFormat:@"%d hours to kill %@", boss.minutesToKill/60, boss.name];
  self.unlockedBossImage.image = [Globals imageNamed:boss.unlockedBossImageName];
  [Globals imageNamed:boss.unlockedBossImageName withView:self.unlockedBossImage maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  self.boss = boss;
  
  [Globals displayUIView:self];
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (IBAction)visitClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] loadNeutralCity:self.boss.cityId asset:self.boss.assetNumWithinCity];
  [self closeClicked:nil];
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    self.boss = nil;
    [self removeFromSuperview];
  }];
}

- (void) dealloc {
  self.mainView = nil;
  self.bgdView = nil;
  self.timeLabel = nil;
  self.tutGirlImage = nil;
  self.boss = nil;
  [super dealloc];
}

@end

@implementation CityBossView

- (void) setTimer:(NSTimer *)t {
  if (_timer != t) {
    [_timer invalidate];
    [_timer release];
    _timer = [t retain];
  }
}

- (void) updateForUserBoss:(UserBoss *)boss {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  FullBossProto *fbp = [gs bossWithId:boss.bossId];
  self.boss = boss;
  self.nameLabel.text = [NSString stringWithFormat:@"%@ (Lvl %d)", fbp.name, boss.currentLevel];
  self.regStamLabel.text = [NSString stringWithFormat:@"%d", fbp.regularAttackEnergyCost];
  self.regDmgLabel.text = @"1x ATTACK";
  self.pwrStamLabel.text = [NSString stringWithFormat:@"%d", fbp.superAttackEnergyCost];
  self.pwrDmgLabel.text = [NSString stringWithFormat:@"%dx ATTACK", (int)fbp.superAttackDamageMultiplier];
  
  self.healthBar.percentage = (float)boss.curHealth/[gl healthForBoss:boss];
  
  [self updateLabels];
  self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void) updateLabels {
  if ([self.boss isAlive]) {
    self.timeLabel.text = [self.boss timeTillEndString];
  } else {
    self.hidden = YES;
  }
}

- (void) dealloc {
  self.timeLabel = nil;
  self.nameLabel = nil;
  self.regStamLabel = nil;
  self.regDmgLabel = nil;
  self.pwrStamLabel = nil;
  self.pwrDmgLabel = nil;
  self.healthBar = nil;
  self.timer = nil;
  [super dealloc];
}

@end
