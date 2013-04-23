//
//  Analytics.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Analytics.h"
//#import "Apsalar.h"
#import "Globals.h"
#import "GameState.h"
#import <StoreKit/StoreKit.h>
#import "Crittercism.h"
#import "Amplitude.h"

#define OPENED_APP @"App: Opened"
#define BEGAN_APP @"App: Began"
#define RESUMED_APP @"App: Resumed"
#define SUSPENDED_APP @"App: Suspended"
#define TERMINATED_APP @"App: Terminated"

#define PURCHASED_GOLD @"Purchased %@"
#define CANCELLED_IAP @"Cancelled gold purchase"
#define IAP_FAILED @"Gold Shoppe: In app purchase failed"
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
#define TASK_OPENED @"Task: Opened"
#define TASK_EXECUTED @"Task: Executed"
#define TASK_CLOSED @"Task: Closed"
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

#define TCM_IMPRESSION @"TCM Impression: %d"
#define TCM_CONVERSION @"TCM Conversion: %d"

#define CHARMOD_ATTEMPTED_NAME @"CharMod: Attempted Name"
#define CHARMOD_CHANGED_NAME @"CharMod: Changed Name"
#define CHARMOD_ATTEMPTED_STATS @"CharMod: Attempted Stats"
#define CHARMOD_CHANGED_STATS @"CharMod: Reset Stats"
#define CHARMOD_ATTEMPTED_TYPE @"CharMod: Attempted Type"
#define CHARMOD_CHANGED_TYPE @"CharMod: Changed Type"
#define CHARMOD_ATTEMPTED_GAME @"CharMod: Attempted Reset"
#define CHARMOD_RESET_GAME @"CharMod: Reset Game"

#define GOLD_SHOPPE_FREE_OFFERS @"Gold Shoppe: Clicked earn free offers"
#define GOLD_SHOPPE_AD_COLONY @"Gold Shoppe: Watched Ad Colony"
#define GOLD_SHOPPE_AD_COLONY_FAILED @"Gold Shoppe: Ad Colony Failed"
#define KIIP_FAILED @"Kiip: Received Fail Message"
#define KIIP_UNLOCKED_ACHIEVEMENT @"Kiip: Unlocked achievement"
#define KIIP_ENTERED_EMAIL @"Kiip: Entered email"

#define CLICKED_SEARCH @"Mkt: Clicked search"
#define CLICKED_VISIT_CITY @"Profile: Clicked visit city"

#define BLACKSMITH_GUARANTEED_FORGE @"Blksmth: Forge w/ grntee"
#define BLACKSMITH_FAILED_GUARANTEED_FORGE @"Blksmth: Failed to grntee"
#define BLACKSMITH_NOT_GUARANTEED_FORGE @"Blksmth: Forge w/o grntee"
#define BLACKSMITH_SPEED_UP @"Blksmth: Speed Up"
#define BLACKSMITH_FAILED_SPEED_UP @"Blksmth: Failed Speed Up"
#define BLACKSMITH_COLLECTED_ITEMS @"Blksmth: Collected Items"
#define BLACKSMITH_GO_TO_MARKETPLACE @"Blksmth: Went to mktplace"
#define BLACKSMITH_BUY_ONE @"Blksmth: Buy one clicked"

