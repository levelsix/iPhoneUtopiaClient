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

@implementation UserEquip

@synthesize userId, equipId, quantity;

- (id) initWithEquipProto:(FullUserEquipProto *)proto {
  if ((self = [super init])){
    self.userId = proto.userId;
    self.equipId = proto.equipId;
    self.quantity = proto.quantity;
  }
  return self;
}

+ (id) userEquipWithProto:(FullUserEquipProto *)proto {
  return [[[self alloc] initWithEquipProto:proto] autorelease];
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
    self.purchaseTime = proto.hasPurchaseTime ? [NSDate dateWithTimeIntervalSince1970:proto.purchaseTime/1000] : nil;
    self.lastRetrieved = proto.hasLastRetrieved ? [NSDate dateWithTimeIntervalSince1970:proto.lastRetrieved/1000] : nil;
    self.lastUpgradeTime = proto.hasLastUpgradeTime ? [NSDate dateWithTimeIntervalSince1970:proto.lastUpgradeTime/1000] : nil;
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

@synthesize name, type, minLevel, size;

- (id) initWithType:(CritStructType)t {
  if ((self = [super init])) {
    self.type = t;
  }
  return self;
}

- (void) setType:(CritStructType)t {
  Globals *gl = [Globals sharedGlobals];
  type = t;
  switch (type) {
    case CritStructTypeVault:
      name = @"Vault";
      minLevel = gl.minLevelForVault;
      size = CGSizeMake(gl.vaultXLength, gl.vaultYLength);
      break;
      
    case CritStructTypeArmory:
      name = @"Armory";
      minLevel = gl.minLevelForArmory;
      size = CGSizeMake(gl.armoryXLength, gl.armoryYLength);
      break;
      
    case CritStructTypeAviary:
      name = @"Aviary";
      minLevel = 1;
      size = CGSizeMake(gl.aviaryXLength, gl.aviaryYLength);
      break;
      
    case CritStructTypeCarpenter:
      name = @"Carpenter";
      minLevel = 1;
      size = CGSizeMake(gl.carpenterXLength, gl.carpenterYLength);
      break;
      
    case CritStructTypeMarketplace:
      name = @"Marketplace";
      minLevel = gl.minLevelForMarketplace;
      size = CGSizeMake(gl.marketplaceXLength, gl.marketplaceYLength);
      break;
      
    default:
      break;
  }
}

- (void) openMenu {
  switch (self.type) {
    case CritStructTypeVault:
      [VaultMenuController displayView];
      break;
      
    case CritStructTypeArmory:
      [ArmoryViewController displayView];
      break;
      
    case CritStructTypeAviary:
      [MapViewController displayView];
      break;
      
    case CritStructTypeCarpenter:
      [CarpenterMenuController displayView];
      break;
      
    case CritStructTypeMarketplace:
      [MarketplaceViewController displayView];
      
    default:
      break;
  }
}

- (void) dealloc {
  self.name = nil;
  [super dealloc];
}

@end

@implementation UserCritStruct

@synthesize location, orientation;

+ (id) critStructWithProto:(FullUserCritstructProto *)proto {
  return [[[self alloc] initWithCritStructProto:proto] autorelease];
}

- (id) initWithCritStructProto:(FullUserCritstructProto *)proto {
  if ((self = [super initWithType:proto.type])) {
    CGPoint coordinates = CGPointMake(proto.coords.x, proto.coords.y);
    location.size = self.size;
    location.origin = coordinates;
    orientation = proto.orientation;
  }
  return self;
}

@end

@implementation UserNotification

@synthesize time, type, otherPlayer;
@synthesize marketPost;
@synthesize battleResult, coinsStolen, stolenEquipId;

- (id) initBattleNotificationAtStartup:(StartupResponseProto_AttackedNotificationProto *)proto {
  if ((self = [super init])) {
    self.otherPlayer = proto.attacker;
    self.battleResult = proto.battleResult;
    self.time = [NSDate dateWithTimeIntervalSince1970:proto.battleCompleteTime/1000];
    self.coinsStolen = proto.coinsStolen;
    self.stolenEquipId = proto.stolenEquipId;
    self.type = kNotificationBattle;
  }
  return self;
}

- (id) initMarketplaceNotificationAtStartup:(StartupResponseProto_MarketplacePostPurchasedNotificationProto *)proto {
  if ((self = [super init])) {
    self.otherPlayer = proto.buyer;
    self.time = [NSDate dateWithTimeIntervalSince1970:proto.timeOfPurchase/1000];
    self.marketPost = proto.marketplacePost;
    self.type = kNotificationMarketplace;
  }
  return self;
}

- (id) initReferralNotificationAtStartup:(StartupResponseProto_ReferralNotificationProto *)proto {
  if ((self = [super init])) {
    self.otherPlayer = proto.referred;
    self.time = [NSDate dateWithTimeIntervalSince1970:proto.recruitTime/1000];
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
    self.stolenEquipId = proto.equipGained.equipId;
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

- (NSString *) description {
  return [NSString stringWithFormat:@"<UserNotification> Type: %d", self.type];
}

- (void) dealloc {
  self.time = nil;
  self.otherPlayer = nil;
  self.marketPost = nil;
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
    self.title = [NSString stringWithFormat:@"Defeat %d %@ %@%@ in %@", p.numEnemiesToDefeat, [Globals factionForUserType:p.typeOfEnemy], [Globals classForUserType:p.typeOfEnemy], p.numEnemiesToDefeat == 1 ? @"" : @"s", [gs cityWithId:p.cityId].name];
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
  
  return jobs;
}

- (void) dealloc {
  self.title = nil;
  self.subtitle = nil;
  [super dealloc];
}

@end
