//
//  BattleCalculator.m
//  Utopia
//
//  Created by Kevin Calloway on 6/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "BattleCalculator.h"

#define PERFECT_PERCENT_THRESHOLD 3
#define GREAT_PERCENT_THRESHOLD   14
#define GOOD_PERCENT_THRESHOLD    30


//#define PERFECT_MULTIPLIER  1.0f
#define PERFECT_MULTIPLIER  1.5f
#define GREAT_MULTIPLIER    0.8f
#define GOOD_MULTIPLIER     0.4f

@implementation BattleCalculator


-(CombatDamageType) damageZoneForPercent:(float)percent
{
  float perfect = _globals.locationBarMax;
  float distFromPerfect    = abs(perfect - percent);
  float percentFromPerfect = 0;
  
  // Make the attack strength asymetric WRT the target 
  if (percent > perfect) {
//    int multOfPerfect = perfect/abs(100 - perfect);
//    percentFromPerfect = distFromPerfect*multOfPerfect;
//    percent = perfect - percentFromPerfect;
//    percentFromPerfect = (percentFromPerfect/perfect)*100;
    
    percentFromPerfect = ((perfect-distFromPerfect)/perfect)*100;
  }
  else {
    percentFromPerfect = (percent/perfect)*100;
  }
  
  CombatDamageType dmgType = DMG_TYPE_MISS;
  if (distFromPerfect <= PERFECT_PERCENT_THRESHOLD) {
   dmgType = DMG_TYPE_PERFECT;
  }
  else if (distFromPerfect <= GREAT_PERCENT_THRESHOLD) {
   dmgType = DMG_TYPE_GREAT;
  }
  else if (distFromPerfect <= GOOD_PERCENT_THRESHOLD) {
   dmgType = DMG_TYPE_GOOD;
  }
  
  return dmgType;
}

//-(CombatDamageType) damageZoneForPercent:(float)percent
//{
//  int multiplerWeightForSecondHalf = _globals.locationBarMax / (100-_globals.locationBarMax);
//  double amountWorseThanMax = (percent <= _globals.locationBarMax) ? (_globals.locationBarMax-percent) : (percent-_globals.locationBarMax)*multiplerWeightForSecondHalf;
//  
//  NSLog(@"Got percent: %f", percent);
//  
//  CombatDamageType dmgType = DMG_TYPE_MISS;
//
//  if (amountWorseThanMax < PERFECT_PERCENT_THRESHOLD) {
//    dmgType = DMG_TYPE_PERFECT;
//  }
//  else if (amountWorseThanMax < GREAT_PERCENT_THRESHOLD) {
//    dmgType = DMG_TYPE_GREAT;
//  }
//  else if (amountWorseThanMax < GOOD_PERCENT_THRESHOLD) {
//    dmgType = DMG_TYPE_GOOD;
//  }
//  return dmgType;
//}

//-(int)attackStrengthForRandomLuck
//{
//  
//}
//
//-(int)attackStrengthForEquippedItems
//{
//  
//}


