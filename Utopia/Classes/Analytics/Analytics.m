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

#define PURCHASED_GOLD @"Purchased gold package"
#define CANCELLED_IAP @"Cancelled gold purchase"
#define TOP_BAR_SHOP @"Viewed gold shop from top bar"

#define GET_MORE_GOLD @"Clicked \"Get more gold\""
#define GET_MORE_SILVER @"Clicked \"Go to Aviary\""
#define NOT_ENOUGH_SILVER_ARMORY @"Armory: Not enough silver"
#define NOT_ENOUGH_GOLD_ARMORY @"Armory: Not enough gold"
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

#define CLICKED_SEARCH @"Mkt: Clicked search"
#define CLICKED_WALL @"Profile: Clicked wall"
#define CLICKED_FREE_OFFERS @"Gold Shop: Clicked free offers"

@implementation Analytics

+ (void) purchasedGoldPackage:(NSString *)package price:(float)price goldAmount:(int)gold {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        package, @"package",
                        [NSNumber numberWithFloat:price], @"price",
                        [NSNumber numberWithInt:gold], @"gold",
                        nil];
  
  [Apsalar event:PURCHASED_GOLD withArgs:args];
}

+ (void) cancelledGoldPackage:(NSString *)package {
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        package, @"package",
                        nil];
  
  [Apsalar event:CANCELLED_IAP withArgs:args];
}

+ (void) viewedGoldShopFromTopMenu {
  [Apsalar event:TOP_BAR_SHOP];
}

+ (void) clickedGetMoreGold:(int)goldAmt {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:goldAmt], @"gold needed",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        nil];
  
  [Apsalar event:GET_MORE_GOLD withArgs:args];
}

+ (void) clickedGetMoreSilver {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.silver], @"current silver",
                        nil];
  
  [Apsalar event:GET_MORE_SILVER withArgs:args];
}

+ (void) notEnoughSilverInArmory:(int)equipId {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:gs.silver], @"current silver",
                        [NSNumber numberWithInt:fep.coinPrice], @"silver needed",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_SILVER_ARMORY withArgs:args];
}

+ (void) notEnoughGoldInArmory:(int)equipId {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        [NSNumber numberWithInt:fep.diamondPrice], @"gold needed",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_GOLD_ARMORY withArgs:args];
}

+ (void) notEnoughGoldToRefillEnergyPopup {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.currentEnergy], @"current energy",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_GOLD_TO_REFILL_ENERGY_POPUP withArgs:args];
}

+ (void) notEnoughGoldToRefillStaminaPopup {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.currentStamina], @"current stamina",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_GOLD_TO_REFILL_STAMINA_POPUP withArgs:args];
}

+ (void) notEnoughSilverInCarpenter:(int)structId {
  GameState *gs = [GameState sharedGameState];
  FullStructureProto *fsp = [gs structWithId:structId];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        [NSNumber numberWithInt:gs.silver], @"current silver",
                        [NSNumber numberWithInt:fsp.coinPrice], @"silver needed",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_SILVER_ARMORY withArgs:args];
}

+ (void) notEnoughGoldInCarpenter:(int)structId {
  GameState *gs = [GameState sharedGameState];
  FullStructureProto *fsp = [gs structWithId:structId];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        [NSNumber numberWithInt:fsp.diamondPrice], @"gold needed",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_GOLD_ARMORY withArgs:args];
}

+ (void) notEnoughGoldForInstaBuild:(int)structId {
  GameState *gs = [GameState sharedGameState];
  FullStructureProto *fsp = [gs structWithId:structId];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        [NSNumber numberWithInt:fsp.instaBuildDiamondCostBase], @"gold needed",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_GOLD_INSTA_BUILD withArgs:args];
}

+ (void) notEnoughGoldForInstaUpgrade:(int)structId level:(int)level cost:(int)cost {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:structId], @"struct id",
                        [NSNumber numberWithInt:level], @"current level",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        [NSNumber numberWithInt:cost], @"gold needed",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_GOLD_INSTA_UPGRADE withArgs:args];
}

+ (void) notEnoughSilverForMarketplaceBuy:(int)equipId cost:(int)cost {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:gs.silver], @"current silver",
                        [NSNumber numberWithInt:cost], @"silver needed",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_SILVER_MARKETPLACE_BUY withArgs:args];
}

+ (void) notEnoughGoldForMarketplaceBuy:(int)equipId cost:(int)cost {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        [NSNumber numberWithInt:cost], @"gold needed",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_GOLD_MARKETPLACE_BUY withArgs:args];
}

+ (void) notEnoughSilverForMarketplaceRetract:(int)equipId cost:(int)cost {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:gs.silver], @"current silver",
                        [NSNumber numberWithInt:cost], @"silver needed",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_SILVER_MARKETPLACE_RETRACT withArgs:args];
}

+ (void) notEnoughGoldForMarketplaceRetract:(int)equipId cost:(int)cost {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:equipId], @"equip id",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        [NSNumber numberWithInt:cost], @"gold needed",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_GOLD_MARKETPLACE_RETRACT withArgs:args];
}

+ (void) notEnoughGoldForMarketplaceShortLicense {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_GOLD_MARKETPLACE_SHORT_LICENSE withArgs:args];
}

+ (void) notEnoughGoldForMarketplaceLongLicense {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_GOLD_MARKETPLACE_LONG_LICENSE withArgs:args];
}

+ (void) notEnoughGoldToRefillEnergyTopBar {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.currentEnergy], @"current energy",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_GOLD_TO_REFILL_ENERGY_TOPBAR withArgs:args];
}

+ (void) notEnoughGoldToRefillStaminaTopBar {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.currentStamina], @"current stamina",
                        [NSNumber numberWithInt:gs.gold], @"current gold",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_GOLD_TO_REFILL_STAMINA_TOPBAR withArgs:args];
}

+ (void) notEnoughStaminaForBattle {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:gs.currentStamina], @"current stamina",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_STAMINA_BATTLE withArgs:args];
}

+ (void) notEnoughEnergyForTasks:(int)taskId {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:taskId], @"task id",
                        [NSNumber numberWithInt:gs.currentEnergy], @"current energy",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_ENERGY_TASKS withArgs:args];
}

+ (void) notEnoughEquipsForTasks:(int)taskId equipReqs:(NSArray *)reqs {
  GameState *gs = [GameState sharedGameState];
  NSDictionary *args = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:taskId], @"task id",
                        reqs, @"equip reqs",
                        [NSNumber numberWithInt:gs.currentStamina], @"current stamina",
                        nil];
  
  [Apsalar event:NOT_ENOUGH_EQUIPS_TASKS withArgs:args];
}

// Missing features

+ (void) clickedMarketplaceSearch {
  [Apsalar event:CLICKED_SEARCH];
}

+ (void) clickedProfileWall {
  [Apsalar event:CLICKED_WALL];
}

+ (void) clickedFreeOffers {
  [Apsalar event:CLICKED_FREE_OFFERS];
}

@end
