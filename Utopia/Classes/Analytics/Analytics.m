//
//  Analytics.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Analytics.h"
#import "Apsalar.h"
#import "Globals.h"
#import "GameState.h"
#import <StoreKit/StoreKit.h>

#define OPENED_APP @"App: Opened"
#define BEGAN_APP @"App: Began"
#define RESUMED_APP @"App: Resumed"
#define SUSPENDED_APP @"App: Suspended"
#define TERMINATED_APP @"App: Terminated"

#define PURCHASED_GOLD @"Purchased gold package"
#define CANCELLED_IAP @"Cancelled gold purchase"
#define TOP_BAR_SHOP @"Viewed gold shop from top bar"

#define GET_MORE_GOLD @"Clicked \"Get more gold\""
#define GET_MORE_SILVER @"Clicked \"Go to Aviary\""
#define NOT_ENOUGH_SILVER_ARMORY @"Armory: Not enough silver"
#define NOT_ENOUGH_GOLD_ARMORY @"Armory: Not enough gold"
#define NOT_ENOUGH_SILVER_UPGRADE @"Upgrade: Not enough silver"
#define NOT_ENOUGH_GOLD_UPGRADE @"Upgrade: Not enough gold"
#define NOT_ENOUGH_GOLD_TO_REFILL_STAMINA_POPUP @"Stamina Popup: Not enough gold"
#define NOT_ENOUGH_GOLD_TO_REFILL_ENERGY_POPUP @"Energy Popup: Not enough gold"
#define NOT_ENOUGH_SILVER_CARPENTER @"Carpenter: Not enough silver"
#define NOT_ENOUGH_GOLD_CARPENTER @"Carpenter: Not enough gold"
#define NOT_ENOUGH_GOLD_INSTA_BUILD @"Insta Build: Not enough gold"
#define NOT_ENOUGH_GOLD_INSTA_UPGRADE @"Insta Upgrade: Not enough gold"
#define NOT_ENOUGH_SILVER_MARKETPLACE_BUY @"Mkt buy: Not enough silver"
#define NOT_ENOUGH_GOLD_MARKETPLACE_BUY @"Mkt buy: Not enough gold"
#define NOT_ENOUGH_SILVER_MARKETPLACE_RETRACT @"Mkt retract: Not enough silver"
#define NOT_ENOUGH_GOLD_MARKETPLACE_RETRACT @"Mkt retract: Not enough gold"
#define NOT_ENOUGH_GOLD_MARKETPLACE_LONG_LICENSE @"Mkt long lic: Not enough gold"
#define NOT_ENOUGH_GOLD_MARKETPLACE_SHORT_LICENSE @"Mkt short lic: Not enough gold"
#define NOT_ENOUGH_GOLD_TO_REFILL_STAMINA_TOPBAR @"Stamina Top Bar: Not enough gold"
#define NOT_ENOUGH_GOLD_TO_REFILL_ENERGY_TOPBAR @"Energy Top Bar: Not enough gold"

#define NOT_ENOUGH_STAMINA_BATTLE @"Battle: Not enough stamina"
#define NOT_ENOUGH_ENERGY_TASKS @"Tasks: Not enough energy"
#define NOT_ENOUGH_EQUIPS_TASKS @"Tasks: Not enough equips"

