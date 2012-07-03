//
//  BattleCalculatorTests.m
//  Utopia
//
//  Created by Kevin Calloway on 6/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "BattleCalculatorTests.h"
#import "Globals.h"

#define HIGH_PERFECT  75.0f
#define LOW_PERFECT   HIGH_PERFECT - PERFECT_PERCENT_THRESHOLD
#define HIGH_GREAT    LOW_PERFECT  - 0.1f
#define LOW_GREAT     HIGH_PERFECT - GREAT_PERCENT_THRESHOLD
#define HIGH_GOOD     LOW_GREAT    - 0.1f
#define LOW_GOOD      HIGH_PERFECT - GOOD_PERCENT_THRESHOLD
#define MISS          LOW_GOOD     - 0.1f

#define START_POINTS          24.0f

#define MAGE_ATTACK_LVL1      START_POINTS*IMBALANCE_PERCENT + .5
#define MAGE_DEFENSE_LVL1     START_POINTS*(1 - IMBALANCE_PERCENT) + .5
#define ARCHER_ATTACK_LVL1    START_POINTS/2
#define ARCHER_DEFENSE_LVL1   START_POINTS/2
#define WARRIOR_ATTACK_LVL1   MAGE_DEFENSE_LVL1 + .5
#define WARRIOR_DEFENSE_LVL1  MAGE_ATTACK_LVL1 + .5

#define PERFECT_PERCENT_THRESHOLD 3.0f
#define GREAT_PERCENT_THRESHOLD   17.0f
#define GOOD_PERCENT_THRESHOLD    38.0f

#define PERFECT_MULTIPLIER  2.0f
#define GREAT_MULTIPLIER    1.5f
#define GOOD_MULTIPLIER     1.0f

#define IMBALANCE_PERCENT .67f

#define TEST_MODE     1


@implementation BattleCalculatorTests
-(id<UserBattleStats>)userForAttack:(int)attack 
                         andDefense:(int)defense
                           andLevel:(int)level
{
  FullUserProto_Builder *builder = [FullUserProto builder];
  [builder setAttack:attack];
  [builder setDefense:defense];
  [builder setLevel:level];
  FullUserProto *user = [builder build];
  
  return [UserBattleStats createWithFullUserProto:user];
}

-(id<UserBattleStats>)userForAttack:(int)attack andDefense:(int)defense
{
  return [self userForAttack:attack andDefense:defense andLevel:1];
}

- (void)setUp
{
  [super setUp];
//  [Globals purgeSingleton];
  FullUserProto_Builder *builder = [FullUserProto builder];
  FullUserProto *leftUser  = [[[builder setAttack:40] setLevel:1] build];
  FullUserProto *rightUser = [[builder setAttack:40] build];

  rightStats = [UserBattleStats createWithFullUserProto:rightUser];
  leftStats  = [UserBattleStats createWithFullUserProto:leftUser];

  [Globals sharedGlobals].locationBarMax = 75;
  
  id<BattleConstants> battleConstants = [Globals sharedGlobals];
  battleConstants.battleWeightGivenToDefenseStat     = 1;
  battleConstants.battleWeightGivenToDefenseEquipSum = 1;
  battleConstants.battleWeightGivenToAttackStat      = 1;
  battleConstants.battleWeightGivenToAttackEquipSum  = 1;
  battleConstants.battleWeightGivenToLevel           = 1;

  battleConstants.battlePerfectPercentThreshold = PERFECT_PERCENT_THRESHOLD;
  battleConstants.battleGreatPercentThreshold   = GREAT_PERCENT_THRESHOLD;
  battleConstants.battleGoodPercentThreshold    = GOOD_PERCENT_THRESHOLD;
  
  battleConstants.battlePerfectMultiplier = PERFECT_MULTIPLIER;
  battleConstants.battleGreatMultiplier   = GREAT_MULTIPLIER;
  battleConstants.battleGoodMultiplier    = GOOD_MULTIPLIER;
  
  testCalculator = [[BattleCalculator alloc] initWithRightStats:rightStats
                                                   andLeftStats:leftStats
                                                     andGlobals:[Globals sharedGlobals]
                                             andBattleConstants:battleConstants];
  srand(4321489024315);
}

- (void)tearDown
{
  // Tear-down code here.
  [testCalculator release];
  [super tearDown];
}

