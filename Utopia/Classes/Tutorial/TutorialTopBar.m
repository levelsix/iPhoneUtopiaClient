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
#import "TutorialHomeMap.h"
#import "DialogMenuController.h"
#import "TutorialConstants.h"
#import "TutorialProfilePicture.h"
#import "TutorialAttackMenuController.h"

@implementation TutorialTopBar

- (void) updateIcon {
  GameState *gs = [GameState sharedGameState];
  
  if (_profilePic) {
    [self removeChild:_profilePic cleanup:YES];
  }
  
  self.profilePic = [TutorialProfilePicture profileWithType:gs.type];
  [self addChild:_profilePic z:2];
  _profilePic.position = ccp(50, self.contentSize.height-50);
  self.isTouchEnabled = NO;
  
  _lockBoxButton.visible = NO;
  
  [_arrow release];
  _arrow = [[CCSprite spriteWithFile:@"3darrow.png"] retain];
  
  [self lowerAllOpacities];
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
    int change = 0;
    if (diff > 0) {
      change = MAX(MIN((int)(0.02*gs.maxEnergy), diff), 1);
    } else if (diff < 0) {
      change = MIN(MAX((int)(-0.02*gs.maxEnergy), diff), -1);
    }
    [self setEnergyBarPercentage:(_curEnergy+change)/((float)gs.maxEnergy)];
    _curEnergy += change;
  }
  
  if (gs.currentStamina != _curStamina) {
    int diff = gs.currentStamina - _curStamina;
    int change = 0;
    if (diff > 0) {
      change = MAX(MIN((int)(0.02*gs.maxStamina), diff), 1);
    } else if (diff < 0) {
      change = MIN(MAX((int)(-0.02*gs.maxStamina), diff), -1);
    }
    [self setStaminaBarPercentage:(_curStamina+change)/((float)gs.maxStamina)];
    _curStamina += change;
  }
  
  if (gs.experience != _curExp) {
    GameState *gs = [GameState sharedGameState];
    int levelDiff = gs.expRequiredForNextLevel-gs.expRequiredForCurrentLevel;
    int diff = gs.experience - _curExp;
    int change = MAX(MIN((int)(0.01*levelDiff), diff), 1);
    [_profilePic setExpPercentage:(_curExp+change-gs.expRequiredForCurrentLevel)/(float)(gs.expRequiredForNextLevel-gs.expRequiredForCurrentLevel)];
    _curExp += change;
  }
  
  if (_profilePic.expLabelTop.visible) {
    [_profilePic.expLabelTop setString:[NSString stringWithFormat:@"%d/", _curExp-gs.expRequiredForCurrentLevel]];
    [_profilePic.expLabelBot setString:[NSString stringWithFormat:@"%d", gs.expRequiredForNextLevel-gs.expRequiredForCurrentLevel]];
  }
  
  [_profilePic setLevel:gs.level];
  
  if (_littleToolTipState == kEnergy) {
    _littleToolTip.position = ccp((_curEnergyBar.position.x-_curEnergyBar.contentSize.width/2)+_curEnergyBar.contentSize.width*_energyBar.percentage, _curEnergyBar.position.y-_curEnergyBar.contentSize.height/2-_littleToolTip.contentSize.height/2);
    _littleCurValLabel.string = [NSString stringWithFormat:@"%d/%d", _curEnergy, gs.maxEnergy];
  } else if (_littleToolTipState == kStamina) {
    _littleToolTip.position = ccp((_curStaminaBar.position.x-_curStaminaBar.contentSize.width/2)+_curStaminaBar.contentSize.width*_staminaBar.percentage, _curStaminaBar.position.y-_curStaminaBar.contentSize.height/2-_littleToolTip.contentSize.height/2);
    _littleCurValLabel.string = [NSString stringWithFormat:@"%d/%d", _curStamina, gs.maxStamina];
  }
}