#define LEVEL_UP @"Level up"
#define PLACE_CRIT_STRUCT @"Placed crit struct"
#define ATTACK_AGAIN @"Battle: Attack again"
#define FLEE @"Battle: Flee"
#define QUEST_ACCEPT @"Quest: Accept"
#define QUEST_COMPLETE @"Quest: Complete"
#define QUEST_REDEEM @"Quest: Redeem"
#define SKILL_POINT @"Profile: Skill Point"
#define MKT_ATTEMPTED_PURCHASE @"Mkt: Attempted Purchase"
#define MKT_ATTEMPTED_POST @"Mkt: Attempted Post"
#define MKT_SUCCESSFUL_PURCHASE @"Mkt: Successful Purchase"
#define MKT_SUCCESSFUL_POST @"Mkt: Successful Post"
#define MKT_VIEW_RETRACT @"Mkt: Viewed retract menu"
#define MKT_ATTEMPTED_RETRACT @"Mkt: Attempted retract"
#define MKT_SUCCESSFUL_RETRACT @"Mkt: Successful retract"
#define MKT_LICENSE_POPUP @"Mkt: License popup"
#define MKT_BOUGHT_LICENSE @"Mkt: Bought license"
#define MKT_LIST_AN_ITEM @"Mkt: Clicked list an item"
#define VAULT_OPEN @"Vault: Opened"
#define VAULT_WITHDRAW @"Vault: Withdraw"
#define VAULT_DEPOSIT @"Vault: Deposit"
#define NORM_STRUCT_UPGRADE @"Norm struct: Upgrade"
#define NORM_STRUCT_PURCHASE @"Norm struct: Purchase"
#define NORM_STRUCT_SELL @"Norm struct: Sell"
#define NORM_STRUCT_INSTA_BUILD @"Norm struct: Insta build"
#define NORM_STRUCT_INSTA_UPGRADE @"Norm struct: Insta upgrade"
#define OPENED_PATH_MENU @"Path Menu: Opened"
#define OPENED_QUEST_LOG @"Path Menu: Clicked quest log"
#define OPENED_NOTIFICATIONS @"Path Menu: Clicked notifications"
#define OPENED_PROFILE @"Path Menu: Clicked profile"
#define CLICKED_VISIT @"Quest Log: Clicked visit"
#define RECEIVED_NOTIFICATION @"Notifications: Received"
#define CLICKED_REVENGE @"Notifications: Clicked revenge"
#define CLICKED_COLLECT @"Notifications: Clicked collect"
#define CLICKED_FILL_ENERGY @"Top bar: Clicked fill energy"
#define CLICKED_FILL_STAMINA @"Top bar: Clicked fill stamina"
#define ENEMY_PROFILE_BATTLE @"Enemy Profile: Battle"
#define ENEMY_PROFILE_ATTACK_MAP @"Enemy Profile: Location map"
#define ENEMY_PROFILE_SPRITE @"Enemy Profile: Sprite"
#define POSTED_TO_ENEMY_PROFILE @"Wall: Posted to Enemy Profile"
#define POSTED_TO_ALLY_PROFILE @"Wall: Posted to Ally Profile"

#define CLICKED_SEARCH @"Mkt: Clicked search"
#define CLICKED_FREE_OFFERS @"Gold Shop: Clicked free offers"
#define CLICKED_VISIT_CITY @"Profile: Clicked visit city"

#define TUTORIAL_START @"Tutorial: Start"
#define TUTORIAL_OPENED_DOOR @"Tutorial: Opened door"
#define TUTORIAL_PAN_DONE @"Tutorial: Pan done"
#define TUTORIAL_CHAR_CHOSEN @"Tutorial: Character chosen"
#define TUTORIAL_QUEST_ACCEPTED @"Tutorial: Quest accepted"
#define TUTORIAL_BATTLE_START @"Tutorial: Battle started"
#define TUTORIAL_BATTLE_COMPLETE @"Tutorial: Battle complete"
#define TUTORIAL_TASK_COMPLETE @"Tutorial: Task complete"
#define TUTORIAL_QUEST_REDEEM @"Tutorial: Quest redeemed"
#define TUTORIAL_SKILL_POINTS_ADDED @"Tutorial: Skill points added"
#define TUTORIAL_AMULET_EQUIPPED @"Tutorial: Amulet equipped"
#define TUTORIAL_GO_HOME @"Tutorial: Clicked home"
#define TUTORIAL_ENTER_CARPENTER @"Tutorial: Enterred carpenter"
#define TUTORIAL_PURCHASE_INN @"Tutorial: Clicked Inn"
#define TUTORIAL_PLACE_INN @"Tutorial: Placed Inn"
#define TUTORIAL_FINISH_NOW @"Tutorial: Insta build"
#define TUTORIAL_WAIT_BUILD @"Tutorial: Waited for build"
#define TUTORIAL_PATH_MENU @"Tutorial: Opened path menu"
#define TUTORIAL_PROFILE_BUTTON @"Tutorial: Clicked profile button"
#define TUTORIAL_USER_CREATED @"Tutorial: User Created"
#define TUTORIAL_TIME_SYNC @"Tutorial: Time not synced"
#define TUTORIAL_OTHER_FAIL @"Tutorial: Other fail"
#define TUTORIAL_COMPLETE @"Tutorial: Complete"

