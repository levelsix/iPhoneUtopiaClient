//
//  Globals.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Globals.h"
#import "LNSynthesizeSingleton.h"
#import "IAPHelper.h"
#import "GameState.h"
#import "Protocols.pb.h"
#import "Downloader.h"
#import "GenericPopupController.h"
#import "SoundEngine.h"
#import "GameLayer.h"
#import "HomeMap.h"

#define FONT_LABEL_OFFSET 3.f
#define SHAKE_DURATION 0.05f
#define PULSE_TIME 0.8f

@implementation Globals

static NSString *fontName = @"AJensonPro-BoldCapt";
static int fontSize = 12;

static NSString *structureImageString = @"struct%d.png";
static NSString *equipImageString = @"equip%d.png";
static NSMutableSet *_donePulsingViews;
static NSMutableSet *_pulsingViews;

@synthesize depositPercentCut;
@synthesize clericLevelFactor, clericHealthFactor;
@synthesize attackBaseGain, defenseBaseGain, energyBaseGain, staminaBaseGain, healthBaseGain;
@synthesize attackBaseCost, defenseBaseCost, energyBaseCost, staminaBaseCost, healthBaseCost;
@synthesize retractPercentCut, purchasePercentCut;
@synthesize energyRefillWaitMinutes, staminaRefillWaitMinutes;
@synthesize energyRefillCost, staminaRefillCost;
@synthesize maxRepeatedNormStructs;
@synthesize productIdentifiers;
@synthesize imageCache, imageViewsWaitingForDownloading;
@synthesize armoryXLength, armoryYLength, carpenterXLength, carpenterYLength, aviaryXLength;
@synthesize aviaryYLength, marketplaceXLength, marketplaceYLength, vaultXLength, vaultYLength;
@synthesize diamondCostOfShortMarketplaceLicense, diamondCostOfLongMarketplaceLicense;
@synthesize cutOfVaultDepositTaken, skillPointsGainedOnLevelup, percentReturnedToUserForSellingEquipInArmory;
@synthesize percentReturnedToUserForSellingNormStructure, numDaysLongMarketplaceLicenseLastsFor;
@synthesize maxLevelForStruct, maxNumbersOfEnemiesToGenerateAtOnce, maxLevelDiffForBattle;
@synthesize maxNumberOfMarketplacePosts, numDaysShortMarketplaceLicenseLastsFor;
@synthesize diamondRewardForReferrer;
@synthesize incomeFromNormStructMultiplier, minutesToUpgradeForNormStructMultiplier;
@synthesize battleWeightGivenToAttackStat, battleWeightGivenToDefenseStat;
@synthesize battleWeightGivenToAttackEquipSum, battleWeightGivenToDefenseEquipSum;
@synthesize diamondCostForInstantUpgradeMultiplier, upgradeStructCoinCostExponentBase;
@synthesize upgradeStructDiamondCostExponentBase;
@synthesize locationBarMax, maxAttackMultiplier;
@synthesize minPercentOfEnemyHealth, maxPercentOfEnemyHealth;
@synthesize battleDifferenceTuner, battleDifferenceMultiplier;

SYNTHESIZE_SINGLETON_FOR_CLASS(Globals);