-(int) skillMultForPercent:(float)percent 
                    andAttacker:(id<UserBattleStats>)attacker 
                    andDefender:(id<UserBattleStats>)defender 
{
  float perfect = _globals.locationBarMax;
  float distFromPerfect    = abs(perfect - percent);
  float percentFromPerfect = 0;
  
  // Make the attack strength asymetric WRT the target 
  if (percent > perfect) {
    //    int multOfPerfect = perfect/abs(100 - perfect);
    //    percentFromPerfect = distFromPerfect*multOfPerfect;
    //    percent = perfect - percentFromPerfect;
    //    percentFromPerfect = (percentFromPerfect/perfect)*100;
    
    percentFromPerfect = ((perfect-distFromPerfect)/perfect)*100;
  }
  else {
    percentFromPerfect = (percent/perfect)*100;
  }
  
  int result = percentFromPerfect;
  
  CombatDamageType dmgType = [self damageZoneForPercent:percent];
  switch (dmgType) {
    case DMG_TYPE_PERFECT:
      result *= PERFECT_MULTIPLIER;
      break;
    case DMG_TYPE_GREAT:
      result *= GREAT_MULTIPLIER;
      break;
    case DMG_TYPE_GOOD:
      result *= GOOD_MULTIPLIER;
      break;
    case DMG_TYPE_MISS:
      result = 0;
      break;
    default:
      break;
  }
    
  return result;
}
//-(int) attackStrengthForPercent:(float)percent 
//                    andAttacker:(id<UserBattleStats>)attacker 
//                    andDefender:(id<UserBattleStats>)defender 
//{
//  float perfect = _globals.locationBarMax;
//  float distFromPerfect    = abs(perfect - percent);
//  float percentFromPerfect = 0;
//  
//  // Make the attack strength asymetric WRT the target 
//  if (percent > perfect) {
////    int multOfPerfect = perfect/abs(100 - perfect);
////    percentFromPerfect = distFromPerfect*multOfPerfect;
////    percent = perfect - percentFromPerfect;
////    percentFromPerfect = (percentFromPerfect/perfect)*100;
//    
//    percentFromPerfect = ((perfect-distFromPerfect)/perfect)*100;
//  }
//  else {
//    percentFromPerfect = (percent/perfect)*100;
//  }
//  
//  int result = percentFromPerfect;
//  
//  if (distFromPerfect <= PERFECT_PERCENT_THRESHOLD) {
//    result *= PERFECT_MULTIPLIER;
//  }
//  else if (distFromPerfect <= GREAT_PERCENT_THRESHOLD) {
//    result *= GREAT_MULTIPLIER;
//  }
//  else if (distFromPerfect <= GOOD_PERCENT_THRESHOLD) {
//    result *= GOOD_MULTIPLIER;
//  }
//  else {
//    result = 0;
//  }
//  
//  return result;
//}

//-(int) attackStrengthForPercent:(float)percent 
//                    andAttacker:(id<UserBattleStats>)attacker 
//                    andDefender:(id<UserBattleStats>)defender 
//{
//  float perfect = _globals.locationBarMax;
//  float distFromPerfect    = abs(perfect - percent);
//  float percentFromPerfect = 0;
//  
//  // Make the attack strength asymetric WRT the target 
//  if (percent > perfect) {
//    int multOfPerfect = perfect/abs(100 - perfect);
//    percentFromPerfect = distFromPerfect*multOfPerfect;
//    percent = perfect - percentFromPerfect;
//    percentFromPerfect = (percentFromPerfect/perfect)*100;
//  }
//  else {
//    percentFromPerfect = (percent/perfect)*100;
//  }
//  
//  int result = percentFromPerfect;
//    
//  if (percentFromPerfect >= 100 - PERFECT_PERCENT_THRESHOLD) {
//    result *= PERFECT_MULTIPLIER;
//  }
//  else if (distFromPerfect <= 100 - GREAT_PERCENT_THRESHOLD) {
//    result *= GREAT_MULTIPLIER;
//  }
//  else if (distFromPerfect <= 100 - GOOD_PERCENT_THRESHOLD) {
//    result *= GOOD_MULTIPLIER;
//  }
//  //  else {
//  //    result = 0;
//  //  }
//  
//  return result;
//}

-(int) attackStrengthForPercent:(float)percent 
                       andRight:(BOOL)rightAttack
{
  // Get Skill-based attack values
  int skillAttack, userAttack;
  if (rightAttack) {
    skillAttack = [self skillMultForPercent:percent 
                                     andAttacker:_rightUser 
                                     andDefender:_leftUser];
    userAttack  = _rightUser.attack;
  }
  else {
    skillAttack = [self skillMultForPercent:percent 
                                     andAttacker:_leftUser
                                     andDefender:_rightUser];
    userAttack  = _leftUser.attack;
  }

  // Get User attack values  
  return (userAttack*skillAttack)/100;
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
+(id<BattleCalculator>) createWithRightStats:(id<UserBattleStats>)right
                                andLeftStats:(id<UserBattleStats>)left
{
  BattleCalculator *calculator = [[BattleCalculator alloc] 
                                  initWithRightStats:right 
                                  andLeftStats:left
                                  andGlobals:[Globals sharedGlobals]];
  [calculator autorelease];
  return calculator;
}

-(id) initWithRightStats:(id<UserBattleStats>)right
            andLeftStats:(id<UserBattleStats>)left
              andGlobals:(Globals *)globals
{
  self = [super init];
  
  if (self) {
    _leftUser  = left;
    _rightUser = right;
    _globals   = globals;
    
    [_leftUser  retain];
    [_rightUser retain];
    [_globals   retain];
  }
  
  return self;
}

-(void)dealloc
{
  [_leftUser  release];
  [_rightUser release];
  [_globals   release];
  
  [super dealloc];
}

@end
