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
#import "OutgoingEventController.h"
#import "GameViewController.h"

#define FONT_LABEL_OFFSET 3.f
#define SHAKE_DURATION 0.05f
#define PULSE_TIME 0.8f

#define BUNDLE_SCHEDULE_INTERVAL 30

@implementation Globals

static NSString *fontName = @"AJensonPro-BoldCapt";
static int fontSize = 12;

static NSString *structureImageString = @"struct%d.png";
static NSString *equipImageString = @"equip%d.png";
static NSMutableSet *_donePulsingViews;
static NSMutableSet *_pulsingViews;

@synthesize depositPercentCut;
@synthesize clericLevelFactor, clericHealthFactor;
@synthesize attackBaseGain, defenseBaseGain, energyBaseGain, staminaBaseGain;
@synthesize attackBaseCost, defenseBaseCost, energyBaseCost, staminaBaseCost;
@synthesize retractPercentCut, purchasePercentCut;
@synthesize energyRefillWaitMinutes, staminaRefillWaitMinutes;
@synthesize energyRefillCost, staminaRefillCost;
@synthesize maxRepeatedNormStructs;
@synthesize imageCache, imageViewsWaitingForDownloading;
@synthesize armoryXLength, armoryYLength, carpenterXLength, carpenterYLength, aviaryXLength;
@synthesize aviaryYLength, marketplaceXLength, marketplaceYLength, vaultXLength, vaultYLength;
@synthesize diamondCostOfShortMarketplaceLicense, diamondCostOfLongMarketplaceLicense;
@synthesize cutOfVaultDepositTaken, skillPointsGainedOnLevelup, percentReturnedToUserForSellingEquipInArmory;
@synthesize percentReturnedToUserForSellingNormStructure, numDaysLongMarketplaceLicenseLastsFor;
@synthesize maxCityRank, sizeOfAttackList;
@synthesize maxLevelForStruct, maxNumbersOfEnemiesToGenerateAtOnce, maxLevelDiffForBattle;
@synthesize maxNumberOfMarketplacePosts, numDaysShortMarketplaceLicenseLastsFor;
@synthesize diamondRewardForReferrer;
@synthesize incomeFromNormStructMultiplier, minutesToUpgradeForNormStructMultiplier;
@synthesize diamondCostForInstantUpgradeMultiplier, upgradeStructCoinCostExponentBase;
@synthesize upgradeStructDiamondCostExponentBase;
@synthesize locationBarMax;
@synthesize minNameLength, maxNameLength;
@synthesize animatingSpriteOffsets;
@synthesize kiipRewardConditions;
@synthesize battleGoodMultiplier, battleGreatMultiplier;
@synthesize battlePerfectMultiplier, battleGoodPercentThreshold, battleGreatPercentThreshold;
@synthesize battlePerfectPercentThreshold;
@synthesize perfectLikelihood, greatLikelihood, missLikelihood, goodLikelihood;
@synthesize forgeMaxEquipLevel, forgeBaseMinutesToOneGold, forgeMinDiamondCostForGuarantee;
@synthesize forgeTimeBaseForExponentialMultiplier, forgeDiamondCostForGuaranteeExponentialMultiplier;
@synthesize levelEquipBoostExponentBase;
@synthesize averageSizeOfLevelBracket, healthFormulaExponentBase;
@synthesize battlePercentOfArmor, battlePercentOfAmulet, battlePercentOfWeapon;
@synthesize battlePercentOfPlayerStats, battleAttackExpoMultiplier;
@synthesize battleHitAttackerPercentOfHealth, battleHitDefenderPercentOfHealth;
@synthesize battlePercentOfEquipment, battleIndividualEquipAttackCap;
@synthesize battleEquipAndStatsWeight;
@synthesize maxLevelForUser;
@synthesize adColonyVideosRequiredToRedeemGold;
@synthesize diamondCostToChangeName, diamondCostToResetCharacter, diamondCostToResetSkillPoints, diamondCostToChangeCharacterType;
@synthesize maxNumTimesAttackedByOneInProtectionPeriod, hoursInAttackedByOneProtectionPeriod;
@synthesize minBattlesRequiredForKDRConsideration;
@synthesize maxLengthOfChatString, diamondPriceForGroupChatPurchasePackage, numChatsGivenPerGroupChatPurchasePackage;
@synthesize diamondPriceToCreateClan, maxCharLengthForClanName, maxCharLengthForClanDescription;
@synthesize maxCharLengthForClanTag;
@synthesize maxCharLengthForWallPost;
@synthesize goldAmountFromGoldminePickup, goldCostForGoldmineRestart, numHoursBeforeGoldmineRetrieval, numHoursForGoldminePickup;
@synthesize freeChanceToPickLockBox, goldChanceToPickLockBox, goldCostToPickLockBox, goldCostToResetPickLockBox;
@synthesize numMinutesToRepickLockBox, silverChanceToPickLockBox, silverCostToPickLockBox;
@synthesize expansionPurchaseCostConstant, expansionPurchaseCostExponentBase, expansionWaitCompleteBaseMinutesToOneGold;
@synthesize expansionWaitCompleteHourConstant, expansionWaitCompleteHourIncrementBase;
@synthesize diamondCostToPlayThreeCardMonte, minLevelToDisplayThreeCardMonte;
@synthesize downloadableNibConstants;
@synthesize numHoursBeforeReshowingGoldSale, numHoursBeforeReshowingLockBox;
@synthesize reviewPageURL, reviewPageConfirmationMessage, levelToShowRateUsPopup;
@synthesize numDaysUntilFreeRetract;

SYNTHESIZE_SINGLETON_FOR_CLASS(Globals);

- (id) init {
  if ((self = [super init])) {
    attackBaseCost = 1;
    defenseBaseCost = 1;
    energyBaseCost = 1;
    staminaBaseCost = 2;
    
    attackBaseGain = 1;
    defenseBaseGain = 1;
    energyBaseGain = 1;
    staminaBaseGain = 1;
    
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
    animatingSpriteOffsets = [[NSMutableDictionary alloc] init];
    
    self.downloadableNibConstants =
    [[[[[[[[[[StartupResponseProto_StartupConstants_DownloadableNibConstants builder]
             setGoldMineNibName:@"GoldMine.2"]
            setLockBoxNibName:@"LockBox.2"]
           setMapNibName:@"TravelingMap.2"]
          setThreeCardMonteNibName:@"ThreeCardMonte.2"]
         setExpansionNibName:@"Expansion.2"]
        setFiltersNibName:@"MarketplaceFilters.2"]
       setBlacksmithNibName:@"Blacksmith.2"]
      setGoldShoppeNibName:@"GoldShoppe.2"]
     build];
    
  }
  return self;
}

