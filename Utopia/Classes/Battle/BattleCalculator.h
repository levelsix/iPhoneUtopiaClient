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

typedef enum CombatDamageType 
{
  DMG_TYPE_PERFECT,
  DMG_TYPE_GREAT,
  DMG_TYPE_GOOD,
  DMG_TYPE_MISS
} CombatDamageType;

@protocol BattleCalculator <NSObject>
-(int) rightAttackStrengthForPercent:(float)percent;
-(int) leftAttackStrengthForPercent:(float)percent;
-(int) skillMultForPercent:(float)percent 
                    andAttacker:(id<UserBattleStats>)attacker 
                    andDefender:(id<UserBattleStats>)defender ;
-(CombatDamageType) damageZoneForPercent:(float)percent;
@end


@interface BattleCalculator : NSObject <BattleCalculator> {
  id<UserBattleStats> _rightUser;
  id<UserBattleStats> _leftUser;
  Globals *_globals;
}
#pragma mark Create/Destroy
+(id<BattleCalculator>) createWithRightStats:(id<UserBattleStats>)right
                                andLeftStats:(id<UserBattleStats>)left;

-(id) initWithRightStats:(id<UserBattleStats>)right
            andLeftStats:(id<UserBattleStats>)left 
              andGlobals:(Globals *)globals;
-(CombatDamageType) damageZoneForPercent:(float)percent;
@end
