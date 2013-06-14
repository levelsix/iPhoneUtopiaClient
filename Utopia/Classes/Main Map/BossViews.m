//
//  BossViews.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/13/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "BossViews.h"
#import "GameState.h"
#import "GameState.h"

@implementation BossUnlockedView

- (void) displayForBoss:(FullBossProto *)boss {
  GameState *gs = [GameState sharedGameState];
  
  self.tutGirlImage.image = [Globals imageNamed:[Globals userTypeIsGood:gs.type] ? @"bigruby2.png" : @"bigadriana2.png"];
  self.timeLabel.text = [NSString stringWithFormat:@"%d hours to kill %@", boss.minutesToKill/60, @"Meepert"];
  
  [Globals displayUIView:self];
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (void) dealloc {
  self.mainView = nil;
  self.bgdView = nil;
  self.timeLabel = nil;
  self.tutGirlImage = nil;
  [super dealloc];
}

@end
