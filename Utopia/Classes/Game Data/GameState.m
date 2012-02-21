//
//  GameState.m
//  Utopia
//
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GameState.h"
#import "SynthesizeSingleton.h"
#import "SocketCommunication.h"
#import "UserData.h"

@implementation GameState

@synthesize connected = nilconnected;
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
@synthesize armyCode = _armyCode;
@synthesize battlesWon = _battlesWon;
@synthesize battlesLost = _battlesLost;
@synthesize hourlyCoins = _hourlyCoins;
@synthesize location = _location;
@synthesize numReferrals = _numReferrals;
@synthesize experience = _experience;
@synthesize tasksCompleted = _tasksCompleted;
@synthesize skillPoints = _skillPoints;
@synthesize marketplaceSilverEarnings = _marketplaceSilverEarnings;
@synthesize marketplaceGoldEarnings = _marketplaceGoldEarnings;
@synthesize numPostsInMarketplace = _numPostsInMarketplace;
@synthesize numMarketplaceSalesUnredeemed = _numMarketplaceSalesUnredeemed;

@synthesize marketplaceEquipPosts = _marketplaceEquipPosts;
@synthesize marketplaceCurrencyPosts = _marketplaceCurrencyPosts;
@synthesize marketplaceEquipPostsFromSender = _marketplaceEquipPostsFromSender;
@synthesize marketplaceCurrencyPostsFromSender = _marketplaceCurrencyPostsFromSender;

@synthesize staticTasks = _staticTasks;
@synthesize staticCities = _staticCities;
@synthesize staticEquips = _staticEquips;
@synthesize staticQuests = _staticQuests;
@synthesize staticStructs = _staticStructs;
@synthesize staticDefeatTypeJobs = _staticDefeatTypeJobs;
@synthesize staticBuildStructJobs = _staticBuildStructJobs;
@synthesize staticPossessEquipJobProto = _staticPossessEquipJobProto;
@synthesize staticUpgradeStructJobProto = _staticUpgradeStructJobProto;

@synthesize myEquips = _myEquips;
@synthesize myStructs = _myStructs;

SYNTHESIZE_SINGLETON_FOR_CLASS(GameState);

- (id) init {
  if ((self = [super init])) {
    _connected = NO;
    _marketplaceEquipPosts = [[NSMutableArray alloc] init];
    _marketplaceCurrencyPosts = [[NSMutableArray alloc] init];
    _marketplaceEquipPostsFromSender = [[NSMutableArray alloc] init];
    _marketplaceCurrencyPostsFromSender = [[NSMutableArray alloc] init];
    _staticTasks = [[NSMutableDictionary alloc] init];
    _staticCities = [[NSMutableDictionary alloc] init];
    _staticEquips = [[NSMutableDictionary alloc] init];
    _staticQuests = [[NSMutableDictionary alloc] init];
    _staticStructs = [[NSMutableDictionary alloc] init];
    _staticDefeatTypeJobs = [[NSMutableDictionary alloc] init];
    _staticBuildStructJobs = [[NSMutableDictionary alloc] init];
    _staticPossessEquipJobProto = [[NSMutableDictionary alloc] init];
    _staticUpgradeStructJobProto = [[NSMutableDictionary alloc] init];
    
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
  self.hourlyCoins = user.hourlyCoins;
  self.armyCode = user.armyCode;
  self.numReferrals = user.numReferrals;
  self.marketplaceGoldEarnings = user.marketplaceDiamondsEarnings;
  self.marketplaceSilverEarnings = user.marketplaceCoinsEarnings;
  self.numPostsInMarketplace = user.numPostsInMarketplace;
  self.numMarketplaceSalesUnredeemed = user.numMarketplaceSalesUnredeemed;
}

- (FullEquipProto *) equipWithId:(int)equipId {
  FullEquipProto *p = nil;
  while (!p) {
    p = [self.staticEquips objectForKey:[NSNumber numberWithInt:equipId]];
  }
  return p;
}

- (FullStructureProto *) structWithId:(int)structId {
  FullStructureProto *p = nil;
  while (!p) {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    p = [self.staticStructs objectForKey:[NSNumber numberWithInt:structId]];
  }
  return p;
}

- (void) addToMyEquips:(NSArray *)equips {
  self.myEquips = [NSMutableArray array];
  for (FullUserEquipProto *eq in equips) {
    [self.myEquips addObject:[UserEquip userEquipWithProto:eq]];
  }
}

- (void) addToMyStructs:(NSArray *)structs {
  self.myStructs = [NSMutableArray array];
  for (FullUserStructureProto *eq in structs) {
    [self.myStructs addObject:[UserStruct userStructWithProto:eq]];
  }
}

- (void) dealloc {
  self.name = nil;
  self.marketplaceEquipPosts = nil;
  self.marketplaceCurrencyPosts = nil;
  self.marketplaceEquipPostsFromSender = nil;
  self.marketplaceCurrencyPostsFromSender = nil;
  self.staticTasks = nil;
  self.staticCities = nil;
  self.staticEquips = nil;
  self.staticQuests = nil;
  self.staticStructs = nil;
  self.staticDefeatTypeJobs = nil;
  self.staticBuildStructJobs = nil;
  self.staticPossessEquipJobProto = nil;
  self.staticUpgradeStructJobProto = nil;
  [super dealloc];
}

@end
