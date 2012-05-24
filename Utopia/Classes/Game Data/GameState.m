//
//  GameState.m
//  Utopia
//
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GameState.h"
#import "SynthesizeSingleton.h"
#import "SocketCommunication.h"
#import "Globals.h"
#import "OutgoingEventController.h"
#import "TopBar.h"
#import "ActivityFeedController.h"

@implementation GameState

@synthesize isTutorial = _isTutorial;
@synthesize connected = _connected;
@synthesize userId = _userId;
@synthesize name = _name;
@synthesize type = _type;
@synthesize level = _level;
@synthesize defense = _defense;
@synthesize attack = _attack;
@synthesize currentEnergy = _currentEnergy;
@synthesize maxEnergy = _maxEnergy;
@synthesize currentStamina = _currentStamina;
@synthesize maxStamina = _maxStamina;
@synthesize maxHealth = _maxHealth;
@synthesize gold = _gold;
@synthesize silver = _silver;
@synthesize vaultBalance = _vaultBalance;
@synthesize referralCode = _referralCode;
@synthesize battlesWon = _battlesWon;
@synthesize battlesLost = _battlesLost;
@synthesize flees = _flees;
@synthesize location = _location;
@synthesize numReferrals = _numReferrals;
@synthesize experience = _experience;
@synthesize tasksCompleted = _tasksCompleted;
@synthesize skillPoints = _skillPoints;
@synthesize marketplaceSilverEarnings = _marketplaceSilverEarnings;
@synthesize marketplaceGoldEarnings = _marketplaceGoldEarnings;
@synthesize numPostsInMarketplace = _numPostsInMarketplace;
@synthesize numMarketplaceSalesUnredeemed = _numMarketplaceSalesUnredeemed;
@synthesize weaponEquipped = _weaponEquipped;
@synthesize armorEquipped = _armorEquipped;
@synthesize amuletEquipped = _amuletEquipped;
@synthesize lastEnergyRefill = _lastEnergyRefill;
@synthesize lastStaminaRefill = _lastStaminaRefill;
@synthesize lastShortLicensePurchaseTime = _lastShortLicensePurchaseTime;
@synthesize lastLongLicensePurchaseTime = _lastLongLicensePurchaseTime;

@synthesize maxCity = _maxCity;
@synthesize expRequiredForCurrentLevel = _expRequiredForCurrentLevel;
@synthesize expRequiredForNextLevel = _expRequiredForNextLevel;

@synthesize marketplaceEquipPosts = _marketplaceEquipPosts;
@synthesize marketplaceEquipPostsFromSender = _marketplaceEquipPostsFromSender;

@synthesize staticTasks = _staticTasks;
@synthesize staticCities = _staticCities;
@synthesize staticEquips = _staticEquips;
@synthesize staticQuests = _staticQuests;
@synthesize staticStructs = _staticStructs;
@synthesize staticDefeatTypeJobs = _staticDefeatTypeJobs;
@synthesize staticBuildStructJobs = _staticBuildStructJobs;
@synthesize staticPossessEquipJobs = _staticPossessEquipJobs;
@synthesize staticUpgradeStructJobs = _staticUpgradeStructJobs;

@synthesize carpenterStructs = _carpenterStructs;
@synthesize armoryWeapons = _armoryWeapons;
@synthesize armoryArmor = _armoryArmor;
@synthesize armoryAmulets = _armoryAmulets;

@synthesize myEquips = _myEquips;
@synthesize myStructs = _myStructs;
@synthesize myCities = _myCities;

@synthesize availableQuests = _availableQuests;
@synthesize inProgressCompleteQuests = _inProgressCompleteQuests;
@synthesize inProgressIncompleteQuests = _inProgressIncompleteQuests;

@synthesize attackList = _attackList;
@synthesize notifications = _notifications;
@synthesize wallPosts = _wallPosts;

SYNTHESIZE_SINGLETON_FOR_CLASS(GameState);

