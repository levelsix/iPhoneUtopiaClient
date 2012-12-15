//
//  Globals.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "Protocols.pb.h"
#import "UserData.h"
#import "Analytics.h"
#import "GameMap.h"
#import "BattleConstants.h"
#import "LoggingContexts.h"

#define BUTTON_CLICKED_LEEWAY 30

#define LNLog(...) CCLOG(__VA_ARGS__)

#define FULL_SCREEN_APPEAR_ANIMATION_DURATION 0.4f
#define FULL_SCREEN_DISAPPEAR_ANIMATION_DURATION 0.7f

#define IAP_DEFAULTS_KEY @"Unresponded In Apps"

#define IAP_SUCCESS_NOTIFICATION @"IapSuccessNotification"

@interface Globals : NSObject <BattleConstants, EnemyBattleStats> {
  int _equipIdToWear;
}

@property (nonatomic, assign) float depositPercentCut;

@property (nonatomic, assign) float clericLevelFactor;
@property (nonatomic, assign) float clericHealthFactor;

@property (nonatomic, assign) int attackBaseGain;
@property (nonatomic, assign) int defenseBaseGain;
@property (nonatomic, assign) int energyBaseGain;
@property (nonatomic, assign) int staminaBaseGain;
@property (nonatomic, assign) int attackBaseCost;
@property (nonatomic, assign) int defenseBaseCost;
@property (nonatomic, assign) int energyBaseCost;
@property (nonatomic, assign) int staminaBaseCost;

@property (nonatomic, assign) float retractPercentCut;
@property (nonatomic, assign) float purchasePercentCut;

@property (nonatomic, assign) float energyRefillWaitMinutes;
@property (nonatomic, assign) float staminaRefillWaitMinutes;
@property (nonatomic, assign) int energyRefillCost;
@property (nonatomic, assign) int staminaRefillCost;

@property (nonatomic, assign) int armoryXLength;
@property (nonatomic, assign) int armoryYLength;
@property (nonatomic, assign) int aviaryXLength;
@property (nonatomic, assign) int aviaryYLength;
@property (nonatomic, assign) int carpenterXLength;
@property (nonatomic, assign) int carpenterYLength;
@property (nonatomic, assign) int marketplaceXLength;
@property (nonatomic, assign) int marketplaceYLength;
@property (nonatomic, assign) int vaultXLength;
@property (nonatomic, assign) int vaultYLength;

@property (nonatomic, assign) int minNameLength;
@property (nonatomic, assign) int maxNameLength;

@property (nonatomic, assign) int maxLevelDiffForBattle;
@property (nonatomic, assign) int skillPointsGainedOnLevelup;
@property (nonatomic, assign) float cutOfVaultDepositTaken;

@property (nonatomic, assign) int maxLevelForStruct;
@property (nonatomic, assign) int maxCityRank;
@property (nonatomic, assign) int maxRepeatedNormStructs;
@property (nonatomic, assign) float percentReturnedToUserForSellingNormStructure;

@property (nonatomic, assign) int maxNumberOfMarketplacePosts;
@property (nonatomic, assign) int sizeOfAttackList;
@property (nonatomic, assign) int numDaysLongMarketplaceLicenseLastsFor;
@property (nonatomic, assign) int numDaysShortMarketplaceLicenseLastsFor;
@property (nonatomic, assign) int diamondCostOfLongMarketplaceLicense;
@property (nonatomic, assign) int diamondCostOfShortMarketplaceLicense;
@property (nonatomic, assign) int numDaysUntilFreeRetract;

@property (nonatomic, assign) int maxNumbersOfEnemiesToGenerateAtOnce;
@property (nonatomic, assign) float percentReturnedToUserForSellingEquipInArmory;

@property (nonatomic, assign) int diamondRewardForReferrer;

@property (nonatomic, assign) float minutesToUpgradeForNormStructMultiplier;
@property (nonatomic, assign) float incomeFromNormStructMultiplier;
@property (nonatomic, assign) float upgradeStructCoinCostExponentBase;
@property (nonatomic, assign) float upgradeStructDiamondCostExponentBase;
@property (nonatomic, assign) float diamondCostForInstantUpgradeMultiplier;

@property (nonatomic, assign) int adColonyVideosRequiredToRedeemGold;

@property (nonatomic, assign) float maxLevelForUser;

@property (nonatomic, assign) int maxNumTimesAttackedByOneInProtectionPeriod;
@property (nonatomic, assign) int hoursInAttackedByOneProtectionPeriod;

