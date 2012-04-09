//
//  TutorialConstants.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TutorialConstants.h"
#import "SynthesizeSingleton.h"
#import "Globals.h"

@implementation TutorialConstants

@synthesize initEnergy, initHealth, initStamina, initGold, initSilver;
@synthesize structToBuild, diamondCostToInstabuildFirstStruct;
@synthesize archerInitArmor, archerInitAttack;
@synthesize archerInitWeapon, archerInitDefense;
@synthesize mageInitArmor, mageInitAttack, mageInitWeapon, mageInitDefense;
@synthesize warriorInitArmor, warriorInitAttack, warriorInitWeapon, warriorInitDefense;
@synthesize minNameLength, maxNameLength;
@synthesize tutorialQuest;
@synthesize expForLevelThree;
@synthesize levelTwoCities, levelTwoEquips, levelTwoStructs;
@synthesize carpenterStructs, firstCityElementsForBad, firstCityElementsForGood;
@synthesize enemyName, enemyType, questGiverName;
@synthesize beforeBlinkText, beforeCharSelectionText;
@synthesize afterBlinkTextBad, afterBlinkTextGood;
@synthesize afterQuestAcceptText, afterQuestAcceptClosedText;
@synthesize beginBattleText, beginAttackText, afterBattleText;
@synthesize beforeTaskTextGood, beforeTaskTextBad;
@synthesize beforeSkillsText;
@synthesize duringPanTexts;
@synthesize afterSkillPointsText;
@synthesize beforeAviaryText1, beforeAviaryText2;
@synthesize insideAviaryText, missionAviaryText, beforeHomeAviaryText, enemiesAviaryText, beforeEnemiesAviaryText;
@synthesize insideHomeText, beforeCarpenterText, insideCarpenterText1, insideCarpenterText2;
@synthesize beforePurchaseText, afterPurchaseText, beforePlacingText, afterSpeedUpText;
@synthesize referralCode, structCoords, structTimeOfPurchase, structTimeOfBuildComplete, structUsedDiamonds;
@synthesize rejectLocationText;
@synthesize diamondRewardForBeingReferred;
@synthesize createSuccessText, invalidReferCodeText, otherFailText, timeSyncErrorText;

SYNTHESIZE_SINGLETON_FOR_CLASS(TutorialConstants);

