//
//  TutorialTopBar.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/16/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TutorialTopBar.h"
#import "GameState.h"
#import "Globals.h"
#import "GameLayer.h"
#import "GameMap.h"

@implementation TutorialTopBar

- (void) updateIcon {
  GameState *gs = [GameState sharedGameState];
  [self removeChild:_profilePic cleanup:YES];
  _profilePic = [ProfilePicture profileWithType:gs.type];
  [self addChild:_profilePic z:2];
  _profilePic.position = ccp(50, self.contentSize.height-50);
  self.isTouchEnabled = NO;
}

- (void) update {
  GameState *gs = [GameState sharedGameState];
  int silver = gs.silver-[[[GameLayer sharedGameLayer] currentMap] silverOnMap];
  if (silver != _curSilver) {
    int diff = silver - _curSilver;
    int change = 0;
    if (diff > 0) {
      change = MAX((int)(0.1*diff), 1);
    } else if (diff < 0) {
      change = MIN((int)(0.1*diff), -1);
    }
    _silverLabel.string = [Globals commafyNumber:_curSilver+change];
    _curSilver += change;
  }
  if (gs.gold != _curGold) {
    int diff = gs.gold - _curGold;
    int change = 0;
    if (diff > 0) {
      change = MAX((int)(0.1*diff), 1);
    } else if (diff < 0) {
      change = MIN((int)(0.1*diff), -1);
    }
    _goldLabel.string = [Globals commafyNumber:_curGold+change];
    _curGold += change;
  }
  
  if (gs.currentEnergy != _curEnergy) {
    int diff = gs.currentEnergy - _curEnergy;
    int change = MAX(MIN((int)(0.03*gs.maxEnergy), diff), 1);
    [self setEnergyBarPercentage:(_curEnergy+change)/((float)gs.maxEnergy)];
    _curEnergy += change;
  }
  
  if (gs.currentStamina != _curStamina) {
    int diff = gs.currentStamina - _curStamina;
    int change = MAX(MIN((int)(0.03*gs.maxStamina), diff), 1);
    [self setStaminaBarPercentage:(_curStamina+change)/((float)gs.maxStamina)];
    _curStamina += change;
  }
  
  if (gs.experience != _curExp) {
    int levelDiff = gs.expRequiredForNextLevel-gs.expRequiredForCurrentLevel;
    int diff = gs.experience - _curExp;
    int change = MAX(MIN((int)(0.01*levelDiff), diff), 1);
    [_profilePic setExpPercentage:(_curExp+change-gs.expRequiredForCurrentLevel)/(float)(gs.expRequiredForNextLevel-gs.expRequiredForCurrentLevel)];
    _curExp += change;
  }
  
  [_profilePic setLevel:gs.level];
}

- (void) dealloc {
  [super dealloc];
}

@end
