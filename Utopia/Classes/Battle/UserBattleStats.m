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
#warning REMOVE THIS STATIC GLOBALS CALL
  Globals *globals =  [Globals sharedGlobals];
  
  if (_userProto) {
    return _userProto.attack;

//    return [globals calculateAttackForStat:_userProto.attack
//                                    weapon:_userProto.weaponEquipped
//                                     armor:_userProto.armorEquipped
//                                    amulet:_userProto.amuletEquipped];
  }
  
  return [globals calculateAttackForStat:_gameState.attack
                                  weapon:_gameState.weaponEquipped
                                   armor:_gameState.armorEquipped
                                  amulet:_gameState.amuletEquipped];
}

-(int)defense
{
#warning REMOVE THIS STATIC GLOBALS CALL

  Globals *globals =  [Globals sharedGlobals];
  
  if (_userProto) {
    
//    int defenseStrength = [globals calculateDefenseForStat:_userProto.defense
//                                                    weapon:_userProto.weaponEquipped
//                                                     armor:_userProto.armorEquipped
//                                                    amulet:_userProto.amuletEquipped]; 
//    return defenseStrength;
    return _userProto.defense;
  }
  
  int defenseStrength = [globals calculateDefenseForStat:_gameState.defense
                                                  weapon:_gameState.weaponEquipped
                                                   armor:_gameState.armorEquipped
                                                  amulet:_gameState.amuletEquipped]; 
  return defenseStrength;
  
//  return _gameState.defense;
}

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
  UserBattleStats *stats = [[UserBattleStats alloc] 
                            initWithUserProto:nil
                            orGameState:[GameState sharedGameState]];
  [stats autorelease];
  return stats;  
}

+(FullUserProto *)userProtoForFakePlayer:(FullUserProto *)enemy 
                              andGlobals:(Globals *)globals
{
  FullUserProto_Builder *builder = [FullUserProto builderWithPrototype:enemy];
  
  // Adjust the enemy based on their character's level.
  UserBattleStats *myStats = [UserBattleStats createFromGameState];
  int levelDiff = enemy.level - myStats.level;
  int additionalSkillPoints;
  additionalSkillPoints = ([globals skillPointsGainedOnLevelup]/2)*levelDiff;
  

  int totalSkillPoints = myStats.attack 
    + myStats.defense + additionalSkillPoints;

//  int totalSkillPoints = gameState.attack 
//            + gameState.defense + additionalSkillPoints;
  
  // Set the enemy's attack/defense
  int enemyAttack, enemyDefense;
  PlayerClassType enemyClass = [Globals playerClassTypeForUserType:enemy.userType];
  
  switch (enemyClass) {
    case WARRIOR_T:
      enemyDefense = (totalSkillPoints * IMBALANCE_PERCENT) + 0.5;
      enemyAttack  = totalSkillPoints - enemyDefense;
      break;
    case ARCHER_T:
      enemyAttack  = totalSkillPoints/2;
      enemyDefense = totalSkillPoints/2;
      break;
    case MAGE_T:
      enemyAttack  = (totalSkillPoints * IMBALANCE_PERCENT) + 0.5;
      enemyDefense = totalSkillPoints - enemyAttack;
      break;
      
    default:
      break;
  }

#warning default stats (attack defense) for the mage are busted!
  int randAtt = arc4random() % 4;
  int randDef = arc4random() % 4;
  enemyAttack  = (arc4random() % 2) 
    ? enemyAttack  - randAtt : enemyAttack + randAtt;
  enemyDefense = (arc4random() % 2) 
    ? enemyDefense - randDef : enemyDefense + randDef;

  [builder setAttack:enemyAttack];
  [builder setDefense:enemyDefense];

  return [builder build];
}

+(id<UserBattleStats>)createWithFullUserProto:(FullUserProto *)user
{
  if (user.isFake) {
    user = [UserBattleStats userProtoForFakePlayer:user 
                                        andGlobals:[Globals sharedGlobals]];
  }

  UserBattleStats *stats = [[UserBattleStats alloc] initWithUserProto:user 
                                                          orGameState:nil];
  [stats autorelease];
  return stats;
}
@end
