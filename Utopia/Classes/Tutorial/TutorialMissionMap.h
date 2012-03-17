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
  
  CCSprite *_ccArrow;
  
  QuestGiver *_questGiver;
  Enemy *_enemy;
  Aviary *_aviary;
}

- (void) doneAcceptingQuest;
- (void) doBlink;
- (void) spawnBattleEnemy;
- (void) battleDone;
- (void) redeemComplete;
- (void) levelUpComplete;

+ (TutorialMissionMap *) sharedTutorialMissionMap;

+ (void) purgeSingleton;

@end
