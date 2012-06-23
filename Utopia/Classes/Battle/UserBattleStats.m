//
//  UserBattleStats.m
//  Utopia
//
//  Created by Kevin Calloway on 6/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "UserBattleStats.h"
#import "Globals.h"

static NSMutableArray *attackLevels  = nil;
static NSMutableArray *defenseLevels = nil;

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
    return _userProto.attack;
  }
  
  return [_globals calculateAttackForStat:_gameState.attack
                                  weapon:_gameState.weaponEquipped
                                   armor:_gameState.armorEquipped
                                  amulet:_gameState.amuletEquipped];
}

-(int)defense
{
  if (_userProto) {
    return _userProto.defense;
  }
  
  int defenseStrength = [_globals calculateDefenseForStat:_gameState.defense
                                                  weapon:_gameState.weaponEquipped
                                                   armor:_gameState.armorEquipped
                                                  amulet:_gameState.amuletEquipped]; 
  return defenseStrength;
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

+(void)repeatInsertingObject:(NSNumber *)curNum
                     inArray:(NSMutableArray *)targetArray
                  untilIndex:(int)index
{
  int indexDiff = abs([targetArray count] - index);
  int prevValue = [[targetArray lastObject] intValue];
  int strengthDiff = abs(prevValue - [curNum intValue]);
  float strengthIncrement = strengthDiff/((float)indexDiff);
  float curAddition = 0;
  while ([targetArray count] < index) {
    curAddition += strengthIncrement;
    NSNumber *nextVal = [NSNumber numberWithInt:prevValue + curAddition];
    [targetArray addObject:nextVal];
  }
}

//FIXME: This equip data should come from a file or server
+(NSArray *)equipAttackLevels
{
//  NSMutableArray *attackLevels = [NSMutableArray arrayWithCapacity:40];
  if (attackLevels == nil) {
    attackLevels = [NSMutableArray arrayWithCapacity:40];
    
    [UserBattleStats repeatInsertingObject:[NSNumber numberWithInt:15]
                                   inArray:attackLevels 
                                untilIndex:5];
    [UserBattleStats repeatInsertingObject:[NSNumber numberWithInt:22]
                                   inArray:attackLevels 
                                untilIndex:10];
    [UserBattleStats repeatInsertingObject:[NSNumber numberWithInt:31]
                                   inArray:attackLevels 
                                untilIndex:15];
    [UserBattleStats repeatInsertingObject:[NSNumber numberWithInt:46]
                                   inArray:attackLevels 
                                untilIndex:20];
    [UserBattleStats repeatInsertingObject:[NSNumber numberWithInt:58]
                                   inArray:attackLevels 
                                untilIndex:25];
    [UserBattleStats repeatInsertingObject:[NSNumber numberWithInt:71]
                                   inArray:attackLevels 
                                untilIndex:30];
    [UserBattleStats repeatInsertingObject:[NSNumber numberWithInt:71]
                                   inArray:attackLevels 
                                untilIndex:40];    
    [attackLevels retain];
  }
  return attackLevels;
}

+(NSArray *)equipDefenseLevels
{
//  NSMutableArray *defenseLevels = [NSMutableArray arrayWithCapacity:40];

  if (defenseLevels == nil) {
    defenseLevels = [NSMutableArray arrayWithCapacity:40];
    [UserBattleStats repeatInsertingObject:[NSNumber numberWithInt:15]
                                   inArray:defenseLevels 
                                untilIndex:5];
    [UserBattleStats repeatInsertingObject:[NSNumber numberWithInt:20]
                                   inArray:defenseLevels 
                                untilIndex:10];
    [UserBattleStats repeatInsertingObject:[NSNumber numberWithInt:31]
                                   inArray:defenseLevels 
                                untilIndex:15];
    [UserBattleStats repeatInsertingObject:[NSNumber numberWithInt:43]
                                   inArray:defenseLevels 
                                untilIndex:20];
    [UserBattleStats repeatInsertingObject:[NSNumber numberWithInt:55]
                                   inArray:defenseLevels 
                                untilIndex:25];
    [UserBattleStats repeatInsertingObject:[NSNumber numberWithInt:68]
                                   inArray:defenseLevels 
                                untilIndex:30];
    [UserBattleStats repeatInsertingObject:[NSNumber numberWithInt:68]
                                   inArray:defenseLevels 
                                untilIndex:40];
    [defenseLevels retain];
  }
  return defenseLevels;
}

+(FullUserProto *)userProtoForFakePlayer:(FullUserProto *)enemy 
                              andGlobals:(Globals *)globals 
                            andGamestate:(GameState *)gameState
{
  FullUserProto_Builder *builder = [FullUserProto builderWithPrototype:enemy];
  
  // Adjust the enemy based on their character's level.
  int levelDiff = enemy.level - gameState.level;
  int additionalSkillPoints;
  additionalSkillPoints = ([globals skillPointsGainedOnLevelup]/2)*levelDiff;

//  int totalSkillPoints = gameState.attack + gameState.defense 
//    + [[[UserBattleStats equipAttackLevels] objectAtIndex:enemy.level-1] intValue]
//    + [[[UserBattleStats equipDefenseLevels] objectAtIndex:enemy.level-1] intValue]
//    + additionalSkillPoints;
  int totalSkillPoints = gameState.attack + gameState.defense 
    + additionalSkillPoints;

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

  enemyAttack  += [[[UserBattleStats equipAttackLevels] objectAtIndex:enemy.level-1] intValue];
  enemyDefense += [[[UserBattleStats equipDefenseLevels] objectAtIndex:enemy.level-1] intValue];

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
                                        andGlobals:[Globals sharedGlobals] 
                                      andGamestate:[GameState sharedGameState]];
  }

  UserBattleStats *stats = [[UserBattleStats alloc] initWithUserProto:user 
                                                          orGameState:nil 
                                                           andGlobals:[Globals
                                                                       sharedGlobals]];
  [stats autorelease];
  return stats;
}
@end