@property (nonatomic, assign) int minBattlesRequiredForKDRConsideration;

@property (nonatomic, assign) int numChatsGivenPerGroupChatPurchasePackage;
@property (nonatomic, assign) int diamondPriceForGroupChatPurchasePackage;
@property (nonatomic, assign) int maxLengthOfChatString;

@property (nonatomic, assign) int maxCharLengthForWallPost;

@property (nonatomic, assign) int numHoursBeforeReshowingGoldSale;
@property (nonatomic, assign) int numHoursBeforeReshowingLockBox;
@property (nonatomic, assign) int numHoursBeforeReshowingBossEvent;

@property (nonatomic, assign) int bossNumAttacksTillSuperAttack;

@property (nonatomic, assign) int minClanMembersToHoldClanTower;

@property (nonatomic, copy) NSString *reviewPageURL;
@property (nonatomic, assign) int levelToShowRateUsPopup;
@property (nonatomic, copy) NSString *reviewPageConfirmationMessage;

@property (nonatomic, assign) int initStamina;

// Forge Constants
@property (nonatomic, assign) float forgeTimeBaseForExponentialMultiplier;
@property (nonatomic, assign) float forgeMinDiamondCostForGuarantee;
@property (nonatomic, assign) float forgeDiamondCostForGuaranteeExponentialMultiplier;
@property (nonatomic, assign) float forgeBaseMinutesToOneGold;
@property (nonatomic, assign) int forgeMaxEquipLevel;
@property (nonatomic, assign) float levelEquipBoostExponentBase;

@property (nonatomic, assign) float averageSizeOfLevelBracket;
@property (nonatomic, assign) float healthFormulaExponentBase;

// Char mod constants
@property (nonatomic, assign) int diamondCostToChangeCharacterType;
@property (nonatomic, assign) int diamondCostToChangeName;
@property (nonatomic, assign) int diamondCostToResetCharacter;
@property (nonatomic, assign) int diamondCostToResetSkillPoints;

// Clan constants
@property (nonatomic, assign) int diamondPriceToCreateClan;
@property (nonatomic, assign) int maxCharLengthForClanName;
@property (nonatomic, assign) int maxCharLengthForClanDescription;
@property (nonatomic, assign) int maxCharLengthForClanTag;

// Goldmine constants
@property (nonatomic, assign) int numHoursBeforeGoldmineRetrieval;
@property (nonatomic, assign) int numHoursForGoldminePickup;
@property (nonatomic, assign) int goldAmountFromGoldminePickup;
@property (nonatomic, assign) int goldCostForGoldmineRestart;

// Lock Box constants
@property (nonatomic, assign) int goldCostToPickLockBox;
@property (nonatomic, assign) int silverCostToPickLockBox;
@property (nonatomic, assign) float goldChanceToPickLockBox;
@property (nonatomic, assign) float silverChanceToPickLockBox;
@property (nonatomic, assign) float freeChanceToPickLockBox;
@property (nonatomic, assign) int numMinutesToRepickLockBox;
@property (nonatomic, assign) int goldCostToResetPickLockBox;

// Expansion Constants
@property (nonatomic, assign) int expansionWaitCompleteHourConstant;
@property (nonatomic, assign) int expansionWaitCompleteHourIncrementBase;
@property (nonatomic, assign) int expansionWaitCompleteBaseMinutesToOneGold;
@property (nonatomic, assign) int expansionPurchaseCostConstant;
@property (nonatomic, assign) int expansionPurchaseCostExponentBase;

// Three Card Monte Constants
@property (nonatomic, assign) int minLevelToDisplayThreeCardMonte;
@property (nonatomic, assign) int diamondCostToPlayThreeCardMonte;
@property (nonatomic, assign) float badMonteCardPercentageChance;
@property (nonatomic, assign) float mediumMonteCardPercentageChance;
@property (nonatomic, assign) float goodMonteCardPercentageChance;

@property (nonatomic, copy) NSArray *productIdentifiers;
@property (nonatomic, retain) NSDictionary *productIdentifiersToGold;

@property (nonatomic, retain) NSMutableDictionary *imageCache;
@property (retain) NSMutableDictionary *imageViewsWaitingForDownloading;

@property (nonatomic, retain) NSMutableDictionary *animatingSpriteOffsets;