- (id) init {
  if ((self = [super init])) {
    _connected = NO;
    _marketplaceEquipPosts = [[NSMutableArray alloc] init];
    _marketplaceEquipPostsFromSender = [[NSMutableArray alloc] init];
    _staticTasks = [[NSMutableDictionary alloc] init];
    _staticCities = [[NSMutableDictionary alloc] init];
    _staticEquips = [[NSMutableDictionary alloc] init];
    _staticQuests = [[NSMutableDictionary alloc] init];
    _staticStructs = [[NSMutableDictionary alloc] init];
    _staticDefeatTypeJobs = [[NSMutableDictionary alloc] init];
    _staticBuildStructJobs = [[NSMutableDictionary alloc] init];
    _staticPossessEquipJobs = [[NSMutableDictionary alloc] init];
    _staticUpgradeStructJobs = [[NSMutableDictionary alloc] init];
    _attackList = [[NSMutableArray alloc] init];
    _notifications = [[NSMutableArray alloc] init];
    _myEquips = [[NSMutableArray alloc] init];
    _myStructs = [[NSMutableArray alloc] init];
    _myCities = [[NSMutableDictionary alloc] init];
    _wallPosts = [[NSMutableArray alloc] init];
    
    _availableQuests = [[NSMutableDictionary alloc] init];
    _inProgressCompleteQuests = [[NSMutableDictionary alloc] init];
    _inProgressIncompleteQuests = [[NSMutableDictionary alloc] init];
    
    _silver = 10000;
    _gold = 50;
    _vaultBalance = 2500;
    _currentEnergy = 1;
    _maxEnergy = 3;
    _currentStamina = 1;
    _maxStamina = 3;
    _maxHealth = 1;
    _level = 12;
    _experience = 30;
    _expRequiredForNextLevel = 40;
  }
  return self;
}

- (void) updateUser:(FullUserProto *)user {
  // Copy over data from full user proto
  if (_userId != user.userId || ![_name isEqualToString:user.name] || _type != user.userType) {
    self.userId = user.userId;
    self.name = user.name;
    self.type = user.userType;
    [[SocketCommunication sharedSocketCommunication] rebuildSender];
  }
  self.level = user.level;
  self.defense = user.defense;
  self.attack = user.attack;
  self.currentEnergy = user.energy;
  self.maxEnergy = user.energyMax;
  self.currentStamina = user.stamina;
  self.maxStamina = user.staminaMax;
  self.maxHealth = user.healthMax;
  self.skillPoints = user.skillPoints;
  self.gold = user.diamonds;
  self.silver = user.coins;
  self.vaultBalance = user.vaultBalance;
  self.experience = user.experience;
  self.tasksCompleted = user.tasksCompleted;
  self.battlesWon = user.battlesWon;
  self.battlesLost = user.battlesLost;
  self.flees = user.flees;
  self.referralCode = user.referralCode;
  self.numReferrals = user.numReferrals;
  self.marketplaceGoldEarnings = user.marketplaceDiamondsEarnings;
  self.marketplaceSilverEarnings = user.marketplaceCoinsEarnings;
  self.numPostsInMarketplace = user.numPostsInMarketplace;
  self.numMarketplaceSalesUnredeemed = user.numMarketplaceSalesUnredeemed;
  self.weaponEquipped = user.weaponEquipped;
  self.armorEquipped = user.armorEquipped;
  self.amuletEquipped = user.amuletEquipped;
  self.location = CLLocationCoordinate2DMake(user.userLocation.latitude, user.userLocation.longitude);
  
  self.lastEnergyRefill = [NSDate dateWithTimeIntervalSince1970:user.lastEnergyRefillTime/1000];
  self.lastStaminaRefill = [NSDate dateWithTimeIntervalSince1970:user.lastStaminaRefillTime/1000];
  self.lastShortLicensePurchaseTime = [NSDate dateWithTimeIntervalSince1970:user.lastShortLicensePurchaseTime/1000];
  self.lastLongLicensePurchaseTime = [NSDate dateWithTimeIntervalSince1970:user.lastLongLicensePurchaseTime/1000];
}

