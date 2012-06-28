//
//  Analytics.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Analytics : NSObject

// App
+ (void) openedApp;
+ (void) beganApp;
+ (void) resumedApp;
+ (void) suspendedApp;
+ (void) terminatedApp;

// Monetization
+ (void) purchasedGoldPackage:(NSString *)package price:(float)price goldAmount:(int)gold;
+ (void) cancelledGoldPackage:(NSString *)package;
+ (void) viewedGoldShopFromTopMenu;

+ (void) clickedGetMoreGold:(int)goldAmt;
+ (void) clickedGetMoreSilver;

+ (void) notEnoughSilverInArmory:(int)equipId;
+ (void) notEnoughGoldInArmory:(int)equipId;

+ (void) notEnoughSilverForUpgrade:(int)structId cost:(int)cost;
+ (void) notEnoughGoldForUpgrade:(int)structId cost:(int)cost;

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

// Engagement events
+ (void) levelUp:(int)level;
+ (void) placedCritStruct:(NSString *)name;

+ (void) attackAgain;
+ (void) fleeWithHealth:(int)curHealth enemyHealth:(int)enemyHealth;

+ (void) questAccept:(int)questId;
+ (void) questComplete:(int)questId;
+ (void) questRedeem:(int)questId;

+ (void) addedSkillPoint:(NSString *)stat;

+ (void) attemptedPurchase;
+ (void) successfulPurchase:(int)equipId;
+ (void) attemptedPost;
+ (void) successfulPost:(int)equipId;
+ (void) viewedRetract;
+ (void) attemptedRetract;
+ (void) successfulRetract;
+ (void) licensePopup;
+ (void) boughtLicense:(NSString *)type;
+ (void) clickedListAnItem;

+ (void) vaultOpen;
+ (void) vaultDeposit;
+ (void) vaultWithdraw;

+ (void) normStructUpgrade:(int)structId level:(int)level;
+ (void) normStructPurchase:(int)structId;
+ (void) normStructSell:(int)structId level:(int)level;
+ (void) normStructInstaUpgrade:(int)structId level:(int)level;
+ (void) normStructInstaBuild:(int)structId;

+ (void) openedPathMenu;
+ (void) openedNotifications;
+ (void) openedQuestLog;
+ (void) openedMyProfile;
+ (void) clickedVisit;
+ (void) receivedNotification;
+ (void) clickedRevenge;
+ (void) clickedCollect;

+ (void) clickedFillEnergy;
+ (void) clickedFillStamina;
+ (void) enemyProfileFromBattle;
+ (void) enemyProfileFromSprite;
+ (void) enemyProfileFromAttackMap;
+ (void) postedToEnemyProfile;
+ (void) postedToAllyProfile;

// Missing Features
+ (void) clickedMarketplaceSearch;
+ (void) clickedFreeOffers;
+ (void) clickedVisitCity;

// Tutorial
+ (void) tutorialStart;
+ (void) tutorialOpenedDoor;
+ (void) tutorialPanDone;
+ (void) tutorialCharChosen;
+ (void) tutorialQuestAccept;
+ (void) tutorialBattleStart;
+ (void) tutorialBattleComplete;
+ (void) tutorialTaskComplete;
+ (void) tutorialQuestRedeem;
+ (void) tutorialSkillPointsAdded;
+ (void) tutorialAmuletEquipped;
+ (void) tutorialGoHome;
+ (void) tutorialEnterCarpenter;
+ (void) tutorialPurchaseInn;
+ (void) tutorialPlaceInn;
+ (void) tutorialFinishNow;
+ (void) tutorialWaitBuild;
+ (void) tutorialPathMenu;
+ (void) tutorialProfileButton;
+ (void) tutorialUserCreated;
+ (void) tutorialTimeSync;
+ (void) tutorialOtherFail;
+ (void) tutorialComplete;

@end
