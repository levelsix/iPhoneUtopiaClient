//
//  UserData.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/9/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "UserData.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "VaultMenuController.h"
#import "MarketplaceViewController.h"
#import "MapViewController.h"
#import "ArmoryViewController.h"
#import "CarpenterMenuController.h"
#import "ForgeMenuController.h"
#import "LeaderboardController.h"
#import "ClanMenuController.h"
#import "BazaarMap.h"

@implementation UserEquip

@synthesize userId, equipId, level, durability, userEquipId;

- (id) initWithEquipProto:(FullUserEquipProto *)proto {
  if ((self = [super init])){
    self.userId = proto.userId;
    self.equipId = proto.equipId;
    self.level = proto.level;
    self.userEquipId = proto.userEquipId;
    self.enhancementPercentage = proto.enhancementPercentage;
  }
  return self;
}

+ (id) userEquipWithProto:(FullUserEquipProto *)proto {
  return [[[self alloc] initWithEquipProto:proto] autorelease];
}

- (id) initWithEquipEnhancementItemProto:(EquipEnhancementItemProto *)proto {
  if ((self = [super init])){
    self.equipId = proto.equipId;
    self.level = proto.level;
    self.enhancementPercentage = proto.enhancementPercentage;
  }
  return self;
}

+ (id) userEquipWithEquipEnhancementItemProto:(EquipEnhancementItemProto *)proto {
  return [[[self alloc] initWithEquipEnhancementItemProto:proto] autorelease];
}

- (NSString *) description {
  return [NSString stringWithFormat:@"%p: Level %d %@, UserEquipId:%d", self, level, [[GameState sharedGameState] equipWithId:equipId].name, userEquipId];
}

- (BOOL) isEqual:(UserEquip *)object {
  return object.userEquipId == userEquipId;
}

@end

@implementation UserStruct

@synthesize userStructId, userId, structId, level, isComplete, coordinates, orientation, purchaseTime, lastRetrieved, lastUpgradeTime;

- (id) initWithStructProto:(FullUserStructureProto *)proto {
  if ((self = [super init])) {
    self.userStructId = proto.userStructId;
    self.userId = proto.userId;
    self.structId = proto.structId;
    self.level = proto.level;
    self.isComplete = proto.isComplete;
    self.coordinates = CGPointMake(proto.coordinates.x, proto.coordinates.y);
    self.orientation = proto.orientation;
    self.purchaseTime = proto.hasPurchaseTime ? [NSDate dateWithTimeIntervalSince1970:proto.purchaseTime/1000.0] : nil;
    self.lastRetrieved = proto.hasLastRetrieved ? [NSDate dateWithTimeIntervalSince1970:proto.lastRetrieved/1000.0] : nil;
    self.lastUpgradeTime = proto.hasLastUpgradeTime ? [NSDate dateWithTimeIntervalSince1970:proto.lastUpgradeTime/1000.0] : nil;
  }
  return self;
}

+ (id) userStructWithProto:(FullUserStructureProto *)proto {
  return [[[self alloc] initWithStructProto:proto] autorelease];
}

- (FullStructureProto *) fsp {
  return [[GameState sharedGameState] structWithId:structId];
}

- (UserStructState) state {
  NSDate *now = [NSDate date];
  NSDate *done;
  FullStructureProto *fsp = self.fsp;
  
  if (!isComplete) {
    if (lastUpgradeTime) {
      return kUpgrading;
    } else {
      return kBuilding;
    }
  }
  
  done = [NSDate dateWithTimeInterval:fsp.minutesToGain*60 sinceDate:lastRetrieved];
  if ([now compare:done] == NSOrderedDescending) {
    return kRetrieving;
  }
  return kWaitingForIncome;
}

- (NSString *) description {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:self.structId];
  return [NSString stringWithFormat:@"%p: %@, %@", self, fsp.name, NSStringFromCGPoint(coordinates)];
}

- (void) dealloc {
  self.lastRetrieved = nil;
  self.lastUpgradeTime = nil;
  self.purchaseTime = nil;
  [super dealloc];
}

@end

@implementation UserCity

@synthesize curRank, cityId, numTasksComplete;