@implementation Analytics

#define OPENED_APP @"App: Opened"
#define BEGAN_APP @"App: Began"
#define RESUMED_APP @"App: Resumed"
#define SUSPENDED_APP @"App: Suspended"
#define TERMINATED_APP @"App: Terminated"

+ (void) event:(NSString *)event {
  [Apsalar event:event];
}

+ (void) event:(NSString *)event withArgs:(NSDictionary *)args {
  [Apsalar event:event withArgs:args];
}

+ (void) openedApp {
  [Analytics event:OPENED_APP];
}

+ (void) beganApp {
  [Analytics event:BEGAN_APP];
}

+ (void) resumedApp {
  [Analytics event:RESUMED_APP];
}

+ (void) suspendedApp {
  [Analytics event:SUSPENDED_APP];
}

+ (void) terminatedApp {
  [Analytics event:TERMINATED_APP];
}

+ (void) purchasedGoldPackage:(NSString *)package price:(float)price goldAmount:(int)gold {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        package, @"package",
                        [NSNumber numberWithFloat:price], @"price",
                        [NSNumber numberWithInt:gold], @"gold",
                        nil];
  
  [Analytics event:PURCHASED_GOLD withArgs:args];
}

+ (void) cancelledGoldPackage:(NSString *)package {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        package, @"package",
                        nil];
  
  [Analytics event:CANCELLED_IAP withArgs:args];
}

+ (void) viewedGoldShopFromTopMenu {
  [Analytics event:TOP_BAR_SHOP];
}

+ (void) clickedGetMoreGold:(int)goldAmt {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:goldAmt], @"gold needed",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        nil];
  
  [Analytics event:GET_MORE_GOLD withArgs:args];
}

+ (void) clickedGetMoreSilver {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.silver], @"current silver",
                        nil];
  
  [Analytics event:GET_MORE_SILVER withArgs:args];
}

+ (void) notEnoughSilverInArmory:(int)equipId {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:gs.silver], @"current silver",
                        [NSNumber numberWithInt:fep.coinPrice], @"silver needed",
                        nil];
  
  [Analytics event:NOT_ENOUGH_SILVER_ARMORY withArgs:args];
}

+ (void) notEnoughGoldInArmory:(int)equipId {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        [NSNumber numberWithInt:fep.diamondPrice], @"gold needed",
                        nil];
  
  [Analytics event:NOT_ENOUGH_GOLD_ARMORY withArgs:args];
}

+ (void) notEnoughGoldToRefillEnergyPopup {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.currentEnergy], @"current energy",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        nil];
  
  [Analytics event:NOT_ENOUGH_GOLD_TO_REFILL_ENERGY_POPUP withArgs:args];
}

+ (void) notEnoughGoldToRefillStaminaPopup {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.currentStamina], @"current stamina",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        nil];
  
  [Analytics event:NOT_ENOUGH_GOLD_TO_REFILL_STAMINA_POPUP withArgs:args];
}

+ (void) notEnoughSilverInCarpenter:(int)structId {
  GameState *gs = [GameState sharedGameState];
  FullStructureProto *fsp = [gs structWithId:structId];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        [NSNumber numberWithInt:gs.silver], @"current silver",
                        [NSNumber numberWithInt:fsp.coinPrice], @"silver needed",
                        nil];
  
  [Analytics event:NOT_ENOUGH_SILVER_ARMORY withArgs:args];
}

+ (void) notEnoughGoldInCarpenter:(int)structId {
  GameState *gs = [GameState sharedGameState];
  FullStructureProto *fsp = [gs structWithId:structId];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        [NSNumber numberWithInt:fsp.diamondPrice], @"gold needed",
                        nil];
  
  [Analytics event:NOT_ENOUGH_GOLD_ARMORY withArgs:args];
}

+ (void) notEnoughSilverForUpgrade:(int)structId cost:(int)cost {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        [NSNumber numberWithInt:gs.silver], @"current silver",
                        [NSNumber numberWithInt:cost], @"silver needed",
                        nil];
  
  [Analytics event:NOT_ENOUGH_SILVER_UPGRADE withArgs:args];
}

