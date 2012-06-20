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

#define BUTTON_CLICKED_LEEWAY 30

#define LNLog(...) CCLOG(__VA_ARGS__)

#define FULL_SCREEN_APPEAR_ANIMATION_DURATION 0.4f
#define FULL_SCREEN_DISAPPEAR_ANIMATION_DURATION 0.7f

@interface Globals : NSObject
@property (nonatomic, assign) float depositPercentCut;

@property (nonatomic, assign) float clericLevelFactor;
@property (nonatomic, assign) float clericHealthFactor;

@property (nonatomic, assign) int attackBaseGain;
@property (nonatomic, assign) int defenseBaseGain;
@property (nonatomic, assign) int energyBaseGain;
@property (nonatomic, assign) int staminaBaseGain;
@property (nonatomic, assign) int healthBaseGain;
@property (nonatomic, assign) int attackBaseCost;
@property (nonatomic, assign) int defenseBaseCost;
@property (nonatomic, assign) int energyBaseCost;
@property (nonatomic, assign) int staminaBaseCost;
@property (nonatomic, assign) int healthBaseCost;

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

@property (nonatomic, assign) int maxLevelDiffForBattle;
@property (nonatomic, assign) int skillPointsGainedOnLevelup;
@property (nonatomic, assign) float cutOfVaultDepositTaken;

@property (nonatomic, assign) int maxLevelForStruct;
@property (nonatomic, assign) int maxRepeatedNormStructs;
@property (nonatomic, assign) float percentReturnedToUserForSellingNormStructure;

@property (nonatomic, assign) int maxNumberOfMarketplacePosts;

@property (nonatomic, assign) int numDaysLongMarketplaceLicenseLastsFor;
@property (nonatomic, assign) int numDaysShortMarketplaceLicenseLastsFor;
@property (nonatomic, assign) int diamondCostOfLongMarketplaceLicense;
@property (nonatomic, assign) int diamondCostOfShortMarketplaceLicense;

@property (nonatomic, assign) int maxNumbersOfEnemiesToGenerateAtOnce;
@property (nonatomic, assign) float percentReturnedToUserForSellingEquipInArmory;

@property (nonatomic, assign) int diamondRewardForReferrer;

@property (nonatomic, assign) float minutesToUpgradeForNormStructMultiplier;
@property (nonatomic, assign) float incomeFromNormStructMultiplier;
@property (nonatomic, assign) float upgradeStructCoinCostExponentBase;
@property (nonatomic, assign) float upgradeStructDiamondCostExponentBase;
@property (nonatomic, assign) float diamondCostForInstantUpgradeMultiplier;
@property (nonatomic, assign) float battleWeightGivenToAttackStat;
@property (nonatomic, assign) float battleWeightGivenToAttackEquipSum;
@property (nonatomic, assign) float battleWeightGivenToDefenseStat;
@property (nonatomic, assign) float battleWeightGivenToDefenseEquipSum;

@property (nonatomic, assign) float locationBarMax;
@property (nonatomic, assign) float maxAttackMultiplier;
@property (nonatomic, assign) float minPercentOfEnemyHealth;
@property (nonatomic, assign) float maxPercentOfEnemyHealth;
@property (nonatomic, assign) float battleDifferenceMultiplier;
@property (nonatomic, assign) float battleDifferenceTuner;

@property (nonatomic, retain) NSDictionary *productIdentifiers;

@property (nonatomic, retain) NSMutableDictionary *imageCache;
@property (retain) NSMutableDictionary *imageViewsWaitingForDownloading;

+ (Globals *) sharedGlobals;
+ (void) purgeSingleton;

- (void) updateConstants:(StartupResponseProto_StartupConstants *)constants;

+ (NSString *) font;
+ (int) fontSize;

+ (NSString *)convertTimeToString:(int)secs;

+ (UIImage *) imageNamed:(NSString *)path;
+ (NSString *) imageNameForConstructionWithSize:(CGSize)size;
+ (UIImage *) imageForStruct:(int)structId;
+ (UIImage *) imageForEquip:(int)eqId;
+ (NSString *) imageNameForStruct:(int)structId;
+ (NSString *) imageNameForEquip:(int)eqId;
+ (NSString *) pathToMap:(NSString *)mapName;
+ (void) loadImageForStruct:(int)structId toView:(UIImageView *)view masked:(BOOL)mask;
+ (void) loadImageForEquip:(int)equipId toView:(UIImageView *)view maskedView:(UIImageView *)maskedView;
+ (void) imageNamed:(NSString *)imageName withImageView:(UIImageView *)view maskedColor:(UIColor *)color indicator:(UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear;

+ (UIColor *) colorForUnequippable;
+ (UIColor *) colorForUnknownEquip;
+ (UIColor *) colorForRarity:(FullEquipProto_Rarity)rarity;
+ (NSString *) stringForRarity:(FullEquipProto_Rarity)rarity;
+ (NSString *) shortenedStringForRarity:(FullEquipProto_Rarity)rarity;
+ (NSString *) factionForUserType:(UserType)type;
+ (NSString *) stringForEquipClassType:(FullEquipProto_ClassType)type;
+ (NSString *) stringForEquipType:(FullEquipProto_EquipType)type;
+ (NSString *) classForUserType:(UserType)type;
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
+ (BOOL) class:(UserType)ut canEquip:(FullEquipProto_ClassType) ct;
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
+(void)  beginPulseForView:(UIView *)view andColor:(UIColor *)glowColor;
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

+ (GameMap *)mapForQuest:(FullQuestProto *)fqp;
+ (NSString *) bazaarQuestGiverName;
+ (NSString *) homeQuestGiverName;

+ (void) animateUIArrow:(UIView *)arrow atAngle:(float)angle;
+ (void) animateCCArrow:(CCNode *)arrow atAngle:(float)angle;

+ (BOOL)userTypeIsGood:(UserType)type;
+ (BOOL)userTypeIsBad:(UserType)type;
+ (BOOL)userType:(UserType)t1 isAlliesWith:(UserType)t2;

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
- (float) calculateAttackForStat:(int)attackStat weapon:(int)weaponId armor:(int)armorId amulet:(int)amuletId;
- (float) calculateDefenseForStat:(int)defenseStat weapon:(int)weaponId armor:(int)armorId amulet:(int)amuletId;

@end