- (id) getStaticDataFrom:(NSDictionary *)dict withId:(int)itemId {
  if (itemId == 0) {
    [Globals popupMessage:@"Attempted to access static item 0"];
    return nil;
  }
  NSNumber *num = [NSNumber numberWithInt:itemId];
  id p = [dict objectForKey:num];
  int numTimes = 0;
  while (!p) {
    numTimes++;
    if (numTimes == 1000) {
      LNLog(@"Lotsa wait time for this");
    }
    //    NSAssert(numTimes < 1000000, @"Waiting too long for static data.. Probably not retrieved!", itemId);
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    // Need this in case game state gets deallocated while waiting for static data
    p = [dict objectForKey:num];
  }
  // Retain and autorelease in case data gets purged
  [p retain];
  return [p autorelease];
}

- (FullEquipProto *) equipWithId:(int)equipId {
  if (equipId == 0) {
    [Globals popupMessage:@"Attempted to access equip 0"];
    return nil;
  }
  return [self getStaticDataFrom:_staticEquips withId:equipId];
}

- (FullStructureProto *) structWithId:(int)structId {
  if (structId == 0) {
    [Globals popupMessage:@"Attempted to access struct 0"];
    return nil;
  }
  return [self getStaticDataFrom:_staticStructs withId:structId];
}

- (FullCityProto *) cityWithId:(int)cityId {
  if (cityId == 0) {
    [Globals popupMessage:@"Attempted to access city 0"];
    return nil;
  }
  return [self getStaticDataFrom:_staticCities withId:cityId];
}

- (FullTaskProto *) taskWithId:(int)taskId {
  if (taskId == 0) {
    [Globals popupMessage:@"Attempted to access task 0"];
    return nil;
  }
  return [self getStaticDataFrom:_staticTasks withId:taskId];
}

- (void) addToMyEquips:(NSArray *)equips {
  for (FullUserEquipProto *eq in equips) {
    [self.myEquips addObject:[UserEquip userEquipWithProto:eq]];
  }
}

- (void) addToMyStructs:(NSArray *)structs {
  for (FullUserStructureProto *st in structs) {
    [self.myStructs addObject:[UserStruct userStructWithProto:st]];
  }
}

- (void) addToMyCities:(NSArray *)cities {
  for (FullUserCityProto *cit in cities) {
    [self.myCities setObject:[UserCity userCityWithProto:cit] forKey:[NSNumber numberWithInt:cit.cityId]];
  }
}

- (void) addToAvailableQuests:(NSArray *)quests {
  for (FullQuestProto *fqp in quests) {
    [self.availableQuests setObject:fqp forKey:[NSNumber numberWithInt:fqp.questId]];
  }
}

- (void) addToInProgressCompleteQuests:(NSArray *)quests {
  for (FullQuestProto *fqp in quests) {
    [self.inProgressCompleteQuests setObject:fqp forKey:[NSNumber numberWithInt:fqp.questId]];
  }
}

- (void) addToInProgressIncompleteQuests:(NSArray *)quests {
  for (FullQuestProto *fqp in quests) {
    [self.inProgressIncompleteQuests setObject:fqp forKey:[NSNumber numberWithInt:fqp.questId]];
  }
}

