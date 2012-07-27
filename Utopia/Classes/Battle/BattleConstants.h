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
@property (nonatomic, assign) float battleHitAttackerPercentOfHealth;
@property (nonatomic, assign) float battleHitDefenderPercentOfHealth;
@property (nonatomic, assign) float battlePercentOfWeapon;
@property (nonatomic, assign) float battlePercentOfArmor;
@property (nonatomic, assign) float battlePercentOfAmulet;
@property (nonatomic, assign) float battlePercentOfEquipment;
@property (nonatomic, assign) float battlePercentOfPlayerStats;
@property (nonatomic, assign) float battleIndividualEquipAttackCap;
@property (nonatomic, assign) float battleAttackExpoMultiplier;
@property (nonatomic, assign) float battlePerfectPercentThreshold;
@property (nonatomic, assign) float battleGreatPercentThreshold;
@property (nonatomic, assign) float battleGoodPercentThreshold;
@property (nonatomic, assign) float battlePerfectMultiplier;
@property (nonatomic, assign) float battleGreatMultiplier;
@property (nonatomic, assign) float battleGoodMultiplier;
@property (nonatomic, assign) float locationBarMax;
@end

@protocol EnemyBattleStats <NSObject>
@property (nonatomic, assign) float perfectLikelihood;
@property (nonatomic, assign) float greatLikelihood;
@property (nonatomic, assign) float goodLikelihood;
@property (nonatomic, assign) float missLikelihood;
@end