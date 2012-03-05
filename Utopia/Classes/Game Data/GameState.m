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

@implementation GameState

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

@synthesize maxCityAccessible = _maxCityAccessible;
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

@synthesize attackList = _attackList;

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
    
    //TODO: take this out
    _userId = 2;
    _name = @"Ashwin";
    _type = UserTypeBadMage;
    
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
  self.connected = YES;
  
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
}

- (id) getStaticDataFrom:(NSDictionary *)dict withId:(int)itemId {
  NSNumber *num = [NSNumber numberWithInt:itemId];
  id p = [dict objectForKey:num];
  while (!p) {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    p = [dict objectForKey:num];
  }
  return p;
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
  self.myEquips = [NSMutableArray array];
  for (FullUserEquipProto *eq in equips) {
    [self.myEquips addObject:[UserEquip userEquipWithProto:eq]];
  }
}

- (void) addToMyStructs:(NSArray *)structs {
  self.myStructs = [NSMutableArray array];
  for (FullUserStructureProto *st in structs) {
    [self.myStructs addObject:[UserStruct userStructWithProto:st]];
  }
}

- (void) addToMyCities:(NSArray *)cities {
  self.myCities = [NSMutableDictionary dictionaryWithCapacity:cities.count];
  for (FullUserCityProto *cit in cities) {
    [self.myCities setObject:[UserCity userCityWithProto:cit] forKey:[NSNumber numberWithInt:cit.cityId]];
  }
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
    if (p.cityId > _maxCityAccessible && p.minLevel <= _level) {
      _maxCityAccessible = p.cityId;
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

- (void) dealloc {
  self.name = nil;
  self.marketplaceEquipPosts = nil;
  self.marketplaceEquipPostsFromSender = nil;
  self.staticTasks = nil;
  self.staticCities = nil;
  self.staticEquips = nil;
  self.staticQuests = nil;
  self.staticStructs = nil;
  self.staticDefeatTypeJobs = nil;
  self.staticBuildStructJobs = nil;
  self.staticPossessEquipJobs = nil;
  self.staticUpgradeStructJobs = nil;
  self.carpenterStructs = nil;
  self.armoryWeapons = nil;
  self.armoryArmor = nil;
  self.armoryAmulets = nil;
  self.attackList = nil;
  [super dealloc];
}

@end
