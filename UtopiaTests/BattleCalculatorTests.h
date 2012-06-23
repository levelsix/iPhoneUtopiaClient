//
//  BattleCalculatorTests.h
//  Utopia
//
//  Created by Kevin Calloway on 6/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "BattleCalculator.h"

@interface BattleCalculatorTests : SenTestCase {
  id<BattleCalculator> testCalculator;
  id<UserBattleStats> rightStats;
  id<UserBattleStats> leftStats;
}

@end
