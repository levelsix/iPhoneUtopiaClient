//
//  TutorialConstants.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TutorialConstants.h"
#import "SynthesizeSingleton.h"

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
  
  self.enemyName = @"Rizzy Wirk";
  self.questGiverName = @"Farmer Mitch";
  
  self.duringPanTexts = [NSArray arrayWithObjects:@"Legends spoke of two royal brothers destined for greatness...",
                    @"Tristan,  assumed the throne leading the Alliance and all that is good.",
                    @"Enraged, Fenrir fled to the Legion, seeking unimaginable powers to destroy the Alliance.",
                    @"Today, he returns with a vengeance, spreading war and chaos across the lands.",
                    @"Just as the Alliance is about to fall, a white light consumes the skies...", nil];
  
  self.beforeCharSelectionText = @"Somebody help me! Weary soldier! Who are you? What is your name?";
  self.beforeBlinkText = @"Please %@, open your eyes!";
  self.afterBlinkTextGood = @"Thank goodness you're awake! The Legion has invaded our town. Talk to Farmer Lieu. He'll know what to do.";
  self.afterBlinkTextBad = @"Welcome back comrade. I do not know how we got here, but talk to Farmer Lieu. He's a Legion informant.";
  self.afterQuestAcceptText = @"Here are the tasks you need to complete for this quest. Close the scroll to begin.";
  self.afterQuestAcceptClosedText = @"Now that you have accepted your quest, let's start by attacking that soldier.";
  self.beginBattleText = @"Tap the attack dial to begin. Take him out!";
  self.beginAttackText = @"Aim for the max for a more powerful attack!";
  self.afterBattleText = @"You made that look easy, but we've still got work to do. Exit the battle and let's finish the last task.";
  self.beforeTaskTextGood = @"It seems the Legion's men are terrorizing the Tavern. Go in there and break it up.";
  self.beforeTaskTextBad = @"Go to the Tavern and set an example of these men by roughing them up.";
  self.beforeSkillsText = @"Skill points are key to your success. Allocate them wisely.";
  self.afterSkillPointsText = @"Great! Now let's equip that amulet you stole during battle.";
  self.beforeAviaryText1 = @"You seem tired… but its too dangerous to rest here! Why don't we go back to your place? ";
  self.beforeAviaryText2 = @"Click on the Aviary to navigate around the world of Utopia. There will be one present in every location.";
}

@end
