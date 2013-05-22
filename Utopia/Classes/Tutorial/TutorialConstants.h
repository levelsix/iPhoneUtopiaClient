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
@property (nonatomic, assign) int initGold;
@property (nonatomic, assign) int initSilver;
@property (nonatomic, assign) int structToBuild;
@property (nonatomic, assign) int diamondCostToInstabuildFirstStruct;
@property (nonatomic, assign) int archerInitAttack;
@property (nonatomic, assign) int archerInitDefense;
@property (nonatomic, retain) FullEquipProto *archerInitWeapon;
@property (nonatomic, retain) FullEquipProto *archerInitArmor;
@property (nonatomic, assign) int mageInitAttack;
@property (nonatomic, assign) int mageInitDefense;
@property (nonatomic, retain) FullEquipProto *mageInitWeapon;
@property (nonatomic, retain) FullEquipProto *mageInitArmor;
@property (nonatomic, assign) int warriorInitAttack;
@property (nonatomic, assign) int warriorInitDefense;
@property (nonatomic, retain) FullEquipProto *warriorInitWeapon;
@property (nonatomic, retain) FullEquipProto *warriorInitArmor;
@property (nonatomic, assign) int expForLevelThree;
@property (nonatomic, retain) NSArray *firstCityElementsForGood;
@property (nonatomic, retain) NSArray *firstCityElementsForBad;
@property (nonatomic, retain) NSArray *carpenterStructs;
@property (nonatomic, retain) NSArray *levelTwoCities;
@property (nonatomic, retain) NSArray *levelTwoEquips;
@property (nonatomic, retain) NSArray *levelTwoStructs;
@property (nonatomic, retain) StartupResponseProto_TutorialConstants_FullTutorialQuestProto *tutorialQuest;
@property (nonatomic, retain) NSString *defaultName;

@property (nonatomic, retain) NSString *firstTaskText;
@property (nonatomic, retain) NSString *lootText;

@property (nonatomic, retain) NSString *questIconText;
@property (nonatomic, retain) NSString *questTaskText;
@property (nonatomic, retain) NSString *beforeEquipText;

@property (nonatomic, retain) NSString *beforeAttackText;
@property (nonatomic, retain) NSString *tapToAttackText;

@property (nonatomic, retain) NSString *beforeBazaarText;
@property (nonatomic, retain) NSString *beforeBlacksmithText;

@property (nonatomic, retain) NSString *beforeHomeText;

@property (nonatomic, retain) NSString *beforeCarpenterText;
@property (nonatomic, retain) NSString *beforePlacingText;
@property (nonatomic, retain) NSString *afterPurchaseText;
@property (nonatomic, retain) NSString *beforeSpeedupText;

@property (nonatomic, retain) NSString *beforeFaceDialText;
@property (nonatomic, retain) NSString *beforeWallText;

@property (nonatomic, retain) NSString *duringCreateText;
@property (nonatomic, retain) NSString *beforeEndText;

@property (nonatomic, retain) NSString *timeSyncErrorText;
@property (nonatomic, retain) NSString *otherFailText;

@property (nonatomic, retain) NSString *enemyName;
@property (nonatomic, assign) UserType enemyType;
@property (nonatomic, retain) NSString *questGiverName;

@property (nonatomic, retain) PlayerWallPostProto *firstWallPost;

@property (nonatomic, retain) FullTaskProto *firstTaskGood;
@property (nonatomic, retain) FullTaskProto *firstTaskBad;
@property (nonatomic, assign) int firstBattleCoinGain;
@property (nonatomic, assign) int firstBattleExpGain;

// Values needed for user create
@property (nonatomic, retain) NSString *referralCode;
@property (nonatomic, retain) NSDate *structTimeOfPurchase;
@property (nonatomic, retain) NSDate *structTimeOfBuildComplete;
@property (nonatomic, assign) CGPoint structCoords;
@property (nonatomic, assign) BOOL structUsedDiamonds;

@property (nonatomic, assign) int diamondRewardForBeingReferred;

+ (TutorialConstants *) sharedTutorialConstants;
+ (void) purgeSingleton;
- (void) loadTutorialConstants:(StartupResponseProto_TutorialConstants *)constants;

@end
