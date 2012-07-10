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


#define MAGE_ATTACK_LVL1      14
#define MAGE_DEFENSE_LVL1     10
#define ARCHER_ATTACK_LVL1    12
#define ARCHER_DEFENSE_LVL1   12
#define WARRIOR_ATTACK_LVL1   10
#define WARRIOR_DEFENSE_LVL1  14

//example characters
#define MAGE_ATTACK_LVL2      15
#define MAGE_DEFENSE_LVL2     10
#define MAGE_ATTACK_LVL3      17
#define MAGE_DEFENSE_LVL3     11
#define MAGE_ATTACK_LVL4      18 + 6
#define MAGE_DEFENSE_LVL4     12 + 6

#define PERFECT_PERCENT_THRESHOLD 3.0f
#define GREAT_PERCENT_THRESHOLD   17.0f
#define GOOD_PERCENT_THRESHOLD    38.0f

#define PERFECT_MULTIPLIER  2.0f
#define GREAT_MULTIPLIER    1.5f
#define GOOD_MULTIPLIER     1.0f

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
  leftStats = [self userForAttack:40 
                        andDefense:0 
                          andLevel:1];
  rightStats = [self userForAttack:40 
                        andDefense:0 
                          andLevel:1];

  [Globals sharedGlobals].locationBarMax = HIGH_PERFECT;
  
  id<BattleConstants> battleConstants = [Globals sharedGlobals];
  battleConstants.battleWeightGivenToDefenseStat     = 1;
  battleConstants.battleWeightGivenToDefenseEquipSum = 1;
  battleConstants.battleWeightGivenToAttackStat      = 1;
  battleConstants.battleWeightGivenToAttackEquipSum  = 1;
  battleConstants.battleWeightGivenToLevel           = 1;
  
  id<EnemyBattleStats> battleStats = [Globals sharedGlobals];
  battleStats.perfectLikelihood = 0.25f;
  battleStats.greatLikelihood   = 0.5f;
  battleStats.goodLikelihood    = 0.15f;
  battleStats.missLikelihood    = 0.10f;

  battleConstants.battlePerfectPercentThreshold = PERFECT_PERCENT_THRESHOLD;
  battleConstants.battleGreatPercentThreshold   = GREAT_PERCENT_THRESHOLD;
  battleConstants.battleGoodPercentThreshold    = GOOD_PERCENT_THRESHOLD;
  
  battleConstants.battlePerfectMultiplier = PERFECT_MULTIPLIER;
  battleConstants.battleGreatMultiplier   = GREAT_MULTIPLIER;
  battleConstants.battleGoodMultiplier    = GOOD_MULTIPLIER;
  
  testCalculator = [[BattleCalculator alloc] initWithRightStats:rightStats
                                                   andLeftStats:leftStats
                                             andBattleConstants:battleConstants 
                                                 andBattleStats:battleStats];
  srand(4321489024315);
}

- (void)tearDown
{
  // Tear-down code here.
  [testCalculator release];
  [super tearDown];
}

#pragma mark ComboBar %
- (void)test_4enemyPercentages
{
  // Set expectations
  float expected = 85.772339;
  int numTests   = 4;
  NSMutableArray *percentages = [NSMutableArray arrayWithCapacity:numTests];
  
  // Run the test
  for (int i = 0;  i < numTests; i++) {
    [percentages addObject:[NSNumber numberWithFloat:[testCalculator
                                                      calculateEnemyPercentage]]];
  }

  float result = [testCalculator calculateEnemyPercentage];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %f got %f", expected, result);
}

- (void)test_87enemyPercentages
{
  // Set expectations
  float expected = 44.534901;
  int numTests   = 87;
  NSMutableArray *percentages = [NSMutableArray arrayWithCapacity:numTests];
  
  // Run the test
  for (int i = 0;  i < numTests; i++) {
    [percentages addObject:[NSNumber numberWithFloat:[testCalculator
                                                     calculateEnemyPercentage]]];
  }

  float result = [testCalculator calculateEnemyPercentage];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %f got %f", expected, result);
}

