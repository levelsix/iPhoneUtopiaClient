//
//  BattleCalculator.m
//  Utopia
//
//  Created by Kevin Calloway on 6/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "BattleCalculator.h"


@implementation BattleCalculator
@synthesize rightUser;
@synthesize leftUser;

#define OVER    0.3f

-(float) randomPercent
{
#ifdef UNIT_TESTING
  return ((float)(abs(rand()) % ((unsigned)RAND_MAX+1))/RAND_MAX);
#else
  return ((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX);
#endif
}

-(float) calculateEnemyPercentage
{
  float   locationOnBar = 0;
  float randomPercent = [self randomPercent];
  
  int attackRange = 0;
  if (randomPercent <= _battleStats.perfectLikelihood) {
    locationOnBar = _battleConstants.locationBarMax - _battleConstants.battlePerfectPercentThreshold;
    attackRange  = _battleConstants.battlePerfectPercentThreshold;
  }
  else if (randomPercent <= _battleStats.perfectLikelihood +
           _battleStats.greatLikelihood) {
    locationOnBar = _battleConstants.locationBarMax
    - _battleConstants.battleGreatPercentThreshold;
    attackRange = _battleConstants.battlePerfectPercentThreshold
    - _battleConstants.battleGreatPercentThreshold;
  }
  else if (randomPercent <= _battleStats.perfectLikelihood +
           _battleStats.greatLikelihood + _battleStats.goodLikelihood) {
    locationOnBar = _battleConstants.locationBarMax
    - _battleConstants.battleGoodPercentThreshold;
    
    attackRange = _battleConstants.battleGreatPercentThreshold
    - (int)_battleConstants.battleGoodPercentThreshold;
    
  }
  else {
    locationOnBar = 0;
    attackRange  = _battleConstants.battleGoodPercentThreshold;
  }
  
  locationOnBar +=  abs(attackRange) * [self randomPercent];
  
  if (OVER > [self randomPercent]) {
    float multOfPerfect  = _battleConstants.locationBarMax/fabs(100 - _battleConstants.locationBarMax);
    locationOnBar = (_battleConstants.locationBarMax - locationOnBar)/multOfPerfect;
    locationOnBar += _battleConstants.locationBarMax;
    
  }
  
  return locationOnBar;
}

#pragma mark Attack/Defense Calculations
-(float) percentFromPerfect:(float)inputPercent
{
  float perfect            = _battleConstants.locationBarMax;
  float distFromPerfect    = fabs(perfect - inputPercent);
  float percentFromPerfect = 0;
  
  // Make the attack strength asymetric WRT the target
  if (inputPercent > perfect) {
    int multOfPerfect  = perfect/fabs(100 - perfect);
    inputPercent = perfect - distFromPerfect*multOfPerfect;
  }
  percentFromPerfect = (inputPercent/perfect)*100.f;
  return percentFromPerfect;
}

- (float) accuracyPercentForPercent:(float)percent
{
  float accuracy = 0;
  accuracy = [self percentFromPerfect:percent]/100;
  return accuracy;
}

-(CombatDamageType) damageZoneForPercent:(float)percent
{
  float perfect = _battleConstants.locationBarMax;
  float distFromPerfect    = fabs(perfect - percent);
  float percentFromPerfect = 0;
  
  // Make the attack strength asymetric WRT the target
  if (percent > perfect) {
    int multOfPerfect  = perfect/fabs(100 - perfect);
    percentFromPerfect = distFromPerfect*multOfPerfect;
    distFromPerfect    = percentFromPerfect;
  }
  
  CombatDamageType dmgType = DMG_TYPE_MISS;
  if (distFromPerfect <= _battleConstants.battlePerfectPercentThreshold) {
    dmgType = DMG_TYPE_PERFECT;
  }
  else if (distFromPerfect <= _battleConstants.battleGreatPercentThreshold) {
    dmgType = DMG_TYPE_GREAT;
  }
  else if (distFromPerfect <= _battleConstants.battleGoodPercentThreshold) {
    dmgType = DMG_TYPE_GOOD;
  }
  
  return dmgType;
}

- (float) skillMultForPercent:(float)percent
{
  int result = [self percentFromPerfect:percent];
  
  CombatDamageType dmgType = [self damageZoneForPercent:percent];
  switch (dmgType) {
    case DMG_TYPE_PERFECT:
      result *= _battleConstants.battlePerfectMultiplier;
      break;
    case DMG_TYPE_GREAT:
      result *= _battleConstants.battleGreatMultiplier;
      break;
    case DMG_TYPE_GOOD:
      result *= _battleConstants.battleGoodMultiplier;
      break;
    case DMG_TYPE_MISS:
      result = 0;
      break;
    default:
      break;
  }
  
  return result;
}

//-(int) afterDefenseAttackStrength:(int)attackStrength
//                      forDefender:(UserBattleStats *)defender
//                       andPercent:(float)percent
//{
//  float accuracy = [self accuracyPercentForPercent:percent];
//
//  attackStrength = MAX(attackStrength - defender.defense, 0) + 6*ceil(accuracy);
//
//  return attackStrength;
//}

-(int) attackStrengthForPercent:(float)percent
                       andRight:(BOOL)rightAttack
{
  // Get Skill-based attack values
  Globals *gl = [Globals sharedGlobals];
  
  UserBattleStats *attacker, *defender;
  float healthPercent;
  if (rightAttack) {
    attacker = rightUser;
    defender = leftUser;
    healthPercent = _battleConstants.battleHitDefenderPercentOfHealth;
  }
  else {
    attacker = leftUser;
    defender = rightUser;
    healthPercent = _battleConstants.battleHitAttackerPercentOfHealth;
  }
  
  BOOL useOldFormula = YES;//gl.useOldBattleFormula;
  
  int battleFormula;
  if (useOldFormula) {
    int health = [gl calculateHealthForLevel:attacker.level];
    double hitStrength = health*healthPercent;
    double totalEquipPortion = MIN(3*_battleConstants.battleIndividualEquipAttackCap, _battleConstants.battlePercentOfEquipment*(((float)(attacker.weaponAttack+attacker.armorAttack+attacker.amuletAttack))/(defender.weaponDefense+defender.armorDefense+defender.amuletDefense)));
    double weaponPortion = MIN(_battleConstants.battleIndividualEquipAttackCap, _battleConstants.battlePercentOfWeapon*(((float)attacker.weaponAttack)/defender.weaponDefense));
    double armorPortion = MIN(_battleConstants.battleIndividualEquipAttackCap, _battleConstants.battlePercentOfArmor*(((float)attacker.armorAttack)/defender.armorDefense));
    double amuletPortion = MIN(_battleConstants.battleIndividualEquipAttackCap, _battleConstants.battlePercentOfAmulet*(((float)attacker.amuletAttack)/defender.armorDefense));
    double statsPortion = _battleConstants.battlePercentOfPlayerStats*(((float)attacker.attackStat)/defender.defenseStat);
    
    battleFormula = (int) (hitStrength*(pow(totalEquipPortion+weaponPortion+armorPortion+amuletPortion+statsPortion,_battleConstants.battleAttackExpoMultiplier)));
  } else {
    int healthOfAttacker = [gl calculateHealthForLevel:attacker.level];
    int healthOfDefender = [gl calculateHealthForLevel:defender.level];
    int health = (healthOfAttacker + healthOfDefender)*(attacker.level/(float)(attacker.level + defender.level));
    double hitStrength = health*healthPercent;
    int levelDifference = defender.level-attacker.level;
    double totalEquipPortion = MIN(3*_battleConstants.battleIndividualEquipAttackCap, _battleConstants.battlePercentOfEquipment*(((float)(attacker.weaponAttack+attacker.armorAttack+attacker.amuletAttack))/(defender.weaponDefense+defender.armorDefense+defender.amuletDefense)));
    double weaponPortion = MIN(_battleConstants.battleIndividualEquipAttackCap, _battleConstants.battlePercentOfWeapon*(((float)attacker.weaponAttack)/defender.weaponDefense));
    double armorPortion = MIN(_battleConstants.battleIndividualEquipAttackCap, _battleConstants.battlePercentOfArmor*(((float)attacker.armorAttack)/defender.armorDefense));
    double amuletPortion = MIN(_battleConstants.battleIndividualEquipAttackCap, _battleConstants.battlePercentOfAmulet*(((float)attacker.amuletAttack)/defender.armorDefense));
    double statsPortion = _battleConstants.battlePercentOfPlayerStats*(((float)attacker.attackStat)/defender.defenseStat)*pow(_battleConstants.battleEquipAndStatsWeight,levelDifference);
    
    int level = attacker.level;
    double weight = -0.0000002*pow(level, 3)+0.00001*pow(level, 2)-0.0015*level+1.0825;
    weight = MAX(weight*1.1, 1.);
    battleFormula = (int) (hitStrength*(pow((totalEquipPortion+weaponPortion+armorPortion+amuletPortion+statsPortion)*
                                            pow(_battleConstants.battleEquipAndStatsWeight, levelDifference),
                                            _battleConstants.battleAttackExpoMultiplier))/weight);
  }
  
  float skillAttack = [self skillMultForPercent:percent];
  
  // Get User attack values
  return battleFormula * skillAttack / 100.f;
}

-(int) rightAttackStrengthForPercent:(float)percent
{
  return [self attackStrengthForPercent:percent
                               andRight:YES];
}

-(int) leftAttackStrengthForPercent:(float)percent
{
  return [self attackStrengthForPercent:percent
                               andRight:NO];
}

#pragma mark Create/Destroy
-(id) initWithRightStats:(id<UserBattleStats>)right
            andLeftStats:(id<UserBattleStats>)left
      andBattleConstants:(id<BattleConstants>)battleConstants
          andBattleStats:(id<EnemyBattleStats>)battleStats
{
  self = [super init];
  
  if (self) {
    leftUser          = left;
    rightUser         = right;
    _battleConstants  = battleConstants;
    _battleStats      = battleStats;
    
    [leftUser         retain];
    [rightUser        retain];
    [_battleConstants retain];
    [_battleStats     retain];
  }
  
  return self;
}

+(id<BattleCalculator>) createWithRightStats:(id<UserBattleStats>)right
                                andLeftStats:(id<UserBattleStats>)left
{
  BattleCalculator *calculator = [[BattleCalculator alloc]
                                  initWithRightStats:right
                                  andLeftStats:left
                                  andBattleConstants:[Globals sharedGlobals]
                                  andBattleStats:[Globals sharedGlobals]];
  [calculator autorelease];
  return calculator;
}

-(void)dealloc
{
  [leftUser         release];
  [rightUser        release];
  [_battleConstants release];
  [_battleStats     release];
  
  [super dealloc];
}

@end
