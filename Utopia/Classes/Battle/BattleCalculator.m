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

//#define COMBO_BAR_PRECISION 1000
//
//#define TOTAL_LIKELIHOOD    100
//#define PERFECT_LIKELIHOOD  30
//#define GREAT_LIKELIHOOD    50
//#define GOOD_LIKELIHOOD     10
//#define MISS_LIKELIHOOD     TOTAL_LIKELIHOOD - PERFECT_LIKELIHOOD + GREAT_LIKELIHOOD + GOOD_LIKELIHOOD
//
////#define PERFECT_PERCENT_THRESHOLD 3.0f
////#define GREAT_PERCENT_THRESHOLD   17.0f
////#define GOOD_PERCENT_THRESHOLD    38.0f
//- (float) comboBarPercentageForDifficultyPercent:(float)difficultyPercent
//{
////  int locationOnBar = 0;
////  float r = [self rand];
////  
////  if (r < .40) {                 //give 45-72 75% of the time
////    locationOnBar = 45 + [self rand] * 27;
////  } else if (r >= .40 && r < .70) {      //give 78-100 20% of the time
////    locationOnBar = 78 + [self rand] * 22;
////  } else if (r >= .70) {     //give 72-78 5% of the time
////    locationOnBar = 72 + [self rand] * 6;
////  }
////  return locationOnBar;
//  
////  int precision = difficultyPercent*COMBO_BAR_PRECISION;
////  int possibleRange = COMBO_BAR_PRECISION - precision;
////  int targetPercent = _globals.locationBarMax;
//  
//#ifndef TEST_MODE
//  int randomBoundedValue = (rand()%(TOTAL_LIKELIHOOD+1));
//#else
//  int randomBoundedValue = (arc4random()%(TOTAL_LIKELIHOOD+1));
//#endif
//  
//  
////  float result = 1 - ((float)randomBoundedValue)/((float)COMBO_BAR_PRECISION);
////  return result*targetPercent;
//  return 0;
//}
//
////- (float) comboBarPercentageForDifficultyPercent:(float)difficultyPercent
////{
////  int precision = difficultyPercent*COMBO_BAR_PRECISION;
////  int possibleRange = COMBO_BAR_PRECISION - precision;
////  int targetPercent = _globals.locationBarMax;
////
////#ifndef TEST_MODE
////  int randomBoundedValue = (rand()%(possibleRange+1));
////#else
////  int randomBoundedValue = (arc4random()%(possibleRange+1));
////#endif
////  
////  float result = 1 - ((float)randomBoundedValue)/((float)COMBO_BAR_PRECISION);
////  return result*targetPercent;
////}

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

  int levelAdjustment = (attacker.level - 1)*_battleConstants.battleWeightGivenToLevel;
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