- (id) init {
  if ((self = [super init])) {
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
    imageViewsWaitingForDownloading = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void) updateConstants:(StartupResponseProto_StartupConstants *)constants {
  self.productIdentifiers = [NSDictionary dictionaryWithObjects:constants.productDiamondsGivenList forKeys:constants.productIdsList];
  self.maxLevelDiffForBattle = constants.maxLevelDifferenceForBattle;
  self.armoryXLength = constants.armoryXlength;
  self.armoryYLength = constants.armoryYlength;
  self.vaultXLength = constants.vaultXlength;
  self.vaultYLength = constants.vaultYlength;
  self.marketplaceXLength = constants.marketplaceXlength;
  self.marketplaceYLength = constants.marketplaceYlength;
  self.carpenterXLength = constants.carpenterXlength;
  self.carpenterYLength = constants.carpenterYlength;
  self.attackBaseGain = constants.attackBaseGain;
  self.attackBaseCost = constants.attackBaseCost;
  self.defenseBaseGain = constants.defenseBaseGain;
  self.defenseBaseCost = constants.defenseBaseCost;
  self.energyBaseGain = constants.energyBaseGain;
  self.energyBaseCost = constants.energyBaseCost;
  self.healthBaseGain = constants.healthBaseGain;
  self.healthBaseCost = constants.healthBaseCost;
  self.staminaBaseGain = constants.staminaBaseGain;
  self.staminaBaseCost = constants.staminaBaseCost;
  self.skillPointsGainedOnLevelup = constants.skillPointsGainedOnLevelup;
  self.cutOfVaultDepositTaken = constants.cutOfVaultDepositTaken;
  self.maxLevelForStruct = constants.maxLevelForStruct;
  self.maxRepeatedNormStructs = constants.maxNumOfSingleStruct;
  self.percentReturnedToUserForSellingEquipInArmory = constants.percentReturnedToUserForSellingEquipInArmory;
  self.numDaysLongMarketplaceLicenseLastsFor = constants.numDaysLongMarketplaceLicenseLastsFor;
  self.numDaysShortMarketplaceLicenseLastsFor = constants.numDaysShortMarketplaceLicenseLastsFor;
  self.diamondCostOfLongMarketplaceLicense = constants.diamondCostOfLongMarketplaceLicense;
  self.diamondCostOfShortMarketplaceLicense = constants.diamondCostOfShortMarketplaceLicense;
  self.maxNumbersOfEnemiesToGenerateAtOnce = constants.maxNumbersOfEnemiesToGenerateAtOnce;
  self.purchasePercentCut = constants.percentOfSellingCostTakenFromSellerOnMarketplacePurchase;
  self.retractPercentCut = constants.percentOfSellingCostTakenFromSellerOnMarketplaceRetract;
  self.maxNumberOfMarketplacePosts = constants.maxNumberOfMarketplacePosts;
  self.energyRefillCost = constants.diamondCostForFullEnergyRefill;
  self.staminaRefillCost = constants.diamondCostForFullStaminaRefill;
  self.energyRefillWaitMinutes = constants.minutesToRefillAenergy;
  self.staminaRefillWaitMinutes = constants.minutesToRefillAstamina;
  
  self.minutesToUpgradeForNormStructMultiplier = constants.formulaConstants.minutesToUpgradeForNormStructMultiplier;
  self.incomeFromNormStructMultiplier = constants.formulaConstants.incomeFromNormStructMultiplier;
  self.upgradeStructCoinCostExponentBase = constants.formulaConstants.upgradeStructCoinCostExponentBase;
  self.upgradeStructDiamondCostExponentBase = constants.formulaConstants.upgradeStructDiamondCostExponentBase;
  self.diamondCostForInstantUpgradeMultiplier = constants.formulaConstants.diamondCostForInstantUpgradeMultiplier;
  self.battleWeightGivenToAttackStat = constants.formulaConstants.battleWeightGivenToAttackStat;
  self.battleWeightGivenToAttackEquipSum = constants.formulaConstants.battleWeightGivenToAttackEquipSum;
  self.battleWeightGivenToDefenseStat = constants.formulaConstants.battleWeightGivenToDefenseStat;
  self.battleWeightGivenToDefenseEquipSum = constants.formulaConstants.battleWeightGivenToDefenseEquipSum;
  
  self.locationBarMax = constants.battleConstants.locationBarMax;
  self.maxAttackMultiplier = constants.battleConstants.maxAttackMultiplier;
  self.minPercentOfEnemyHealth = constants.battleConstants.minPercentOfEnemyHealth;
  self.maxPercentOfEnemyHealth = constants.battleConstants.maxPercentOfEnemyHealth;
  self.battleDifferenceMultiplier = constants.battleConstants.battleDifferenceMultiplier;
  self.battleDifferenceTuner = constants.battleConstants.battleDifferenceTuner;
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

+ (NSString *)convertTimeToString:(int)secs {
  int days = secs / 86400;
  secs %= 86400;
  int hrs = secs / 3600;
  secs %= 3600;
  int mins = secs / 60;
  secs %= 60;
  
  NSString *daysString = days ? [NSString stringWithFormat:@"%d:", days] : @"";
  return [NSString stringWithFormat:@"%@%02d:%02d:%02d", daysString, hrs, mins, secs];
}

+ (NSString *) imageNameForConstructionWithSize:(CGSize)size {
  return [NSString stringWithFormat:@"ConstructionSite%dx%d.png", (int)size.width, (int)size.height];
}

+ (NSString *) imageNameForStruct:(int)structId {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:structId];
  NSString *str = [fsp.name.capitalizedString stringByReplacingOccurrencesOfString:@" " withString:@""];
  str = [str stringByReplacingOccurrencesOfString:@"'" withString:@""];
  str = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
  NSString *file = [str stringByAppendingString:@".png"];
  return file;
}

+ (NSString *) imageNameForEquip:(int)eqId {
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:eqId];
  NSString *str = [fep.name.capitalizedString stringByReplacingOccurrencesOfString:@" " withString:@""];
  str = [str stringByReplacingOccurrencesOfString:@"'" withString:@""];
  str = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
  NSString *file = [str stringByAppendingString:@".png"];
  return file;
}

+ (UIImage *) imageForStruct:(int)structId {
  return structId == 0 ? nil : [self imageNamed:[self imageNameForStruct:structId]];
}

+ (UIImage *) imageForEquip:(int)eqId {
  return eqId == 0 ? nil : [self imageNamed:[self imageNameForEquip:eqId]];
}

