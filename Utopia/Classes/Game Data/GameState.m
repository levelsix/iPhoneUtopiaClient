//
//  GameState.m
//  Utopia
//
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GameState.h"
#import "SynthesizeSingleton.h"

@implementation GameState

static NSString *fontName = @"AJensonPro-BoldCapt";

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
@synthesize gold = _gold;
@synthesize silver = _silver;
@synthesize wood = _wood;
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
@synthesize marketplaceWoodEarnings = _marketplaceWoodEarnings;

@synthesize marketplaceEquipPosts = _marketplaceEquipPosts;
@synthesize marketplaceCurrencyPosts = _marketplaceCurrencyPosts;
@synthesize marketplaceEquipPostsFromSender = _marketplaceEquipPostsFromSender;
@synthesize marketplaceCurrencyPostsFromSender = _marketplaceCurrencyPostsFromSender;

SYNTHESIZE_SINGLETON_FOR_CLASS(GameState);

- (id) init {
  if ((self = [super init])) {
    _connected = NO;
    _marketplaceEquipPosts = [[NSMutableArray alloc] init];
    _marketplaceCurrencyPosts = [[NSMutableArray alloc] init];
    _marketplaceEquipPostsFromSender = [[NSMutableArray alloc] init];
    _marketplaceCurrencyPostsFromSender = [[NSMutableArray alloc] init];
    _userId = 2;
    _marketplaceGoldEarnings = 2;
  }
  return self;
}

- (void) userConnected: (FullUserProto *)user {
  self.connected = YES;
  
  // Copy over data from full user proto
  self.userId = user.userId;
  self.name = user.name;
  self.type = user.userType;
  self.level = user.level;
  self.defense = user.defense;
  self.attack = user.attack;
  self.currentEnergy = user.energy;
  self.maxEnergy = user.energyMax;
  self.currentStamina = user.stamina;
  self.maxStamina = user.staminaMax;
  self.gold = user.diamonds;
  self.silver = user.coins;
  self.vaultBalance = user.vaultBalance;
  self.armyCode = user.armyCode;
  self.marketplaceGoldEarnings = user.marketplaceDiamondsEarnings;
  self.marketplaceSilverEarnings = user.marketplaceCoinsEarnings;
  self.marketplaceWoodEarnings = user.marketplaceWoodEarnings;
}

+ (NSString *) font {
  return fontName;
}

- (void) dealloc {
  self.marketplaceEquipPosts = nil;
  self.marketplaceCurrencyPosts = nil;
  self.marketplaceEquipPostsFromSender = nil;
  self.marketplaceCurrencyPostsFromSender = nil;
  [super dealloc];
}

@end
