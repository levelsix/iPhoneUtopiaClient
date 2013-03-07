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
  self.tutorialQuest = constants.tutorialQuest;
  self.expForLevelThree = constants.expRequiredForLevelThree;
  self.firstCityElementsForBad = constants.firstCityElementsForBadList;
  self.firstCityElementsForGood = constants.firstCityElementsForGoodList;
  self.carpenterStructs = constants.carpenterStructsList;
  self.levelTwoCities = constants.citiesNewlyAvailableToUserAfterLevelupList;
  self.levelTwoEquips = constants.newlyEquippableEpicsAndLegendariesForAllClassesAfterLevelupList;
  self.levelTwoStructs = constants.newlyAvailableStructsAfterLevelupList;
  self.firstWallPost = constants.firstWallPost;
  self.firstTaskBad = constants.firstTaskBad;
  self.firstTaskGood = constants.firstTaskGood;
  self.firstBattleCoinGain = constants.firstBattleCoinGain;
  self.firstBattleExpGain = constants.firstBattleExpGain;
  
  self.enemyName = @"Rizzy Wirk";
  self.questGiverName = @"Farmer Mitch";
  
  self.firstTaskText = @"Rebels have invaded the tavern. Tap to engage!";
  self.lootText = @"Outstanding work! Now tap the loot to collect it.";
  self.questIconText = @"Tap this icon to see your QUESTS.";
  self.questTaskText = @"Tap the Captain and take him out!";
  self.beforeEquipText = @"Great! Now let's equip that amulet you just received.";
  self.beforeAttackText = @"Now, let's attack a rival player.";
  self.tapToAttackText = @"Tap to attack a rival.";
  self.beforeHomeText = @"Well done! You're ready to run your own city. Tap here to check it out.";
  self.beforeCarpenterText = @"Buildings earn silver. Tap on your carpenter and build an inn!";
  self.beforePlacingText = @"Drag your inn to a suitable location and tap the green checkmark.";
  self.afterPurchaseText = @"I don't have time to wait around for your inn to finish. Speed it up!";
  self.beforeSpeedupText = @"Gold is a powerful resource. Use it now to complete construction!";
  self.beforeFaceDialText = @"You've got a notification! Tap on the face dial to access the menu.";
  self.beforeWallText = @"Someone posted on your wall! Tap the profile button to see their post.";
  self.duringCreateText = @"You're doing great! Hold on while we prep the game for your adventures!";
  self.beforeEndText = @"Alright! Be on your way! The townspeople have quests for you.";
  self.timeSyncErrorText = @"Looks like the time on your device is wrong, reset and restart, thx!";
  self.otherFailText = @"There was an error (code=%d). Email support@lvl6.com for help, thanks!";
}

@end