+ (void) loadImageForStruct:(int)structId toView:(UIImageView *)view masked:(BOOL)mask {
  [self imageNamed:[self imageNameForStruct:structId] withImageView:view maskedColor:mask ? [UIColor colorWithWhite:0.f alpha:0.7f] : nil indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
}

+ (void) loadImageForEquip:(int)equipId toView:(UIImageView *)view maskedView:(UIImageView *)maskedView {
  [self imageNamed:[self imageNameForEquip:equipId] withImageView:view maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
  //  if (maskedView) {
  //    [self imageNamed:[self imageNameForEquip:equipId] withImageView:maskedView maskedColor:[self colorForUnequippable] indicator:UIActivityIndicatorViewStyleWhite];
  //     maskedView.hidden = YES;
  //  }
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
      return [UIColor colorWithRed:236/255.f green:230/255.f blue:195/255.f alpha:1.f];
      
    case FullEquipProto_RarityUncommon:
      return [UIColor colorWithRed:160/255.f green:218/255.f blue:21/255.f alpha:1.f];
      
    case FullEquipProto_RarityRare:
      return [UIColor colorWithRed:12/255.f green:217/255.f blue:241/255.f alpha:1.f];
      
    case FullEquipProto_RarityEpic:
      return [UIColor colorWithRed:138/255.f green:0/255.f blue:255/255.f alpha:1.f];
      
    case FullEquipProto_RarityLegendary:
      return [UIColor colorWithRed:255/255.f green:102/255.f blue:0/255.f alpha:1.f];
      
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

+(PlayerClassType) playerClassTypeForUserType:(UserType)userType
{
  if (userType % 3 == 0) {
    return  WARRIOR_T;
  }
  else if (userType % 3 == 1) {
    return ARCHER_T;
  }
  return MAGE_T;
}

+ (NSString *) classForUserType:(UserType)type {
  PlayerClassType enemyClass = [Globals playerClassTypeForUserType:type];
  
  switch (enemyClass) {
    case WARRIOR_T:
      return @"Warrior";
      break;
    case ARCHER_T:
      return @"Archer";
      break;
    case MAGE_T:
      return @"Mage";
      break;
      
    default:
      break;
  }
  return nil;
}

+ (NSString *) stringForEquipClassType:(FullEquipProto_ClassType)type {
  if (type == FullEquipProto_ClassTypeWarrior) {
    return @"Warrior";
  } else if (type == FullEquipProto_ClassTypeArcher) {
    return @"Archer";
  } else if (type == FullEquipProto_ClassTypeMage) {
    return @"Mage";
  } else if (type == FullEquipProto_ClassTypeAllAmulet) {
    return @"All";
  }
  return nil;
}

+ (NSString *) stringForEquipType:(FullEquipProto_EquipType)type {
  if (type == FullEquipProto_EquipTypeWeapon) {
    return @"Weapon";
  } else if (type == FullEquipProto_EquipTypeArmor) {
    return @"Armor";
  } else if (type == FullEquipProto_EquipTypeAmulet) {
    return @"Amulet";
  }
  return nil;
}

+ (NSString *) stringForTimeSinceNow:(NSDate *)date {
  int time = -1*[date timeIntervalSinceNow];
  
  
  if (time < 0) {
    return @"In the future!";
  }
  
  int interval = 1;
  if (time < interval*60) {
    return [NSString stringWithFormat:@"%d second%@ ago", time / interval, time / interval != 1 ? @"s" : @""];
  } 
  
  interval *= 60;
  if (time < interval*60) {
    return [NSString stringWithFormat:@"%d minute%@ ago", time / interval, time / interval != 1 ? @"s" : @""];
  }
  
  interval *= 60;
  if (time < interval*24) {
    return [NSString stringWithFormat:@"%d hour%@ ago", time / interval, time / interval != 1 ? @"s" : @""];
  }
  
  interval *= 24;
  if (time < interval*7) {
    return [NSString stringWithFormat:@"%d day%@ ago", time / interval, time / interval != 1 ? @"s" : @""];
  }
  
  interval *= 7;
  if (time < interval*4) {
    return [NSString stringWithFormat:@"%d week%@ ago", time / interval, time / interval != 1 ? @"s" : @""];
  }
  
  // Approximate the size of a month to 30 days
  interval = interval/7*30;
  if (time < interval*12) {
    return [NSString stringWithFormat:@"%d month%@ ago", time / interval, time / interval != 1 ? @"s" : @""];
  }
  
  interval = interval/30*365;
  return [NSString stringWithFormat:@"%d year%@ ago", time / interval, time / interval != 1 ? @"s" : @""];
}

+ (BOOL) class:(UserType)ut canEquip:(FullEquipProto_ClassType) ct {
  return (ct == ut % 3 || ct == FullEquipProto_ClassTypeAllAmulet);
}

+ (BOOL) canEquip:(FullEquipProto *)fep {
  GameState *gs = [GameState sharedGameState];
  return fep.minLevel <= gs.level && [self class:gs.type canEquip:fep.classType]; 
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
  BOOL neg = n < 0;
  n = abs(n);
  NSString *s = [NSString stringWithFormat:@"%03d", n%1000];
  n /= 1000;
  while (n > 0) {
    s = [NSString stringWithFormat:@"%03d,%@", n%1000, s];
    n /= 1000;
  }
  
  int x = 0;
  while (x < s.length && [s characterAtIndex:x] == '0') {
    x++;
  }
  s = [s substringFromIndex:x];
  NSString *pre = neg ? @"-" : @"";
  return s.length > 0 ? [pre stringByAppendingString:s] : @"0";
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
  // Divide by 2 to account for autoreversing
  int repeatCt = duration / SHAKE_DURATION / 2;
  [animation setDuration:SHAKE_DURATION];
  [animation setRepeatCount:repeatCt];
  [animation setAutoreverses:YES];
  [animation setFromValue:[NSValue valueWithCGPoint:
                           CGPointMake(view.center.x - offset, view.center.y)]];
  [animation setToValue:[NSValue valueWithCGPoint:
                         CGPointMake(view.center.x + offset, view.center.y)]];
  [view.layer addAnimation:animation forKey:@"position"];
}

+ (void) displayUIView:(UIView *)view {
  [[[[CCDirector sharedDirector] openGLView] superview] addSubview:view];
}

+ (NSString *) pathToMap:(NSString *)mapName {
  if (!mapName) {
    return nil;
  }
  
  // prevents overloading the autorelease pool
  NSString *resName = [CCFileUtils getDoubleResolutionImage:mapName validate:NO];
  NSString *fullpath = [[NSBundle mainBundle] pathForResource:resName ofType:nil];
  
  // Added for Utopia project
  if (!fullpath) {
    // Image not in NSBundle: look in documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    fullpath = [documentsPath stringByAppendingPathComponent:resName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
      // Map not in docs: download it
      [[Downloader sharedDownloader] syncDownloadMap:fullpath.lastPathComponent];
    }
  }
  
  return fullpath;
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
      [[Downloader sharedDownloader] syncDownloadImage:fullpath.lastPathComponent];
    }
  }
  
  image = [UIImage imageWithContentsOfFile:fullpath];
  
  if (image) {
    [gl.imageCache setObject:image forKey:path];
  }
  
  return image;
}

