//
//  BattleCalculatorTests.m
//  Utopia
//
//  Created by Kevin Calloway on 6/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "BattleCalculatorTests.h"
#import "Globals.h"

@implementation BattleCalculatorTests

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

- (void)test_leftAttackStrengthForUserStats
{
  // Set expectations
  int expected = 60;
  
  // Run the test
  int result = [testCalculator leftAttackStrengthForPercent:75];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_rightSkillMultAboveTargetGOOD
{
  // Set expectations
  int expected = 72;
  
  // Run the test
  int result = [testCalculator skillMultForPercent:82
                                            andAttacker:rightStats
                                            andDefender:leftStats];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_rightSkillMultGOOD
{
  // Set expectations
  int expected = 27;
  
  // Run the test
  int result = [testCalculator skillMultForPercent:52
                                            andAttacker:rightStats
                                            andDefender:leftStats];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_rightSkillMultGREAT
{
  // Set expectations
  int expected = 74;
  
  // Run the test
  int result = [testCalculator skillMultForPercent:70
                                            andAttacker:rightStats
                                            andDefender:leftStats];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_SkillMultForPercentPERFECT
{
  // Set expectations
  int expected = 144;
  
  // Run the test
  int result = [testCalculator skillMultForPercent:72.3
                                            andAttacker:rightStats
                                            andDefender:leftStats];

  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_rightskillMultMISS
{
  // Set expectations
  int expected = 0;
  
  // Run the test
  int result = [testCalculator skillMultForPercent:10
                                            andAttacker:rightStats
                                            andDefender:leftStats];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

- (void)test_rightSkillMultMISS100
{
  // Set expectations
  int expected = 0;
  
  // Run the test
  int result = [testCalculator skillMultForPercent:100
                                            andAttacker:rightStats
                                            andDefender:leftStats];
  
  // Check expectations
  STAssertTrue(expected == result, @"Expected %d got %d", expected, result);
}

@end
