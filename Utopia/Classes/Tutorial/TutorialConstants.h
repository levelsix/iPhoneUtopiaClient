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
@property (nonatomic, assign) int minNameLength;
@property (nonatomic, assign) int maxNameLength;
@property (nonatomic, assign) int expForLevelThree;
@property (nonatomic, retain) NSArray *firstCityElementsForGood;
@property (nonatomic, retain) NSArray *firstCityElementsForBad;
@property (nonatomic, retain) NSArray *carpenterStructs;
@property (nonatomic, retain) NSArray *levelTwoCities;
@property (nonatomic, retain) NSArray *levelTwoEquips;
@property (nonatomic, retain) NSArray *levelTwoStructs;
@property (nonatomic, retain) StartupResponseProto_TutorialConstants_FullTutorialQuestProto *tutorialQuest;

@property (nonatomic, retain) NSArray *duringPanTexts;

@property (nonatomic, retain) NSString *beforeCharSelectionText;
@property (nonatomic, retain) NSString *beforeBlinkText;
@property (nonatomic, retain) NSString *afterBlinkTextGood;
@property (nonatomic, retain) NSString *afterBlinkTextBad;

@property (nonatomic, retain) NSString *afterQuestAcceptText;
@property (nonatomic, retain) NSString *afterQuestAcceptClosedText;

@property (nonatomic, retain) NSString *beginBattleText;
@property (nonatomic, retain) NSString *beginAttackText;
@property (nonatomic, retain) NSString *afterBattleText;

@property (nonatomic, retain) NSString *beforeTaskTextGood;
@property (nonatomic, retain) NSString *beforeTaskTextBad;
@property (nonatomic, retain) NSString *beforeSkillsText;
@property (nonatomic, retain) NSString *afterSkillPointsText;

@property (nonatomic, retain) NSString *beforeAviaryText1;
@property (nonatomic, retain) NSString *beforeAviaryText2;
@property (nonatomic, retain) NSString *insideAviaryText;
@property (nonatomic, retain) NSString *missionAviaryText;
@property (nonatomic, retain) NSString *beforeEnemiesAviaryText;
@property (nonatomic, retain) NSString *enemiesAviaryText;
@property (nonatomic, retain) NSString *rejectLocationText;
@property (nonatomic, retain) NSString *beforeHomeAviaryText;

@property (nonatomic, retain) NSString *insideHomeText;
@property (nonatomic, retain) NSString *beforeCarpenterText;
@property (nonatomic, retain) NSString *insideCarpenterText1;
@property (nonatomic, retain) NSString *insideCarpenterText2;
@property (nonatomic, retain) NSString *beforePurchaseText;
@property (nonatomic, retain) NSString *beforePlacingText;
@property (nonatomic, retain) NSString *afterPurchaseText;

@property (nonatomic, retain) NSString *afterSpeedUpText;

@property (nonatomic, retain) NSString *createSuccessText;
@property (nonatomic, retain) NSString *timeSyncErrorText;
@property (nonatomic, retain) NSString *invalidReferCodeText;
@property (nonatomic, retain) NSString *otherFailText;

@property (nonatomic, retain) NSString *enemyName;
@property (nonatomic, assign) UserType enemyType;
@property (nonatomic, retain) NSString *questGiverName;

// Values needed for user create
@property (nonatomic, retain) NSString *referralCode;
@property (nonatomic, retain) NSDate *structTimeOfPurchase;
@property (nonatomic, retain) NSDate *structTimeOfBuildComplete;
@property (nonatomic, assign) CGPoint structCoords;
@property (nonatomic, assign) BOOL structUsedDiamonds;

@property (nonatomic, assign) int diamondRewardForBeingReferred;

+ (TutorialConstants *) sharedTutorialConstants;
- (void) loadTutorialConstants:(StartupResponseProto_TutorialConstants *)constants;

@end