#pragma mark ComboBar %
//- (void)test_ComboBarPercentForZero
//{
//  // Set expectations
//  float expected = 10;
//  
//  // Run the test
//  float result = [testCalculator comboBarPercentageForDifficultyPercent:0.0];
//  
//  // Check expectations
//  STAssertTrue(expected > result, @"Expected %f got %f", expected, result);
//}
//
//- (void)test_ComboBarPercentFor50
//{
//  // Set expectations
//  float expected = 60;
//  
//  // Run the test
//  float result = [testCalculator comboBarPercentageForDifficultyPercent:0.50];
//  
//  // Check expectations
//  STAssertTrue(expected == result, @"Expected %f got %f", expected, result);
//}
//
//- (void)test_ComboBarPercentFor75
//{
//  // Set expectations
//  float expected = 60;
//  
//  // Run the test
//  float result = [testCalculator comboBarPercentageForDifficultyPercent:0.75];
//  
//  // Check expectations
//  STAssertTrue(expected == result, @"Expected %f got %f", expected, result);
//}
//
//- (void)test_ComboBarPercentFor100
//{
//  // Set expectations
//  float expected = HIGH_PERFECT;
//  
//  // Run the test
//  float result = [testCalculator comboBarPercentageForDifficultyPercent:1.0];
//  
//  // Check expectations
//  STAssertTrue(expected == result, @"Expected %f got %f", expected, result);
//}