+ (void) imageNamed:(NSString *)imageName withImageView:(UIImageView *)view maskedColor:(UIColor *)color indicator: (UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear {
  Globals *gl = [Globals sharedGlobals];
  NSString *key = [NSString stringWithFormat:@"%p", view];
  [[gl imageViewsWaitingForDownloading] removeObjectForKey:key];
  
  UIActivityIndicatorView *loadingView = (UIActivityIndicatorView *)[view viewWithTag:150];
  [loadingView stopAnimating];
  [loadingView removeFromSuperview];
  
  UIImage *cachedImage = [gl.imageCache objectForKey:imageName];
  if (cachedImage) {
    if (color) {
      cachedImage = [self maskImage:cachedImage   withColor:color];
    }
    view.image = cachedImage;
    // Do this for equip masked images
    view.hidden = NO;
    
    return;
  }
  
  NSString *resName = [CCFileUtils getDoubleResolutionImage:imageName validate:NO];
  NSString *fullpath = [[NSBundle mainBundle] pathForResource:resName ofType:nil];
  
  if (!fullpath) {
    // Image not in NSBundle: look in documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    fullpath = [documentsPath stringByAppendingPathComponent:resName];
    
//#warning change
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
      if (![view viewWithTag:150]) {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:indicatorStyle];
        loadingView.tag = 150;
        [loadingView startAnimating];
        [view addSubview:loadingView];
        [loadingView release];
        loadingView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
      }
      
      if (clear) {
        view.image = nil;
      }
      
      [[gl imageViewsWaitingForDownloading] setObject:imageName forKey:key];
      
      // Image not in docs: download it
      // Game will crash if view is released before image download completes so retain it
      [view retain];
      [[Downloader sharedDownloader] downloadImage:fullpath.lastPathComponent completion:^{
        NSString *str = [[gl imageViewsWaitingForDownloading] objectForKey:key];
        if ([str isEqualToString:imageName]) {
          NSString *resName = [CCFileUtils getDoubleResolutionImage:imageName validate:NO];
          NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
          NSString *documentsPath = [paths objectAtIndex:0];
          NSString *fullpath = [documentsPath stringByAppendingPathComponent:resName]; 
          UIImage *img = [UIImage imageWithContentsOfFile:fullpath];
          
          if (img) {
            [gl.imageCache setObject:img forKey:imageName];
          }
          if (color) {
            img = [self maskImage:img withColor:color];
          }
          
          view.image = img;
          [view release];
          view.hidden = NO;
          
          UIActivityIndicatorView *loadingView = (UIActivityIndicatorView *)[view viewWithTag:150];
          [loadingView stopAnimating];
          [loadingView removeFromSuperview];
          [[gl imageViewsWaitingForDownloading] removeObjectForKey:view];
        }
      }];
      return;
    }
  }
  
  UIImage* image = [UIImage imageWithContentsOfFile:fullpath];
  UIView *loader = [view viewWithTag:150];
  if (loader) {
    [loader removeFromSuperview];
  }
  
  if (image) {
    [gl.imageCache setObject:image forKey:imageName];
    
    if (color) {
      image = [self maskImage:image withColor:color];
    }
    
    view.image = image;
    view.hidden = NO;
  }
}

+ (void) setFrameForView:(UIView *)view forPoint:(CGPoint)pt {
  // place it so that the bottom middle is at pt
  // Remember, frame is relative to top left corner
  float width = view.frame.size.width;
  float height = view.frame.size.height;
  view.frame = CGRectMake(pt.x-width/2, ([[CCDirector sharedDirector] winSize].height - pt.y)-height, width, height);
}

+ (BOOL)userTypeIsGood:(UserType)type {
  return type < 3;
}

+ (BOOL)userTypeIsBad:(UserType)type {
  return ![self userTypeIsGood:type];
}

+ (BOOL)userType:(UserType)t1 isAlliesWith:(UserType)t2 {
  BOOL b1 = [self userTypeIsGood:t1];
  BOOL b2 = [self userTypeIsGood:t2];
  return !(b1 ^ b2);
}

+ (NSString *) nameForDialogueSpeaker:(DialogueProto_SpeechSegmentProto_DialogueSpeaker)speaker {
  switch (speaker) {
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerBadArcher:
      return @"Legion Archer";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerBadMage:
      return @"Legion Mage";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerBadWarrior:
      return @"Legion Warrior";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerGoodArcher:
      return @"Alliance Archer";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerGoodMage:
      return @"Alliance Mage";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerGoodWarrior:
      return @"Alliance Warrior";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerBadTutorialGirl:
      return @"Adriana";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerBazaar:
      return [self bazaarQuestGiverName];
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerGoodTutorialGirl:
      return @"Ruby";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerPlayerType:
      return [[GameState sharedGameState] name];
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver1:
      return @"Farmer Mitch";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver2:
      return @"Captain Riz";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver3:
      return @"Sean the Brave";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver4:
      return @"Captain Riz";
      break;
    default:
      break;
  }
}

