//
//  UserBattleStats.m
//  Utopia
//
//  Created by Kevin Calloway on 6/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "UserBattleStats.h"

@implementation UserBattleStats
@dynamic attack;
@synthesize defense;
@synthesize maxHealth;
@synthesize currentHealth;

-(int)attack
{
  if (_userProto) {
    return _userProto.attack;
  }
  
  return _gameState.attack;
}

-(int)defense
{
  if (_userProto) {
    return _userProto.defense;
  }
  
  return _gameState.defense;
}

//_leftAttack = [gl calculateAttackForStat:gs.attack weapon:gs.weaponEquipped armor:gs.armorEquipped amulet:gs.amuletEquipped];
//_leftDefense = [gl calculateDefenseForStat:gs.defense weapon:gs.weaponEquipped armor:gs.armorEquipped amulet:gs.amuletEquipped];



#pragma mark Create/Destroy
-(id)initWithUserProto:(FullUserProto *)user orGameState:(GameState *)gameState
{
  self = [super init];
  
  if (self) {
    _userProto = user;
    _gameState = gameState;
    
    [_userProto retain];
    [_gameState retain];
  }
  
  return self;
}

-(void)dealloc
{
  [_userProto release];
  [super dealloc];
}

+(id<UserBattleStats>)createFromGameState
{
  UserBattleStats *stats = [[UserBattleStats alloc] initWithUserProto:nil
                                                          orGameState:[GameState sharedGameState]];
  [stats autorelease];
  return stats;  
}

#define SKILL_DIFFERENTIATOR  4

+(FullUserProto *)userProtoForFakePlayer:(FullUserProto *)enemy 
                            andGameState:(GameState *)gameState
{
  FullUserProto_Builder *builder = [FullUserProto builder];
 
  int attackDefenseQuarter 
    = (gameState.attack + gameState.defense)/SKILL_DIFFERENTIATOR;
  
  int enemyAttack  = attackDefenseQuarter;
  int enemyDefense = attackDefenseQuarter;
  
  PlayerClassType enemyClass = [Globals playerClassTypeForUserType:enemy.userType];
  
  switch (enemyClass) {
    case WARRIOR_T:
      enemyDefense += attackDefenseQuarter;
      enemyDefense += attackDefenseQuarter;
      break;
    case ARCHER_T:
      enemyDefense += attackDefenseQuarter;
      enemyAttack  += attackDefenseQuarter;
      break;
    case MAGE_T:
      enemyAttack += attackDefenseQuarter;
      enemyAttack += attackDefenseQuarter;
      break;
      
    default:
      break;
  }

#warning default stats (attack defense) for the mage are busted!
  int randAtt = arc4random() % 6;
  int randDef = arc4random() % 6;
  if (enemy.level > gameState.level) {
    enemyAttack  += randAtt;
    enemyDefense += randDef;
  } 
  else if (enemy.level == gameState.level) {
    enemyAttack  = (arc4random() % 1) 
      ? enemyAttack  - randAtt : enemyAttack + randAtt;
    enemyDefense = (arc4random() % 1) 
      ? enemyDefense - randDef : enemyDefense + randDef;
  }
  else {
    enemyAttack  -= randAtt;
    enemyDefense -= randDef;
  }
  
  [builder setAttack:enemyAttack];
  [builder setDefense:enemyDefense];

  return [builder build];
}

+(id<UserBattleStats>)createWithFullUserProto:(FullUserProto *)user
{
  if (user.isFake) {
    user = [UserBattleStats userProtoForFakePlayer:user 
                                      andGameState:[GameState sharedGameState]];
  }

  UserBattleStats *stats = [[UserBattleStats alloc] initWithUserProto:user 
                                                          orGameState:nil];
  [stats autorelease];
  return stats;
}
@end