- (void) addNotification:(UserNotification *)un {
  [self.notifications addObject:un];
  [self.notifications sortUsingComparator:^NSComparisonResult(UserNotification *obj1, UserNotification *obj2) {
    return [obj2.time compare:obj1.time];
  }];
  
  [[[ActivityFeedController sharedActivityFeedController] activityTableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
  
  [[[TopBar sharedTopBar] profilePic] incrementNotificationBadge];
}

- (void) addWallPost:(PlayerWallPostProto *)wallPost {
  [self.wallPosts addObject:wallPost];
  [self.wallPosts sortUsingComparator:^NSComparisonResult(PlayerWallPostProto *obj1, PlayerWallPostProto *obj2) {
    if (obj1.timeOfPost < obj2.timeOfPost) {
      return NSOrderedDescending;
    } else if (obj1.timeOfPost == obj2.timeOfPost) {
      return NSOrderedSame;
    } else {
      return NSOrderedAscending;
    }
  }];
}

- (UserEquip *) myEquipWithId:(int)equipId {
  for (UserEquip *ue in self.myEquips) {
    if (ue.equipId == equipId) {
      return ue;
    }
  }
  return nil;
}

- (UserStruct *) myStructWithId:(int)structId {
  for (UserStruct *us in self.myStructs) {
    if (us.structId == structId) {
      return us;
    }
  }
  return nil;
}

- (UserCity *) myCityWithId:(int)cityId {
  return [self.myCities objectForKey:[NSNumber numberWithInt:cityId]];
}

- (void) addToStaticStructs:(NSArray *)arr {
  for (FullStructureProto *p in arr) {
    [self.staticStructs setObject:p forKey:[NSNumber numberWithInt:p.structId]];
  }
}

- (void) addToStaticTasks:(NSArray *)arr {
  for (FullTaskProto *p in arr) {
    [self.staticTasks setObject:p forKey:[NSNumber numberWithInt:p.taskId]];
  }
}

- (void) addToStaticQuests:(NSArray *)arr {
  for (FullQuestProto *p in arr) {
    [self.staticQuests setObject:p forKey:[NSNumber numberWithInt:p.questId]];
  }
}

- (void) addToStaticCities:(NSArray *)arr {
  for (FullCityProto *p in arr) {
    [self.staticCities setObject:p forKey:[NSNumber numberWithInt:p.cityId]];
    if (p.cityId > _maxCity) {
      _maxCity = p.cityId;
    }
  }
}

- (void) addToStaticEquips:(NSArray *)arr {
  for (FullEquipProto *p in arr) {
    [self.staticEquips setObject:p forKey:[NSNumber numberWithInt:p.equipId]];
  }
}

- (void) addToStaticBuildStructJobs:(NSArray *)arr {
  for (BuildStructJobProto *p in arr) {
    [self.staticBuildStructJobs setObject:p forKey:[NSNumber numberWithInt:p.buildStructJobId]];
  }
}

- (void) addToStaticDefeatTypeJobs:(NSArray *)arr {
  for (DefeatTypeJobProto *p in arr) {
    [self.staticDefeatTypeJobs setObject:p forKey:[NSNumber numberWithInt:p.defeatTypeJobId]];
  }
}

- (void) addToStaticPossessEquipJobs:(NSArray *)arr {
  for (PossessEquipJobProto *p in arr) {
    [self.staticPossessEquipJobs setObject:p forKey:[NSNumber numberWithInt:p.possessEquipJobId]];
  }
}

- (void) addToStaticUpgradeStructJobs:(NSArray *)arr {
  for (UpgradeStructJobProto *p in arr) {
    [self.staticUpgradeStructJobs setObject:p forKey:[NSNumber numberWithInt:p.upgradeStructJobId]];
  }
}

- (BOOL) hasValidLicense {
  Globals *gl = [Globals sharedGlobals];
  
  NSTimeInterval shortLic = [self.lastShortLicensePurchaseTime timeIntervalSinceNow];
  NSTimeInterval time = -((NSTimeInterval)gl.numDaysShortMarketplaceLicenseLastsFor)*24*60*60;
  if (shortLic > time) {
    return YES;
  }
  
  NSTimeInterval longLic = [self.lastLongLicensePurchaseTime timeIntervalSinceNow];
  time = -gl.numDaysLongMarketplaceLicenseLastsFor*24l*60l*60l;
  if (longLic > time) {
    return YES;
  }
  
  return NO;
}

- (void) changeQuantityForEquip:(int)equipId by:(int)qDelta {
  UserEquip *ue = [self myEquipWithId:equipId];
  if (ue) {
    ue.quantity += qDelta;
  } else {
    ue = [[UserEquip alloc] init];
    ue.userId = self.userId;
    ue.equipId = equipId;
    ue.quantity = qDelta;
    [_myEquips addObject:ue];
    [ue release];
  }
  
  if (ue.quantity < 1) {
    [_myEquips removeObject:ue];
    if (_weaponEquipped == equipId) {
      _weaponEquipped = 0;
    } else if (_armorEquipped == equipId) {
      _armorEquipped = 0;
    } else if (_amuletEquipped == equipId) {
      _amuletEquipped = 0;
    }
  }
}

- (void) purgeStaticData {
  [_staticQuests removeAllObjects];
  [_staticBuildStructJobs removeAllObjects];
  [_staticDefeatTypeJobs removeAllObjects];
  [_staticPossessEquipJobs removeAllObjects];
  [_staticUpgradeStructJobs removeAllObjects];
  
  // Reretrieve necessary data
  [[OutgoingEventController sharedOutgoingEventController] retrieveAllStaticData];
}

- (void) clearAllData {
  _connected = NO;
  self.marketplaceEquipPosts = [[NSMutableArray alloc] init];
  self.marketplaceEquipPostsFromSender = [[NSMutableArray alloc] init];
  self.staticTasks = [[NSMutableDictionary alloc] init];
  self.staticCities = [[NSMutableDictionary alloc] init];
  self.staticEquips = [[NSMutableDictionary alloc] init];
  self.staticQuests = [[NSMutableDictionary alloc] init];
  self.staticStructs = [[NSMutableDictionary alloc] init];
  self.staticDefeatTypeJobs = [[NSMutableDictionary alloc] init];
  self.staticBuildStructJobs = [[NSMutableDictionary alloc] init];
  self.staticPossessEquipJobs = [[NSMutableDictionary alloc] init];
  self.staticUpgradeStructJobs = [[NSMutableDictionary alloc] init];
  self.attackList = [[NSMutableArray alloc] init];
  self.notifications = [[NSMutableArray alloc] init];
  self.myEquips = [[NSMutableArray alloc] init];
  self.myStructs = [[NSMutableArray alloc] init];
  self.myCities = [[NSMutableDictionary alloc] init];
  self.wallPosts = [[NSMutableArray alloc] init];
  
  self.availableQuests = [[NSMutableDictionary alloc] init];
  self.inProgressCompleteQuests = [[NSMutableDictionary alloc] init];
  self.inProgressIncompleteQuests = [[NSMutableDictionary alloc] init];
}

- (void) dealloc {
  self.name = nil;
  self.referralCode = nil;
  self.carpenterStructs = nil;
  self.armoryWeapons = nil;
  self.armoryArmor = nil;
  self.armoryAmulets = nil;
  self.lastEnergyRefill = nil;
  self.lastStaminaRefill = nil;
  self.marketplaceEquipPosts = nil;
  self.marketplaceEquipPostsFromSender = nil;
  self.lastShortLicensePurchaseTime = nil;
  self.lastLongLicensePurchaseTime = nil;
  self.staticTasks = nil;
  self.staticCities = nil;
  self.staticEquips = nil;
  self.staticQuests = nil;
  self.staticStructs = nil;
  self.staticDefeatTypeJobs = nil;
  self.staticBuildStructJobs = nil;
  self.staticPossessEquipJobs = nil;
  self.staticUpgradeStructJobs = nil;
  self.myCities = nil;
  self.myEquips = nil;
  self.myStructs = nil;
  self.availableQuests = nil;
  self.inProgressCompleteQuests = nil;
  self.inProgressIncompleteQuests = nil;
  self.attackList = nil;
  self.notifications = nil;
  self.wallPosts = nil;
  [super dealloc];
}

@end