+ (void) notEnoughGoldForUpgrade:(int)structId cost:(int)cost {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        [NSNumber numberWithInt:cost], @"gold needed",
                        nil];
  
  [Analytics event:NOT_ENOUGH_GOLD_UPGRADE withArgs:args];
}

+ (void) notEnoughGoldForInstaBuild:(int)structId {
  GameState *gs = [GameState sharedGameState];
  FullStructureProto *fsp = [gs structWithId:structId];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        [NSNumber numberWithInt:fsp.instaBuildDiamondCost], @"gold needed",
                        nil];
  
  [Analytics event:NOT_ENOUGH_GOLD_INSTA_BUILD withArgs:args];
}

+ (void) notEnoughGoldForInstaUpgrade:(int)structId level:(int)level cost:(int)cost {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        [NSNumber numberWithInt:level], @"current level",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        [NSNumber numberWithInt:cost], @"gold needed",
                        nil];
  
  [Analytics event:NOT_ENOUGH_GOLD_INSTA_UPGRADE withArgs:args];
}

+ (void) notEnoughSilverForMarketplaceBuy:(int)equipId cost:(int)cost {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:gs.silver], @"current silver",
                        [NSNumber numberWithInt:cost], @"silver needed",
                        nil];
  
  [Analytics event:NOT_ENOUGH_SILVER_MARKETPLACE_BUY withArgs:args];
}

+ (void) notEnoughGoldForMarketplaceBuy:(int)equipId cost:(int)cost {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        [NSNumber numberWithInt:cost], @"gold needed",
                        nil];
  
  [Analytics event:NOT_ENOUGH_GOLD_MARKETPLACE_BUY withArgs:args];
}

+ (void) notEnoughSilverForMarketplaceRetract:(int)equipId cost:(int)cost {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:gs.silver], @"current silver",
                        [NSNumber numberWithInt:cost], @"silver needed",
                        nil];
  
  [Analytics event:NOT_ENOUGH_SILVER_MARKETPLACE_RETRACT withArgs:args];
}

+ (void) notEnoughGoldForMarketplaceRetract:(int)equipId cost:(int)cost {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        [NSNumber numberWithInt:cost], @"gold needed",
                        nil];
  
  [Analytics event:NOT_ENOUGH_GOLD_MARKETPLACE_RETRACT withArgs:args];
}

+ (void) notEnoughGoldForMarketplaceShortLicense {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        nil];
  
  [Analytics event:NOT_ENOUGH_GOLD_MARKETPLACE_SHORT_LICENSE withArgs:args];
}

+ (void) notEnoughGoldForMarketplaceLongLicense {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        nil];
  
  [Analytics event:NOT_ENOUGH_GOLD_MARKETPLACE_LONG_LICENSE withArgs:args];
}

+ (void) notEnoughGoldToRefillEnergyTopBar {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.currentEnergy], @"current energy",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        nil];
  
  [Analytics event:NOT_ENOUGH_GOLD_TO_REFILL_ENERGY_TOPBAR withArgs:args];
}

+ (void) notEnoughGoldToRefillStaminaTopBar {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.currentStamina], @"current stamina",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        nil];
  
  [Analytics event:NOT_ENOUGH_GOLD_TO_REFILL_STAMINA_TOPBAR withArgs:args];
}

+ (void) notEnoughStaminaForBattle {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.currentStamina], @"current stamina",
                        nil];
  
  [Analytics event:NOT_ENOUGH_STAMINA_BATTLE withArgs:args];
}

+ (void) notEnoughEnergyForTasks:(int)taskId {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:taskId], @"task id",
                        [NSNumber numberWithInt:gs.currentEnergy], @"current energy",
                        nil];
  
  [Analytics event:NOT_ENOUGH_ENERGY_TASKS withArgs:args];
}

+ (void) notEnoughEquipsForTasks:(int)taskId equipReqs:(NSArray *)reqs {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:taskId], @"task id",
                        reqs, @"equip reqs",
                        [NSNumber numberWithInt:gs.currentStamina], @"current stamina",
                        nil];
  
  [Analytics event:NOT_ENOUGH_EQUIPS_TASKS withArgs:args];
}

// Engagement events

+ (void) levelUp:(int)level {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.level], @"level",
                        nil];
  
  [Analytics event:LEVEL_UP withArgs:args];
}