#define TUTORIAL_START @"Tut: Start"
#define TUTORIAL_CHAR_CHOSEN @"Tut: Character chosen"
#define TUTORIAL_NAME_ENTERED @"Tut: Name entered"
#define TUTORIAL_COMPLETE_TASK_1 @"Tut: Complete task 1"
#define TUTORIAL_TASK_COIN @"Tut: Task coin collect"
#define TUTORIAL_QUEST_BUTTON_1 @"Tut: Quests clicked 1"
#define TUTORIAL_AVAIL_QUEST @"Tut: Avail quest clicked"
#define TUTORIAL_CLICKED_VISIT @"Tut: Clicked visit"
#define TUTORIAL_COMPLETE_QUEST_TASK @"Tut: Complete quest task"
#define TUTORIAL_QUEST_COIN @"Tut: Quest coin collect"
#define TUTORIAL_QUEST_REDEEM @"Tut: Quest redeemed"
#define TUTORIAL_LEVEL_UP @"Tut: Level up"
#define TUTORIAL_SKILL_POINTS @"Tut: Skill points"
#define TUTORIAL_PROFILE_CLICKED @"Tut: Clicked profile tab"
#define TUTORIAL_NO_AMULET_CLICKED @"Tut: No amulet clicked"
#define TUTORIAL_AMULET_EQUIPPED @"Tut: Amulet equipped"
#define TUTORIAL_CLOSE_BROWSE_VIEW @"Tut: Close browse view"
#define TUTORIAL_CLOSE_PROFILE_1 @"Tut: Close profile 1"
#define TUTORIAL_ATTACK_CLICKED @"Tut: Attack clicked"
#define TUTORIAL_BATTLE_START @"Tut: Battle started"
#define TUTORIAL_CLICKED_BEGIN @"Tut: Clicked begin"
#define TUTORIAL_CLICKED_OKAY_1 @"Tut: Clicked okay 1"
#define TUTORIAL_CLICKED_OKAY_2 @"Tut: Clicked okay 2"
#define TUTORIAL_CLICKED_DONE @"Tut: Clicked done"
#define TUTORIAL_CLOSED_BATTLE_SUMMARY @"Tut: Closed battle summary"
#define TUTORIAL_MY_CITY_CLICKED @"Tut: My city clicked"
#define TUTORIAL_CARPENTER_CLICKED @"Tut: Carpenter clicked"
#define TUTORIAL_PURCHASE_INN @"Tut: Clicked Inn"
#define TUTORIAL_PLACED_INN @"Tut: Placed Inn"
#define TUTORIAL_FINISH_NOW @"Tut: Insta build"
#define TUTORIAL_PATH_MENU @"Tut: Opened path menu"
#define TUTORIAL_PROFILE_BUTTON @"Tut: Clicked profile button"
#define TUTORIAL_CLOSE_PROFILE_2 @"Tut: Close profile 2"
#define TUTORIAL_USER_CREATED @"Tut: User Created"
#define TUTORIAL_QUEST_BUTTON_2 @"Tut: Quests clicked 2"
#define TUTORIAL_COMPLETE @"Tut: Complete"


@implementation Analytics

+ (void) event:(NSString *)event {
  GameState *gs = [GameState sharedGameState];
  if (gs.isTutorial && [event rangeOfString:@"Tut"].length > 0) {
    return;
  }
  
#ifndef DEBUG
  [Crittercism leaveBreadcrumb:event];
  [Amplitude logEvent:event];
#endif
}

+ (void) event:(NSString *)event withArgs:(NSDictionary *)args {
  GameState *gs = [GameState sharedGameState];
  if (gs.isTutorial && [event rangeOfString:@"Tut"].length > 0) {
    return;
  }
  
#ifndef DEBUG
  [Crittercism leaveBreadcrumb:event];
  [Amplitude logEvent:event withCustomProperties:args];
#endif
}

+ (void) logRevenue:(NSNumber *)num {
#ifndef DEBUG
  [Amplitude logRevenue:num];
#endif
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
  
  [Analytics event:[NSString stringWithFormat:PURCHASED_GOLD, package] withArgs:args];
  [Analytics logRevenue:[NSNumber numberWithFloat:price]];
}

+ (void) cancelledGoldPackage:(NSString *)package {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        package, @"package",
                        nil];
  
  [Analytics event:CANCELLED_IAP withArgs:args];
}

+ (void) inAppPurchaseFailed {
  [Analytics event:IAP_FAILED];
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

+ (void) taskViewed:(int)taskId {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:taskId], @"task id",
                        nil];
  
  [Analytics event:TASK_OPENED withArgs:args];
}

+ (void) taskExecuted:(int)taskId {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:taskId], @"task id",
                        nil];
  
  [Analytics event:TASK_EXECUTED withArgs:args];
}

+ (void) taskClosed:(int)taskId {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:taskId], @"task id",
                        nil];
  
  [Analytics event:TASK_CLOSED withArgs:args];
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
  GameState *gs = [GameState sharedGameState];
  if (!gs.isTutorial) {
    [Analytics event:CLICKED_VISIT];
  } else {
    [Analytics event:TUTORIAL_CLICKED_VISIT];
  }
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

+ (void) clickedFreeOffers {
  [Analytics event:GOLD_SHOPPE_FREE_OFFERS];
}