- (id) initWithCityProto:(FullUserCityProto *)proto {
  if ((self = [super init])) {
    self.curRank = proto.currentRank;
    self.cityId = proto.cityId;
    self.numTasksComplete = proto.numTasksCurrentlyCompleteInRank;
  }
  return self;
}

+ (id) userCityWithProto:(FullUserCityProto *)proto {
  return [[[self alloc] initWithCityProto:proto] autorelease];
}

@end

@implementation CritStruct

@synthesize name, type, goldMineView;

- (id) initWithType:(BazaarStructType)t {
  if ((self = [super init])) {
    self.type = t;
  }
  return self;
}

- (void) setType:(BazaarStructType)t {
  Globals *gl = [Globals sharedGlobals];
  StartupResponseProto_StartupConstants_BazaarMinLevelConstants *mlc = gl.minLevelConstants;
  type = t;
  switch (type) {
    case BazaarStructTypeVault:
      name = @"Vault";
      self.minLevel = mlc.vaultMinLevel;
      break;
      
    case BazaarStructTypeBlacksmith:
      name = @"Blacksmith";
      self.minLevel = mlc.blacksmithMinLevel;
      break;
      
    case BazaarStructTypeArmory:
      name = @"Armory";
      self.minLevel = mlc.armoryMinLevel;
      break;
      
    case BazaarStructTypeAviary:
      name = @"Aviary";
      break;
      
    case BazaarStructTypeCarpenter:
      name = @"Carpenter";
      break;
      
    case BazaarStructTypeMarketplace:
      name = @"Marketplace";
      self.minLevel = mlc.marketplaceMinLevel;
      break;
      
    case BazaarStructTypeLeaderboard:
      name = @"Leaderboard";
      self.minLevel = mlc.leaderboardMinLevel;
      break;
      
    case BazaarStructTypeClanHouse:
      name = @"Clan House";
      self.minLevel = mlc.clanHouseMinLevel;
      break;
      
    case BazaarStructTypeGoldMine:
      name = @"Gold Mine";
      break;
      
    default:
      break;
  }
}

- (GoldMineView *) goldMineView {
  if (!goldMineView) {
    Globals *gl = [Globals sharedGlobals];
    [[Globals bundleNamed:gl.downloadableNibConstants.goldMineNibName] loadNibNamed:@"GoldMineView" owner:self options:nil];
  }
  return goldMineView;
}

- (void) openMenu {
  GameState *gs = [GameState sharedGameState];
  
  if (gs.level < _minLevel) {
    [Globals popupMessage:[NSString stringWithFormat:@"The %@ unlocks at level %d.", name, _minLevel]];
    return;
  }
  
  switch (self.type) {
    case BazaarStructTypeVault:
      [VaultMenuController displayView];
      break;
      
    case BazaarStructTypeBlacksmith:
      [ForgeMenuController displayView];
      break;
      
    case BazaarStructTypeArmory:
      [ArmoryViewController displayView];
      break;
      
    case BazaarStructTypeAviary:
      [MapViewController displayView];
      break;
      
    case BazaarStructTypeCarpenter:
      [CarpenterMenuController displayView];
      break;
      
    case BazaarStructTypeMarketplace:
      [MarketplaceViewController displayView];
      break;
      
    case BazaarStructTypeLeaderboard:
      [LeaderboardController displayView];
      break;
      
    case BazaarStructTypeClanHouse:
      [ClanMenuController displayView];
      break;
      
    case BazaarStructTypeGoldMine:
      [self goldMineClicked];
      break;
      
    default:
      break;
  }
}

- (void) goldMineClicked {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  NSTimeInterval timeInterval = -[gs.lastGoldmineRetrieval timeIntervalSinceNow];
  int timeToStartCollect = 3600.f*gl.numHoursBeforeGoldmineRetrieval;
  int timeToEndCollect = 3600.f*(gl.numHoursBeforeGoldmineRetrieval+gl.numHoursForGoldminePickup);
  
  if (timeInterval > timeToStartCollect && timeInterval < timeToEndCollect) {
    [[OutgoingEventController sharedOutgoingEventController] collectFromGoldmine];
    BazaarMap *bm = [BazaarMap sharedBazaarMap];
    CritStructBuilding *csb = (CritStructBuilding *)[bm getChildByTag:self.type];
    [bm addGoldDrop:1 fromSprite:csb toPosition:CGPointZero secondsToPickup:0];
    csb.retrievable = NO;
  } else {
    [self.goldMineView displayForCurrentState];
  }
}