- (void) updateConstants:(StartupResponseProto_StartupConstants *)constants {
  if (constants.inAppPurchasePackagesList.count > 0) {
    self.iapPackages = constants.inAppPurchasePackagesList;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (InAppPurchasePackageProto *pkg in self.iapPackages) {
      [dict setObject:pkg forKey:pkg.packageId];
    }
    
    GameState *gs = [GameState sharedGameState];
    for (GoldSaleProto *p in gs.staticGoldSales) {
      if (self.iapPackages.count > 0) {
        if (p.hasPackage1SaleIdentifier)  [dict setObject:[self.iapPackages objectAtIndex:0] forKey:p.package1SaleIdentifier];
        if (p.hasPackage2SaleIdentifier)  [dict setObject:[self.iapPackages objectAtIndex:2] forKey:p.package2SaleIdentifier];
        if (p.hasPackage3SaleIdentifier)  [dict setObject:[self.iapPackages objectAtIndex:4] forKey:p.package3SaleIdentifier];
        if (p.hasPackage4SaleIdentifier)  [dict setObject:[self.iapPackages objectAtIndex:6] forKey:p.package4SaleIdentifier];
        if (p.hasPackage5SaleIdentifier)  [dict setObject:[self.iapPackages objectAtIndex:8] forKey:p.package5SaleIdentifier];
        if (p.hasPackageS1SaleIdentifier) [dict setObject:[self.iapPackages objectAtIndex:1] forKey:p.packageS1SaleIdentifier];
        if (p.hasPackageS2SaleIdentifier) [dict setObject:[self.iapPackages objectAtIndex:3] forKey:p.packageS2SaleIdentifier];
        if (p.hasPackageS3SaleIdentifier) [dict setObject:[self.iapPackages objectAtIndex:5] forKey:p.packageS3SaleIdentifier];
        if (p.hasPackageS4SaleIdentifier) [dict setObject:[self.iapPackages objectAtIndex:7] forKey:p.packageS4SaleIdentifier];
        if (p.hasPackageS5SaleIdentifier) [dict setObject:[self.iapPackages objectAtIndex:9] forKey:p.packageS5SaleIdentifier];
      }
    }
    self.productIdsToPackages = dict;
  } else {
    NSMutableArray *pkgs = [NSMutableArray array];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (int i = 0; i < constants.productIdsList.count && i < constants.productDiamondsGivenList.count; i++) {
      InAppPurchasePackageProto_Builder *iap = [InAppPurchasePackageProto builder];
      iap.isGold = YES;
      iap.imageName = @"stack.png";
      iap.packageId = [constants.productIdsList objectAtIndex:i];
      iap.currencyAmount = [[constants.productDiamondsGivenList objectAtIndex:i] intValue];
      InAppPurchasePackageProto *pkg = [iap build];
      [pkgs addObject:pkg];
      [dict setObject:pkg forKey:pkg.packageId];
    }
    self.iapPackages = pkgs;
    
    GameState *gs = [GameState sharedGameState];
    for (GoldSaleProto *p in gs.staticGoldSales) {
      if (self.iapPackages.count > 0) {
        if (p.hasPackage1SaleIdentifier)  [dict setObject:[self.iapPackages objectAtIndex:0] forKey:p.package1SaleIdentifier];
        if (p.hasPackage2SaleIdentifier)  [dict setObject:[self.iapPackages objectAtIndex:1] forKey:p.package2SaleIdentifier];
        if (p.hasPackage3SaleIdentifier)  [dict setObject:[self.iapPackages objectAtIndex:2] forKey:p.package3SaleIdentifier];
        if (p.hasPackage4SaleIdentifier)  [dict setObject:[self.iapPackages objectAtIndex:3] forKey:p.package4SaleIdentifier];
        if (p.hasPackage5SaleIdentifier)  [dict setObject:[self.iapPackages objectAtIndex:4] forKey:p.package5SaleIdentifier];
      }
    }
    
    self.productIdsToPackages = dict;
  }
  [[IAPHelper sharedIAPHelper] requestProducts];
  
  self.maxLevelDiffForBattle = constants.maxLevelDifferenceForBattle;
  self.maxLevelForUser = constants.maxLevelForUser;
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
  self.staminaBaseGain = constants.staminaBaseGain;
  self.staminaBaseCost = constants.staminaBaseCost;
  self.skillPointsGainedOnLevelup = constants.skillPointsGainedOnLevelup;
  self.cutOfVaultDepositTaken = constants.cutOfVaultDepositTaken;
  self.maxLevelForStruct = constants.maxLevelForStruct;
  self.maxRepeatedNormStructs = constants.maxNumOfSingleStruct;
  self.percentReturnedToUserForSellingEquipInArmory = constants.percentReturnedToUserForSellingEquipInArmory;
  self.percentReturnedToUserForSellingNormStructure = constants.percentReturnedToUserForSellingNormStructure;
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
  self.adColonyVideosRequiredToRedeemGold = constants.adColonyVideosRequiredToRedeemDiamonds;
  self.minNameLength = constants.minNameLength;
  self.maxNameLength = constants.maxNameLength;
  self.maxCityRank = constants.maxCityRank;
  self.sizeOfAttackList = constants.sizeOfAttackList;
  self.maxNumTimesAttackedByOneInProtectionPeriod = constants.maxNumTimesAttackedByOneInProtectionPeriod;
  self.hoursInAttackedByOneProtectionPeriod = constants.hoursInAttackedByOneProtectionPeriod;
  self.minBattlesRequiredForKDRConsideration = constants.minBattlesRequiredForKdrconsideration;
  self.maxLengthOfChatString = constants.maxLengthOfChatString;
  self.diamondPriceForGroupChatPurchasePackage = constants.diamondPriceForGroupChatPurchasePackage;
  self.numChatsGivenPerGroupChatPurchasePackage = constants.numChatsGivenPerGroupChatPurchasePackage;
  self.maxCharLengthForWallPost = constants.maxCharLengthForWallPost;
  self.numHoursBeforeReshowingGoldSale = constants.numHoursBeforeReshowingGoldSale;
  self.numHoursBeforeReshowingLockBox = constants.numHoursBeforeReshowingLockBox;
  self.numHoursBeforeReshowingBossEvent = constants.numHoursBeforeReshowingBossEvent;
  self.numDaysUntilFreeRetract = constants.numDaysUntilFreeRetract;
  self.levelToShowRateUsPopup = constants.levelToShowRateUsPopup;
  self.bossNumAttacksTillSuperAttack = constants.bossEventNumberOfAttacksUntilSuperAttack;
  self.initStamina = constants.initStamina;
  self.minClanMembersToHoldClanTower = constants.minClanMembersToHoldClanTower;
  self.useOldBattleFormula = constants.useOldBattleFormula;
  self.questIdForFirstLossTutorial = constants.questIdForFirstLossTutorial;
  self.questIdsGuaranteedWin = constants.questIdsGuaranteedWinList;
  self.fbConnectRewardDiamonds = constants.fbConnectRewardDiamonds;
  self.minLevelForPrestige = constants.minLevelForPrestige;
  
  self.minutesToUpgradeForNormStructMultiplier = constants.formulaConstants.minutesToUpgradeForNormStructMultiplier;
  self.incomeFromNormStructMultiplier = constants.formulaConstants.incomeFromNormStructMultiplier;
  self.upgradeStructCoinCostExponentBase = constants.formulaConstants.upgradeStructCoinCostExponentBase;
  self.upgradeStructDiamondCostExponentBase = constants.formulaConstants.upgradeStructDiamondCostExponentBase;
  self.diamondCostForInstantUpgradeMultiplier = constants.formulaConstants.diamondCostForInstantUpgradeMultiplier;
  
  self.battleAttackExpoMultiplier = constants.battleConstants.battleAttackExpoMultiplier;
  self.battlePercentOfWeapon = constants.battleConstants.battlePercentOfWeapon;
  self.battlePercentOfArmor = constants.battleConstants.battlePercentOfArmor;
  self.battlePercentOfPlayerStats = constants.battleConstants.battlePercentOfPlayerStats;
  self.battlePercentOfEquipment = constants.battleConstants.battlePercentOfEquipment;
  self.battleIndividualEquipAttackCap = constants.battleConstants.battleIndividualEquipAttackCap;
  self.battlePercentOfAmulet = constants.battleConstants.battlePercentOfAmulet;
  self.battleHitAttackerPercentOfHealth = constants.battleConstants.battleHitAttackerPercentOfHealth;
  self.battleHitDefenderPercentOfHealth = constants.battleConstants.battleHitDefenderPercentOfHealth;
  self.battlePerfectPercentThreshold = constants.battleConstants.battlePerfectPercentThreshold;
  self.battleGreatPercentThreshold = constants.battleConstants.battleGreatPercentThreshold;
  self.battleGoodPercentThreshold = constants.battleConstants.battleGoodPercentThreshold;
  self.battlePerfectMultiplier = constants.battleConstants.battlePerfectMultiplier;
  self.battleGreatMultiplier = constants.battleConstants.battleGreatMultiplier;
  self.battleGoodMultiplier = constants.battleConstants.battleGoodMultiplier;
  self.perfectLikelihood = constants.battleConstants.battlePerfectLikelihood;
  self.greatLikelihood = constants.battleConstants.battleGreatLikelihood;
  self.goodLikelihood = constants.battleConstants.battleGoodLikelihood;
  self.missLikelihood = constants.battleConstants.battleMissLikelihood;
  self.battleEquipAndStatsWeight = constants.battleConstants.battleEquipAndStatsWeight;
  
  self.forgeBaseMinutesToOneGold = constants.forgeConstants.forgeBaseMinutesToOneGold;
  self.forgeDiamondCostForGuaranteeExponentialMultiplier = constants.forgeConstants.forgeDiamondCostForGuaranteeExponentialMultiplier;
  self.forgeMaxEquipLevel = constants.forgeConstants.forgeMaxEquipLevel;
  self.forgeMinDiamondCostForGuarantee = constants.forgeConstants.forgeMinDiamondCostForGuarantee;
  self.forgeTimeBaseForExponentialMultiplier = constants.forgeConstants.forgeTimeBaseForExponentialMultiplier;
  self.levelEquipBoostExponentBase = constants.levelEquipBoostExponentBase;
  self.averageSizeOfLevelBracket = constants.averageSizeOfLevelBracket;
  self.healthFormulaExponentBase = constants.healthFormulaExponentBase;
  self.forgeMaxForgeSlots = constants.forgeConstants.forgeMaxForgeSlots;
  
  self.diamondCostToResetCharacter = constants.charModConstants.diamondCostToResetCharacter;
  self.diamondCostToChangeName = constants.charModConstants.diamondCostToChangeName;
  self.diamondCostToResetSkillPoints = constants.charModConstants.diamondCostToResetSkillPoints;
  self.diamondCostToChangeCharacterType = constants.charModConstants.diamondCostToChangeCharacterType;
  
  self.diamondPriceToCreateClan = constants.clanConstants.diamondPriceToCreateClan;
  self.maxCharLengthForClanName = constants.clanConstants.maxCharLengthForClanName;
  self.maxCharLengthForClanDescription = constants.clanConstants.maxCharLengthForClanDescription;
  self.maxCharLengthForClanTag = constants.clanConstants.maxCharLengthForClanTag;
  
  self.goldCostForGoldmineRestart = constants.goldmineConstants.goldCostForGoldmineRestart;
  self.goldAmountFromGoldminePickup = constants.goldmineConstants.goldAmountFromGoldminePickup;
  self.numHoursForGoldminePickup = constants.goldmineConstants.numHoursForGoldminePickup;
  self.numHoursBeforeGoldmineRetrieval = constants.goldmineConstants.numHoursBeforeGoldmineRetrieval;
  
  self.goldChanceToPickLockBox = constants.lockBoxConstants.goldChanceToPickLockBox;
  self.silverCostToPickLockBox = constants.lockBoxConstants.silverCostToPickLockBox;
  self.goldCostToPickLockBox = constants.lockBoxConstants.goldCostToPickLockBox;
  self.silverChanceToPickLockBox = constants.lockBoxConstants.silverChanceToPickLockBox;
  self.freeChanceToPickLockBox = constants.lockBoxConstants.freeChanceToPickLockBox;
  self.numMinutesToRepickLockBox = constants.lockBoxConstants.numMinutesToRepickLockBox;
  self.goldCostToResetPickLockBox = constants.lockBoxConstants.goldCostToResetPickLockBox;
  
  self.expansionPurchaseCostConstant = constants.expansionConstants.expansionPurchaseCostConstant;
  self.expansionPurchaseCostExponentBase = constants.expansionConstants.expansionPurchaseCostExponentBase;
  self.expansionWaitCompleteBaseMinutesToOneGold = constants.expansionConstants.expansionWaitCompleteBaseMinutesToOneGold;
  self.expansionWaitCompleteHourConstant = constants.expansionConstants.expansionWaitCompleteHourConstant;
  self.expansionWaitCompleteHourIncrementBase = constants.expansionConstants.expansionWaitCompleteHourIncrementBase;
  
  self.diamondCostToPlayThreeCardMonte = constants.threeCardMonteConstants.diamondCostToPlayThreeCardMonte;
  self.minLevelToDisplayThreeCardMonte = constants.threeCardMonteConstants.minLevelToDisplayThreeCardMonte;
  self.badMonteCardPercentageChance = constants.threeCardMonteConstants.badMonteCardPercentageChance;
  self.mediumMonteCardPercentageChance = constants.threeCardMonteConstants.mediumMonteCardPercentageChance;
  self.goodMonteCardPercentageChance = constants.threeCardMonteConstants.goodMonteCardPercentageChance;
  
  self.tournamentWinsWeight = constants.leaderboardConstants.winsWeight;
  self.tournamentLossesWeight = constants.leaderboardConstants.lossesWeight;
  self.tournamentFleesWeight = constants.leaderboardConstants.fleesWeight;
  self.tournamentNumHrsToDisplayAfterEnd = constants.leaderboardConstants.numHoursToShowAfterEventEnd;
  
  self.maxEnhancementLevel = constants.enhanceConstants.maxEnhancementLevel;
  self.enhancePercentPerLevel = constants.enhanceConstants.enhancePercentPerLevel;
  self.enhanceTimeConstantA = constants.enhanceConstants.enhanceTimeConstantA;
  self.enhanceTimeConstantB = constants.enhanceConstants.enhanceTimeConstantB;
  self.enhanceTimeConstantC = constants.enhanceConstants.enhanceTimeConstantC;
  self.enhanceTimeConstantD = constants.enhanceConstants.enhanceTimeConstantD;
  self.enhanceTimeConstantE = constants.enhanceConstants.enhanceTimeConstantE;
  self.enhanceTimeConstantF = constants.enhanceConstants.enhanceTimeConstantF;
  self.enhanceTimeConstantG = constants.enhanceConstants.enhanceTimeConstantG;
  self.enhancePercentConstantA = constants.enhanceConstants.enhancePercentConstantA;
  self.enhancePercentConstantB = constants.enhanceConstants.enhancePercentConstantB;
  self.enhanceLevelExponentBase = constants.enhanceConstants.enhanceLevelExponentBase;
  
  self.purchaseOptionOneNumBoosterItems = constants.boosterPackConstants.purchaseOptionOneNumBoosterItems;
  self.purchaseOptionTwoNumBoosterItems = constants.boosterPackConstants.purchaseOptionTwoNumBoosterItems;
  self.infoImageName = constants.boosterPackConstants.infoImageName;
  self.numDaysToBuyStarterPack = constants.boosterPackConstants.numDaysToBuyStarterPack;
  self.numTimesToBuyStarterPack = constants.boosterPackConstants.numTimesToBuyStarterPack;
  
  self.locationBarMax = constants.battleConstants.locationBarMax;
  
  self.kiipRewardConditions = constants.kiipRewardConditions;
  
  if (constants.hasDownloadableNibConstants) {
    StartupResponseProto_StartupConstants_DownloadableNibConstants_Builder *b = [StartupResponseProto_StartupConstants_DownloadableNibConstants builderWithPrototype:self.downloadableNibConstants];
    [b mergeFrom:constants.downloadableNibConstants];
    self.downloadableNibConstants = [b build];
  }
  
  self.minLevelConstants = constants.minLevelConstants;
  
  for (StartupResponseProto_StartupConstants_AnimatedSpriteOffsetProto *aso in constants.animatedSpriteOffsetsList) {
    [self.animatingSpriteOffsets setObject:aso.offSet forKey:aso.imageName];
  }
}

