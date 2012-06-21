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

#define IMBALANCE_PERCENT     0.65F
#define START_POINTS          32

#define MAGE_ATTACK_LVL1      START_POINTS*IMBALANCE_PERCENT
#define MAGE_DEFENSE_LVL1     START_POINTS*(1 - IMBALANCE_PERCENT)
#define ARCHER_ATTACK_LVL1    START_POINTS/2
#define ARCHER_DEFENSE_LVL1   START_POINTS/2
#define WARRIOR_ATTACK_LVL1   MAGE_DEFENSE_LVL1
#define WARRIOR_DEFENSE_LVL1  MAGE_ATTACK_LVL1

@implementation BattleCalculatorTests
-(id<UserBattleStats>)userForAttack:(int)attack andDefense:(int)defense
{
  FullUserProto_Builder *builder = [FullUserProto builder];
  [builder setAttack:attack];
  [builder setDefense:defense];
  FullUserProto *user = [builder build];
  
  return [UserBattleStats createWithFullUserProto:user];
}

- (void)setUp
{
  [super setUp];
//  [Globals purgeSingleton];
  FullUserProto_Builder *builder = [FullUserProto builder];
  FullUserProto *leftUser = [[builder setAttack:40] build];
  FullUserProto *rightUser = [[builder setAttack:40] build];

  rightStats = [UserBattleStats createWithFullUserProto:rightUser];
  leftStats  = [UserBattleStats createWithFullUserProto:leftUser];
  testCalculator = [[BattleCalculator alloc] initWithRightStats:rightStats
                                                   andLeftStats:leftStats
                                                     andGlobals:[Globals sharedGlobals]];
  [Globals sharedGlobals].locationBarMax = 75;
}

- (void)tearDown
{
  // Tear-down code here.
  [testCalculator release];
  [super tearDown];
}

#pragma mark Warrior/Warrior DefenseTests
- (void)test_WarriorAttackWARRIORPERFECTWithDefense
{
  // Set expectations
  int expected = 9;
  testCalculator.rightUser = [self userForAttack:8 andDefense:24];
  testCalculator.leftUser  = [self userForAttack:8 andDefense:24];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

#pragma mark MAGE/MAGE DefenseTests
- (void)test_MageAttackMAGEPERFECTWithDefense
{
  // Set expectations
  int expected = 34;
  testCalculator.rightUser = [self userForAttack:24 andDefense:8];
  testCalculator.leftUser  = [self userForAttack:24 andDefense:8];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

#pragma mark MAGE/ARCHER DefenseTests
- (void)test_mageAttackArcherPERFECTWithDefense
{
  // Set expectations
  int expected = 21;
  testCalculator.rightUser = [self userForAttack:16 andDefense:16];
  testCalculator.leftUser  = [self userForAttack:24 andDefense:8];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_archerAttackMagePERFECTWithDefense
{
  // Set expectations
  int expected = 21;
  testCalculator.rightUser = [self userForAttack:24 andDefense:8];
  testCalculator.leftUser = [self userForAttack:16 andDefense:16];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

#pragma mark MAGE/WARRIOR DefenseTests
- (void)test_mageAttackWarriorPERFECTWithDefense
{
  // Set expectations
  int expected = 9;
  testCalculator.rightUser = [self userForAttack:8 andDefense:24];
  testCalculator.leftUser  = [self userForAttack:24 andDefense:8];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_WarriorAttackMagePERFECTWithDefense
{
  // Set expectations
  int expected = 9;
  testCalculator.rightUser = [self userForAttack:24 andDefense:8];
  testCalculator.leftUser = [self userForAttack:8 andDefense:24];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

#pragma mark Balanced DefenseTests
- (void)test_leftAttackStrengthForUserStatsPERFECTWithDefense
{
  // Set expectations
  int expected = 18;
  testCalculator.rightUser = [self userForAttack:12 andDefense:12];
  testCalculator.leftUser  = [self userForAttack:12 andDefense:12];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_leftAttackStrengthForUserStatsGREATWithDefense
{
  // Set expectations
  int expected = 10;
  testCalculator.rightUser = [self userForAttack:12 andDefense:12];
  testCalculator.leftUser  = [self userForAttack:12 andDefense:12];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_GREAT];

  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_leftAttackStrengthForUserStatsLOWGREATWithDefense
{
  // Set expectations
  int expected = 8;
  testCalculator.rightUser = [self userForAttack:12 andDefense:12];
  testCalculator.leftUser  = [self userForAttack:12 andDefense:12];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:LOW_GREAT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_leftAttackStrengthForUserStatsGOODWithDefense
{
  // Set expectations
  int expected = 4;
  testCalculator.rightUser = [self userForAttack:12 andDefense:12];
  testCalculator.leftUser  = [self userForAttack:12 andDefense:12];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_GOOD];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_leftAttackStrengthForUserStatsLOWGOODWithDefense
{
  // Set expectations
  int expected = 3;
  testCalculator.rightUser = [self userForAttack:12 andDefense:12];
  testCalculator.leftUser  = [self userForAttack:12 andDefense:12];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:LOW_GOOD];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}


#pragma mark Undefended Tests
//- (void)test_leftAttackStrengthForUserStats
//{
//  // Set expectations
//  int expected = 60;
//  
//  // Run the test
//  int result = [testCalculator leftAttackStrengthForPercent:75];
//  
//  // Check expectations
//  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
//}
//
//- (void)test_skillMultAboveTargetGOOD
//{
//  // Set expectations
//  int expected = 72;
//  
//  // Run the test
//  int result = [testCalculator skillMultForPercent:82
//                                            andAttacker:rightStats
//                                            andDefender:leftStats];
//  
//  // Check expectations
//  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
//}
//
//- (void)test_skillMultGOOD
//{
//  // Set expectations
//  int expected = 27;
//  
//  // Run the test
//  int result = [testCalculator skillMultForPercent:52
//                                            andAttacker:rightStats
//                                            andDefender:leftStats];
//  
//  // Check expectations
//  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
//}
//
//- (void)test_SkillMultGREAT
//{
//  // Set expectations
//  int expected = 74;
//  
//  // Run the test
//  int result = [testCalculator skillMultForPercent:70
//                                            andAttacker:rightStats
//                                            andDefender:leftStats];
//  
//  // Check expectations
//  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
//}
//
//- (void)test_skillMultForPercentPERFECT
//{
//  // Set expectations
//  int expected = 144;
//  
//  // Run the test
//  int result = [testCalculator skillMultForPercent:72.3
//                                            andAttacker:rightStats
//                                            andDefender:leftStats];
//
//  
//  // Check expectations
//  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
//}
//
//- (void)test_skillMultMISS
//{
//  // Set expectations
//  int expected = 0;
//  
//  // Run the test
//  int result = [testCalculator skillMultForPercent:10
//                                            andAttacker:rightStats
//                                            andDefender:leftStats];
//  
//  // Check expectations
//  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
//}

//- (void)test_skillMultMISS100
//{
//  // Set expectations
//  int expected = 0;
//  
//  // Run the test
//  int result = [testCalculator skillMultForPercent:100
//                                            andAttacker:rightStats
//                                            andDefender:leftStats];
//  
//  // Check expectations
//  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
//}

@end