- (void) dealloc {
  self.name = nil;
  [super dealloc];
}

@end

@implementation UserNotification

@synthesize time, type, otherPlayer;
@synthesize marketPost, sellerHadLicense;
@synthesize battleResult, coinsStolen, stolenEquipId, stolenEquipLevel;
@synthesize forgeEquipId;
@synthesize wallPost;
@synthesize goldmineCollect;
@synthesize hasBeenViewed;

- (id) initBattleNotificationAtStartup:(StartupResponseProto_AttackedNotificationProto *)proto {
  if ((self = [super init])) {
    self.otherPlayer = proto.attacker;
    self.battleResult = proto.battleResult;
    self.time = [NSDate dateWithTimeIntervalSince1970:proto.battleCompleteTime/1000.0];
    self.coinsStolen = proto.coinsStolen;
    self.stolenEquipId = proto.stolenEquipId;
    self.stolenEquipLevel = proto.stolenEquipLevel;
    self.type = kNotificationBattle;
  }
  return self;
}

- (id) initMarketplaceNotificationAtStartup:(StartupResponseProto_MarketplacePostPurchasedNotificationProto *)proto {
  if ((self = [super init])) {
    self.otherPlayer = proto.buyer;
    self.time = [NSDate dateWithTimeIntervalSince1970:proto.timeOfPurchase/1000.0];
    self.marketPost = proto.marketplacePost;
    self.type = kNotificationMarketplace;
    self.sellerHadLicense = proto.sellerHadLicense;
  }
  return self;
}

- (id) initReferralNotificationAtStartup:(StartupResponseProto_ReferralNotificationProto *)proto {
  if ((self = [super init])) {
    self.otherPlayer = proto.referred;
    self.time = [NSDate dateWithTimeIntervalSince1970:proto.recruitTime/1000.0];
    self.type = kNotificationReferral;
  }
  return self;
}

- (id) initWithBattleResponse:(BattleResponseProto *)proto {
  if ((self = [super init])) {
    self.otherPlayer = proto.attacker;
    self.battleResult = proto.battleResult;
    self.time = [NSDate date];
    self.coinsStolen = proto.coinsGained;
    self.stolenEquipId = proto.userEquipGained.equipId;
    self.stolenEquipLevel = proto.userEquipGained.level;
    self.type = kNotificationBattle;
  }
  return self;
}

- (id) initWithMarketplaceResponse:(PurchaseFromMarketplaceResponseProto *)proto {
  if ((self = [super init])) {
    self.otherPlayer = proto.purchaser;
    self.time = [NSDate date];
    self.marketPost = proto.marketplacePost;
    self.type = kNotificationMarketplace;
    self.sellerHadLicense = proto.sellerHadLicense;
  }
  return self;
}

- (id) initWithReferralResponse:(ReferralCodeUsedResponseProto *)proto {
  if ((self = [super init])) {
    self.otherPlayer = proto.referredPlayer;
    self.time = [NSDate date];
    self.type = kNotificationReferral;
  }
  return self;
}

- (id) initWithForgeAttempt:(ForgeAttempt *)fa {
  if ((self = [super init])) {
    Globals *gl = [Globals sharedGlobals];
    if (fa.speedupTime) {
      self.time = fa.speedupTime;
    } else {
      float seconds = [gl calculateMinutesForForge:fa.equipId level:fa.level]*60.f;
      self.time = [fa.startTime dateByAddingTimeInterval:seconds];
    }
    self.type = kNotificationForge;
    self.forgeEquipId = fa.equipId;
  }
  return self;
}

- (id) initWithWallPost:(PlayerWallPostProto *)proto {
  if ((self = [super init])) {
    self.otherPlayer = proto.poster;
    self.time = [NSDate date];
    self.type = kNotificationWallPost;
    self.wallPost = proto.content;
  }
  return self;
}

