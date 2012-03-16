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
  
  CCSprite *_ccArrow;
  
  QuestGiver *_questGiver;
  Enemy *_enemy;
}

- (void) doneAcceptingQuest;
- (void) doBlink;
- (void) spawnBattleEnemy;
- (void) battleDone;

+ (TutorialMissionMap *) sharedTutorialMissionMap;

@end
