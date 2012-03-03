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

@property (nonatomic, assign) int energyRefillCost;
@property (nonatomic, assign) int staminaRefillCost;

@property (nonatomic, assign) int maxRepeatedNormStructs;
@property (nonatomic, assign) int maxEquipId;
@property (nonatomic, assign) int maxStructId;

@property (nonatomic, assign) NSDictionary *productIdentifiers;

+ (Globals *) sharedGlobals;
- (void) updateConstants:(StartupResponseProto_StartupConstants *)constants;
+ (NSString *) font;
+ (int) fontSize;
+ (UIImage *) imageForStruct:(int)structId;
+ (UIImage *) imageForEquip:(int)eqId;
+ (NSString *) imageNameForStruct:(int)structId;
+ (NSString *) imageNameForEquip:(int)eqId;
+ (UIColor *) colorForUnequippable;
+ (UIColor *) colorForRarity:(FullEquipProto_Rarity)rarity;
+ (NSString *) stringForRarity:(FullEquipProto_Rarity)rarity;
+ (NSString *) shortenedStringForRarity:(FullEquipProto_Rarity)rarity;
+ (NSString *) factionForUserType:(UserType)type;
+ (NSString *) stringForEquipType:(FullEquipProto_ClassType)type;
+ (NSString *) classForUserType:(UserType)type;
+ (BOOL) canEquip:(FullEquipProto *)fep;

+ (void) adjustFontSizeForSize:(int)size withUIView:(UIView *)somethingWithText;
+ (void) adjustFontSizeForSize:(int)size withUIViews:(UIView *)field1, ... NS_REQUIRES_NIL_TERMINATION;
+ (void) adjustFontSizeForUIViewWithDefaultSize:(UIView *)somethingWithText;
+ (void) adjustFontSizeForUIViewsWithDefaultSize:(UIView *)field1, ... NS_REQUIRES_NIL_TERMINATION;
+ (void) adjustFontSizeForUILabel:(UILabel *)label;
+ (void) adjustFontSizeForUILabels:(UILabel *)field1, ... NS_REQUIRES_NIL_TERMINATION;
+ (void) adjustFontSizeForCCLabelTTF:(CCLabelTTF *)label;
+ (void) adjustFontSizeForCCLabelTTFs:(CCLabelTTF *)field1, ... NS_REQUIRES_NIL_TERMINATION;

+ (NSString *) commafyNumber:(int) n;

+ (void) popupMessage: (NSString *)msg;
+ (UIImage*) maskImage:(UIImage *)image withColor:(UIColor *)color;
+ (void) shakeView:(UIView *)view duration:(float)duration offset:(int)offset;
+ (UIImage *) imageNamed:(NSString *)path;

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

@end
