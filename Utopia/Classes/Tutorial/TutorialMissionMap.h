//
//  TutorialMissionMap.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/15/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MissionMap.h"
#import "LevelUpViewController.h"

@class QuestGiver;

@interface TutorialMissionMap : MissionMap {
  BOOL _beforeBlinkPhase;
  BOOL _doBattlePhase;
  BOOL _inBattlePhase;
  BOOL _doTaskPhase;
  BOOL _doQuestPhase;
  BOOL _canUnclick;
  
  BOOL _pickupSilver;
  
  int _coinsGiven;
  
  CCSprite *_ccArrow;
  UIImageView *_uiArrow;
  
  QuestGiver *_questGiver;
  Enemy *_enemy;
  
  CCLabelTTF *_label;
  
  // For preloading
  LevelUpViewController *luvc;
}

- (void) beginInitialTask;
- (void) battleDone;
- (void) redeemComplete;
- (void) levelUpComplete;

+ (TutorialMissionMap *) sharedTutorialMissionMap;

+ (void) purgeSingleton;

@end
