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
@dynamic attackStat;
@dynamic defenseStat;
@synthesize weaponAttack, weaponDefense;
@synthesize armorAttack, armorDefense;
@synthesize amuletAttack, amuletDefense;

- (int) weaponAttack {
  Globals *gl = [Globals sharedGlobals];
  if (_userProto) {
    return _userProto.hasWeaponEquippedUserEquip ? [gl calculateAttackForEquip:_userProto.weaponEquippedUserEquip.equipId level:_userProto.weaponEquippedUserEquip.level enhancePercent:_userProto.weaponEquippedUserEquip.enhancementPercentage] : 1;
  }
  
  GameState *gs = [GameState sharedGameState];
  UserEquip *eq = [gs myEquipWithUserEquipId:gs.weaponEquipped];
  return eq ? [gl calculateAttackForEquip:eq.equipId level:eq.level enhancePercent:eq.enhancementPercentage] : 1;
}

- (int) armorAttack {
  Globals *gl = [Globals sharedGlobals];
  if (_userProto) {
    return _userProto.hasArmorEquippedUserEquip ? [gl calculateAttackForEquip:_userProto.armorEquippedUserEquip.equipId level:_userProto.armorEquippedUserEquip.level enhancePercent:_userProto.armorEquippedUserEquip.enhancementPercentage] : 1;
  }
  
  GameState *gs = [GameState sharedGameState];
  UserEquip *eq = [gs myEquipWithUserEquipId:gs.armorEquipped];
  return eq ? [gl calculateAttackForEquip:eq.equipId level:eq.level enhancePercent:eq.enhancementPercentage] : 1;
}

- (int) amuletAttack {
  Globals *gl = [Globals sharedGlobals];
  if (_userProto) {
    return _userProto.hasAmuletEquippedUserEquip ? [gl calculateAttackForEquip:_userProto.amuletEquippedUserEquip.equipId level:_userProto.amuletEquippedUserEquip.level enhancePercent:_userProto.amuletEquippedUserEquip.enhancementPercentage] : 1;
  }
  
  GameState *gs = [GameState sharedGameState];
  UserEquip *eq = [gs myEquipWithUserEquipId:gs.amuletEquipped];
  return eq ? [gl calculateAttackForEquip:eq.equipId level:eq.level enhancePercent:eq.enhancementPercentage] : 1;
}

- (int) weaponDefense {
  Globals *gl = [Globals sharedGlobals];
  if (_userProto) {
    return _userProto.hasWeaponEquippedUserEquip ? [gl calculateDefenseForEquip:_userProto.weaponEquippedUserEquip.equipId level:_userProto.weaponEquippedUserEquip.level enhancePercent:_userProto.weaponEquippedUserEquip.enhancementPercentage] : 1;
  }
  
  GameState *gs = [GameState sharedGameState];
  UserEquip *eq = [gs myEquipWithUserEquipId:gs.weaponEquipped];
  return eq ? [gl calculateDefenseForEquip:eq.equipId level:eq.level enhancePercent:eq.enhancementPercentage] : 1;
}

- (int) armorDefense {
  Globals *gl = [Globals sharedGlobals];
  if (_userProto) {
    return _userProto.hasArmorEquippedUserEquip ? [gl calculateDefenseForEquip:_userProto.armorEquippedUserEquip.equipId level:_userProto.armorEquippedUserEquip.level enhancePercent:_userProto.armorEquippedUserEquip.enhancementPercentage] : 1;
  }
  
  GameState *gs = [GameState sharedGameState];
  UserEquip *eq = [gs myEquipWithUserEquipId:gs.armorEquipped];
  return eq ? [gl calculateDefenseForEquip:eq.equipId level:eq.level enhancePercent:eq.enhancementPercentage] : 1;
}

- (int) amuletDefense {
  Globals *gl = [Globals sharedGlobals];
  if (_userProto) {
    return _userProto.hasAmuletEquippedUserEquip ? [gl calculateDefenseForEquip:_userProto.amuletEquippedUserEquip.equipId level:_userProto.amuletEquippedUserEquip.level enhancePercent:_userProto.amuletEquippedUserEquip.enhancementPercentage] : 1;
  }
  
  GameState *gs = [GameState sharedGameState];
  UserEquip *eq = [gs myEquipWithUserEquipId:gs.amuletEquipped];
  return eq ? [gl calculateDefenseForEquip:eq.equipId level:eq.level enhancePercent:eq.enhancementPercentage] : 1;
}

-(int32_t)level
{
  if (_userProto) {    
    return _userProto.level;
  }
  
  return _gameState.level;
}

-(int)attackStat
{
  if (_userProto) {
    return _userProto.attack;
  }
  
  GameState *gs = [GameState sharedGameState];
  return gs.attack;
}

-(int)defenseStat
{
  if (_userProto) {
    return _userProto.defense;
  }
  
  GameState *gs = [GameState sharedGameState];
  return gs.defense;
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
