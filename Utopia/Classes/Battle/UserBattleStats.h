//
//  UserBattleStats.h
//  Utopia
//
//  Created by Kevin Calloway on 6/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameState.h"

@protocol UserBattleStats <NSObject>
@end

@interface UserBattleStats : NSObject <UserBattleStats> {
  FullUserProto *_userProto;
  GameState     *_gameState;
  Globals       *_globals;
}

@property (readonly) int attackStat;
@property (readonly) int defenseStat;
@property (readonly) int32_t level;
@property (readonly) int weaponAttack;
@property (readonly) int armorAttack;
@property (readonly) int amuletAttack;
@property (readonly) int weaponDefense;
@property (readonly) int armorDefense;
@property (readonly) int amuletDefense;

+(id<UserBattleStats>)createWithFullUserProto:(FullUserProto *)user;
+(id<UserBattleStats>)createFromGameState;

@end
