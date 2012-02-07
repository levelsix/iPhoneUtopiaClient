//
//  Globals.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Globals : NSObject

@property (nonatomic, assign) float depositPercentCut;

@property (nonatomic, assign) float clericLevelFactor;
@property (nonatomic, assign) float clericHealthFactor;

@property (nonatomic, assign) int attackBaseGain;
@property (nonatomic, assign) int defenseBaseGain;
@property (nonatomic, assign) int energyBaseGain;
@property (nonatomic, assign) int staminaBaseGain;
@property (nonatomic, assign) int healthBaseGain;
@property (nonatomic, assign) int attackBaseCost;
@property (nonatomic, assign) int defenseBaseCost;
@property (nonatomic, assign) int energyBaseCost;
@property (nonatomic, assign) int staminaBaseCost;
@property (nonatomic, assign) int healthBaseCost;

@property (nonatomic, assign) float retractPercentCut;
@property (nonatomic, assign) float purchasePercentCut;

@property (nonatomic, assign) int energyRefillCost;
@property (nonatomic, assign) int staminaRefillCost;

+ (Globals *) sharedGlobals;

@end