+ (void) placedCritStruct:(NSString *)name {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.level], @"level",
                        name, @"crit struct",
                        nil];
  
  [Analytics event:PLACE_CRIT_STRUCT withArgs:args];
}

+ (void) attackAgain {
  [Analytics event:ATTACK_AGAIN];
}

+ (void) fleeWithHealth:(int)curHealth enemyHealth:(int)enemyHealth {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:curHealth], @"current health",
                        [NSNumber numberWithInt:enemyHealth], @"enemyHealth",
                        nil];
  
  [Analytics event:FLEE withArgs:args];
}

+ (void) questAccept:(int)questId {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:questId], @"quest id",
                        nil];
  
  [Analytics event:QUEST_ACCEPT withArgs:args];
}

+ (void) questComplete:(int)questId {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:questId], @"quest id",
                        nil];
  
  [Analytics event:QUEST_COMPLETE withArgs:args];
}

+ (void) questRedeem:(int)questId {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:questId], @"quest id",
                        nil];
  
  [Analytics event:QUEST_REDEEM withArgs:args];
}

+ (void) addedSkillPoint:(NSString *)stat {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        stat, @"stat",
                        nil];
  
  [Analytics event:SKILL_POINT withArgs:args];
}

+ (void) attemptedPurchase {
  [Analytics event:MKT_ATTEMPTED_PURCHASE];
}

+ (void) successfulPurchase:(int)equipId {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        nil];
  
  [Analytics event:MKT_SUCCESSFUL_PURCHASE withArgs:args];
}

+ (void) attemptedPost {
  [Analytics event:MKT_ATTEMPTED_POST];
}

+ (void) successfulPost:(int)equipId {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        nil];
  
  [Analytics event:MKT_SUCCESSFUL_POST withArgs:args];
}

+ (void) viewedRetract {
  [Analytics event:MKT_VIEW_RETRACT];
}

+ (void) attemptedRetract {
  [Analytics event:MKT_ATTEMPTED_RETRACT];
}

+ (void) successfulRetract {
  [Analytics event:MKT_SUCCESSFUL_RETRACT];
}

+ (void) licensePopup {
  [Analytics event:MKT_LICENSE_POPUP];
}

+ (void) boughtLicense:(NSString *)type {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        type, @"type",
                        nil];
  
  [Analytics event:MKT_BOUGHT_LICENSE withArgs:args];
}

+ (void) clickedListAnItem {
  [Analytics event:MKT_LIST_AN_ITEM];
}

+ (void) vaultOpen {
  [Analytics event:VAULT_OPEN];
}

+ (void) vaultDeposit {
  [Analytics event:VAULT_DEPOSIT];
}

+ (void) vaultWithdraw {
  [Analytics event:VAULT_WITHDRAW];
}

+ (void) normStructUpgrade:(int)structId level:(int)level {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        [NSNumber numberWithInt:level], @"level",
                        nil];
  
  [Analytics event:NORM_STRUCT_UPGRADE withArgs:args];
}

+ (void) normStructPurchase:(int)structId {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        nil];
  
  [Analytics event:NORM_STRUCT_PURCHASE withArgs:args];
}

+ (void) normStructSell:(int)structId level:(int)level {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        [NSNumber numberWithInt:level], @"level",
                        nil];
  
  [Analytics event:NORM_STRUCT_SELL withArgs:args];
}

+ (void) normStructInstaUpgrade:(int)structId level:(int)level {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        [NSNumber numberWithInt:level], @"level",
                        nil];
  
  [Analytics event:NORM_STRUCT_INSTA_UPGRADE withArgs:args];
}

+ (void) normStructInstaBuild:(int)structId {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        nil];
  
  [Analytics event:NORM_STRUCT_INSTA_BUILD withArgs:args];
}

+ (void) openedPathMenu {
  [Analytics event:OPENED_PATH_MENU];
}

+ (void) openedNotifications {
  [Analytics event:OPENED_NOTIFICATIONS];
}

+ (void) openedQuestLog {
  [Analytics event:OPENED_QUEST_LOG];
}

+ (void) openedMyProfile {
  [Analytics event:OPENED_PROFILE];
}

+ (void) clickedVisit {
  [Analytics event:CLICKED_VISIT];
}

+ (void) receivedNotification {
  [Analytics event:RECEIVED_NOTIFICATION];
}