- (void) loadTutorialConstants:(StartupResponseProto_TutorialConstants *)constants {
  self.initEnergy = constants.initEnergy;
  self.initHealth = constants.initHealth;
  self.initStamina = constants.initStamina;
  self.initSilver = constants.initCoins;
  self.initGold = constants.initDiamonds;
  self.structToBuild = constants.structToBuild;
  self.diamondCostToInstabuildFirstStruct = constants.diamondCostToInstabuildFirstStruct;
  self.archerInitArmor = constants.archerInitArmor;
  self.archerInitWeapon = constants.archerInitWeapon;
  self.archerInitAttack = constants.archerInitAttack;
  self.archerInitDefense = constants.archerInitDefense;
  self.mageInitArmor = constants.mageInitArmor;
  self.mageInitWeapon = constants.mageInitWeapon;
  self.mageInitAttack = constants.mageInitAttack;
  self.mageInitDefense = constants.mageInitDefense;
  self.warriorInitArmor = constants.warriorInitArmor;
  self.warriorInitAttack = constants.warriorInitAttack;
  self.warriorInitWeapon = constants.warriorInitWeapon;
  self.warriorInitDefense = constants.warriorInitDefense;
  self.minNameLength = constants.minNameLength;
  self.maxNameLength = constants.maxNameLength;
  self.tutorialQuest = constants.tutorialQuest;
  self.expForLevelThree = constants.expRequiredForLevelThree;
  self.firstCityElementsForBad = constants.firstCityElementsForBadList;
  self.firstCityElementsForGood = constants.firstCityElementsForGoodList;
  self.carpenterStructs = constants.carpenterStructsList;
  self.levelTwoCities = constants.citiesNewlyAvailableToUserAfterLevelupList;
  self.levelTwoEquips = constants.newlyEquippableEpicsAndLegendariesForAllClassesAfterLevelupList;
  self.levelTwoStructs = constants.newlyAvailableStructsAfterLevelupList;
  self.diamondRewardForBeingReferred = constants.diamondRewardForBeingReferred;
  
  self.enemyName = @"Rizzy Wirk";
  self.questGiverName = @"Farmer Mitch";
  
  self.duringPanTexts = [NSArray arrayWithObjects:@"Legends spoke of two royal brothers destined for greatness...",
                    @"Tristan, the elder son, assumed the throne leading the Alliance and all that is good.",
                    @"Enraged, Fenrir fled to the Legion, seeking unimaginable powers to destroy the Alliance.",
                    @"Today, he returns with a vengeance, spreading war and chaos across the lands.",
                    @"Just as the Alliance is about to fall, a white light consumes the skies...", nil];
  
  self.beforeCharSelectionText = @"Somebody help me! Weary soldier! Who are you? What is your name?";
  self.beforeBlinkText = @"Please %@, open your eyes!";
  self.afterBlinkTextGood = [NSString stringWithFormat:@"Thank goodness you're awake! The Legion has invaded our town. Talk to %@. He'll know what to do.", self.questGiverName];;
  self.afterBlinkTextBad = [NSString stringWithFormat:@"Welcome back comrade. I do not know how we got here, but talk to %@. He's a Legion informant.", self.questGiverName];
  self.afterQuestAcceptText = @"Here are the tasks you need to complete for this quest. Close the scroll to begin.";
  self.afterQuestAcceptClosedText = @"Now that you have accepted your quest, let's start by attacking that soldier.";
  self.beginBattleText = @"Tap the attack dial to begin. Take him out!";
  self.beginAttackText = @"Aim for the max for a more powerful attack!";
  self.afterBattleText = @"You made that look easy, but we've still got work to do. Exit the battle and let's finish the last task.";
  self.beforeTaskTextGood = @"It seems the Legion's men are terrorizing the Tavern. Go in there and break it up.";
  self.beforeTaskTextBad = @"Go to the Tavern and set an example of these men by roughing them up.";
  self.beforeSkillsText = [NSString stringWithFormat:@"Skill points are key to your success. You are awarded %d skill points every level. Allocate them wisely.", [[Globals sharedGlobals] skillPointsGainedOnLevelup]];
  self.afterSkillPointsText = @"Great! Now let's equip that amulet you stole during battle.";
  self.beforeAviaryText1 = @"Battles cost stamina and tasks cost energy, but that's the only way to get stronger! Now let's go back to your place.";
  self.beforeAviaryText2 = @"Click on the Aviary to navigate around the world of Utopia. There will be one present in every location.";
  self.insideAviaryText = @"Before we go to your place, let me teach you how to use the Aviary.";
  self.missionAviaryText = @"In the missions tab, navigate the world and complete quests by using this map.";
  self.beforeEnemiesAviaryText = @"Now let's check out the Attack tab. Hurry! I'm getting tired.";
  self.enemiesAviaryText = @"Utilize this map to fight and defeat real players in their real locations all around the world!";
  self.rejectLocationText = @"We will assign you a random location. You can give 'Lost Nations' location permissions in your device settings anytime.";
  self.beforeHomeAviaryText = @"Let's get some rest now by going home!";
  self.insideHomeText = @"Wait… you mean to tell me you don't even have a bed to sleep in!?";
  self.beforeCarpenterText = @"Click on your carpenter and build an inn now!";
  self.insideCarpenterText1 = @"The carpenter allows you to construct buildings in your home map. Buildings generate silver for you over time.";
  self.insideCarpenterText2 = @"Additionally, in the Special tab, you can acquire buildings that provide special features free of cost.";
  self.beforePurchaseText = @"Now, click on the Inn to purchase it.";
  self.beforePlacingText = @"You can only place buildings on certain tiles. Move the Inn off the road and click the green checkmark when you are ready.";
  self.afterPurchaseText = @"I don't have time to wait around for your inn to finish. Speed it up!";
  self.afterSpeedUpText = @"Alright! Now take a short break. If someone referred you, enter his or her referral code to earn both of you some extra gold.";
  self.createSuccessText = @"Congratulations %@! It seems like you know what you're doing. Get back out there and bring glory to the %@!";
  self.timeSyncErrorText = @"Please change your device's time to \"Set Automatically\" to prevent crashes during gameplay.";
  self.invalidReferCodeText = @"The referral code you entered is invalid.";
  self.otherFailText = @"There was an error in creating your player. Please contact support@lvl6.com to let us know how this happened.";
}

- (void) dealloc {
  self.archerInitArmor = nil;
  self.archerInitWeapon = nil;
  self.warriorInitArmor = nil;
  self.warriorInitWeapon = nil;
  self.mageInitArmor = nil;
  self.mageInitWeapon = nil;
  self.firstCityElementsForBad = nil;
  self.firstCityElementsForGood = nil;
  self.carpenterStructs = nil;
  self.levelTwoCities = nil;
  self.levelTwoEquips = nil;
  self.levelTwoStructs = nil;
  self.tutorialQuest = nil;
  self.duringPanTexts = nil;
  self.beforeCharSelectionText = nil;
  self.beforeBlinkText = nil;
  self.afterBlinkTextBad = nil;
  self.afterBlinkTextGood = nil;
  self.afterQuestAcceptText = nil;
  self.afterQuestAcceptClosedText = nil;
  self.beginBattleText = nil;
  self.beginAttackText = nil;
  self.afterBattleText = nil;
  self.beforeTaskTextBad = nil;
  self.beforeTaskTextGood = nil;
  self.beforeSkillsText = nil;
  self.afterSkillPointsText = nil;
  self.beforeAviaryText1 = nil;
  self.beforeAviaryText2 = nil;
  self.insideAviaryText = nil;
  self.missionAviaryText = nil;
  self.beforeEnemiesAviaryText = nil;
  self.enemiesAviaryText = nil;
  self.beforeHomeAviaryText = nil;
  self.insideHomeText = nil;
  self.beforeCarpenterText = nil;
  self.insideCarpenterText1 = nil;
  self.insideCarpenterText2 = nil;
  self.beforePurchaseText = nil;
  self.beforePlacingText = nil;
  self.afterPurchaseText = nil;
  self.afterSpeedUpText = nil;
  self.enemyName = nil;
  self.questGiverName = nil;
  self.referralCode = nil;
  self.structTimeOfPurchase = nil;
  self.structTimeOfBuildComplete = nil;
  
  [super dealloc];
}

@end