+ (void) watchedAdColony {
  [Analytics event:GOLD_SHOPPE_AD_COLONY];
}

+ (void) adColonyFailed {
  [Analytics event:GOLD_SHOPPE_AD_COLONY_FAILED];
}

+ (void) kiipFailed {
  [Analytics event:KIIP_FAILED];
}

+ (void) kiipUnlockedAchievement {
  [Analytics event:KIIP_UNLOCKED_ACHIEVEMENT];
}

+ (void) kiipEnteredEmail {
  [Analytics event:KIIP_ENTERED_EMAIL];
}

+ (void) attemptedNameChange {
  [Analytics event:CHARMOD_ATTEMPTED_NAME];
}

+ (void) nameChange {
  [Analytics event:CHARMOD_CHANGED_NAME];
}

+ (void) attemptedStatReset {
  [Analytics event:CHARMOD_ATTEMPTED_STATS];
}

+ (void) statReset {
  [Analytics event:CHARMOD_CHANGED_STATS];
}

+ (void) attemptedTypeChange {
  [Analytics event:CHARMOD_ATTEMPTED_TYPE];
}

+ (void) typeChange {
  [Analytics event:CHARMOD_CHANGED_TYPE];
}

+ (void) attemptedResetGame {
  [Analytics event:CHARMOD_ATTEMPTED_GAME];
}

+ (void) resetGame {
  [Analytics event:CHARMOD_RESET_GAME];
}

+ (void) threeCardMonteImpression:(int)badCardId {
  [Analytics event:[NSString stringWithFormat:TCM_IMPRESSION, badCardId]];
}

+ (void) threeCardMonteConversion:(int)badCardId numPlays:(int)numPlays pattern:(NSString *)pattern {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:numPlays], @"num plays",
                        pattern, @"pattern",
                        nil];
  [Analytics event:[NSString stringWithFormat:TCM_CONVERSION, badCardId] withArgs:args];
}

+ (void) blacksmithGuaranteedForgeWithEquipId:(int)equipId level:(int)level {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:level], @"level",
                        nil];
  
  [Analytics event:BLACKSMITH_GUARANTEED_FORGE withArgs:args];
}

+ (void) blacksmithFailedToGuaranteeForgeWithEquipId:(int)equipId level:(int)level cost:(int)gold {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:level], @"level",
                        [NSNumber numberWithInt:gs.gold], @"cur gold",
                        [NSNumber numberWithInt:gold], @"gold cost",
                        nil];
  
  [Analytics event:BLACKSMITH_FAILED_GUARANTEED_FORGE withArgs:args];
}

+ (void) blacksmithNotGuaranteedForgeWithEquipId:(int)equipId level:(int)level {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:level], @"level",
                        nil];
  
  [Analytics event:BLACKSMITH_NOT_GUARANTEED_FORGE withArgs:args];
}

+ (void) blacksmithSpeedUpWithEquipId:(int)equipId level:(int)level {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:level], @"level",
                        nil];
  
  [Analytics event:BLACKSMITH_SPEED_UP withArgs:args];
}

+ (void) blacksmithFailedToSpeedUpWithEquipId:(int)equipId level:(int)level cost:(int)gold {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:level], @"level",
                        [NSNumber numberWithInt:gs.gold], @"cur gold",
                        [NSNumber numberWithInt:gold], @"gold cost",
                        nil];
  
  [Analytics event:BLACKSMITH_SPEED_UP withArgs:args];
}

+ (void) blacksmithCollectedItemsWithEquipId:(int)equipId level:(int)level {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:level], @"level",
                        nil];
  
  [Analytics event:BLACKSMITH_COLLECTED_ITEMS withArgs:args];
}

+ (void) blacksmithGoToMarketplaceWithEquipId:(int)equipId level:(int)level {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:level], @"level",
                        nil];
  
  [Analytics event:BLACKSMITH_GO_TO_MARKETPLACE withArgs:args];
}

+ (void) blacksmithBuyOneWithEquipId:(int)equipId level:(int)level {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:level], @"level",
                        nil];
  
  [Analytics event:BLACKSMITH_BUY_ONE withArgs:args];
}

// Missing features

+ (void) clickedMarketplaceSearch {
  [Analytics event:CLICKED_SEARCH];
}