+ (NSString *) imageNameForDialogueUserType:(UserType)type {
  switch (type) {
    case UserTypeBadArcher:
      return @"dialoguelegionarcher.png";
      break;
    case UserTypeBadMage:
      return @"dialoguelegionmage.png";
      break;
    case UserTypeBadWarrior:
      return @"dialoguewarrior.png";
      break;
    case UserTypeGoodArcher:
      return @"dialoguealliancearcher.png";
      break;
    case UserTypeGoodMage:
      return @"dialoguealliancearcher.png";
      break;
    case UserTypeGoodWarrior:
      return @"dialogueskeleton.png";
      break;
      
      
    default:
      break;
  }
}

+ (NSString *) imageNameForDialogueSpeaker:(DialogueProto_SpeechSegmentProto_DialogueSpeaker)speaker {
  switch (speaker) {
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerBadArcher:
      return [self imageNameForDialogueUserType:UserTypeBadArcher];
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerBadMage:
      return [self imageNameForDialogueUserType:UserTypeBadMage];
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerBadWarrior:
      return [self imageNameForDialogueUserType:UserTypeBadWarrior];
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerGoodArcher:
      return [self imageNameForDialogueUserType:UserTypeGoodArcher];
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerGoodMage:
      return [self imageNameForDialogueUserType:UserTypeGoodMage];
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerGoodWarrior:
      return [self imageNameForDialogueUserType:UserTypeGoodWarrior];
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerBadTutorialGirl:
      return @"dialogueadriana.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerBazaar:
      return @"dialoguemitch.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerGoodTutorialGirl:
      return @"dialogueruby.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerPlayerType:
      return [self imageNameForDialogueUserType:[[GameState sharedGameState] type]];
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver1:
      return @"@dialoguemitch.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver2:
      return @"dialogueriz.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver3:
      return @"dialoguesean.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver4:
      return @"dialogueriz.png";
      break;
    default:
      break;
  }
}

+ (UIImage *) squareImageForUser:(UserType)type {
  switch (type) {
    case UserTypeGoodWarrior:
      return [Globals imageNamed:@"warrior.png"];
      break;
      
    case UserTypeGoodArcher:
      return [Globals imageNamed:@"alarcher.png"];
      break;
      
    case UserTypeGoodMage:
      return [Globals imageNamed:@"panda.png"];
      break;
      
    case UserTypeBadWarrior:
      return [Globals imageNamed:@"skel.png"];
      break;
      
    case UserTypeBadArcher:
      return [Globals imageNamed:@"legarcher.png"];
      break;
      
    case UserTypeBadMage:
      return [Globals imageNamed:@"invoker.png"];
      break;
      
    default:
      break;
  }
}

+ (UIImage *) circleImageForUser:(UserType)type {
  switch (type) {
    case UserTypeGoodWarrior:
      return [Globals imageNamed:@"warrioricon.png"];
      break;
      
    case UserTypeGoodArcher:
      return [Globals imageNamed:@"allarchicon.png"];
      break;
      
    case UserTypeGoodMage:
      return [Globals imageNamed:@"pandaicon.png"];
      break;
      
    case UserTypeBadWarrior:
      return [Globals imageNamed:@"skelicon.png"];
      break;
      
    case UserTypeBadArcher:
      return [Globals imageNamed:@"legarchicon.png"];
      break;
      
    case UserTypeBadMage:
      return [Globals imageNamed:@"invokericon.png"];
      break;
      
    default:
      break;
  }
}

+ (UIImage *) profileImageForUser:(UserType)type {
  switch (type) {
    case UserTypeGoodWarrior:
      return [Globals imageNamed:@"pwarrior.png"];
      break;
      
    case UserTypeGoodArcher:
      return [Globals imageNamed:@"paarcher.png"];
      break;
      
    case UserTypeGoodMage:
      return [Globals imageNamed:@"ppanda.png"];
      break;
      
    case UserTypeBadWarrior:
      return [Globals imageNamed:@"pskel.png"];
      break;
      
    case UserTypeBadArcher:
      return [Globals imageNamed:@"plarcher.png"];
      break;
      
    case UserTypeBadMage:
      return [Globals imageNamed:@"pinvoker.png"];
      break;
      
    default:
      break;
  }
}

+ (NSString *) battleImageNameForUser:(UserType)type {
  switch (type) {
    case UserTypeGoodWarrior:
      return @"bwarrior.png";
      break;
      
    case UserTypeGoodArcher:
      return @"baarcher.png";
      break;
      
    case UserTypeGoodMage:
      return @"bpanda.png";
      break;
      
    case UserTypeBadWarrior:
      return @"bskel.png";
      break;
      
    case UserTypeBadArcher:
      return @"blarcher.png";
      break;
      
    case UserTypeBadMage:
      return @"binvoker.png";
      break;
      
    default:
      break;
  }
}

+ (NSString *) headshotImageNameForUser:(UserType)type {
  switch (type) {
    case UserTypeGoodWarrior:
      return @"hwarrior.png";
      break;
      
    case UserTypeGoodArcher:
      return @"haarcher.png";
      break;
      
    case UserTypeGoodMage:
      return @"hpanda.png";
      break;
      
    case UserTypeBadWarrior:
      return @"hskel.png";
      break;
      
    case UserTypeBadArcher:
      return @"hlarcher.png";
      break;
      
    case UserTypeBadMage:
      return @"hinvoker.png";
      break;
      
    default:
      break;
  }
}

