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

@implementation TutorialTopBar

- (void) update {
  GameState *gs = [GameState sharedGameState];
  _silverLabel.string = [Globals commafyNumber:gs.silver];
  _goldLabel.string = [Globals commafyNumber:gs.gold];
  [self setEnergyBarPercentage:gs.currentEnergy/((float)gs.maxEnergy)];
  [self setStaminaBarPercentage:gs.currentStamina/((float)gs.maxStamina)];
  [_profilePic setExpPercentage:(gs.experience-gs.expRequiredForCurrentLevel)/(float)(gs.expRequiredForNextLevel-gs.expRequiredForCurrentLevel)];
  [_profilePic setLevel:gs.level];
}

@end