+ (void) clickedVisitCity {
  [Analytics event:CLICKED_VISIT_CITY];
}

// Tutorial

+ (void) tutStart {
  [Analytics event:TUTORIAL_START];
}

+ (void) tutCharChosen {
  [Analytics event:TUTORIAL_CHAR_CHOSEN];
}

+ (void) tutNameEntered {
  [Analytics event:TUTORIAL_NAME_ENTERED];
}

+ (void) tutCompleteTask1 {
  [Analytics event:TUTORIAL_COMPLETE_TASK_1];
}

+ (void) tutTaskCoin {
  [Analytics event:TUTORIAL_TASK_COIN];
}

+ (void) tutQuestButton1 {
  [Analytics event:TUTORIAL_QUEST_BUTTON_1];
}

+ (void) tutAvailQuest {
  [Analytics event:TUTORIAL_AVAIL_QUEST];
}

+ (void) tutClickedVisit {
  [Analytics event:TUTORIAL_CLICKED_VISIT];
}

+ (void) tutCompleteQuestTask {
  [Analytics event:TUTORIAL_COMPLETE_QUEST_TASK];
}

+ (void) tutQuestCoin {
  [Analytics event:TUTORIAL_QUEST_COIN];
}

+ (void) tutQuestRedeem {
  [Analytics event:TUTORIAL_QUEST_REDEEM];
}

+ (void) tutLevelUp {
  [Analytics event:TUTORIAL_LEVEL_UP];
}

+ (void) tutSkillPoints {
  [Analytics event:TUTORIAL_SKILL_POINTS];
}

+ (void) tutProfileClicked {
  [Analytics event:TUTORIAL_PROFILE_CLICKED];
}

+ (void) tutNoAmuletClicked {
  [Analytics event:TUTORIAL_NO_AMULET_CLICKED];
}

+ (void) tutAmuletEquipped {
  [Analytics event:TUTORIAL_AMULET_EQUIPPED];
}

+ (void) tutCloseBrowseView {
  [Analytics event:TUTORIAL_CLOSE_BROWSE_VIEW];
}

+ (void) tutCloseProfile1 {
  [Analytics event:TUTORIAL_CLOSE_PROFILE_1];
}

+ (void) tutAttackClicked {
  [Analytics event:TUTORIAL_ATTACK_CLICKED];
}

+ (void) tutBattleStart {
  [Analytics event:TUTORIAL_BATTLE_START];
}

+ (void) tutClickedBegin {
  [Analytics event:TUTORIAL_CLICKED_BEGIN];
}

+ (void) tutClickedOkay1 {
  [Analytics event:TUTORIAL_CLICKED_OKAY_1];
}

+ (void) tutClickedOkay2 {
  [Analytics event:TUTORIAL_CLICKED_OKAY_2];
}

+ (void) tutClickedDone {
  [Analytics event:TUTORIAL_CLICKED_DONE];
}

+ (void) tutClosedBattleSummary {
  [Analytics event:TUTORIAL_CLOSED_BATTLE_SUMMARY];
}

+ (void) tutMyCityClicked {
  [Analytics event:TUTORIAL_MY_CITY_CLICKED];
}

+ (void) tutCarpenterClicked {
  [Analytics event:TUTORIAL_CARPENTER_CLICKED];
}

+ (void) tutPurchaseInn {
  [Analytics event:TUTORIAL_PURCHASE_INN];
}

+ (void) tutPlacedInn {
  [Analytics event:TUTORIAL_PLACED_INN];
}

+ (void) tutFinishNow {
  [Analytics event:TUTORIAL_FINISH_NOW];
}

+ (void) tutPathMenu {
  [Analytics event:TUTORIAL_PATH_MENU];
}

+ (void) tutProfileButton {
  [Analytics event:TUTORIAL_PROFILE_BUTTON];
}

+ (void) tutCloseProfile2 {
  [Analytics event:TUTORIAL_CLOSE_PROFILE_2];
}

+ (void) tutUserCreated {
  [Analytics event:TUTORIAL_USER_CREATED];
}

+ (void) tutQuestButton2 {
  [Analytics event:TUTORIAL_QUEST_BUTTON_2];
}

+ (void) tutComplete {
  [Analytics event:TUTORIAL_COMPLETE];
}

@end