@property (nonatomic, retain) StartupResponseProto_StartupConstants_KiipRewardConditions *kiipRewardConditions;
@property (nonatomic, retain) StartupResponseProto_StartupConstants_DownloadableNibConstants *downloadableNibConstants;

+ (Globals *) sharedGlobals;
+ (void) purgeSingleton;

- (void) updateConstants:(StartupResponseProto_StartupConstants *)constants;

+ (NSString *) font;
+ (int) fontSize;

+ (NSString *)convertTimeToString:(int)secs withDays:(BOOL)withDays;

+ (UIImage *) imageNamed:(NSString *)path;
+ (NSString *) imageNameForConstructionWithSize:(CGSize)size;
+ (UIImage *) imageForStruct:(int)structId;
+ (UIImage *) imageForEquip:(int)eqId;
+ (NSString *) imageNameForStruct:(int)structId;
+ (NSString *) imageNameForEquip:(int)eqId;
+ (NSString *) pathToFile:(NSString *)fileName;
+ (NSBundle *) bundleNamed:(NSString *)bundleName;
+ (void) asyncDownloadBundles;
+ (void) loadImageForStruct:(int)structId toView:(UIImageView *)view masked:(BOOL)mask indicator:(UIActivityIndicatorViewStyle)indicator;
+ (void) loadImageForEquip:(int)equipId toView:(UIImageView *)view maskedView:(UIImageView *)maskedView;
+ (void) imageNamed:(NSString *)imageName withImageView:(UIImageView *)view maskedColor:(UIColor *)color indicator:(UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear;

+ (UIColor *) colorForUnequippable;
+ (UIColor *) colorForUnknownEquip;
+ (UIColor *) colorForRarity:(FullEquipProto_Rarity)rarity;
+ (NSString *) stringForRarity:(FullEquipProto_Rarity)rarity;
+ (NSString *) shortenedStringForRarity:(FullEquipProto_Rarity)rarity;
+ (NSString *) factionForUserType:(UserType)type;
+ (NSString *) stringForEquipClassType:(EquipClassType)type;
+ (NSString *) stringForEquipType:(FullEquipProto_EquipType)type;
+ (NSString *) classForUserType:(UserType)type;
+ (PlayerClassType) playerClassTypeForUserType:(UserType)userType;

+ (UIImage *) squareImageForUser:(UserType)type;
+ (UIImage *) circleImageForUser:(UserType)type;
+ (UIImage *) profileImageForUser:(UserType)type;
+ (NSString *) battleImageNameForUser:(UserType)type;
+ (NSString *) headshotImageNameForUser:(UserType)type;
+ (NSString *) spriteImageNameForUser:(UserType)type;
+ (NSString *) animatedSpritePrefix:(UserType)type;
+ (NSString *) battleAnimationFileForUser:(UserType)type;
+ (NSString *) stringForTimeSinceNow:(NSDate *)date;
+ (BOOL) sellsForGoldInMarketplace:(FullEquipProto *)fep;
+ (BOOL) class:(UserType)ut canEquip:(EquipClassType) ct;
+ (BOOL) canEquip:(FullEquipProto *)fep;

+ (NSString *) nameForDialogueSpeaker:(DialogueProto_SpeechSegmentProto_DialogueSpeaker)speaker;
+ (NSString *) imageNameForDialogueSpeaker:(DialogueProto_SpeechSegmentProto_DialogueSpeaker)speaker;

+ (void) playComboBarChargeupSound:(UserType)type;
+ (void) playBattleAttackSound:(UserType)type;

+ (void) adjustFontSizeForSize:(int)size withUIView:(UIView *)somethingWithText;
+ (void) adjustFontSizeForSize:(int)size withUIViews:(UIView *)field1, ... NS_REQUIRES_NIL_TERMINATION;
+ (void) adjustFontSizeForUIViewWithDefaultSize:(UIView *)somethingWithText;
+ (void) adjustFontSizeForUIViewsWithDefaultSize:(UIView *)field1, ... NS_REQUIRES_NIL_TERMINATION;
+ (void) adjustFontSizeForUILabel:(UILabel *)label;
+ (void) adjustFontSizeForUILabels:(UILabel *)field1, ... NS_REQUIRES_NIL_TERMINATION;
+ (void) adjustFontSizeForCCLabelTTF:(CCLabelTTF *)label size:(int)size;
+ (void) adjustFontSizeForSize:(int)size CCLabelTTFs:(CCLabelTTF *)field1, ... NS_REQUIRES_NIL_TERMINATION;

+ (NSString *) commafyNumber:(int) n;

+ (void) setFrameForView:(UIView *)view forPoint:(CGPoint)pt;
+ (void) popupView:(UIView *)targetView
       onSuperView:(UIView *)superView
           atPoint:(CGPoint)point
withCompletionBlock:(void(^)(BOOL))completionBlock;
+ (void) popupMessage: (NSString *)msg;
+ (void) beginPulseForView:(UIView *)view andColor:(UIColor *)glowColor;
+ (void) endPulseForView:(UIView *)view;
+ (void) bounceView:(UIView *)view;
+ (void) bounceView:(UIView *)view fadeInBgdView: (UIView *)bgdView;
+ (void) popOutView:(UIView *)view fadeOutBgdView:(UIView *)bgdView completion:(void (^)(void))completed;
+ (UIImage*) maskImage:(UIImage *)image withColor:(UIColor *)color;
+ (void) shakeView:(UIView *)view duration:(float)duration offset:(int)offset;
+ (void) displayUIView:(UIView *)view;

+ (UIColor *)creamColor;
+ (UIColor *)goldColor;
+ (UIColor *)greenColor;
+ (UIColor *)orangeColor;
+ (UIColor *)redColor;
+ (UIColor *)blueColor;

+ (GameMap *) mapForQuest:(FullQuestProto *)fqp;
+ (NSString *) bazaarQuestGiverName;
+ (NSString *) homeQuestGiverName;

+ (void) animateUIArrow:(UIView *)arrow atAngle:(float)angle;
+ (void) animateCCArrow:(CCNode *)arrow atAngle:(float)angle;

+ (BOOL) userTypeIsGood:(UserType)type;
+ (BOOL) userTypeIsBad:(UserType)type;
+ (BOOL) userType:(UserType)t1 isAlliesWith:(UserType)t2;

- (void) confirmWearEquip:(int)userEquipId;

- (BOOL) validateUserName:(NSString *)name;

+ (NSString *) fullNameWithName:(NSString *)name clanTag:(NSString *)tag;

+ (void) checkRateUsPopup;

- (int) percentOfSkillPointsInStamina;

// Formulas
- (int) calculateEquipSilverSellCost:(UserEquip *)ue;
- (int) calculateEquipGoldSellCost:(UserEquip *)ue;
- (int) calculateIncomeForUserStruct:(UserStruct *)us;
- (int) calculateIncomeForUserStructAfterLevelUp:(UserStruct *)us;
- (int) calculateStructSilverSellCost:(UserStruct *)us;
- (int) calculateStructGoldSellCost:(UserStruct *)us;
- (int) calculateUpgradeCost:(UserStruct *)us;
- (int) calculateDiamondCostForInstaBuild:(UserStruct *)us;
- (int) calculateDiamondCostForInstaUpgrade:(UserStruct *)us;
- (int) calculateMinutesToUpgrade:(UserStruct *)us;
- (float) calculateAttackForAttackStat:(int)attackStat weapon:(UserEquip *)weapon armor:(UserEquip *)armor amulet:(UserEquip *)amulet;
- (float) calculateDefenseForDefenseStat:(int)defenseStat weapon:(UserEquip *)weapon armor:(UserEquip *)armor amulet:(UserEquip *)amulet;
- (int) calculateHealthForLevel:(int)level;

- (BOOL) canRetractMarketplacePostForFree:(FullMarketplacePostProto *)post;

// Forging formulas
- (int) calculateAttackForEquip:(int)equipId level:(int)level;
- (int) calculateDefenseForEquip:(int)equipId level:(int)level;
- (float) calculateChanceOfSuccess:(int)equipId level:(int)level;
- (int) calculateMinutesForForge:(int)equipId level:(int)level;
- (int) calculateGoldCostToGuaranteeForgingSuccess:(int)equipId level:(int)level;
- (int) calculateGoldCostToSpeedUpForging:(int)equipId level:(int)level;
- (int) calculateRetailValueForEquip:(int)equipId level:(int)level;
- (int) calculateNumMinutesForNewExpansion:(UserExpansion *)ue;
- (int) calculateGoldCostToSpeedUpExpansion:(UserExpansion *)ue;
- (int) calculateSilverCostForNewExpansion:(UserExpansion *)ue;

+ (void) adjustViewForCentering:(UIView *)view withLabel:(UILabel *)label;

@end

@interface CCNode (RecursiveOpacity)

- (void) recursivelyApplyOpacity:(GLubyte)opacity;

@end
