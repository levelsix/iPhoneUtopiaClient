//
//  BattleCalculator.h
//  Utopia
//
//  Created by Kevin Calloway on 6/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserBattleStats.h"
#import "Globals.h"

#define PERFECT_PERCENT_THRESHOLD 3.0f
#define GREAT_PERCENT_THRESHOLD   17.0f
#define GOOD_PERCENT_THRESHOLD    38.0f

typedef enum CombatDamageType 
{
  DMG_TYPE_PERFECT,
  DMG_TYPE_GREAT,
  DMG_TYPE_GOOD,
  DMG_TYPE_MISS
} CombatDamageType;

@protocol BattleCalculator <NSObject>
@property (retain) id<UserBattleStats> rightUser;
@property (retain) id<UserBattleStats> leftUser;

-(int) rightAttackStrengthForPercent:(float)percent;
-(int) leftAttackStrengthForPercent:(float)percent;
-(int) skillMultForPercent:(float)percent;
-(CombatDamageType) damageZoneForPercent:(float)percent;
@end

@interface BattleCalculator : NSObject <BattleCalculator> {
  id<UserBattleStats> rightUser;
  id<UserBattleStats> leftUser;
  Globals *_globals;
}
#pragma mark Create/Destroy
+(id<BattleCalculator>) createWithRightStats:(id<UserBattleStats>)right
                                andLeftStats:(id<UserBattleStats>)left;

-(id) initWithRightStats:(id<UserBattleStats>)right
            andLeftStats:(id<UserBattleStats>)left 
              andGlobals:(Globals *)globals;
@end