+ (NSString *) spriteImageNameForUser:(UserType)type {
  switch (type) {
    case UserTypeGoodWarrior:
      return @"AllianceWarrior.png";
      break;
      
    case UserTypeGoodArcher:
      return @"AllianceArcher.png";
      break;
      
    case UserTypeGoodMage:
      return @"PandaMage.png";
      break;
      
    case UserTypeBadWarrior:
      return @"SkeletonWarrior.png";
      break;
      
    case UserTypeBadArcher:
      return @"DrowArcher.png";
      break;
      
    case UserTypeBadMage:
      return @"LegionMage.png";
      break;
      
    default:
      break;
  }
}

+ (NSString *) battleAnimationFileForUser:(UserType)type {
  switch (type) {
    case UserTypeGoodWarrior:
      return @"warrior.plist";
      break;
      
    case UserTypeGoodArcher:
      return @"aarcher.plist";
      break;
      
    case UserTypeGoodMage:
      return @"panda.plist";
      break;
      
    case UserTypeBadWarrior:
      return @"warrior.plist";
      break;
      
    case UserTypeBadArcher:
      return @"larcher.plist";
      break;
      
    case UserTypeBadMage:
      return @"invoker.plist";
      break;
      
    default:
      break;
  }
}

+ (void) playComboBarChargeupSound:(UserType)type {
  SoundEngine *se = [SoundEngine sharedSoundEngine];
  switch (type) {
    case UserTypeGoodWarrior:
    case UserTypeBadWarrior:
      [se warriorCharge];
      break;
      
    case UserTypeGoodArcher:
    case UserTypeBadArcher:
      [se archerCharge];
      break;
      
    case UserTypeGoodMage:
      [se allianceMageCharge];
      break;
      
    case UserTypeBadMage:
      [se legionMageCharge];
      break;
      
    default:
      break;
  }
}

+ (void) playBattleAttackSound:(UserType)type {
  SoundEngine *se = [SoundEngine sharedSoundEngine];
  switch (type) {
    case UserTypeGoodWarrior:
    case UserTypeBadWarrior:
      [se warriorAttack];
      break;
      
    case UserTypeGoodArcher:
    case UserTypeBadArcher:
      [se archerAttack];
      break;
      
    case UserTypeGoodMage:
      [se allianceMageAttack];
      break;
      
    case UserTypeBadMage:
      [se legionMageAttack];
      break;
      
    default:
      break;
  }
}

+ (BOOL) sellsForGoldInMarketplace:(FullEquipProto *)fep {
  return fep.rarity == FullEquipProto_RarityEpic || fep.rarity == FullEquipProto_RarityLegendary || !(fep.diamondPrice == 0);
}

// Formulas

- (int) calculateEquipSilverSellCost:(UserEquip *)ue {
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:ue.equipId];
  return fep.coinPrice * self.percentReturnedToUserForSellingEquipInArmory;
}

- (int) calculateEquipGoldSellCost:(UserEquip *)ue {
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:ue.equipId];
  return fep.diamondPrice * self.percentReturnedToUserForSellingEquipInArmory;
}

- (int) calculateIncome:(int)income level:(int)level {
  return MAX(1, income * level * self.incomeFromNormStructMultiplier);
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
  return fsp.coinPrice * self.percentReturnedToUserForSellingNormStructure;
}

- (int) calculateStructGoldSellCost:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return fsp.diamondPrice * self.percentReturnedToUserForSellingNormStructure;
}

- (int) calculateUpgradeCost:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  if (fsp.coinPrice > 0) {
    return MAX(0, (int)(fsp.coinPrice * powf(self.upgradeStructCoinCostExponentBase, us.level)));
  } else {
    return MAX(0, (int)(fsp.diamondPrice * powf(self.upgradeStructDiamondCostExponentBase, us.level)));
  }
}

- (int) calculateDiamondCostForInstaBuild:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return fsp.instaBuildDiamondCost;
}

- (int) calculateDiamondCostForInstaUpgrade:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return MAX(1,fsp.instaUpgradeDiamondCostBase * us.level * self.diamondCostForInstantUpgradeMultiplier);
}

- (int) calculateMinutesToUpgrade:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  return MAX(1, (int)(fsp.minutesToUpgradeBase * us.level * self.minutesToUpgradeForNormStructMultiplier));
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
  NSLog(@"attack %d, %d, %d, %d\n", attackStat, weapon.attackBoost, armor.attackBoost, amulet.attackBoost);
  return attackStat + weapon.attackBoost + armor.attackBoost + amulet.attackBoost;
//  GameState *gs = [GameState sharedGameState];
//  FullEquipProto *weapon = nil;
//  if (weaponId != 0) {
//    weapon = [gs equipWithId:weaponId];
//  }
//  FullEquipProto *armor = nil;
//  if (armorId != 0) {
//    armor = [gs equipWithId:armorId];
//  }
//  FullEquipProto *amulet = nil;
//  if (amuletId != 0) {
//    amulet = [gs equipWithId:amuletId];
//  }
//  
//  return self.battleWeightGivenToAttackStat*(attackStat) + self.battleWeightGivenToAttackEquipSum*(weapon.attackBoost + armor.attackBoost + amulet.attackBoost);
}

