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
@synthesize health = _health;
@synthesize maxHealth = _maxHealth;
@synthesize diamonds = _diamonds;
@synthesize coins = _coins;
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

SYNTHESIZE_SINGLETON_FOR_CLASS(GameState);

- (id) init {
  if ((self = [super init])) {
    self.connected = NO;
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
  self.health = user.health;
  self.maxHealth = user.healthMax;
  self.diamonds = user.diamonds;
  self.coins = user.coins;
  self.vaultBalance = user.vaultBalance;
  self.armyCode = user.armyCode;
}

+ (NSString *) font {
  return fontName;
}

@end
