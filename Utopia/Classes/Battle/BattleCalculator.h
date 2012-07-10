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
#import "BattleConstants.h"

@protocol BattleCalculator <NSObject>
@property (retain) id<UserBattleStats> rightUser;
@property (retain) id<UserBattleStats> leftUser;

-(int) rightAttackStrengthForPercent:(float)percent;
-(int) leftAttackStrengthForPercent:(float)percent;
-(int) skillMultForPercent:(float)percent;
-(CombatDamageType) damageZoneForPercent:(float)percent;
-(float) calculateEnemyPercentage;
@end

@interface BattleCalculator : NSObject <BattleCalculator> {
  id<UserBattleStats> rightUser;
  id<UserBattleStats> leftUser;
  id<BattleConstants> _battleConstants;
  Globals *_globals;
}

#pragma mark Create/Destroy
+(id<BattleCalculator>) createWithRightStats:(id<UserBattleStats>)right
                                andLeftStats:(id<UserBattleStats>)left;

-(id) initWithRightStats:(id<UserBattleStats>)right
            andLeftStats:(id<UserBattleStats>)left
              andGlobals:(Globals *)globals 
      andBattleConstants:(id<BattleConstants>)battleConstants;
@end
