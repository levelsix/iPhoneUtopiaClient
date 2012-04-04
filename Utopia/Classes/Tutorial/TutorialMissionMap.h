//
//  TutorialMissionMap.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/15/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MissionMap.h"

@class QuestGiver;

@interface TutorialMissionMap : MissionMap {
  BOOL _acceptQuestPhase;
  BOOL _redeemQuestPhase;
  BOOL _doBattlePhase;
  BOOL _doTaskPhase;
  BOOL _aviaryPhase;
  BOOL _canUnclick;
  
  BOOL _pickupSilver;
  
  CCSprite *_ccArrow;
  UIImageView *_uiArrow;
  
  QuestGiver *_questGiver;
  Enemy *_enemy;
  Aviary *_aviary;
}

- (void) doBlink;
- (void) questGiverInProgress;
- (void) questLogClosed;
- (void) battleDone;
- (void) battleClosed;
- (void) redeemComplete;
- (void) levelUpComplete;

+ (TutorialMissionMap *) sharedTutorialMissionMap;

+ (void) purgeSingleton;

@end
