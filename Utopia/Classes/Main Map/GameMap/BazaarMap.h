//
//  BazaarMap.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/2/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "GameMap.h"

@interface BazaarMap : GameMap {
  QuestGiver *_questGiver;
}

+ (BazaarMap *) sharedBazaarMap;
+ (void) purgeSingleton;
+ (BOOL) isInitialized;

- (void) moveToCritStruct:(BazaarStructType)type animated:(BOOL)animated;
- (void) moveToQuestGiverAnimated:(BOOL)animated;

- (void) reloadAllies;

@end
