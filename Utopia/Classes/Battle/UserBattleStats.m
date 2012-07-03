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
    return [_globals calculateAttackForStat:_userProto.attack
                                     weapon:_userProto.weaponEquipped
                                      armor:_userProto.armorEquipped
                                     amulet:_userProto.amuletEquipped];
  }
  
  return [_globals calculateAttackForStat:_gameState.attack
                                  weapon:_gameState.weaponEquipped
                                   armor:_gameState.armorEquipped
                                  amulet:_gameState.amuletEquipped];
}

-(int)defense
{
  if (_userProto) {
    return [_globals calculateDefenseForStat:_userProto.defense
                                                 weapon:_userProto.weaponEquipped
                                                  armor:_userProto.armorEquipped
                                                 amulet:_userProto.amuletEquipped];
  }

  return [_globals calculateDefenseForStat:_gameState.defense
                                    weapon:_gameState.weaponEquipped
                                     armor:_gameState.armorEquipped
                                    amulet:_gameState.amuletEquipped]; 

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
