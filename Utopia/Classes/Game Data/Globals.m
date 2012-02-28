//
//  Globals.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Globals.h"
#import "SynthesizeSingleton.h"
#import "IAPHelper.h"
#import "GameState.h"
#import "Protocols.pb.h"

#define FONT_LABEL_OFFSET 3.f

@implementation Globals

static NSString *fontName = @"AJensonPro-BoldCapt";
static int fontSize = 12;

static NSString *structureImageString = @"struct%d.png";
static NSString *equipImageString = @"equip%d.png";

@synthesize depositPercentCut;
@synthesize clericLevelFactor, clericHealthFactor;
@synthesize attackBaseGain, defenseBaseGain, energyBaseGain, staminaBaseGain, healthBaseGain;
@synthesize attackBaseCost, defenseBaseCost, energyBaseCost, staminaBaseCost, healthBaseCost;
@synthesize retractPercentCut, purchasePercentCut;
@synthesize energyRefillCost, staminaRefillCost;
@synthesize maxRepeatedNormStructs, maxEquipId, maxStructId;
@synthesize productIdentifiers;

SYNTHESIZE_SINGLETON_FOR_CLASS(Globals);

- (id) init {
  if ((self = [super init])) {
    self.retractPercentCut = 0.05;
    self.depositPercentCut = 0.1;
    self.maxRepeatedNormStructs = 2;
    maxStructId = 4;
  }
  return self;
}

- (void) updateConstants:(StartupResponseProto_StartupConstants *)constants {
  self.productIdentifiers = [NSDictionary dictionaryWithObjects:constants.productDiamondsGivenList forKeys:constants.productIdsList];
  self.energyRefillCost = constants.diamondCostForEnergyRefill;
  self.staminaRefillCost = constants.diamondCostForStaminaRefill;
}

- (void) setProductIdentifiers:(NSDictionary *)productIds {
  [productIdentifiers release];
  productIdentifiers = [productIds retain];
  [[IAPHelper sharedIAPHelper] requestProducts];
}

+ (NSString *) font {
  return fontName;
}

+ (int) fontSize {
  return fontSize;
}

+ (NSString *) imageNameForStruct:(int)structId {
  NSString *file = [NSString stringWithFormat:structureImageString, structId];
  return file;
}

+ (NSString *) imageNameForEquip:(int)eqId {
  return @"exampleweapon.png";//[NSString stringWithFormat:equipImageString, eqId];
}

+ (UIImage *) imageForStruct:(int)structId {
  return [UIImage imageNamed:[self imageNameForStruct:structId]];
}

+ (UIImage *) imageForEquip:(int)eqId {
  return [UIImage imageNamed:[self imageNameForEquip:eqId]];//[NSString stringWithFormat:equipImageString, eqId];
}

+ (UIColor *) colorForRarity:(FullEquipProto_Rarity)rarity {  
  switch (rarity) {
    case FullEquipProto_RarityCommon:
      return [UIColor whiteColor];
      
    case FullEquipProto_RarityUncommon:
      return [UIColor greenColor];
      
    case FullEquipProto_RarityRare:
      return [UIColor blueColor];
      
    case FullEquipProto_RarityEpic:
      return [UIColor purpleColor];
      
    case FullEquipProto_RarityLegendary:
      return [UIColor yellowColor];
      
    default:
      break;
  }
}

+ (NSString *) stringForRarity:(FullEquipProto_Rarity)rarity {
  switch (rarity) {
    case FullEquipProto_RarityCommon:
      return @"Common";
      
    case FullEquipProto_RarityUncommon:
      return @"Uncommon";
      
    case FullEquipProto_RarityRare:
      return @"Rare";
      
    case FullEquipProto_RarityEpic:
      return @"Epic";
      
    case FullEquipProto_RarityLegendary:
      return @"Legendary";
      
    default:
      break;
  }
}

+ (NSString *) shortenedStringForRarity:(FullEquipProto_Rarity)rarity {
  NSString *str = [self stringForRarity:rarity];
  
  if (str.length > 4) {
    str = [str stringByReplacingCharactersInRange:NSMakeRange(3, str.length-3) withString:@"."];
  }
  return [str uppercaseString];
}

+ (NSString *) factionForUserType:(UserType)type {
  return type >= 3 ? @"Legion" : @"Alliance";
}

+ (NSString *) classForUserType:(UserType)type {
  if (type % 3 == 0) {
    return @"Warrior";
  } else if (type % 3 == 1) {
    return @"Archer";
  } else if (type % 3 == 2) {
    return @"Mage";
  }
  return nil;
}

