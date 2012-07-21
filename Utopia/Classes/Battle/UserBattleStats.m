//
//  UserBattleStats.m
//  Utopia
//
//  Created by Kevin Calloway on 6/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "UserBattleStats.h"
#import "Globals.h"

@implementation UserBattleStats
@dynamic level;
@dynamic attack;
@dynamic defense;
@synthesize maxHealth;
@synthesize currentHealth;

-(int32_t)level
{
  if (_userProto) {    
    return _userProto.level;
  }
  
  return _gameState.level;
}

-(int)attack
{  
  if (_userProto) {
    UserEquip *weapon = _userProto.hasWeaponEquippedUserEquip ? (UserEquip *)_userProto.weaponEquippedUserEquip : nil;
    UserEquip *armor = _userProto.hasArmorEquippedUserEquip ? (UserEquip *)_userProto.armorEquippedUserEquip : nil;
    UserEquip *amulet = _userProto.hasAmuletEquippedUserEquip ? (UserEquip *)_userProto.amuletEquippedUserEquip : nil;
    return [_globals calculateAttackForAttackStat:_userProto.attack
                                           weapon:weapon
                                            armor:armor
                                           amulet:amulet];
  }
  
  GameState *gs = [GameState sharedGameState];
  int attack = [_globals calculateAttackForAttackStat:_gameState.attack
                                               weapon:[gs myEquipWithUserEquipId:gs.weaponEquipped]
                                                armor:[gs myEquipWithUserEquipId:gs.armorEquipped]
                                               amulet:[gs myEquipWithUserEquipId:gs.amuletEquipped]];
  
  return attack;
}

-(int)defense
{
  if (_userProto) {
    UserEquip *weapon = _userProto.hasWeaponEquippedUserEquip ? (UserEquip *)_userProto.weaponEquippedUserEquip : nil;
    UserEquip *armor = _userProto.hasArmorEquippedUserEquip ? (UserEquip *)_userProto.armorEquippedUserEquip : nil;
    UserEquip *amulet = _userProto.hasAmuletEquippedUserEquip ? (UserEquip *)_userProto.amuletEquippedUserEquip : nil;
    return [_globals calculateDefenseForDefenseStat:_userProto.defense
                                             weapon:weapon
                                              armor:armor
                                             amulet:amulet];
  }
  
  GameState *gs = [GameState sharedGameState];
  return [_globals calculateDefenseForDefenseStat:_gameState.defense
                                           weapon:[gs myEquipWithUserEquipId:gs.weaponEquipped]
                                            armor:[gs myEquipWithUserEquipId:gs.armorEquipped]
                                           amulet:[gs myEquipWithUserEquipId:gs.amuletEquipped]]; 
  
}

#pragma mark Create/Destroy
-(id)initWithUserProto:(FullUserProto *)user 
           orGameState:(GameState *)gameState
            andGlobals:(Globals*)globals
{
  self = [super init];
  
  if (self) {
    _userProto = user;
    _gameState = gameState;
    _globals   = globals;
    
    [_userProto retain];
    [_gameState retain];
    [_globals   retain];
  }
  
  return self;
}

-(void)dealloc
{
  [_userProto release];
  [_gameState release];
  [_globals   release];
  
  [super dealloc];
}

+(id<UserBattleStats>)createFromGameState
{
  UserBattleStats *stats = [[UserBattleStats alloc] 
                            initWithUserProto:nil
                            orGameState:[GameState sharedGameState] 
                            andGlobals:[Globals sharedGlobals]];
  [stats autorelease];
  return stats;  
}

+(id<UserBattleStats>)createWithFullUserProto:(FullUserProto *)user
{
  UserBattleStats *stats = [[UserBattleStats alloc] initWithUserProto:user 
                                                          orGameState:nil 
                                                           andGlobals:[Globals
                                                                       sharedGlobals]];
  [stats autorelease];
  return stats;
}
@end