- (float) calculateDefenseForStat:(int)defenseStat weapon:(int)weaponId armor:(int)armorId amulet:(int)amuletId {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *weapon = weaponId > 0 ? [gs equipWithId:weaponId] : nil;
  FullEquipProto *armor = armorId > 0 ? [gs equipWithId:armorId] : nil;
  FullEquipProto *amulet = amuletId > 0 ? [gs equipWithId:amuletId] : nil;
  NSLog(@"defense%d, %d, %d, %d\n", defenseStat, weapon.defenseBoost, armor.defenseBoost, amulet.defenseBoost);

  return defenseStat + weapon.defenseBoost + armor.defenseBoost + amulet.defenseBoost;

//  GameState *gs = [GameState sharedGameState];
//  FullEquipProto *weapon = weaponId > 0 ? [gs equipWithId:weaponId] : nil;
//  FullEquipProto *armor = armorId > 0 ? [gs equipWithId:armorId] : nil;
//  FullEquipProto *amulet = amuletId > 0 ? [gs equipWithId:amuletId] : nil;
//  
//  return self.battleWeightGivenToDefenseStat*defenseStat + self.battleWeightGivenToDefenseEquipSum*(weapon.defenseBoost + armor.defenseBoost + amulet.defenseBoost);
}

+ (void) popupView:(UIView *)targetView
       onSuperView:(UIView *)superView
           atPoint:(CGPoint)point
withCompletionBlock:(void(^)(BOOL))completionBlock
{
  [superView addSubview:targetView];
  [superView bringSubviewToFront:targetView];

  void(^bounceBlock)(BOOL) = ^(BOOL finished) {
    void (^animationBlock)() = ^(void) {
      targetView.alpha = 0;
      CGRect newFrame = targetView.frame;
      newFrame.origin.y -= 40;
      [targetView setFrame:newFrame];
    };
    
    [UIView animateWithDuration:2.0 
                     animations:animationBlock 
                     completion:completionBlock];
  };

  [Globals bounceView:targetView 
  withCompletionBlock:bounceBlock];
}

+ (void) popupMessage: (NSString *)msg {
  //  [[[[UIAlertView alloc] initWithTitle:@"Notification" message:msg  delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] autorelease] show];
  [GenericPopupController displayViewWithText:msg title:nil];
}

#pragma mark Bounce View
+ (void) bounceView: (UIView *) view
withCompletionBlock:(void(^)(BOOL))completionBlock 
{
  view.layer.transform = CATransform3DMakeScale(0.3, 0.3, 1.0);
  
  CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
  bounceAnimation.values = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.3],
                            [NSNumber numberWithFloat:1.1],
                            [NSNumber numberWithFloat:0.95],
                            [NSNumber numberWithFloat:1.0], nil];
  
  bounceAnimation.keyTimes = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0],
                              [NSNumber numberWithFloat:0.4],
                              [NSNumber numberWithFloat:0.7],
                              [NSNumber numberWithFloat:0.9],
                              [NSNumber numberWithFloat:1.0], nil];
  
  bounceAnimation.timingFunctions = [NSArray arrayWithObjects:
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], 
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut], nil];
  
  bounceAnimation.duration = 0.5;
  [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
  
  view.layer.transform = CATransform3DIdentity;
  if (completionBlock) {
    [UIView animateWithDuration:0 delay:0.5 options:UIViewAnimationOptionTransitionNone animations:nil completion:completionBlock];
  }
}

+ (void) bounceView: (UIView *) view {
  [Globals bounceView:view withCompletionBlock:nil];
}

#pragma mark View Pulsing
+(UIImage *)roundGlowForColor:(UIColor *)glowColor
{
  UIImage *coloredImage = [Globals imageNamed:@"round_glow.png"];
  if (glowColor) {
     coloredImage = [Globals maskImage:coloredImage withColor:glowColor];
  }
  return coloredImage;
}

+ (void) pulse:(BOOL)shouldBrighten onView:(UIView *)view 
{
  // We must check if this view was signaled to stop glowing
  if ([_donePulsingViews containsObject:view.superview]) {
    [_donePulsingViews removeObject:view.superview];
    [view removeFromSuperview];

    return;
  }

  // One block either glows or fades
  void (^pulseBlock)() = ^(void) {
    view.alpha = shouldBrighten;
  };

  // The other block repeats the animation in 
  // the opposite direction
  void(^completionBlock)(BOOL) = ^(BOOL finished) {
    [self pulse:!shouldBrighten onView:view];
  };
  
  // Run the animation
  [UIView animateWithDuration:PULSE_TIME 
                        delay:0
                      options:UIViewAnimationOptionCurveEaseInOut
                   animations:pulseBlock
                   completion:completionBlock];
}

+(void)clearPulsingViews
{
  for (NSObject *curView in _pulsingViews) {
    if([curView retainCount] == 1) {
      [_pulsingViews removeObject:curView];
    }
  }
}

+(void)setupPulseAnimation {
  if(!_pulsingViews) {
    _donePulsingViews = [[NSMutableSet set] retain];
    _pulsingViews     = [[NSMutableSet set] retain];
  }
}

+(void)beginPulseForView:(UIView *)view andColor:(UIColor *)glowColor {

  [Globals setupPulseAnimation];
  [Globals clearPulsingViews];

  UIImageView *glow = [[UIImageView alloc] 
                       initWithImage:[Globals roundGlowForColor:glowColor]];
  CGRect frame = view.frame;
  frame.origin.x = 0;
  frame.origin.y = 0;
  [glow setFrame:frame];
  [view addSubview:glow];
  [view bringSubviewToFront:glow];

  [_pulsingViews addObject:view];
  [self pulse:0 onView:glow];
}

