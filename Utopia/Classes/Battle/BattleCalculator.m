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

#define PERFECT 0.25f
#define GREAT   0.5f
#define GOOD    0.15f
#define MISS    0.10f
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
  id<BattleConstants> battleConstants = [Globals sharedGlobals];
  
  int attackRange = 0;
  if (randomPercent <= PERFECT) {
    locationOnBar = battleConstants.locationBarMax - battleConstants.battlePerfectPercentThreshold; 
    attackRange  = battleConstants.battlePerfectPercentThreshold;
  }
  else if (randomPercent <= PERFECT + GREAT) {
    locationOnBar = battleConstants.locationBarMax 
    - battleConstants.battleGreatPercentThreshold;
    attackRange = battleConstants.battlePerfectPercentThreshold
    - battleConstants.battleGreatPercentThreshold;
  }
  else if (randomPercent <= PERFECT + GREAT + GOOD) {
    locationOnBar = battleConstants.locationBarMax 
    - battleConstants.battleGoodPercentThreshold;
    
    attackRange = battleConstants.battleGreatPercentThreshold 
    - (int)battleConstants.battleGoodPercentThreshold;
  }
  else {
    locationOnBar = 0;
    attackRange  = battleConstants.battleGoodPercentThreshold;
  }

  float randomAttack = [self randomPercent]*100;
  locationOnBar +=  ((int)randomAttack) % (abs(attackRange) + 1);
  
  if (OVER < [self randomPercent]) {
    float multOfPerfect  = battleConstants.locationBarMax/fabs(100 - battleConstants.locationBarMax);
    locationOnBar = battleConstants.locationBarMax + ((float)locationOnBar)/multOfPerfect; 
  }
  
  return locationOnBar;
}

#pragma mark Attack/Defense Calculations
-(float) percentFromPerfect:(float)inputPercent
{
  float perfect            = _globals.locationBarMax;
  float distFromPerfect    = fabs(perfect - inputPercent);
  float percentFromPerfect = 0;
  
  // Make the attack strength asymetric WRT the target 
  if (inputPercent > perfect) {
    int multOfPerfect  = perfect/fabs(100 - perfect);
    percentFromPerfect = distFromPerfect*multOfPerfect;
    percentFromPerfect = perfect - percentFromPerfect;
  }
  else {
    percentFromPerfect = (inputPercent/perfect)*100;
  }
  return percentFromPerfect;
}

-(float) accuracyPercentForPercent:(float)percent
{
  float accuracy = 0;
  accuracy = [self percentFromPerfect:percent]/100;
  return accuracy;
}

-(CombatDamageType) damageZoneForPercent:(float)percent
{
  float perfect = _globals.locationBarMax;
  float distFromPerfect    = fabs(perfect - percent);
  float percentFromPerfect = 0;
  
  // Make the attack strength asymetric WRT the target 
  if (percent > perfect) {
    int multOfPerfect  = perfect/fabs(100 - perfect);
    percentFromPerfect = distFromPerfect*multOfPerfect;
    distFromPerfect    = percentFromPerfect;
  }
  else {
    percentFromPerfect = (percent/perfect)*100;
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

-(int) skillMultForPercent:(float)percent
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

-(int) afterDefenseAttackStrength:(int)attackStrength
                      forDefender:(id<UserBattleStats>)defender 
                       andPercent:(float)percent
{
  float accuracy = [self accuracyPercentForPercent:percent];

  attackStrength = MAX(attackStrength - defender.defense, 0) + 6*ceil(accuracy);

  return attackStrength;
}

-(int) attackStrengthForPercent:(float)percent 
                       andRight:(BOOL)rightAttack
{
  // Get Skill-based attack values
  int skillAttack, userAttack;
  
  id<UserBattleStats> attacker, defender;
  if (rightAttack) {
    attacker = rightUser;
    defender = leftUser;
  }
  else {
    attacker = leftUser;
    defender = rightUser;
  }

  skillAttack = [self skillMultForPercent:percent];
  userAttack  = attacker.attack;
  
  // Note:It may seem that this Nerf's the stronger character
  // In reality, the only reason why we given an attack boost
  // based on level is so that the battle lengths stay consistent.
  // The risk is that this expandes the difference between levels
  // (above better gear and skill points).  Thus we take the lower
  // value as the attack boost
  int lowerLevel = MIN(attacker.level, defender.level);
  int levelAdjustment = (lowerLevel - 1)*_battleConstants.battleWeightGivenToLevel;
  int attackStrength = [self afterDefenseAttackStrength:userAttack + levelAdjustment
                                            forDefender:defender 
                                             andPercent:percent];
  attackStrength = (attackStrength*skillAttack)/100;

  // Get User attack values  
  return attackStrength;
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
              andGlobals:(Globals *)globals 
      andBattleConstants:(id<BattleConstants>)battleConstants
{
  self = [super init];
  
  if (self) {
    leftUser          = left;
    rightUser         = right;
    _globals          = globals;
    _battleConstants  = battleConstants;
    
    [leftUser         retain];
    [rightUser        retain];
    [_globals         retain];
    [_battleConstants retain];
  }
  
  return self;
}

+(id<BattleCalculator>) createWithRightStats:(id<UserBattleStats>)right
                                andLeftStats:(id<UserBattleStats>)left
{
  BattleCalculator *calculator = [[BattleCalculator alloc] 
                                  initWithRightStats:right 
                                  andLeftStats:left
                                  andGlobals:[Globals sharedGlobals] 
                                  andBattleConstants:[Globals sharedGlobals]];
  [calculator autorelease];
  return calculator;
}

-(void)dealloc
{
  [leftUser         release];
  [rightUser        release];
  [_globals         release];
  [_battleConstants release];
  
  [super dealloc];
}

@end
