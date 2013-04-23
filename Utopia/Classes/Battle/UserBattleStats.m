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
  int val1 = 0;
  int val2 = 0;
  if (_userProto) {
    BOOL hasEq1 = _userProto.hasWeaponEquippedUserEquip;
    BOOL hasEq2 = _userProto.hasWeaponTwoEquippedUserEquip;
    FullUserEquipProto *eq1 = _userProto.weaponEquippedUserEquip;
    FullUserEquipProto *eq2 = _userProto.weaponTwoEquippedUserEquip;
    val1 = hasEq1 ? [gl calculateAttackForEquip:eq1.equipId level:eq1.level enhancePercent:eq1.enhancementPercentage] : 0;
    val2 = hasEq2 ? [gl calculateAttackForEquip:eq2.equipId level:eq2.level enhancePercent:eq2.enhancementPercentage] : 0;
  } else {
    GameState *gs = [GameState sharedGameState];
    UserEquip *eq1 = [gs myEquipWithUserEquipId:gs.weaponEquipped];
    UserEquip *eq2 = [gs myEquipWithUserEquipId:gs.weaponEquipped2];
    val1 = eq1 ? [gl calculateAttackForEquip:eq1.equipId level:eq1.level enhancePercent:eq1.enhancementPercentage] : 0;
    val2 = eq2 ? [gl calculateAttackForEquip:eq2.equipId level:eq2.level enhancePercent:eq2.enhancementPercentage] : 0;
  }
  int val = val1+val2;
  val = val > 0 ? val : 1;
  return val;
}

- (int) armorAttack {
  Globals *gl = [Globals sharedGlobals];
  int val1 = 0;
  int val2 = 0;
  if (_userProto) {
    BOOL hasEq1 = _userProto.hasArmorEquippedUserEquip;
    BOOL hasEq2 = _userProto.hasArmorTwoEquippedUserEquip;
    FullUserEquipProto *eq1 = _userProto.armorEquippedUserEquip;
    FullUserEquipProto *eq2 = _userProto.armorTwoEquippedUserEquip;
    val1 = hasEq1 ? [gl calculateAttackForEquip:eq1.equipId level:eq1.level enhancePercent:eq1.enhancementPercentage] : 0;
    val2 = hasEq2 ? [gl calculateAttackForEquip:eq2.equipId level:eq2.level enhancePercent:eq2.enhancementPercentage] : 0;
  } else {
    GameState *gs = [GameState sharedGameState];
    UserEquip *eq1 = [gs myEquipWithUserEquipId:gs.armorEquipped];
    UserEquip *eq2 = [gs myEquipWithUserEquipId:gs.armorEquipped2];
    val1 = eq1 ? [gl calculateAttackForEquip:eq1.equipId level:eq1.level enhancePercent:eq1.enhancementPercentage] : 0;
    val2 = eq2 ? [gl calculateAttackForEquip:eq2.equipId level:eq2.level enhancePercent:eq2.enhancementPercentage] : 0;
  }
  int val = val1+val2;
  val = val > 0 ? val : 1;
  return val;
}

- (int) amuletAttack {
  Globals *gl = [Globals sharedGlobals];
  int val1 = 0;
  int val2 = 0;
  if (_userProto) {
    BOOL hasEq1 = _userProto.hasAmuletEquippedUserEquip;
    BOOL hasEq2 = _userProto.hasAmuletTwoEquippedUserEquip;
    FullUserEquipProto *eq1 = _userProto.amuletEquippedUserEquip;
    FullUserEquipProto *eq2 = _userProto.amuletTwoEquippedUserEquip;
    val1 = hasEq1 ? [gl calculateAttackForEquip:eq1.equipId level:eq1.level enhancePercent:eq1.enhancementPercentage] : 0;
    val2 = hasEq2 ? [gl calculateAttackForEquip:eq2.equipId level:eq2.level enhancePercent:eq2.enhancementPercentage] : 0;
  } else {
    GameState *gs = [GameState sharedGameState];
    UserEquip *eq1 = [gs myEquipWithUserEquipId:gs.amuletEquipped];
    UserEquip *eq2 = [gs myEquipWithUserEquipId:gs.amuletEquipped2];
    val1 = eq1 ? [gl calculateAttackForEquip:eq1.equipId level:eq1.level enhancePercent:eq1.enhancementPercentage] : 0;
    val2 = eq2 ? [gl calculateAttackForEquip:eq2.equipId level:eq2.level enhancePercent:eq2.enhancementPercentage] : 0;
  }
  int val = val1+val2;
  val = val > 0 ? val : 1;
  return val;
}