+(void)endPulseForView:(UIView *)view {
  [Globals setupPulseAnimation];

  if ([_pulsingViews    containsObject:view]) {
    [_donePulsingViews  addObject:view];
    [_pulsingViews      removeObject:view];
  }
}

+ (void) bounceView:(UIView *)view fadeInBgdView: (UIView *)bgdView {
  view.alpha = 0;
  bgdView.alpha = 0;
  [UIView animateWithDuration:0.15 animations:^{
    view.alpha = 1.0;
    bgdView.alpha = 1.f;
  }];
  [self bounceView:view];
}

+ (void) popOutView:(UIView *)view fadeOutBgdView:(UIView *)bgdView completion:(void (^)(void))completed {
  [UIView animateWithDuration:0.3 animations:^{
    view.alpha = 0.f;
    bgdView.alpha = 0.f;
    view.transform = CGAffineTransformMakeScale(2.0, 2.0);
  } completion:^(BOOL finished) {
    if (finished) {
      view.transform = CGAffineTransformIdentity;
      if (completed) {
        completed();
      }
    }
  }];
}

#pragma mark Colors
+ (UIColor *)creamColor {
  return [UIColor colorWithRed:236/255.f green:230/255.f blue:195/255.f alpha:1.f];
}

+ (UIColor *)goldColor {
  return [UIColor colorWithRed:255/255.f green:200/255.f blue:0/255.f alpha:1.f];
}

+ (UIColor *)greenColor {
  return [UIColor colorWithRed:156/255.f green:202/255.f blue:16/255.f alpha:1.f];
}

+ (UIColor *)orangeColor {
  return [UIColor colorWithRed:255/255.f green:102/255.f blue:0/255.f alpha:1.f];
}

+ (UIColor *)redColor {
  return [UIColor colorWithRed:255/255.f green:0/255.f blue:0/255.f alpha:1.f];
}

+ (GameMap *)mapForQuest:(FullQuestProto *)fqp {
  if (fqp.cityId > 0) {
    GameLayer *gLay = [GameLayer sharedGameLayer];
    if (gLay.currentCity == fqp.cityId) {
      return (GameMap *)[gLay missionMap];
    } else {
      return nil;
    }
  } else {
    if (fqp.assetNumWithinCity == 1) {
      return [HomeMap sharedHomeMap];
    } else if (fqp.assetNumWithinCity == 2) {
      return [BazaarMap sharedBazaarMap];
    }
  }
  return nil;
}

+ (NSString *) bazaarQuestGiverName {
  return @"Bizzaro Byrone";
}

+ (NSString *) homeQuestGiverName {
  GameState *gs = [GameState sharedGameState];
  
  if ([self userTypeIsGood:gs.type]) {
    return @"Ruby";
  } else {
    return @"Adriana";
  }
}

#define ARROW_ANIMATION_DURATION 0.5f
#define ARROW_ANIMATION_DISTANCE 14
+ (void) animateUIArrow:(UIView *)arrow atAngle:(float)angle {
  [arrow.layer removeAllAnimations];
  float rotation = -M_PI_2-angle;
  arrow.layer.transform = CATransform3DMakeRotation(rotation, 0.0f, 0.0f, 1.0f);
  arrow.layer.transform = CATransform3DScale(arrow.layer.transform, 1.f, 0.9f, 1.f);
  UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
  [UIView animateWithDuration:ARROW_ANIMATION_DURATION delay:0.f options:opt animations:^{
    arrow.layer.transform = CATransform3DMakeRotation(rotation, 0.0f, 0.0f, 1.0f);
    arrow.center = CGPointMake(arrow.center.x-ARROW_ANIMATION_DISTANCE*cosf(angle), arrow.center.y+ARROW_ANIMATION_DISTANCE*sinf(angle));
  } completion:nil];
}

+ (void) animateCCArrow:(CCNode *)arrow atAngle:(float)angle {
  [arrow stopAllActions];
  arrow.rotation = CC_RADIANS_TO_DEGREES(-M_PI_2-angle);
  
  CCMoveBy *upAction = [CCEaseSineInOut actionWithAction:[CCSpawn actions:
                                                          [CCMoveTo actionWithDuration:ARROW_ANIMATION_DURATION position:ccpAdd(arrow.position, ccp(-ARROW_ANIMATION_DISTANCE*cosf(angle), -ARROW_ANIMATION_DISTANCE*sinf(angle)))],
                                                          [CCScaleTo actionWithDuration:ARROW_ANIMATION_DURATION scaleX:1.f scaleY:1.f],
                                                          nil]];
  CCMoveBy *downAction = [CCEaseSineInOut actionWithAction:[CCSpawn actions:
                                                          [CCMoveTo actionWithDuration:ARROW_ANIMATION_DURATION position:arrow.position],
                                                          [CCScaleTo actionWithDuration:ARROW_ANIMATION_DURATION scaleX:1.f scaleY:0.9f],
                                                          nil]];
  [arrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, downAction, nil]]];
}

- (void) dealloc {
  self.productIdentifiers = nil;
  self.imageCache = nil;
  self.imageViewsWaitingForDownloading = nil;
  [super dealloc];
}

@end
