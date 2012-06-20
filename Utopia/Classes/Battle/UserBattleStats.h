//
//  UserBattleStats.h
//  Utopia
//
//  Created by Kevin Calloway on 6/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"
#import "GameState.h"

@protocol UserBattleStats <NSObject>
@property (readonly) int attack;
@property (readonly) int defense;
@property (readonly) int maxHealth;
@property (readonly) int currentHealth;
@end

@interface UserBattleStats : NSObject <UserBattleStats> {
  FullUserProto *_userProto;
  GameState     *_gameState;
}

@property (readonly) int attack;
@property (readonly) int defense;
@property (readonly) int maxHealth;
@property (readonly) int currentHealth;

+(id<UserBattleStats>)createWithFullUserProto:(FullUserProto *)user;
+(id<UserBattleStats>)createFromGameState;

@end