+ (void) clickedRevenge {
  [Analytics event:CLICKED_REVENGE];
}

+ (void) clickedCollect {
  [Analytics event:CLICKED_COLLECT];
}

+ (void) clickedFillEnergy {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.currentEnergy], @"current energy",
                        [NSNumber numberWithInt:gs.level], @"level",
                        nil];
  
  [Analytics event:CLICKED_FILL_ENERGY withArgs:args];
}

+ (void) clickedFillStamina {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.currentStamina], @"current stamina",
                        [NSNumber numberWithInt:gs.level], @"level",
                        nil];
  
  [Analytics event:CLICKED_FILL_STAMINA withArgs:args];
}

+ (void) enemyProfileFromBattle {
  [Analytics event:ENEMY_PROFILE_BATTLE];
}

+ (void) enemyProfileFromSprite {
  [Analytics event:ENEMY_PROFILE_SPRITE];
}

+ (void) enemyProfileFromAttackMap {
  [Analytics event:ENEMY_PROFILE_ATTACK_MAP];
}

+ (void) postedToEnemyProfile {
  [Analytics event:POSTED_TO_ENEMY_PROFILE];
}

+ (void) postedToAllyProfile {
  [Analytics event:POSTED_TO_ALLY_PROFILE];
   }

// Missing features

+ (void) clickedMarketplaceSearch {
  [Analytics event:CLICKED_SEARCH];
}

+ (void) clickedFreeOffers {
  [Analytics event:CLICKED_FREE_OFFERS];
}

+ (void) clickedVisitCity {
  [Analytics event:CLICKED_VISIT_CITY];
}

// Tutorial

+ (void) tutorialStart {
  [Analytics event:TUTORIAL_START];
}

+ (void) tutorialOpenedDoor {
  [Analytics event:TUTORIAL_OPENED_DOOR];
}

+ (void) tutorialPanDone {
  [Analytics event:TUTORIAL_PAN_DONE];
}

+ (void) tutorialCharChosen {
  [Analytics event:TUTORIAL_CHAR_CHOSEN];
}

+ (void) tutorialQuestAccept {
  [Analytics event:TUTORIAL_QUEST_ACCEPTED];
}

+ (void) tutorialBattleStart {
  [Analytics event:TUTORIAL_BATTLE_START];
}

+ (void) tutorialBattleComplete {
  [Analytics event:TUTORIAL_BATTLE_COMPLETE];
}

+ (void) tutorialTaskComplete {
  [Analytics event:TUTORIAL_TASK_COMPLETE];
}

+ (void) tutorialQuestRedeem {
  [Analytics event:TUTORIAL_QUEST_REDEEM];
}

+ (void) tutorialSkillPointsAdded {
  [Analytics event:TUTORIAL_SKILL_POINTS_ADDED];
}

+ (void) tutorialAmuletEquipped {
  [Analytics event:TUTORIAL_AMULET_EQUIPPED];
}

+ (void) tutorialGoHome {
  [Analytics event:TUTORIAL_GO_HOME];
}

+ (void) tutorialEnterCarpenter {
  [Analytics event:TUTORIAL_ENTER_CARPENTER];
}

+ (void) tutorialPurchaseInn {
  [Analytics event:TUTORIAL_PURCHASE_INN];
}

+ (void) tutorialPlaceInn {
  [Analytics event:TUTORIAL_PLACE_INN];
}

+ (void) tutorialFinishNow {
  [Analytics event:TUTORIAL_FINISH_NOW];
}

+ (void) tutorialWaitBuild {
  [Analytics event:TUTORIAL_WAIT_BUILD];
}

+ (void) tutorialPathMenu {
  [Analytics event:TUTORIAL_PATH_MENU];
}

+ (void) tutorialProfileButton {
  [Analytics event:TUTORIAL_PROFILE_BUTTON];
}

+ (void) tutorialUserCreated {
  [Analytics event:TUTORIAL_USER_CREATED];
}

+ (void) tutorialTimeSync {
  [Analytics event:TUTORIAL_TIME_SYNC];
}

+ (void) tutorialOtherFail {
  [Analytics event:TUTORIAL_OTHER_FAIL];
}

+ (void) tutorialComplete {
  [Analytics event:TUTORIAL_COMPLETE];
}

@end
