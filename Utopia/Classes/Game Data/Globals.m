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
#import "Downloader.h"
#import "GenericPopupController.h"

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
@synthesize maxRepeatedNormStructs;
@synthesize productIdentifiers;
@synthesize imageCache, imageViewsWaitingForDownloading;
@synthesize armoryXLength, armoryYLength, carpenterXLength, carpenterYLength, aviaryXLength;
@synthesize aviaryYLength, marketplaceXLength, marketplaceYLength, vaultXLength, vaultYLength;
@synthesize minLevelForVault, minLevelForArmory, minLevelForMarketplace;
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
  [self imageNamed:[self imageNameForStruct:structId] withImageView:view maskedColor:mask ? [UIColor colorWithWhite:0.f alpha:0.7f] : nil indicator:UIActivityIndicatorViewStyleGray];
}

+ (void) loadImageForEquip:(int)equipId toView:(UIImageView *)view maskedView:(UIImageView *)maskedView {
  [self imageNamed:[self imageNameForEquip:equipId] withImageView:view maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite];
  
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

+ (void) imageNamed:(NSString *)imageName withImageView:(UIImageView *)view maskedColor:(UIColor *)color indicator: (UIActivityIndicatorViewStyle)indicatorStyle {
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
  
  // prevents overloading the autorelease pool
  NSString *resName = [CCFileUtils getDoubleResolutionImage:imageName validate:NO];
  NSString *fullpath = [[NSBundle mainBundle] pathForResource:resName ofType:nil];
  
  // Added for Utopia project
  if (!fullpath) {
    // Image not in NSBundle: look in documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    fullpath = [documentsPath stringByAppendingPathComponent:resName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
      if (![view viewWithTag:150]) {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:indicatorStyle];
        loadingView.tag = 150;
        [loadingView startAnimating];
        [view addSubview:loadingView];
        [loadingView release];
        loadingView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
      }
      view.image = nil;
      
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

+ (BOOL)userTypeIsGood:(UserType)type {
  return type < 3;
}

+ (BOOL)userTypeIsBad:(UserType)type {
  return ![self userTypeIsGood:type];
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

+ (NSString *) comboBarChargeupSound:(UserType)type {
  switch (type) {
    case UserTypeGoodWarrior:
    case UserTypeBadWarrior:
      return @"Warrior_Combo.m4a";
      break;
      
    case UserTypeGoodArcher:
    case UserTypeBadArcher:
      return @"Archer_Combo.m4a";
      break;
      
    case UserTypeGoodMage:
      return @"Panda_Combo.m4a";
      break;
      
    case UserTypeBadMage:
      return @"Invoker_Combo.m4a";
      break;
      
    default:
      break;
  }
}

+ (NSString *) battleAttackSound:(UserType)type {
  switch (type) {
    case UserTypeGoodWarrior:
    case UserTypeBadWarrior:
      return @"Warrior_Attack.m4a";
      break;
      
    case UserTypeGoodArcher:
    case UserTypeBadArcher:
      return @"Archer_Attack.m4a";
      break;
      
    case UserTypeGoodMage:
      return @"Panda_Attack.m4a";
      break;
      
    case UserTypeBadMage:
      return @"Invoker_Attack.m4a";
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
  return income * level * self.incomeFromNormStructMultiplier;
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
  
  return self.battleWeightGivenToAttackStat*(attackStat) + self.battleWeightGivenToAttackEquipSum*(weapon.attackBoost + armor.attackBoost + amulet.attackBoost);
}

- (float) calculateDefenseForStat:(int)defenseStat weapon:(int)weaponId armor:(int)armorId amulet:(int)amuletId {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *weapon = weaponId > 0 ? [gs equipWithId:weaponId] : nil;
  FullEquipProto *armor = armorId > 0 ? [gs equipWithId:armorId] : nil;
  FullEquipProto *amulet = amuletId > 0 ? [gs equipWithId:amuletId] : nil;
  
  return self.battleWeightGivenToDefenseStat*defenseStat + self.battleWeightGivenToDefenseEquipSum*(weapon.defenseBoost + armor.defenseBoost + amulet.defenseBoost);
}

+ (void) popupMessage: (NSString *)msg {
  //  [[[[UIAlertView alloc] initWithTitle:@"Notification" message:msg  delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] autorelease] show];
  [GenericPopupController displayViewWithText:msg title:nil];
}

+ (void) bounceView: (UIView *) view {
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
    view.transform = CGAffineTransformIdentity;
    if (completed) {
      completed();
    }
  }];
}

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

- (void) dealloc {
  self.productIdentifiers = nil;
  self.imageCache = nil;
  self.imageViewsWaitingForDownloading = nil;
  [super dealloc];
}

@end