- (id) initWithGoldmineRetrieval:(NSDate *)goldmineStart {
  if ((self = [super init])) {
    Globals *gl = [Globals sharedGlobals];
    
    self.type = kNotificationGoldmine;
    
    NSTimeInterval timeInterval = -[goldmineStart timeIntervalSinceNow];
    int timeToStartCollect = 3600.f*gl.numHoursBeforeGoldmineRetrieval;
    int timeToEndCollect = 3600.f*(gl.numHoursBeforeGoldmineRetrieval+gl.numHoursForGoldminePickup);
    
    if (timeInterval > timeToEndCollect) {
      self.time = [goldmineStart dateByAddingTimeInterval:timeToEndCollect];
      self.goldmineCollect = NO;
    } else if (timeInterval > timeToStartCollect) {
      self.time = [goldmineStart dateByAddingTimeInterval:timeToStartCollect];
      self.goldmineCollect = YES;
    } else {
      [self release];
      return nil;
    }
  }
  return self;
}

- (id) initWithTitle:(NSString *)t subtitle:(NSString *)st color:(UIColor *)c {
  if ((self = [super init])) {
    self.title = t;
    self.subtitle = st;
    self.color = c;
    self.type = kNotificationGeneral;
  }
  return self;
}

- (NSString *) description {
  return [NSString stringWithFormat:@"<UserNotification> Type: %d", self.type];
}

- (void) dealloc {
  self.time = nil;
  self.otherPlayer = nil;
  self.marketPost = nil;
  self.wallPost = nil;
  [super dealloc];
}

@end

@implementation UserJob

@synthesize jobId, jobType;
@synthesize title, subtitle;
@synthesize numCompleted, total;

- (id) initWithTask:(FullTaskProto *)p {
  if ((self = [super init])) {
    self.jobId = p.taskId;
    self.jobType = kTask;
    self.title = p.name;
    self.total = p.numRequiredForCompletion;
  }
  return self;
}

- (id) initWithDefeatTypeJob:(DefeatTypeJobProto *)p {
  if ((self = [super init])) {
    GameState *gs = [GameState sharedGameState];
    self.jobId = p.defeatTypeJobId;
    self.jobType = kDefeatTypeJob;
    
    BOOL specificEnemy = (p.typeOfEnemy != DefeatTypeJobProto_DefeatTypeJobEnemyTypeAllTypesFromOpposingSide);
    UserType type = specificEnemy ? p.typeOfEnemy : (gs.type+3)%6;
    NSString *character = [NSString stringWithFormat:@"%@%@", specificEnemy ? [Globals classForUserType:p.typeOfEnemy] : @"Player", p.numEnemiesToDefeat == 1 ? @"" : @"s"];
    NSString *end = p.cityId > 0 ? [NSString stringWithFormat:@"in %@", [gs cityWithId:p.cityId].name] : [NSString stringWithFormat:@"from the Attack Screen"];
    self.title = [NSString stringWithFormat:@"Defeat %d %@ %@ %@", p.numEnemiesToDefeat, [Globals factionForUserType:type], character, end];
    self.total = p.numEnemiesToDefeat;
  }
  return self;
}

- (id) initWithPossessEquipJob:(PossessEquipJobProto *)p {
  if ((self = [super init])) {
    GameState *gs = [GameState sharedGameState];
    FullEquipProto *e = [gs equipWithId:p.equipId];
    self.jobId = p.possessEquipJobId;
    self.jobType = kPossessEquipJob;
    self.title = [NSString stringWithFormat:@"Attain %@%@", e.name, p.quantityReq == 1 ? @"" : [NSString stringWithFormat:@" (%d)", p.quantityReq]];
    self.total = p.quantityReq;
  }
  return self;
}

- (id) initWithBuildStructJob:(BuildStructJobProto *)p {
  if ((self = [super init])) {
    GameState *gs = [GameState sharedGameState];
    FullStructureProto *s = [gs structWithId:p.structId];
    self.jobId = p.buildStructJobId;
    self.jobType = kBuildStructJob;
    self.title = [NSString stringWithFormat:@"Build %@%@", s.name, p.quantityRequired == 1 ? @"" : [NSString stringWithFormat:@" (%d)", p.quantityRequired]];
    self.total = p.quantityRequired;
  }
  return self;
}

