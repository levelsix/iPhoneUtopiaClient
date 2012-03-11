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
#import "ImageDownloader.h"

#define FONT_LABEL_OFFSET 3.f
#define SHAKE_DURATION 0.05f

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
@synthesize energyRefillWaitMinutes, staminaRefillWaitMinutes;
@synthesize energyRefillCost, staminaRefillCost;
@synthesize maxRepeatedNormStructs, maxEquipId, maxStructId;
@synthesize productIdentifiers;
@synthesize imageCache;
@synthesize armoryXLength, armoryYLength, carpenterXLength, carpenterYLength, aviaryXLength;
@synthesize aviaryYLength, marketplaceXLength, marketplaceYLength, vaultXLength, vaultYLength;

SYNTHESIZE_SINGLETON_FOR_CLASS(Globals);

- (id) init {
  if ((self = [super init])) {
    self.retractPercentCut = 0.05;
    self.depositPercentCut = 0.1;
    self.maxRepeatedNormStructs = 2;
    maxStructId = 4;
    
    attackBaseCost = 1;
    defenseBaseCost = 1;
    energyBaseCost = 1;
    staminaBaseCost = 2;
    healthBaseCost = 1;
    
    attackBaseGain = 1;
    defenseBaseGain = 1;
    energyBaseGain = 1;
    staminaBaseGain = 1;
    healthBaseGain = 10;
    
    energyRefillWaitMinutes = 3;
    staminaRefillWaitMinutes = 4;
    
    aviaryXLength = 2;
    aviaryYLength = 2;
    armoryXLength = 2;
    armoryYLength = 2;
    carpenterXLength = 2;
    carpenterYLength = 2;
    marketplaceXLength = 2;
    marketplaceYLength = 2;
    vaultXLength = 2;
    vaultYLength = 2;
    
    imageCache = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void) updateConstants:(StartupResponseProto_StartupConstants *)constants {
  self.productIdentifiers = [NSDictionary dictionaryWithObjects:constants.productDiamondsGivenList forKeys:constants.productIdsList];
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
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:structId];
  NSString *str = [fsp.name stringByReplacingOccurrencesOfString:@" " withString:@""];
  str = [str stringByReplacingOccurrencesOfString:@"'" withString:@""];
  NSString *file = [NSString stringWithFormat:[str stringByAppendingString:@".png"]];
  return file;
}

+ (NSString *) imageNameForEquip:(int)eqId {
  return @"exampleweapon.png";//[NSString stringWithFormat:equipImageString, eqId];
}

+ (UIImage *) imageForStruct:(int)structId {
  return [self imageNamed:[self imageNameForStruct:structId]];
}

+ (UIImage *) imageForEquip:(int)eqId {
  return [self imageNamed:[self imageNameForEquip:eqId]];//[NSString stringWithFormat:equipImageString, eqId];
}

+ (UIColor *) colorForUnequippable {
  return [UIColor colorWithRed:150/255.f green:0.f blue:0.f alpha:1.f];
}