#pragma mark Warrior/Warrior DefenseTests
- (void)test_WarriorAttackWARRIORPERFECTWithDefenseLevelImbalance
{
  // Set expectations
  int expected = 14;
  testCalculator.rightUser = [self userForAttack:WARRIOR_ATTACK_LVL1
                                      andDefense:WARRIOR_DEFENSE_LVL1 
                                        andLevel:40];
  testCalculator.leftUser  = [self userForAttack:WARRIOR_ATTACK_LVL1 
                                      andDefense:WARRIOR_DEFENSE_LVL1 
                                        andLevel:11];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_WarriorAttackWARRIORPERFECTWithDefense
{
  // Set expectations
  int expected = 12;
  testCalculator.rightUser = [self userForAttack:WARRIOR_ATTACK_LVL1
                                      andDefense:WARRIOR_DEFENSE_LVL1];
  testCalculator.leftUser  = [self userForAttack:WARRIOR_ATTACK_LVL1 
                                      andDefense:WARRIOR_DEFENSE_LVL1];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

#pragma mark MAGE/MAGE DefenseTests
- (void)test_MageAttackMagePERFECTWithDefenseLevelImbalance
{
  // Set expectations
  int expected = 48;
  testCalculator.rightUser = [self userForAttack:MAGE_ATTACK_LVL1
                                      andDefense:MAGE_DEFENSE_LVL1 
                                        andLevel:40];
  testCalculator.leftUser  = [self userForAttack:MAGE_ATTACK_LVL1 
                                      andDefense:MAGE_DEFENSE_LVL1 
                                        andLevel:11];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}
- (void)test_MageAttackMAGEPERFECTWithDefense
{
  // Set expectations
  int expected = 28;
  testCalculator.rightUser = [self userForAttack:MAGE_ATTACK_LVL1 
                                      andDefense:MAGE_DEFENSE_LVL1];
  testCalculator.leftUser  = [self userForAttack:MAGE_ATTACK_LVL1 
                                      andDefense:MAGE_DEFENSE_LVL1];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

#pragma mark ARCHER/ARCHER DefenseTests
- (void)test_ArcherAttackArcherPERFECTWithDefense
{
  // Set expectations
  int expected = 12;
  testCalculator.rightUser = [self userForAttack:ARCHER_ATTACK_LVL1 
                                      andDefense:ARCHER_DEFENSE_LVL1];
  testCalculator.leftUser  = [self userForAttack:ARCHER_ATTACK_LVL1 
                                      andDefense:ARCHER_DEFENSE_LVL1];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

#pragma mark MAGE/ARCHER DefenseTests
- (void)test_mageAttackArcherPERFECTWithDefense
{
  // Set expectations
  int expected = 20;
  testCalculator.rightUser = [self userForAttack:ARCHER_ATTACK_LVL1 andDefense:ARCHER_ATTACK_LVL1];
  testCalculator.leftUser  = [self userForAttack:MAGE_ATTACK_LVL1 
                                      andDefense:MAGE_DEFENSE_LVL1];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_archerAttackMagePERFECTWithDefense
{
  // Set expectations
  int expected = 20;
  testCalculator.rightUser = [self userForAttack:MAGE_ATTACK_LVL1
                                      andDefense:MAGE_DEFENSE_LVL1];
  testCalculator.leftUser = [self userForAttack:ARCHER_ATTACK_LVL1 
                                     andDefense:ARCHER_DEFENSE_LVL1];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}


- (void)test_archerAttackMageHIGHGREATWithDefense
{
  // Set expectations
  int expected = 14;
  testCalculator.rightUser = [self userForAttack:MAGE_ATTACK_LVL1
                                      andDefense:MAGE_DEFENSE_LVL1];
  testCalculator.leftUser = [self userForAttack:ARCHER_ATTACK_LVL1 
                                     andDefense:ARCHER_DEFENSE_LVL1];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_GREAT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_archerAttackMageLOWGREATithDefense
{
  // Set expectations
  int expected = 11;
  testCalculator.rightUser = [self userForAttack:MAGE_ATTACK_LVL1
                                      andDefense:MAGE_DEFENSE_LVL1];
  testCalculator.leftUser = [self userForAttack:ARCHER_ATTACK_LVL1 
                                     andDefense:ARCHER_DEFENSE_LVL1];

  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:LOW_GREAT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_archerAttackMageHIGHGOODWithDefense
{
  // Set expectations
  int expected = 7;
  testCalculator.rightUser = [self userForAttack:MAGE_ATTACK_LVL1
                                      andDefense:MAGE_DEFENSE_LVL1];
  testCalculator.leftUser = [self userForAttack:ARCHER_ATTACK_LVL1 
                                     andDefense:ARCHER_DEFENSE_LVL1];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_GOOD];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_archerAttackMageLOWGOODWithDefense
{
  // Set expectations
  int expected = 4;
  testCalculator.rightUser = [self userForAttack:MAGE_ATTACK_LVL1
                                      andDefense:MAGE_DEFENSE_LVL1];
  testCalculator.leftUser = [self userForAttack:ARCHER_ATTACK_LVL1 
                                     andDefense:ARCHER_DEFENSE_LVL1];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:LOW_GOOD];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

#pragma mark MAGE/WARRIOR DefenseTests
- (void)test_mageAttackWarriorPERFECTWithDefense
{
  // Set expectations
  int expected = 12;
  testCalculator.rightUser = [self userForAttack:WARRIOR_ATTACK_LVL1 
                                      andDefense:WARRIOR_DEFENSE_LVL1];
  testCalculator.leftUser  = [self userForAttack:MAGE_ATTACK_LVL1 
                                      andDefense:MAGE_DEFENSE_LVL1];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_WarriorAttackMagePERFECTWithDefense
{
  // Set expectations
  int expected = 12;
  testCalculator.rightUser = [self userForAttack:MAGE_ATTACK_LVL1 
                                      andDefense:MAGE_DEFENSE_LVL1];
  testCalculator.leftUser = [self userForAttack:WARRIOR_ATTACK_LVL1 
                                     andDefense:WARRIOR_DEFENSE_LVL1];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_mageAttackWarriorHIGHGREATWithDefense
{
  // Set expectations
  int expected = 8;
  testCalculator.rightUser = [self userForAttack:WARRIOR_ATTACK_LVL1 
                                      andDefense:WARRIOR_DEFENSE_LVL1];
  testCalculator.leftUser  = [self userForAttack:MAGE_ATTACK_LVL1 
                                      andDefense:MAGE_DEFENSE_LVL1];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_GREAT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_mageAttackWarriorLOWGREATWithDefense
{
  // Set expectations
  int expected = 6;
  testCalculator.rightUser = [self userForAttack:WARRIOR_ATTACK_LVL1 
                                      andDefense:WARRIOR_DEFENSE_LVL1];
  testCalculator.leftUser  = [self userForAttack:MAGE_ATTACK_LVL1 
                                      andDefense:MAGE_DEFENSE_LVL1];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:LOW_GREAT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_mageAttackWarriorHIGHGOODWithDefense
{
  // Set expectations
  int expected = 4;
  testCalculator.rightUser = [self userForAttack:WARRIOR_ATTACK_LVL1 
                                      andDefense:WARRIOR_DEFENSE_LVL1];
  testCalculator.leftUser  = [self userForAttack:MAGE_ATTACK_LVL1 
                                      andDefense:MAGE_DEFENSE_LVL1];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_GOOD];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_mageAttackWarriorLOWGOODWithDefense
{
  // Set expectations
  int expected = 2;
  testCalculator.rightUser = [self userForAttack:WARRIOR_ATTACK_LVL1 
                                      andDefense:WARRIOR_DEFENSE_LVL1];
  testCalculator.leftUser  = [self userForAttack:MAGE_ATTACK_LVL1 
                                      andDefense:MAGE_DEFENSE_LVL1];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:LOW_GOOD];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

#pragma mark Undefended Tests (maybe unnecessary?)
- (void)test_leftAttackStrengthForUserStats
{
  // Set expectations
  int expected = 92;
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:75];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_skillMultAboveTargetGOOD
{
  // Set expectations
  int expected = 54;
  
  // Run the test
  int result = [testCalculator skillMultForPercent:82];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_skillMultAboveTargetPERFECT
{
  // Set expectations
  int expected = 144;
  
  // Run the test
  int result = [testCalculator skillMultForPercent:76];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_skillMultGOOD
{
  // Set expectations
  int expected = 69;
  
  // Run the test
  int result = [testCalculator skillMultForPercent:52];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_SkillMultGREAT
{
  // Set expectations
  int expected = 139;
  
  // Run the test
  int result = [testCalculator skillMultForPercent:70];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_skillMultForPercentPERFECT
{
  // Set expectations
  int expected = 192;
  
  // Run the test
  int result = [testCalculator skillMultForPercent:72.3];

  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_skillMultMISS
{
  // Set expectations
  int expected = 0;
  
  // Run the test
  int result = [testCalculator skillMultForPercent:10];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_skillMultMISS100
{
  // Set expectations
  int expected = 0;
  
  // Run the test
  int result = [testCalculator skillMultForPercent:100];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

@end