- (id) initWithUpgradeStructJob:(UpgradeStructJobProto *)p {
  if ((self = [super init])) {
    GameState *gs = [GameState sharedGameState];
    FullStructureProto *s = [gs structWithId:p.structId];
    self.jobId = p.upgradeStructJobId;
    self.jobType = kUpgradeStructJob;
    self.title = [NSString stringWithFormat:@"Upgrade %@ to Level %d", s.name, p.levelReq];
    self.total = p.levelReq;
  }
  return self;
}

- (id) initWithCoinRetrieval:(int)amount questId:(int)questId {
  if ((self = [super init])) {
    self.jobId = questId;
    self.jobType = kCoinRetrievalJob;
    self.title = [NSString stringWithFormat:@"Collect %d silver from your income buildings", amount];
    self.total = amount;
  }
  return self;
}

- (id) initWithSpecialQuestAction:(SpecialQuestAction)sqa questId:(int)questId {
  if ((self = [super init])) {
    self.jobId = questId;
    self.jobType = kSpecialJob;
    
    NSString *desc = nil;
    switch (sqa) {
      case SpecialQuestActionSellToArmory:
        desc = @"Sell 1 Item to the Armory";
        break;
        
      case SpecialQuestActionDepositInVault:
        desc = @"Make 1 Deposit to the Vault";
        break;
        
      case SpecialQuestActionWriteOnEnemyWall:
        desc = @"Write on an Enemy's Wall";
        break;
        
      case SpecialQuestActionPostToMarketplace:
        desc = @"Post an Item to the Marketplace";
        break;
        
      case SpecialQuestActionWithdrawFromVault:
        desc = @"Make 1 Withdrawal from the Vault";
        break;
        
      case SpecialQuestActionPurchaseFromArmory:
        desc = @"Purchase 1 Item from the Armory";
        break;
        
      case SpecialQuestActionPurchaseFromMarketplace:
        desc = @"Purchase 1 Item from the Marketplace";
        break;
        
      case SpecialQuestActionRequestJoinClan:
        desc = @"Request to Join 1 Clan";
        
      default:
        break;
    }
    self.title = desc;
    
    self.total = 1;
  }
  return self;
}

+ (NSArray *)jobsForQuest:(FullQuestProto *)fqp {
  GameState *gs = [GameState sharedGameState];
  NSMutableArray *jobs = [NSMutableArray array];
  UserJob *job = nil;
  
  for (NSNumber *n in fqp.taskReqsList) {
    job = [[UserJob alloc] initWithTask:[gs taskWithId:n.intValue]];
    [jobs addObject:job];
    [job release];
  }
  
  for (NSNumber *n in fqp.defeatTypeReqsList) {
    job = [[UserJob alloc] initWithDefeatTypeJob:[gs.staticDefeatTypeJobs objectForKey:n]];
    [jobs addObject:job];
    [job release];
  }
  
  for (NSNumber *n in fqp.possessEquipJobReqsList) {
    job = [[UserJob alloc] initWithPossessEquipJob:[gs.staticPossessEquipJobs objectForKey:n]];
    [jobs addObject:job];
    [job release];
  }
  
  for (NSNumber *n in fqp.buildStructJobsReqsList) {
    job = [[UserJob alloc] initWithBuildStructJob:[gs.staticBuildStructJobs objectForKey:n]];
    [jobs addObject:job];
    [job release];
  }
  
  for (NSNumber *n in fqp.upgradeStructJobsReqsList) {
    job = [[UserJob alloc] initWithUpgradeStructJob:[gs.staticUpgradeStructJobs objectForKey:n]];
    [jobs addObject:job];
    [job release];
  }
  
  if (fqp.coinRetrievalReq > 0) {
    job = [[UserJob alloc] initWithCoinRetrieval:fqp.coinRetrievalReq questId:fqp.questId];
    [jobs addObject:job];
    [job release];
  }
  
  if (fqp.hasSpecialQuestActionReq) {
    job = [[UserJob alloc] initWithSpecialQuestAction:fqp.specialQuestActionReq questId:fqp.questId];
    [jobs addObject:job];
    [job release];
  }
  
  return jobs;
}

