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

-(float)percentFromPerfect:(float)inputPercent
{
  float perfect  = _globals.locationBarMax;
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
-(float)accuracyPercentForPercent:(float)percent
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

  int attackStrength = [self afterDefenseAttackStrength:userAttack
                                            forDefender:defender 
                                             andPercent:percent];
  attackStrength = ((attackStrength + attacker.level - 1)*skillAttack)/100;
  
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
