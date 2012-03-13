//
//  TutorialConstants.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"

@interface TutorialConstants : NSObject

@property (nonatomic, assign) int initEnergy;
@property (nonatomic, assign) int initStamina;
@property (nonatomic, assign) int initHealth;
@property (nonatomic, assign) int structToBuild;
@property (nonatomic, assign) int diamondCostToInstabuildFirstStruct;
@property (nonatomic, assign) int archerInitAttack;
@property (nonatomic, assign) int archerInitDefense;
@property (nonatomic, assign) FullEquipProto *archerInitWeapon;
@property (nonatomic, assign) FullEquipProto *archerInitArmor;
@property (nonatomic, assign) int mageInitAttack;
@property (nonatomic, assign) int mageInitDefense;
@property (nonatomic, assign) FullEquipProto *mageInitWeapon;
@property (nonatomic, assign) FullEquipProto *mageInitArmor;
@property (nonatomic, assign) int warriorInitAttack;
@property (nonatomic, assign) int warriorInitDefense;
@property (nonatomic, assign) FullEquipProto *warriorInitWeapon;
@property (nonatomic, assign) FullEquipProto *warriorInitArmor;
@property (nonatomic, assign) int minNameLength;
@property (nonatomic, assign) int maxNameLength;
@property (nonatomic, assign) int diamondRewardForReferrer;
@property (nonatomic, assign) int diamondRewardForBeingReferred;


@end