- (void) dealloc {
  self.title = nil;
  self.subtitle = nil;
  [super dealloc];
}

@end

@implementation ForgeAttempt

@synthesize blacksmithId, equipId, level;
@synthesize startTime, isComplete, guaranteed;
@synthesize speedupTime;

- (id) initWithUnhandledBlacksmithAttemptProto:(UnhandledBlacksmithAttemptProto *)attempt {
  if ((self = [super init])) {
    self.blacksmithId = attempt.blacksmithId;
    self.equipId = attempt.equipId;
    self.level = attempt.goalLevel-1;
    self.startTime = [NSDate dateWithTimeIntervalSince1970:attempt.startTime/1000.0];
    self.isComplete = attempt.attemptComplete;
    self.guaranteed = attempt.guaranteed;
    self.speedupTime = attempt.hasTimeOfSpeedup ? [NSDate dateWithTimeIntervalSince1970:attempt.timeOfSpeedup/1000.0] : nil;
  }
  return self;
}

+ (id) forgeAttemptWithUnhandledBlacksmithAttemptProto:(UnhandledBlacksmithAttemptProto *)attempt {
  return [[[self alloc] initWithUnhandledBlacksmithAttemptProto:attempt] autorelease];
}

- (void) dealloc {
  self.startTime = nil;
  self.speedupTime = nil;
  [super dealloc];
}

@end

@implementation ChatMessage

@synthesize message, sender, date, isAdmin;

- (id) initWithProto:(GroupChatMessageProto *)p {
  if ((self = [super init])) {
    self.message = p.content;
    self.sender = p.sender;
    self.date = [NSDate dateWithTimeIntervalSince1970:p.timeOfChat/1000.];
    self.isAdmin = p.isAdmin;
  }
  return self;
}

- (void) dealloc {
  self.message = nil;
  self.sender = nil;
  self.date = nil;
  [super dealloc];
}

@end

@implementation UserExpansion

@synthesize userId, isExpanding, lastExpandDirection, lastExpandTime;
@synthesize farLeftExpansions, farRightExpansions, nearLeftExpansions, nearRightExpansions;

- (id) initWithFullUserCityExpansionDataProto:(FullUserCityExpansionDataProto *)proto {
  if ((self = [super init])) {
    self.userId = proto.userId;
    self.farLeftExpansions = proto.farLeftExpansions;
    self.farRightExpansions = proto.farRightExpansions;
    self.nearLeftExpansions = proto.nearLeftExpansions;
    self.nearRightExpansions = proto.nearRightExpansions;
    self.lastExpandTime = proto.hasLastExpandTime ? [NSDate dateWithTimeIntervalSince1970:proto.lastExpandTime/1000.0] : nil;
    self.isExpanding = proto.isExpanding;
    self.lastExpandDirection = proto.lastExpandDirection;
  }
  return self;
}

+ (id) userExpansionWithFullUserCityExpansionDataProto:(FullUserCityExpansionDataProto *)proto {
  return [[[self alloc] initWithFullUserCityExpansionDataProto:proto] autorelease];
}

- (int) numCompletedExpansions {
  return farLeftExpansions + farRightExpansions + nearLeftExpansions + nearRightExpansions;
}

- (void) dealloc {
  self.lastExpandTime = nil;
  [super dealloc];
}

@end

@implementation UserBoss

- (id) initWithFullUserBossProto:(FullUserBossProto *)ub {
  if ((self = [super init])) {
    self.bossId = ub.bossId;
    self.userId = ub.userId;
    self.curHealth = ub.curHealth;
    self.numTimesKilled = ub.numTimesKilled;
    self.startTime = ub.hasStartTime ? [NSDate dateWithTimeIntervalSince1970:ub.startTime/1000.] : nil;
    self.lastKilledTime = ub.hasLastKilledTime ? [NSDate dateWithTimeIntervalSince1970:ub.lastKilledTime/1000.] : nil;
    
    if ([self isAlive] && ![self hasBeenAttacked]) {
      GameState *gs = [GameState sharedGameState];
      FullBossProto *fbp = [gs bossWithId:_bossId];
      self.curHealth = fbp.baseHealth;
    }
  }
  return self;
}