#pragma mark Warrior/Warrior DefenseTests
- (void)test_WarriorAttackWARRIORPERFECTWithDefenseHighLevel
{
  // Set expectations
  int expected = 24;
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
- (void)test_MageAttackMagePERFECTWithDefenseHighLevel
{
  // Set expectations
  int expected = 40;
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
  int expected = 20;
  testCalculator.rightUser = [self userForAttack:MAGE_ATTACK_LVL1 
                                      andDefense:MAGE_DEFENSE_LVL1];
  testCalculator.leftUser  = [self userForAttack:MAGE_ATTACK_LVL1 
                                      andDefense:MAGE_DEFENSE_LVL1];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

#pragma mark  Tests for fights betweeen characters of different level
- (void)test_MageAttackLowerLevelMagePERFECTWithDefenseLevelImbalance2
{
  // Set expectations
  int expected = 26;
  testCalculator.rightUser = [self userForAttack:MAGE_ATTACK_LVL1 
                                      andDefense:MAGE_DEFENSE_LVL1 
                                        andLevel:1];
  testCalculator.leftUser  = [self userForAttack:MAGE_ATTACK_LVL3 
                                      andDefense:MAGE_DEFENSE_LVL3 
                                        andLevel:3];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_MageAttackHigherLevelMagePERFECTWithDefenseLevelImbalance2
{
  // Set expectations
  int expected = 18;

  testCalculator.rightUser  = [self userForAttack:MAGE_ATTACK_LVL3 
                                      andDefense:MAGE_DEFENSE_LVL3 
                                        andLevel:3];
  testCalculator.leftUser   = [self userForAttack:MAGE_ATTACK_LVL1 
                                      andDefense:MAGE_DEFENSE_LVL1 
                                        andLevel:1];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_MageAttackLowerLevelMageGREATWithDefenseLevelImbalance3
{
  // Set expectations
  int expected = 28;
  testCalculator.rightUser = [self userForAttack:MAGE_ATTACK_LVL1 
                                      andDefense:MAGE_DEFENSE_LVL1 
                                        andLevel:1];
  testCalculator.leftUser  = [self userForAttack:MAGE_ATTACK_LVL4 
                                      andDefense:MAGE_DEFENSE_LVL4 
                                        andLevel:4];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_GREAT];

  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_MageAttackHigherLevelMageGREATWithDefenseLevelImbalance
{
  // Set expectations
  int expected = 8;
  testCalculator.rightUser = [self userForAttack:MAGE_ATTACK_LVL4 
                                      andDefense:MAGE_DEFENSE_LVL4 
                                        andLevel:4];
  testCalculator.leftUser  = [self userForAttack:MAGE_ATTACK_LVL1 
                                      andDefense:MAGE_DEFENSE_LVL1 
                                        andLevel:1];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_GREAT];
  
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
  int expected = 16;
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
  int expected = 16;
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
  int expected = 11;
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
  int expected = 9;
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
  int expected = 6;
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
  int expected = 3;
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
- (void)test_WarriorAttackMagePERFECTWithDefenseHighLevel
{
  // Set expectations
  int expected = 14;
  testCalculator.rightUser = [self userForAttack:MAGE_ATTACK_LVL1
                                      andDefense:MAGE_DEFENSE_LVL1 
                                        andLevel:2];
  testCalculator.leftUser  = [self userForAttack:WARRIOR_ATTACK_LVL1 
                                      andDefense:WARRIOR_DEFENSE_LVL1 
                                        andLevel:2];
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_MageAttackWarriorPERFECTWithDefenseHighLevel
{
  // Set expectations
  int expected = 14;
  testCalculator.rightUser = [self userForAttack:WARRIOR_ATTACK_LVL1
                                      andDefense:WARRIOR_DEFENSE_LVL1 
                                        andLevel:2];
  testCalculator.leftUser  = [self userForAttack:MAGE_ATTACK_LVL1 
                                      andDefense:MAGE_DEFENSE_LVL1 
                                        andLevel:2];
  

  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:HIGH_PERFECT];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

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