+ (void) asyncDownloadBundles {
  Globals *gl = [Globals sharedGlobals];
  StartupResponseProto_StartupConstants_DownloadableNibConstants *n = gl.downloadableNibConstants;
  NSArray *bundleNames = [NSArray arrayWithObjects:n.goldShoppeNibName, n.blacksmithNibName, n.filtersNibName, n.mapNibName, n.threeCardMonteNibName, n.expansionNibName, n.lockBoxNibName, nil];
  Downloader *dl = [Downloader sharedDownloader];
  
  int i = BUNDLE_SCHEDULE_INTERVAL;
  for (NSString *name in bundleNames) {
    if (![self bundleExists:name]) {
      [dl performSelector:@selector(asyncDownloadBundle:) withObject:name afterDelay:i];
      LNLog(@"Scheduled download of bundle %@ in %d seconds", name, i);
      i += BUNDLE_SCHEDULE_INTERVAL;
    }
  }
  
  [self imageNamed:gl.infoImageName withView:nil maskedColor:nil indicator:UIActivityIndicatorViewStyleGray clearImageDuringDownload:YES];
}

+ (NSString *) font {
  return fontName;
}

+ (int) fontSize {
  return fontSize;
}

+ (NSString *) convertTimeToString:(int)secs withDays:(BOOL)withDays {
  if (secs < 0) {
    return @"00:00:00";
  }
  
  int days = 0;
  
  if (withDays) {
    days = secs / 86400;
    secs %= 86400;
  }
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

+ (void) loadImageForStruct:(int)structId toView:(UIImageView *)view masked:(BOOL)mask indicator:(UIActivityIndicatorViewStyle)indicator {
  if (!structId || !view) return;
  [self imageNamed:[self imageNameForStruct:structId] withView:view maskedColor:mask ? [UIColor colorWithWhite:0.f alpha:0.7f] : nil indicator:indicator clearImageDuringDownload:YES];
}

+ (void) loadImageForEquip:(int)equipId toView:(UIImageView *)view maskedView:(UIImageView *)maskedView {
  if (!equipId || !view) {
    view.image = nil;
    return;
  }
  [self imageNamed:[self imageNameForEquip:equipId] withView:view maskedColor:nil indicator:UIActivityIndicatorViewStyleWhite clearImageDuringDownload:YES];
  
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
      return [self creamColor];
      
    case FullEquipProto_RarityUncommon:
      return [self greenColor];
      
    case FullEquipProto_RarityRare:
      return [self blueColor];
      
    case FullEquipProto_RaritySuperrare:
      return [self goldColor];
      
    case FullEquipProto_RarityEpic:
      return [self purpleColor];
      
    case FullEquipProto_RarityLegendary:
      return [self redColor];
      
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
      
    case FullEquipProto_RaritySuperrare:
      return @"Super Rare";
      
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
  
  if (rarity == FullEquipProto_RaritySuperrare) {
    return @"S. RA";
  }
  
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

+ (NSString *) stringForEquipClassType:(EquipClassType)type {
  if (type == EquipClassTypeWarrior) {
    return @"Warrior";
  } else if (type == EquipClassTypeArcher) {
    return @"Archer";
  } else if (type == EquipClassTypeMage) {
    return @"Mage";
  } else if (type == EquipClassTypeAllAmulet) {
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

+ (NSString *) shortenedStringForEquipType:(FullEquipProto_EquipType)type {
  if (type == FullEquipProto_EquipTypeWeapon) {
    return @"weap";
  } else if (type == FullEquipProto_EquipTypeArmor) {
    return @"arm";
  } else if (type == FullEquipProto_EquipTypeAmulet) {
    return @"amu";
  }
  return nil;
}

+ (NSString *) stringForTimeSinceNow:(NSDate *)date shortened:(BOOL)shortened {
  int time = -1*[date timeIntervalSinceNow];
  
  
  if (time < 0) {
    return @"In the future!";
  }
  
  int interval = 1;
  if (time < interval*60) {
    return [NSString stringWithFormat:@"%d %@%@ ago", time / interval, shortened ? @"sec" : @"second", time / interval != 1 ? @"s" : @""];
  }
  
  interval *= 60;
  if (time < interval*60) {
    return [NSString stringWithFormat:@"%d %@%@ ago", time / interval, shortened ? @"min" : @"minute", time / interval != 1 ? @"s" : @""];
  }
  
  interval *= 60;
  if (time < interval*24) {
    return [NSString stringWithFormat:@"%d %@%@ ago", time / interval, shortened ? @"hr" : @"hour", time / interval != 1 ? @"s" : @""];
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

+ (BOOL) class:(UserType)ut canEquip:(EquipClassType) ct {
  return (ct == ut % 3 || ct == EquipClassTypeAllAmulet);
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
  float width = image.size.width;
  float height = image.size.height;
  
  UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0.f);
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
  [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
  [animation setFromValue:[NSValue valueWithCGPoint:
                           CGPointMake(view.center.x - offset, view.center.y)]];
  [animation setToValue:[NSValue valueWithCGPoint:
                         CGPointMake(view.center.x + offset, view.center.y)]];
  [view.layer addAnimation:animation forKey:@"position"];
}

+ (void) displayUIView:(UIView *)view {
  UIView *sv = [[GameViewController sharedGameViewController] view];
  
  CGRect r = view.frame;
  r.size.width = MIN(r.size.width, sv.frame.size.width);
  view.frame = r;
  
  view.center = CGPointMake(sv.frame.size.width/2, sv.frame.size.height/2);
  
  [sv addSubview:view];
}

+ (void) displayUIViewWithoutAdjustment:(UIView *)view {
  UIView *sv = [[GameViewController sharedGameViewController] view];
  view.center = CGPointMake(sv.frame.size.width/2, sv.frame.size.height/2);
  [sv addSubview:view];
}

+ (NSString *) pathToFile:(NSString *)fileName {
  if (!fileName) {
    return nil;
  }
  
  // prevents overloading the autorelease pool
  NSString *resName = [CCFileUtils getDoubleResolutionImage:fileName validate:NO];
  NSString *fullpath = [[NSBundle mainBundle] pathForResource:resName ofType:nil];
  
  // Added for Utopia project
  if (!fullpath) {
    // Image not in NSBundle: look in documents
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    fullpath = [documentsPath stringByAppendingPathComponent:resName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
      // Map not in docs: download it
      [[Downloader sharedDownloader] syncDownloadFile:fullpath.lastPathComponent];
    }
  }
  
  return fullpath;
}

+ (NSString *) pathToBundle:(NSString *)bundleName {
  NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  NSString *fullPath = [cachesDirectory stringByAppendingPathComponent:bundleName];
  return fullPath;
}

+ (BOOL) bundleExists:(NSString *)bundleName {
  return [[NSFileManager defaultManager] fileExistsAtPath:[self pathToBundle:bundleName]];
}

+ (NSBundle *) bundleNamed:(NSString *)bundleName {
  if (!bundleName) {
    return nil;
  }
  NSString *fullPath = [self pathToBundle:bundleName];
  
  if (![self bundleExists:bundleName]) {
    [[Downloader sharedDownloader] syncDownloadBundle:bundleName];
  }
  
  return [NSBundle bundleWithPath:fullPath];
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
    
    BOOL fileExists = NO;
    fullpath = [documentsPath stringByAppendingPathComponent:resName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
      fileExists = YES;
    }
    
    if (!fileExists) {
      // Image not in docs: download it
      [[Downloader sharedDownloader] syncDownloadFile:fullpath.lastPathComponent];
    }
  }
  
  image = [UIImage imageWithContentsOfFile:fullpath];
  
  if (image) {
    [gl.imageCache setObject:image forKey:path];
  }
  
  return image;
}

+ (void) imageNamed:(NSString *)imageName withView:(UIView *)view maskedColor:(UIColor *)color indicator: (UIActivityIndicatorViewStyle)indicatorStyle clearImageDuringDownload:(BOOL)clear {
  // If imageName is null, it will clear the view's pre-downloading stuff
  // If view is null, it will download image without worrying about the view
  Globals *gl = [Globals sharedGlobals];
  NSString *key = [NSString stringWithFormat:@"%p", view];
  [[gl imageViewsWaitingForDownloading] removeObjectForKey:key];
  
  UIActivityIndicatorView *loadingView = (UIActivityIndicatorView *)[view viewWithTag:150];
  [loadingView stopAnimating];
  [loadingView removeFromSuperview];
  
  if (!imageName || imageName.length == 0) {
    if ([view isKindOfClass:[UIImageView class]]) {
      [(UIImageView *)view setImage:nil];
    } else if ([view isKindOfClass:[UIButton class]]) {
      [(UIButton *)view setImage:nil forState:UIControlStateNormal];
    }
    return;
  }
  
  UIImage *cachedImage = imageName ? [gl.imageCache objectForKey:imageName] : nil;
  if (cachedImage) {
    if (color) {
      cachedImage = [self maskImage:cachedImage withColor:color];
    }
    if ([view isKindOfClass:[UIImageView class]]) {
      [(UIImageView *)view setImage:cachedImage];
    } else if ([view isKindOfClass:[UIButton class]]) {
      [(UIButton *)view setImage:cachedImage forState:UIControlStateNormal];
      
      // For Armory View Controller
      CGRect r = view.frame;
      r.origin.y = CGRectGetMaxY(r)-cachedImage.size.height;
      r.size = cachedImage.size;
      view.frame = r;
    }
    
    return;
  }
  
  NSString *resName = [CCFileUtils getDoubleResolutionImage:imageName validate:NO];
  NSString *fullpath = [[NSBundle mainBundle] pathForResource:resName ofType:nil];
  
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
        loadingView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
        
        // Set up scale
        float scale = MIN(1.f, MIN(view.frame.size.width/loadingView.frame.size.width/2.f, view.frame.size.width/loadingView.frame.size.width/2.f));
        loadingView.transform = CGAffineTransformMakeScale(scale, scale);
        [loadingView release];
      }
      
      if (clear) {
        if ([view isKindOfClass:[UIImageView class]]) {
          [(UIImageView *)view setImage:nil];
        } else if ([view isKindOfClass:[UIButton class]]) {
          [(UIButton *)view setImage:nil forState:UIControlStateNormal];
        }
      }
      
      [[gl imageViewsWaitingForDownloading] setObject:imageName forKey:key];
      
      // Image not in docs: download it
      // Game will crash if view is released before image download completes so retain it
      [view retain];
      [[Downloader sharedDownloader] asyncDownloadFile:fullpath.lastPathComponent completion:^{
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
          
          if ([view isKindOfClass:[UIImageView class]]) {
            [(UIImageView *)view setImage:img];
          } else if ([view isKindOfClass:[UIButton class]]) {
            [(UIButton *)view setImage:img forState:UIControlStateNormal];
            
            // For Armory View Controller
            CGRect r = view.frame;
            r.origin.y = CGRectGetMaxY(r)-img.size.height;
            r.size = img.size;
            view.frame = r;
          }
          [view release];
          
          UIActivityIndicatorView *loadingView = (UIActivityIndicatorView *)[view viewWithTag:150];
          [loadingView stopAnimating];
          [loadingView removeFromSuperview];
          [[gl imageViewsWaitingForDownloading] removeObjectForKey:key];
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
    
    if ([view isKindOfClass:[UIImageView class]]) {
      [(UIImageView *)view setImage:image];
    } else if ([view isKindOfClass:[UIButton class]]) {
      [(UIButton *)view setImage:image forState:UIControlStateNormal];
      
      // For Armory View Controller
      CGRect r = view.frame;
      r.origin.y = CGRectGetMaxY(r)-image.size.height;
      r.size = image.size;
      view.frame = r;
    }
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
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver5:
      return @"Sailor Steve";
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
      return @"dialogueskeleton.png";
      break;
    case UserTypeGoodArcher:
      return @"dialoguealliancearcher.png";
      break;
    case UserTypeGoodMage:
      return @"dialoguepanda.png";
      break;
    case UserTypeGoodWarrior:
      return @"dialoguewarrior.png";
      break;
      
    default:
      return nil;
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
      return @"dialogueben.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerGoodTutorialGirl:
      return @"dialogueruby.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerPlayerType:
      return [self imageNameForDialogueUserType:[[GameState sharedGameState] type]];
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver1:
      return @"dialoguemitch.png";
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
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver5:
      return @"dialoguesteve.png";
      break;
    default:
      return nil;
      break;
  }
}

+ (NSString *) imageNameForBigDialogueSpeaker:(DialogueProto_SpeechSegmentProto_DialogueSpeaker)speaker {
  switch (speaker) {
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerBadTutorialGirl:
      return @"bigadriana2.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerBazaar:
      return @"bigben2.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerGoodTutorialGirl:
      return @"bigruby2.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerPlayerType:
      return nil;
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver1:
      return @"bigmitch2.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver2:
      return @"bigriz2.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver3:
      return @"bigsean2.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver4:
      return @"bigriz2.png";
      break;
    case DialogueProto_SpeechSegmentProto_DialogueSpeakerQuestgiver5:
      return @"bigsteve2.png";
      break;
    default:
      return nil;
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
      return @"AllianceMage.png";
      break;
      
    case UserTypeBadWarrior:
      return @"LegionWarrior.png";
      break;
      
    case UserTypeBadArcher:
      return @"LegionArcher.png";
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

+ (NSString *) animatedSpritePrefix:(UserType)type {
  switch (type) {
    case UserTypeGoodWarrior:
      return @"AllianceWarrior";
      break;
      
    case UserTypeGoodArcher:
      return @"AllianceArcher";
      break;
      
    case UserTypeGoodMage:
      return @"AllianceMage";
      break;
      
    case UserTypeBadWarrior:
      return @"LegionWarrior";
      break;
      
    case UserTypeBadArcher:
      return @"LegionArcher";
      break;
      
    case UserTypeBadMage:
      return @"LegionMage";
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
  return fep.rarity >= FullEquipProto_RarityRare;
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

- (float) calculateAttackForAttackStat:(int)attackStat weapon:(UserEquip *)weapon armor:(UserEquip *)armor amulet:(UserEquip *)amulet {
  int weaponAttack = weapon ? [self calculateAttackForEquip:weapon.equipId level:weapon.level enhancePercent:weapon.enhancementPercentage] : 0;
  int armorAttack = armor ? [self calculateAttackForEquip:armor.equipId level:armor.level enhancePercent:armor.enhancementPercentage] : 0;
  int amuletAttack = amulet ? [self calculateAttackForEquip:amulet.equipId level:amulet.level enhancePercent:amulet.enhancementPercentage] : 0;
  
  return (weaponAttack+armorAttack+amuletAttack);
}

- (float) calculateDefenseForDefenseStat:(int)defenseStat weapon:(UserEquip *)weapon armor:(UserEquip *)armor amulet:(UserEquip *)amulet {
  int weaponDefense = weapon ? [self calculateDefenseForEquip:weapon.equipId level:weapon.level enhancePercent:weapon.enhancementPercentage] : 0;
  int armorDefense = armor ? [self calculateDefenseForEquip:armor.equipId level:armor.level enhancePercent:armor.enhancementPercentage] : 0;
  int amuletDefense = amulet ? [self calculateDefenseForEquip:amulet.equipId level:amulet.level enhancePercent:amulet.enhancementPercentage] : 0;
  
  return (weaponDefense+armorDefense+amuletDefense);
}

- (int) calculateAttackForEquip:(int)equipId level:(int)level enhancePercent:(int)enhancePercent {
  if (equipId == 0) return 0;
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  int enhanceLevel = [self calculateEnhancementLevel:enhancePercent];
  return (int)ceilf(fep.attackBoost*pow(self.levelEquipBoostExponentBase, level-1)*pow(self.enhanceLevelExponentBase, enhanceLevel));
}

- (int) calculateDefenseForEquip:(int)equipId level:(int)level enhancePercent:(int)enhancePercent {
  if (equipId == 0) return 0;
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  int enhanceLevel = [self calculateEnhancementLevel:enhancePercent];
  return (int)ceilf(fep.defenseBoost*pow(self.levelEquipBoostExponentBase, level-1)*pow(self.enhanceLevelExponentBase, enhanceLevel));
}

- (float) calculateChanceOfSuccess:(int)equipId level:(int)level {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  float chanceOfSuccess = 1.f-fep.chanceOfForgeFailureBase;
  return chanceOfSuccess-(chanceOfSuccess/(self.forgeMaxEquipLevel-1)*(level-1));
}

- (int) calculateMinutesForForge:(int)equipId level:(int)level {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  return (int)(fep.minutesToAttemptForgeBase*pow(self.forgeTimeBaseForExponentialMultiplier, level+1));
}

- (int) calculateGoldCostToGuaranteeForgingSuccess:(int)equipId level:(int)level {
  float chanceOfSuccess = [self calculateChanceOfSuccess:equipId level:level];
  int goldCost = [self calculateGoldCostToSpeedUpForging:equipId level:level];
  return (int)(goldCost/chanceOfSuccess);
}

- (int) calculateGoldCostToSpeedUpForging:(int)equipId level:(int)level {
  return (int)ceil([self calculateMinutesForForge:equipId level:level]/(float)self.forgeBaseMinutesToOneGold);
}

- (int) calculateRetailValueForEquip:(int)equipId level:(int)level {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:equipId];
  int value = fep.diamondPrice ? fep.diamondPrice : fep.coinPrice;
  return (int)(value*pow(2.f, level-1));
}

- (int) calculateHealthForLevel:(int)level {
  return (int)(30.f * powf(self.healthFormulaExponentBase, level-1));
}

- (int) calculateNumMinutesForNewExpansion:(UserExpansion *)ue {
  return (expansionWaitCompleteHourConstant + expansionWaitCompleteHourIncrementBase*(ue.numCompletedExpansions+1))*60;
}

- (int) calculateGoldCostToSpeedUpExpansion:(UserExpansion *)ue {
  return [self calculateNumMinutesForNewExpansion:ue]/expansionWaitCompleteBaseMinutesToOneGold;
}

- (int) calculateSilverCostForNewExpansion:(UserExpansion *)ue {
  return (int)(expansionPurchaseCostConstant*powf(expansionPurchaseCostExponentBase, ue.numCompletedExpansions));
}

- (int) calculateTotalMinutesToLevelUpEnhancementEquip:(UserEquip *)ue {
  GameState *gs = [GameState sharedGameState];
  FullEquipProto *fep = [gs equipWithId:ue.equipId];
  double result = self.enhanceTimeConstantA*powf(ue.level, self.enhanceTimeConstantB);
  result = powf(result, self.enhanceTimeConstantC+self.enhanceTimeConstantD*(fep.rarity+1));
  result *= powf(self.enhanceTimeConstantE, (fep.minLevel/self.averageSizeOfLevelBracket*self.enhanceTimeConstantF));
  result *= powf(self.enhanceTimeConstantG, [self calculateEnhancementLevel:ue.enhancementPercentage]+1);
  
  //  LNLog(@"minutes=%f", result);
  return (int)MAX(result, 1.f);
}

- (int) calculateMinutesToEnhance:(UserEquip *)enhancingEquip feeders:(NSArray *)feeders {
  if (!enhancingEquip || feeders.count <= 0) {
    return 0;
  }
  
  int pChange = [self calculateEnhancementPercentageIncrease:enhancingEquip feeders:feeders];
  float percent = [self calculatePercentOfLevel:pChange];
  int totalTime = [self calculateTotalMinutesToLevelUpEnhancementEquip:enhancingEquip];
  int result = (int)ceilf(percent*totalTime);
  
  //  LNLog(@"time for enhance=%d", result);
  return result;
}

- (int) calculateGoldCostToSpeedUpEnhance:(UserEquip *)enhancingEquip feeders:(NSArray *)feeders {
  int mins = [self calculateMinutesToEnhance:enhancingEquip feeders:feeders];
  int result = (int)ceilf(((float)mins)/self.forgeBaseMinutesToOneGold);
  
  //  LNLog(@"diamonds=%d", result);
  return result;
}

- (float) calculatePercentOfLevel:(int)percentage {
  if (!self.enhancePercentPerLevel) return 0;
  return ((float)percentage)/self.enhancePercentPerLevel;
}

- (int) calculateEnhancementLevel:(int)percentage {
  if (!self.enhancePercentPerLevel) return 0;
  return percentage / self.enhancePercentPerLevel;
}

- (int) calculateEnhancementPercentageToNextLevel:(int)percentage {
  if (!self.enhancePercentPerLevel) return 0;
  return percentage % self.enhancePercentPerLevel;
}

- (int) calculateEnhancementPercentageIncrease:(UserEquip *)enhancingEquip feeders:(NSArray *)feeders {
  int change = 0;
  for (UserEquip *f in feeders) {
    change += [self calculateEnhancementPercentageIncrease:enhancingEquip feeder:f];
  }
  
  int maxChange = ([self calculateEnhancementLevel:enhancingEquip.enhancementPercentage]+1)*self.enhancePercentPerLevel-enhancingEquip.enhancementPercentage;
  
  //  LNLog(@"totalChange=%d maxChange=%d", change, maxChange);
  return MIN(maxChange, change);
}

- (int) calculateEnhancementPercentageIncrease:(UserEquip *)enhancingEquip feeder:(UserEquip *)feeder {
  int mainAttack = [self calculateAttackForEquip:enhancingEquip.equipId level:enhancingEquip.level enhancePercent:enhancingEquip.enhancementPercentage];
  int mainDefense = [self calculateDefenseForEquip:enhancingEquip.equipId level:enhancingEquip.level enhancePercent:enhancingEquip.enhancementPercentage];
  int feederAttack = [self calculateAttackForEquip:feeder.equipId level:feeder.level enhancePercent:feeder.enhancementPercentage];
  int feederDefense = [self calculateDefenseForEquip:feeder.equipId level:feeder.level enhancePercent:feeder.enhancementPercentage];
  
  int mainStats = mainAttack + mainDefense;
  int feederStats = feederAttack + feederDefense;
  
  int result = (int)((((float)feederStats)/mainStats)/(self.enhancePercentConstantA*powf(self.enhancePercentConstantB, [self calculateEnhancementLevel:enhancingEquip.enhancementPercentage]+1))*self.enhancePercentPerLevel);
  
  //  LNLog(@"percentage=%d", result);
  return result;
}

- (BOOL) canRetractMarketplacePostForFree:(FullMarketplacePostProto *)post {
  GameState *gs = [GameState sharedGameState];
  if ([gs hasValidLicense]) {
    return YES;
  } else {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:post.timeOfPost/1000.+numDaysUntilFreeRetract*24.*60*60];
    if (date.timeIntervalSinceNow < 0) {
      return YES;
    }
    return NO;
  }
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

+ (void) popupMessage:(NSString *)msg {
  [GenericPopupController displayNotificationViewWithText:msg title:nil];
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
  NSMutableArray *toRemove = [NSMutableArray array];
  for (id curView in _pulsingViews) {
    if([curView retainCount] == 1) {
      [toRemove addObject:curView];
    }
  }
  for (id rem in toRemove) {
    [_pulsingViews removeObject:rem];
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
  
  if (![_pulsingViews    containsObject:view]) {
    UIImageView *glow = [[UIImageView alloc]
                         initWithImage:[Globals roundGlowForColor:glowColor]];
    CGRect frame = view.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    [glow setFrame:frame];
    [view addSubview:glow];
    [glow release];
    [view bringSubviewToFront:glow];
    
    [_pulsingViews addObject:view];
    [self pulse:0 onView:glow];
  }
}

+(void)endPulseForView:(UIView *)view {
  [Globals setupPulseAnimation];
  
  if ([_pulsingViews    containsObject:view]) {
    [_donePulsingViews  addObject:view];
    [_pulsingViews      removeObject:view];
  }
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
  return [UIColor colorWithRed:240/255.f green:237/255.f blue:213/255.f alpha:1.f];
}

+ (UIColor *)goldColor {
  return [UIColor colorWithRed:255/255.f green:200/255.f blue:0/255.f alpha:1.f];
}

+ (UIColor *)greenColor {
  return [UIColor colorWithRed:176/255.f green:223/255.f blue:33/255.f alpha:1.f];
}

+ (UIColor *)orangeColor {
  return [UIColor colorWithRed:255/255.f green:102/255.f blue:0/255.f alpha:1.f];
}

+ (UIColor *)redColor {
  return [UIColor colorWithRed:217/255.f green:0/255.f blue:0/255.f alpha:1.f];
}

+ (UIColor *)blueColor {
  return [UIColor colorWithRed:92/255.f green:228/255.f blue:255/255.f alpha:1.f];
}

+ (UIColor *)purpleColor {
  return [UIColor colorWithRed:156/255.f green:0/255.f blue:255/255.f alpha:1.f];
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

- (void) confirmWearEquip:(int)userEquipId {
  _equipIdToWear = userEquipId;
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserEquip *equip = [gs myEquipWithUserEquipId:userEquipId];
  
  if (!equip) {
    return;
  }
  
  FullEquipProto *fep = [gs equipWithId:equip.equipId];
  if ([Globals canEquip:fep]) {
    UserEquip *ue = nil;
    UserEquip *ue1 = nil;
    UserEquip *ue2 = nil;
    if (fep.equipType == FullEquipProto_EquipTypeWeapon) {
      ue1 = [gs myEquipWithUserEquipId:gs.weaponEquipped];
      ue2 = [gs myEquipWithUserEquipId:gs.weaponEquipped2];
    } else if (fep.equipType == FullEquipProto_EquipTypeArmor) {
      ue1 = [gs myEquipWithUserEquipId:gs.armorEquipped];
      ue2 = [gs myEquipWithUserEquipId:gs.armorEquipped2];
    } else if (fep.equipType == FullEquipProto_EquipTypeAmulet) {
      ue1 = [gs myEquipWithUserEquipId:gs.amuletEquipped];
      ue2 = [gs myEquipWithUserEquipId:gs.amuletEquipped2];
    }
    
    // Find the weaker item
    int attack1 = [gl calculateAttackForEquip:ue1.equipId level:ue1.level enhancePercent:ue1.enhancementPercentage];
    int defense1 = [gl calculateDefenseForEquip:ue1.equipId level:ue1.level enhancePercent:ue1.enhancementPercentage];
    int attack2 = [gl calculateAttackForEquip:ue2.equipId level:ue2.level enhancePercent:ue2.enhancementPercentage];
    int defense2 = [gl calculateDefenseForEquip:ue2.equipId level:ue2.level enhancePercent:ue2.enhancementPercentage];
    
    if (attack1 + defense1 <= attack2 + defense2) {
      ue = ue1;
      _isForSlot2 = NO;
    } else {
      ue = ue2;
      _isForSlot2 = YES;
    }
    
    int curAttack = 0;
    int curDefense = 0;
    if (ue) {
      curAttack = [gl calculateAttackForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage];
      curDefense = [gl calculateDefenseForEquip:ue.equipId level:ue.level enhancePercent:ue.enhancementPercentage];
    }
    int newAttack = [gl calculateAttackForEquip:equip.equipId level:equip.level enhancePercent:equip.enhancementPercentage];
    int newDefense = [gl calculateDefenseForEquip:equip.equipId level:equip.level enhancePercent:equip.enhancementPercentage];
    
    if (newAttack + newDefense > curAttack + curDefense) {
      [GenericPopupController displayConfirmationWithDescription:[NSString stringWithFormat:@"Would you like to equip this %@?",
                                                                  fep.name]
                                                           title:@"Equip Item?"
                                                      okayButton:@"Equip Item"
                                                    cancelButton:@"No"
                                                          target:self
                                                        selector:@selector(wearEquipConfirmed)];
    }
  }
}

- (void) wearEquipConfirmed {
  [[OutgoingEventController sharedOutgoingEventController] wearEquip:_equipIdToWear forPrestigeSlot:_isForSlot2];
}

- (BOOL) validateUserName:(NSString *)name {
  // make sure length is okay
  if (name.length < minNameLength) {
    [Globals popupMessage:@"This name is too short."];
    return NO;
  } else if (name.length > maxNameLength) {
    [Globals popupMessage:@"This name is too long."];
    return NO;
  }
  
  // make sure there are no obvious swear words
  NSString *lowerStr = [name lowercaseString];
  NSArray *swearWords = [NSArray arrayWithObjects:@"fuck", @"shit", @"bitch", nil];
  for (NSString *swear in swearWords) {
    if ([lowerStr rangeOfString:swear].location != NSNotFound) {
      [Globals popupMessage:@"Please refrain from using vulgar language within this game."];
      return NO;
    }
  }
  return YES;
}

+ (NSString *) fullNameWithName:(NSString *)name clanTag:(NSString *)tag {
  if (tag.length > 0) {
    return [NSString stringWithFormat:@"[%@] %@", tag, name];
  } else {
    return name;
  }
}

#define RATE_US_POPUP_DEFAULT_KEY @"RateUsLastPopupTimeKey"
#define RATE_US_CLICKED_LATER @"RateUsClickedLater"
#define RATE_US_CLICKED_REVIEW @"RateUsClickedReview"

+ (void) checkRateUsPopup {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDate *lastSeen = [defaults objectForKey:RATE_US_POPUP_DEFAULT_KEY];
  if (!lastSeen) {
    [[Globals sharedGlobals] displayRateUsPopup];
    [defaults setObject:[NSDate date] forKey:RATE_US_POPUP_DEFAULT_KEY];
  }
}

- (void) displayRateUsPopup {
  GameState *gs = [GameState sharedGameState];
  NSString *desc = [NSString stringWithFormat:@"Hey %@! Are you enjoying Age of Chaos?", gs.name];
  [GenericPopupController displayConfirmationWithDescription:desc title:@"Enjoying AoC?" okayButton:@"Yes" cancelButton:@"No" okTarget:self okSelector:@selector(userClickedLike) cancelTarget:self cancelSelector:@selector(userClickedDislike)];
}

- (void) userClickedDislike {
  [Globals popupMessage:@"Thank you for the feedback. Email support@lvl6.com with suggestions."];
}

- (void) userClickedLike {
  NSString *desc = self.reviewPageConfirmationMessage;
  [GenericPopupController displayConfirmationWithDescription:desc title:@"Rate Us!" okayButton:@"Rate" cancelButton:@"Later" okTarget:self okSelector:@selector(rateUs) cancelTarget:self cancelSelector:@selector(later)];
}

- (void) rateUs {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.reviewPageURL]];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:RATE_US_CLICKED_REVIEW];
}

- (void) later {
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:RATE_US_CLICKED_LATER];
}

- (int) percentOfSkillPointsInStamina {
  GameState *gs = [GameState sharedGameState];
  int totalSkillPoints = (gs.level-1)*self.skillPointsGainedOnLevelup;
  int percent = ((float)(gs.maxStamina-self.initStamina)*self.staminaBaseCost)/totalSkillPoints*100;
  return percent;
}

+ (void) adjustViewForCentering:(UIView *)view withLabel:(UILabel *)label {
  CGSize size = [label.text sizeWithFont:label.font constrainedToSize:label.frame.size lineBreakMode:label.lineBreakMode];
  CGPoint oldCenter = view.center;
  
  CGRect r = view.frame;
  r.size.width = label.frame.origin.x + size.width;
  view.frame = r;
  
  view.center = oldCenter;
}

+ (UIColor *) colorForColorProto:(ColorProto *)cp {
  return [UIColor colorWithRed:cp.red/255.f green:cp.green/255.f blue:cp.blue/255.f alpha:255.f];
}

- (InAppPurchasePackageProto *) packageForProductId:(NSString *)pid {
  return [self.productIdsToPackages objectForKey:pid];
}

+ (NSArray *) getUserEquipArrayFromFullUserProto:(FullUserProto *)fup {
  NSMutableArray *arr = [NSMutableArray array];
  [arr addObject:fup.hasWeaponEquippedUserEquip ? [UserEquip userEquipWithProto:fup.weaponEquippedUserEquip] : [NSNull null]];
  [arr addObject:fup.hasArmorEquippedUserEquip ? [UserEquip userEquipWithProto:fup.armorEquippedUserEquip] : [NSNull null]];
  [arr addObject:fup.hasAmuletEquippedUserEquip ? [UserEquip userEquipWithProto:fup.amuletEquippedUserEquip] : [NSNull null]];
  [arr addObject:fup.hasWeaponTwoEquippedUserEquip ? [UserEquip userEquipWithProto:fup.weaponTwoEquippedUserEquip] : [NSNull null]];
  [arr addObject:fup.hasArmorTwoEquippedUserEquip ? [UserEquip userEquipWithProto:fup.armorTwoEquippedUserEquip] : [NSNull null]];
  [arr addObject:fup.hasAmuletTwoEquippedUserEquip ? [UserEquip userEquipWithProto:fup.amuletTwoEquippedUserEquip] : [NSNull null]];
  return arr;
}

- (void) dealloc {
  self.imageCache = nil;
  self.imageViewsWaitingForDownloading = nil;
  self.animatingSpriteOffsets = nil;
  self.kiipRewardConditions = nil;
  self.downloadableNibConstants = nil;
  self.reviewPageURL = nil;
  self.reviewPageConfirmationMessage = nil;
  [super dealloc];
}

@end

@implementation CCNode (RecursiveOpacity)

- (void) recursivelyApplyOpacity:(GLubyte)opacity {
  if ([self conformsToProtocol:@protocol(CCRGBAProtocol)]) {
    [(id<CCRGBAProtocol>)self setOpacity:opacity];
  }
  for (CCNode *c in children_) {
    [c recursivelyApplyOpacity:opacity];
  }
}

@end

@implementation RecursiveFadeTo

-(void) update: (ccTime) t
{
	[target_ recursivelyApplyOpacity:fromOpacity_ + ( toOpacity_ - fromOpacity_ ) * t];
}

@end