- (void) beginMyCityPhase {
  _myCityPhase = YES;
  
  [TutorialHomeMap sharedHomeMap];
  
  [self addChild:_arrow];
  _arrow.position = ccpAdd(_homeButton.position, ccp(-_homeButton.contentSize.width/2-_arrow.contentSize.width/2-15, 0));
  [Globals animateCCArrow:_arrow atAngle:0];
  
  _homeButton.normalImage.opacity = 255;
  _homeButton.selectedImage.opacity = 255;
  
  [DialogMenuController displayViewForText:[[TutorialConstants sharedTutorialConstants] beforeHomeText]];
}

- (void) beginQuestsPhase {
  _questsPhase = YES;
  
  [self addChild:_arrow];
  _arrow.position = ccpAdd(_questButton.position, ccp(-_questButton.contentSize.width/2-15, 0));
  [Globals animateCCArrow:_arrow atAngle:0];
  
  _questButton.normalImage.opacity = 255;
  _questButton.selectedImage.opacity = 255;
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  
  if (_finishedFirstQuestPhase) {
    [DialogMenuController displayViewForText:tc.beforeEndText];
  } else {
    [DialogMenuController displayViewForText:tc.questIconText];
  }
}

- (void) beginAttackPhase {
  _attackPhase = YES;
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.beforeAttackText];
  
  _attackButton.normalImage.opacity = 255;
  _attackButton.selectedImage.opacity = 255;
  
  [self addChild:_arrow];
  _arrow.position = ccpAdd(_attackButton.position, ccp(0, _attackButton.contentSize.width/2+15));
  [Globals animateCCArrow:_arrow atAngle:-M_PI_2];
}

- (void) globeClicked {
  return;
}

- (void) forumClicked {
  return;
}

- (void) mapClicked {
  return;
}

- (void) attackClicked {
  if (_attackPhase) {
    _attackPhase = NO;
    [_arrow removeFromParentAndCleanup:YES];
    _attackButton.normalImage.opacity = BUTTON_OPACITY;
    _attackButton.selectedImage.opacity = BUTTON_OPACITY;
    
    [TutorialAttackMenuController sharedAttackMenuController];
    [AttackMenuController displayView];
    
    TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
    [DialogMenuController displayViewForText:tc.tapToAttackText];
    DialogMenuController *dmc = [DialogMenuController sharedDialogMenuController];
    dmc.view.center = ccpAdd(dmc.view.center, ccp(0, 150));
    
    [Analytics tutAttackClicked];
  }
}

- (void) lockBoxButtonClicked {
  return;
}

- (void) bossEventButtonClicked {
  return;
}

- (void) tournamentButtonClicked {
  return;
}

- (void) questButtonClicked {
  if (_questsPhase) {
    [super questButtonClicked];
    _questsPhase = NO;
    [_arrow removeFromParentAndCleanup:YES];
    _questButton.normalImage.opacity = BUTTON_OPACITY;
    _questButton.selectedImage.opacity = BUTTON_OPACITY;
    
    if (_finishedFirstQuestPhase) {
      [Analytics tutQuestButton2];
      [[TutorialHomeMap sharedHomeMap] performSelector:@selector(endTutorial) withObject:nil afterDelay:0.5f];
    } else {
      [Analytics tutQuestButton1];
      _finishedFirstQuestPhase = YES;
    }
    
    [DialogMenuController closeView];
  }
}

- (void) bazaarClicked {
  return;
}

- (void) homeClicked {
  if (_myCityPhase) {
    [super homeClicked];
    _myCityPhase = NO;
    [_arrow removeFromParentAndCleanup:YES];
    _homeButton.normalImage.opacity = BUTTON_OPACITY;
    _homeButton.selectedImage.opacity = BUTTON_OPACITY;
    
    [[TutorialHomeMap sharedHomeMap] performSelector:@selector(startCarpPhase) withObject:nil afterDelay:0.5f];
    
    [Analytics tutMyCityClicked];
    
    [DialogMenuController closeView];
  }
}

- (void) dealloc {
  [_arrow release];
  [super dealloc];
}

@end
