//
//  Analytics.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Analytics : NSObject

// Monetization
+ (void) purchasedGoldPackage:(NSString *)package price:(float)price goldAmount:(int)gold;
+ (void) cancelledGoldPackage:(NSString *)package;
+ (void) viewedGoldShopFromTopMenu;

+ (void) clickedGetMoreGold:(int)goldAmt;
+ (void) clickedGetMoreSilver;

+ (void) notEnoughSilverInArmory:(int)equipId;
+ (void) notEnoughGoldInArmory:(int)equipId;

+ (void) notEnoughGoldToRefillEnergyPopup;
+ (void) notEnoughGoldToRefillStaminaPopup;

+ (void) notEnoughSilverInCarpenter:(int)structId;
+ (void) notEnoughGoldInCarpenter:(int)structId;

+ (void) notEnoughGoldForInstaBuild:(int)structId;
+ (void) notEnoughGoldForInstaUpgrade:(int)structId level:(int)level cost:(int)cost;

+ (void) notEnoughSilverForMarketplaceBuy:(int)equipId cost:(int)cost;
+ (void) notEnoughGoldForMarketplaceBuy:(int)equipId cost:(int)cost;
+ (void) notEnoughSilverForMarketplaceRetract:(int)equipId cost:(int)cost;
+ (void) notEnoughGoldForMarketplaceRetract:(int)equipId cost:(int)cost;
+ (void) notEnoughGoldForMarketplaceShortLicense;
+ (void) notEnoughGoldForMarketplaceLongLicense;

+ (void) notEnoughGoldToRefillEnergyTopBar;
+ (void) notEnoughGoldToRefillStaminaTopBar;

+ (void) notEnoughStaminaForBattle;
+ (void) notEnoughEnergyForTasks:(int)taskId;
+ (void) notEnoughEquipsForTasks:(int)taskId equipReqs:(NSArray *)reqs;

// Missing Features
+ (void) clickedMarketplaceSearch;
+ (void) clickedProfileWall;
+ (void) clickedFreeOffers;

@end