+ (id) userBossWithFullUserBossProto:(FullUserBossProto *)ub {
  return [[[self alloc] initWithFullUserBossProto:ub] autorelease];
}

- (NSDate *) nextRespawnTime {
  GameState *gs = [GameState sharedGameState];
  FullBossProto *fbp = [gs bossWithId:_bossId];
  BOOL validLastKilledTime = self.lastKilledTime.timeIntervalSince1970 > self.startTime.timeIntervalSince1970;
  NSDate *baseDate = validLastKilledTime ? self.lastKilledTime : [self.startTime dateByAddingTimeInterval:fbp.minutesToKill*60];
  return [baseDate dateByAddingTimeInterval:fbp.minutesToRespawn*60];
}

- (NSDate *) timeUpDate {
  GameState *gs = [GameState sharedGameState];
  FullBossProto *fbp = [gs bossWithId:_bossId];
  return [self.startTime dateByAddingTimeInterval:fbp.minutesToKill*60];
}

- (BOOL) isAlive {
  if (!self.startTime) {
    return YES;
  }
  
  BOOL validLastKilledTime = self.lastKilledTime.timeIntervalSince1970 > self.startTime.timeIntervalSince1970;
  NSDate *endDate = validLastKilledTime ? self.lastKilledTime : [self timeUpDate];
  NSDate *nextRespawnTime = [self nextRespawnTime];
  NSDate *now = [NSDate date];
  
  return now.timeIntervalSince1970 < endDate.timeIntervalSince1970 || now.timeIntervalSince1970 > nextRespawnTime.timeIntervalSince1970;
}

- (BOOL) hasBeenAttacked {
  if (!self.startTime) {
    return NO;
  }
  
  BOOL validLastKilledTime = self.lastKilledTime.timeIntervalSince1970 > self.startTime.timeIntervalSince1970;
  NSDate *lastEndDate = validLastKilledTime ? self.lastKilledTime : [self timeUpDate];
  NSDate *nextRespawnTime = [self nextRespawnTime];
  NSDate *now = [NSDate date];
  
  return !(now.timeIntervalSince1970 > lastEndDate.timeIntervalSince1970 && now.timeIntervalSince1970 > nextRespawnTime.timeIntervalSince1970);
}

- (void) createTimer {
  [_timer invalidate];
  self.timer = nil;
  
  if ([self isAlive]) {
    if ([self hasBeenAttacked]) {
      // Boss is still alive
      NSDate *timeUpDate = [self timeUpDate];
      self.timer = [NSTimer timerWithTimeInterval:timeUpDate.timeIntervalSinceNow target:self selector:@selector(timeUp) userInfo:nil repeats:NO];
      LNLog(@"Firing up boss time up timer with time interval %f", timeUpDate.timeIntervalSinceNow);
    }
  } else {
    // Boss is dead
    NSDate *respawnDate = [self nextRespawnTime];
    self.timer = [NSTimer timerWithTimeInterval:respawnDate.timeIntervalSinceNow target:self selector:@selector(respawn) userInfo:nil repeats:NO];
    LNLog(@"Firing up boss respawn timer with time interval %f", respawnDate.timeIntervalSinceNow);
  }
  
  if (self.timer) {
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
  }
}

- (void) respawn {
  GameState *gs = [GameState sharedGameState];
  FullBossProto *fbp = [gs bossWithId:_bossId];
  self.curHealth = fbp.baseHealth;
  LNLog(@"Respawning boss..");
  [_delegate bossRespawned:self];
}

- (void) timeUp {
  [_delegate bossTimeUp:self];
  LNLog(@"Time's up");
  [self createTimer];
  
}

- (void) dealloc {
  self.startTime = nil;
  [self.timer invalidate];
  self.timer = nil;
  [super dealloc];
}

@end

@implementation BossReward

@end

@implementation ClanTowerUserBattle

- (void) dealloc {
  self.attacker = nil;
  self.defender = nil;
  self.date = nil;
  [super dealloc];
}

@end