+ (NSString *) stringForEquipType:(FullEquipProto_ClassType)type {
  if (type % 3 == 0) {
    return @"Warrior";
  } else if (type % 3 == 1) {
    return @"Archer";
  } else if (type % 3 == 2) {
    return @"Mage";
  }
  return nil;
}

+ (BOOL) canEquip:(FullUserEquipProto *)equip {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equip.equipId];
  NSLog(@"%d: %d, %d, %d, %d, %d, %d", fep.equipId, fep.minLevel, gs.level, fep.classType, gs.type %3, equip.userId, gs.userId);
  return fep.minLevel <= gs.level && fep.classType == gs.type % 3 && equip.userId == gs.userId; 
}

+ (void) adjustFontSizeForSize:(int)size withUIView:(UIView *)somethingWithText {
  if ([somethingWithText respondsToSelector:@selector(setFont:)]) {
    UIFont *f = [UIFont fontWithName:[self font] size:size];
    [somethingWithText performSelector:@selector(setFont:) withObject:f];
    
    // Move frame down to account for this font
    CGRect tmp = somethingWithText.frame;
    tmp.origin.y += FONT_LABEL_OFFSET * size / [self fontSize];
    somethingWithText.frame = tmp;
  }
}

+ (void) adjustFontSizeForSize:(int)size withUIViews:(UIView *)field1, ... {
  va_list params;
	va_start(params,field1);
	
  for (UIView *arg = field1; arg != nil; arg = va_arg(params, UIView *))
  {
    [self adjustFontSizeForSize:size withUIView:field1];
  }
  va_end(params);
}

+ (void) adjustFontSizeForUIViewWithDefaultSize:(UIView *)somethingWithText {
  [self adjustFontSizeForSize:[self fontSize] withUIView:somethingWithText];
}

+ (void) adjustFontSizeForUIViewsWithDefaultSize:(UIView *)field1, ...
{
	va_list params;
	va_start(params,field1);
	
  for (UIView *arg = field1; arg != nil; arg = va_arg(params, UIView *))
  {
    [self adjustFontSizeForUIViewWithDefaultSize:arg];
  }
  va_end(params);
}

+ (void) adjustFontSizeForUILabel:(UILabel *)label {
  [self adjustFontSizeForSize:label.font.pointSize withUIView:label];
}

+ (void) adjustFontSizeForUILabels:(UILabel *)field1, ...
{
	va_list params;
	va_start(params,field1);
	
  for (UILabel *arg = field1; arg != nil; arg = va_arg(params, UILabel *))
  {
    [self adjustFontSizeForUILabel:arg];
  }
  va_end(params);
}

+ (void) adjustFontSizeForCCLabelTTF:(CCLabelTTF *)label {
  label.position = ccpAdd(label.position, ccp(0,-FONT_LABEL_OFFSET));
}

+ (void) adjustFontSizeForCCLabelTTFs:(CCLabelTTF *)field1, ...
{
	va_list params;
	va_start(params,field1);
	
  for (CCLabelTTF *arg = field1; arg != nil; arg = va_arg(params, CCLabelTTF *))
  {
    [self adjustFontSizeForCCLabelTTF:arg];
  }
  va_end(params);
}

+ (NSString *) commafyNumber:(int) n {
  return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInt:n] numberStyle:NSNumberFormatterDecimalStyle];
}

// Formulas

// Buildings
- (int) calculateIncome:(int)income level:(int)level {
  return income*level;
}

- (int) calculateIncomeForUserStruct:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return [self calculateIncome:fsp.income level:us.level];
}

- (int) calculateIncomeForUserStructAfterLevelUp:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return [self calculateIncome:fsp.income level:us.level+1];
}

- (int) calculateSellCost:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return fsp.coinPrice/2;
}

- (int) calculateUpgradeCost:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return us.level/2 * fsp.upgradeCoinCostBase;
}

- (int) calculateDiamondCostForInstaBuild:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return MAX(1,fsp.instaUpgradeDiamondCostBase * us.level);
}

- (int) calculateDiamondCostForInstaUpgrade:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return MAX(1,fsp.instaBuildDiamondCostBase * us.level);
}

- (int) calculateMinutesToUpgrade:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return fsp.minutesToUpgradeBase * us.level;
}

+ (void) popupMessage: (NSString *)msg {
  [[[UIAlertView alloc] initWithTitle:@"Notification" message:msg  delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
}

- (void) dealloc {
  self.productIdentifiers = nil;
  [super dealloc];
}

@end
