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

@interface TutorialMissionMap : MissionMap <CCTargetedTouchDelegate> {
  BOOL _beforeBlinkPhase;
  BOOL _acceptQuestPhase;
  BOOL _redeemQuestPhase;
  BOOL _doBattlePhase;
  BOOL _doTaskPhase;
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

- (void) allowBlink;
- (void) doBlink;
- (void) questGiverInProgress;
- (void) battleDone;
- (void) redeemComplete;
- (void) levelUpComplete;

+ (TutorialMissionMap *) sharedTutorialMissionMap;

+ (void) purgeSingleton;

@end