- (int) weaponDefense {
  Globals *gl = [Globals sharedGlobals];
  int val1 = 0;
  int val2 = 0;
  if (_userProto) {
    BOOL hasEq1 = _userProto.hasWeaponEquippedUserEquip;
    BOOL hasEq2 = _userProto.hasWeaponTwoEquippedUserEquip;
    FullUserEquipProto *eq1 = _userProto.weaponEquippedUserEquip;
    FullUserEquipProto *eq2 = _userProto.weaponTwoEquippedUserEquip;
    val1 = hasEq1 ? [gl calculateDefenseForEquip:eq1.equipId level:eq1.level enhancePercent:eq1.enhancementPercentage] : 0;
    val2 = hasEq2 ? [gl calculateDefenseForEquip:eq2.equipId level:eq2.level enhancePercent:eq2.enhancementPercentage] : 0;
  } else {
    GameState *gs = [GameState sharedGameState];
    UserEquip *eq1 = [gs myEquipWithUserEquipId:gs.weaponEquipped];
    UserEquip *eq2 = [gs myEquipWithUserEquipId:gs.weaponEquipped2];
    val1 = eq1 ? [gl calculateDefenseForEquip:eq1.equipId level:eq1.level enhancePercent:eq1.enhancementPercentage] : 0;
    val2 = eq2 ? [gl calculateDefenseForEquip:eq2.equipId level:eq2.level enhancePercent:eq2.enhancementPercentage] : 0;
  }
  int val = val1+val2;
  val = val > 0 ? val : 1;
  return val;
}

- (int) armorDefense {
  Globals *gl = [Globals sharedGlobals];
  int val1 = 0;
  int val2 = 0;
  if (_userProto) {
    BOOL hasEq1 = _userProto.hasArmorEquippedUserEquip;
    BOOL hasEq2 = _userProto.hasArmorTwoEquippedUserEquip;
    FullUserEquipProto *eq1 = _userProto.armorEquippedUserEquip;
    FullUserEquipProto *eq2 = _userProto.armorTwoEquippedUserEquip;
    val1 = hasEq1 ? [gl calculateDefenseForEquip:eq1.equipId level:eq1.level enhancePercent:eq1.enhancementPercentage] : 0;
    val2 = hasEq2 ? [gl calculateDefenseForEquip:eq2.equipId level:eq2.level enhancePercent:eq2.enhancementPercentage] : 0;
  } else {
    GameState *gs = [GameState sharedGameState];
    UserEquip *eq1 = [gs myEquipWithUserEquipId:gs.armorEquipped];
    UserEquip *eq2 = [gs myEquipWithUserEquipId:gs.armorEquipped2];
    val1 = eq1 ? [gl calculateDefenseForEquip:eq1.equipId level:eq1.level enhancePercent:eq1.enhancementPercentage] : 0;
    val2 = eq2 ? [gl calculateDefenseForEquip:eq2.equipId level:eq2.level enhancePercent:eq2.enhancementPercentage] : 0;
  }
  int val = val1+val2;
  val = val > 0 ? val : 1;
  return val;
}

- (int) amuletDefense {
  Globals *gl = [Globals sharedGlobals];
  int val1 = 0;
  int val2 = 0;
  if (_userProto) {
    BOOL hasEq1 = _userProto.hasAmuletEquippedUserEquip;
    BOOL hasEq2 = _userProto.hasAmuletTwoEquippedUserEquip;
    FullUserEquipProto *eq1 = _userProto.amuletEquippedUserEquip;
    FullUserEquipProto *eq2 = _userProto.amuletTwoEquippedUserEquip;
    val1 = hasEq1 ? [gl calculateDefenseForEquip:eq1.equipId level:eq1.level enhancePercent:eq1.enhancementPercentage] : 0;
    val2 = hasEq2 ? [gl calculateDefenseForEquip:eq2.equipId level:eq2.level enhancePercent:eq2.enhancementPercentage] : 0;
  } else {
    GameState *gs = [GameState sharedGameState];
    UserEquip *eq1 = [gs myEquipWithUserEquipId:gs.amuletEquipped];
    UserEquip *eq2 = [gs myEquipWithUserEquipId:gs.amuletEquipped2];
    val1 = eq1 ? [gl calculateDefenseForEquip:eq1.equipId level:eq1.level enhancePercent:eq1.enhancementPercentage] : 0;
    val2 = eq2 ? [gl calculateDefenseForEquip:eq2.equipId level:eq2.level enhancePercent:eq2.enhancementPercentage] : 0;
  }
  int val = val1+val2;
  val = val > 0 ? val : 1;
  return val;
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