+ (UIColor *) colorForUnknownEquip {
  return [UIColor colorWithWhite:87/256.f alpha:1.f];
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

+ (NSString *) stringForEquipClassType:(FullEquipProto_ClassType)type {
  if (type % 3 == 0) {
    return @"Warrior";
  } else if (type % 3 == 1) {
    return @"Archer";
  } else if (type % 3 == 2) {
    return @"Mage";
  }
  return nil;
}

+ (BOOL) canEquip:(FullEquipProto *)fep {
  GameState *gs = [GameState sharedGameState];
  return fep.minLevel <= gs.level && (fep.classType == gs.type % 3 || fep.classType == FullEquipProto_ClassTypeAllAmulet); 
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

+ (void) adjustFontSizeForCCLabelTTF:(CCLabelTTF *)label size:(int)size {
  label.position = ccpAdd(label.position, ccp(0,-FONT_LABEL_OFFSET * size / [self fontSize]));
}

+ (void) adjustFontSizeForSize:(int)size CCLabelTTFs:(CCLabelTTF *)field1, ...
{
	va_list params;
	va_start(params,field1);
	
  for (CCLabelTTF *arg = field1; arg != nil; arg = va_arg(params, CCLabelTTF *))
  {
    [self adjustFontSizeForCCLabelTTF:arg size:size];
  }
  va_end(params);
}

+ (NSString *) commafyNumber:(int) n {
  return [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithInt:n] numberStyle:NSNumberFormatterDecimalStyle];
}

+ (UIImage*) maskImage:(UIImage *)image withColor:(UIColor *)color {
  
  CGImageRef alphaImage = CGImageRetain(image.CGImage);
  float width = CGImageGetWidth(alphaImage);
  float height = CGImageGetHeight(alphaImage);
  
  UIGraphicsBeginImageContext(CGSizeMake(width, height));
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  if (!context) {
    CGImageRelease(alphaImage);
    return nil;
  }
  
	CGRect r = CGRectMake(0, 0, width, height);
	CGContextTranslateCTM(context, 0.0, r.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
  CGContextSetFillColorWithColor(context, color.CGColor);
  
	// You can also use the clip rect given to scale the mask image
	CGContextClipToMask(context, CGRectMake(0.0, 0.0, width, height), alphaImage);
	// As above, not being careful with bounds since we are clipping.
	CGContextFillRect(context, r);
  
  UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  CGImageRelease(alphaImage);
  
  // return the image
  return theImage;
}

+ (void) shakeView:(UIView *)view duration:(float)duration offset:(int)offset {
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
  int repeatCt = duration / SHAKE_DURATION;
  [animation setDuration:SHAKE_DURATION];
  [animation setRepeatCount:repeatCt];
  [animation setAutoreverses:YES];
  [animation setFromValue:[NSValue valueWithCGPoint:
                           CGPointMake(view.center.x - offset, view.center.y)]];
  [animation setToValue:[NSValue valueWithCGPoint:
                         CGPointMake(view.center.x + offset, view.center.y)]];
  [view.layer addAnimation:animation forKey:@"position"];
}

+ (UIImage *) imageNamed:(NSString *)path {
  if (!path) {
    return nil;
  }
  
  Globals *gl = [Globals sharedGlobals];
  UIImage *cachedImage = [gl.imageCache objectForKey:path];
  if (cachedImage) {
    return cachedImage;
  }
  
  // prevents overloading the autorelease pool
  NSString *resName = [CCFileUtils getDoubleResolutionImage:path validate:NO];
  UIImage *image = nil;
  NSString *fullpath = [[NSBundle mainBundle] pathForResource:resName ofType:nil];
  
  // Added for Utopia project
  if (!fullpath) {
    // Image not in NSBundle: look in documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    fullpath = [documentsPath stringByAppendingPathComponent:resName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
      // Image not in docs: download it
      [[ImageDownloader sharedImageDownloader] downloadImage:fullpath.lastPathComponent];
    }
  }
  
  image = [UIImage imageWithContentsOfFile:fullpath];
  
  if (image) {
    [gl.imageCache setObject:image forKey:path];
  }
  
  return image;
}

// Formulas

// Buildings
- (int) calculateIncome:(int)income level:(int)level {
  return income*level;
}

- (int) calculateEquipSilverSellCost:(UserEquip *)ue {
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:ue.equipId];
  return fep.coinPrice/2;
}

- (int) calculateEquipGoldSellCost:(UserEquip *)ue {
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:ue.equipId];
  return fep.diamondPrice/2;
}

- (int) calculateIncomeForUserStruct:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return [self calculateIncome:fsp.income level:us.level];
}

- (int) calculateIncomeForUserStructAfterLevelUp:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return [self calculateIncome:fsp.income level:us.level+1];
}

- (int) calculateStructSilverSellCost:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return fsp.coinPrice/2;
}

- (int) calculateStructGoldSellCost:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return fsp.diamondPrice/2;
}

- (int) calculateUpgradeCost:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return us.level/2 * fsp.coinPrice;
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

- (float) calculateAttackForStat:(int)attackStat weapon:(int)weaponId armor:(int)armorId amulet:(int)amuletId {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *weapon = nil;
  if (weaponId != 0) {
     weapon = [gs equipWithId:weaponId];
  }
  FullEquipProto *armor = nil;
  if (armorId != 0) {
    armor = [gs equipWithId:armorId];
  }
  FullEquipProto *amulet = nil;
  if (amuletId != 0) {
    amulet = [gs equipWithId:amuletId];
  }
  
  return attackStat + weapon.attackBoost + armor.attackBoost + amulet.attackBoost;
}

- (float) calculateDefenseForStat:(int)defenseStat weapon:(int)weaponId armor:(int)armorId amulet:(int)amuletId {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *weapon = [gs equipWithId:weaponId];
  FullEquipProto *armor = [gs equipWithId:armorId];
  FullEquipProto *amulet = [gs equipWithId:amuletId];
  
  return defenseStat + weapon.defenseBoost + armor.defenseBoost + amulet.defenseBoost;
}

+ (void) popupMessage: (NSString *)msg {
  [[[[UIAlertView alloc] initWithTitle:@"Notification" message:msg  delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] autorelease] show];
}

- (void) dealloc {
  self.productIdentifiers = nil;
  [super dealloc];
}

@end
