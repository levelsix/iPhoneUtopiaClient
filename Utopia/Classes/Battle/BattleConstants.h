//
//  BattleConstants.h
//  Utopia
//
//  Created by Kevin Calloway on 6/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum CombatDamageType 
{
  DMG_TYPE_PERFECT,
  DMG_TYPE_GREAT,
  DMG_TYPE_GOOD,
  DMG_TYPE_MISS
} CombatDamageType;

@protocol BattleConstants <NSObject>
  @property (nonatomic, assign) float battleWeightGivenToAttackStat;
  @property (nonatomic, assign) float battleWeightGivenToAttackEquipSum;
  @property (nonatomic, assign) float battleWeightGivenToDefenseStat;
  @property (nonatomic, assign) float battleWeightGivenToDefenseEquipSum;
  @property (nonatomic, assign) float battlePerfectPercentThreshold;
  @property (nonatomic, assign) float battleGreatPercentThreshold;
  @property (nonatomic, assign) float battleGoodPercentThreshold;
  @property (nonatomic, assign) float battlePerfectMultiplier;
  @property (nonatomic, assign) float battleGreatMultiplier;
  @property (nonatomic, assign) float battleGoodMultiplier;
  @property (nonatomic, assign) float battleImbalancePercent;
@end

