//
//  TutorialConstants.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TutorialConstants.h"
#import "LNSynthesizeSingleton.h"
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
@synthesize beforeEnemyClickedText, beforeAttackClickedText;
@synthesize beforeTaskTextGood, beforeTaskTextBad;
@synthesize beforeRedeemText;
@synthesize beforeSkillsText;
@synthesize duringPanTexts;
@synthesize afterSkillPointsText;
@synthesize beforeHomeText, insideHomeText, beforeCarpenterText;
@synthesize beforePlacingText, beforeFaceDialText, beforeWallText, afterPurchaseText;
@synthesize duringCreateText, beforeEndText;
@synthesize referralCode, structCoords, structTimeOfPurchase, structTimeOfBuildComplete, structUsedDiamonds;
@synthesize diamondRewardForBeingReferred;
@synthesize otherFailText, timeSyncErrorText;
@synthesize firstWallPost;

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
  self.firstWallPost = constants.firstWallPost;
  
  self.enemyName = @"Rizzy Wirk";
  self.questGiverName = @"Farmer Mitch";
  
  self.duringPanTexts = [NSArray arrayWithObjects:
                         @"Legends spoke of Tristan and Fenrir, two royal brothers destined for greatness...",
                         @"Tristan, the younger son, assumed the throne leading the Alliance because of his father's will.",
                         @"Enraged, Fenrir fled to the Legion, seeking unimaginable powers to destroy the Alliance.",
                         @"Today, he returns with a vengeance, spreading war and chaos across the lands.",
                         @"Just as the Alliance is about to fall, a white light consumes the skies...", nil];
  
  self.beforeCharSelectionText = @"Somebody help me! Weary soldier! Who are you? What is your name?";
  self.beforeBlinkText = @"Please %@, open your eyes!";
  self.afterBlinkTextGood = [NSString stringWithFormat:@"The Legion has invaded our town! Tap on %@ to talk with him.", self.questGiverName];;
  self.afterBlinkTextBad = [NSString stringWithFormat:@"We're taking over the town! Tap on %@ to talk with him.", self.questGiverName];
  self.beforeEnemyClickedText = [NSString stringWithFormat:@"Tap on %@.", self.enemyName];
  self.beforeAttackClickedText = @"Hit attack!";
  self.beforeTaskTextGood = @"Tap on the tavern and break up the fight.";
  self.beforeTaskTextBad = @"Tap on the tavern and rough up the men.";
  self.beforeRedeemText = [NSString stringWithFormat:@"Nice job! Tap on %@ to claim your reward.", self.questGiverName];
  self.beforeSkillsText = @"Skill points make you stronger. Tap on the + signs to allocate them.";
  self.afterSkillPointsText = @"Great! Now let's equip that amulet you stole during battle.";
  self.beforeHomeText = @"Let's get some rest now by going home!";
  self.insideHomeText = @"Wait… you mean to tell me you don't even have a bed to sleep in!?";
  self.beforeCarpenterText = @"Buildings earn income. Tap on your carpenter and build an inn!";
  self.beforePlacingText = @"Drag your inn to a suitable location and tap the green checkmark.";
  self.afterPurchaseText = @"I don't have time to wait around for your inn to finish. Speed it up!";
  self.beforeFaceDialText = @"You've got a notification! Tap on the face dial to access the menu.";
  self.beforeWallText = @"Someone posted on your wall! Tap the profile button to see their post.";
  self.duringCreateText = @"You're doing great! Hold on while we prep the game for your adventures!";
  self.beforeEndText = @"Alright! Be on your way! The townspeople have quests for you.";
  self.timeSyncErrorText = @"Looks like the time on your device is wrong, reset and restart, thx!";
  self.otherFailText = @"There was an error (code=%d). Email support@lvl6.com for help, thanks!";
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
  self.beforeEnemyClickedText = nil;
  self.beforeAttackClickedText = nil;
  self.beforeTaskTextBad = nil;
  self.beforeTaskTextGood = nil;
  self.beforeRedeemText = nil;
  
  self.beforeSkillsText = nil;
  self.afterSkillPointsText = nil;
  self.beforeHomeText = nil;
  self.insideHomeText = nil;
  self.beforePlacingText = nil;
  self.afterPurchaseText = nil;
  self.beforeFaceDialText = nil;
  self.beforeWallText = nil;
  self.beforeEndText = nil;
  self.duringCreateText = nil;
  self.timeSyncErrorText = nil;
  self.otherFailText = nil;
  self.enemyName = nil;
  self.questGiverName = nil;
  self.referralCode = nil;
  self.structTimeOfPurchase = nil;
  self.structTimeOfBuildComplete = nil;
  self.firstWallPost = nil;
  
  [super dealloc];
}

@end
