//
//  GameState.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/2/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Info.pb.h"
#import <CoreLocation/CoreLocation.h>

@interface GameState : NSObject {
  BOOL _connected;
  int _userId;
  NSString *_name;
  UserType _type;
  int _level;
  int _defense;
  int _attack;
  int _currentEnergy;
  int _maxEnergy;
  int _currentStamina;
  int _maxStamina;
  int _maxHealth;
  int _gold;
  int _silver;
  int _vaultBalance;
  NSString *_armyCode;
  int _battlesWon;
  int _battlesLost;
  int _hourlyCoins;
  CLLocationCoordinate2D _location;
  int _skillPoints;
  int _experience;
  int _tasksCompleted;
  int _numReferrals;
  int _marketplaceGoldEarnings;
  int _marketplaceSilverEarnings;
  int _numMarketplaceSalesUnredeemed;
  int _numPostsInMarketplace;
  
  NSMutableArray *_marketplaceEquipPosts;
  NSMutableArray *_marketplaceEquipPostsFromSender;
  
  NSMutableDictionary *_staticStructs;
  NSMutableDictionary *_staticTasks;
  NSMutableDictionary *_staticQuests;
  NSMutableDictionary *_staticCities;
  NSMutableDictionary *_staticEquips;
  NSMutableDictionary *_staticBuildStructJobs;
  NSMutableDictionary *_staticDefeatTypeJobs;
  NSMutableDictionary *_staticPossessEquipJobProto;
  NSMutableDictionary *_staticUpgradeStructJobProto;
  
  NSMutableArray *_carpenterStructs;
  NSMutableArray *_armoryEquips;
  
  NSMutableArray *_myEquips;
  NSMutableArray *_myStructs;
  
  NSMutableArray *_attackList;
}

@property (assign) BOOL connected;
@property (assign) int userId;
@property (retain) NSString *name;
@property (assign) UserType type;
@property (assign) int level;
@property (assign) int defense;
@property (assign) int attack;
@property (assign) int currentEnergy;
@property (assign) int maxEnergy;
@property (assign) int currentStamina;
@property (assign) int maxStamina;
@property (assign) int maxHealth;
@property (assign) int gold;
@property (assign) int silver;
@property (assign) int vaultBalance;
@property (retain) NSString *armyCode;
@property (assign) int battlesWon;
@property (assign) int battlesLost;
@property (assign) int hourlyCoins;
@property (assign) CLLocationCoordinate2D location;
@property (assign) int skillPoints;
@property (assign) int experience;
@property (assign) int tasksCompleted;
@property (assign) int numReferrals;
@property (assign) int marketplaceGoldEarnings;
@property (assign) int marketplaceSilverEarnings;
@property (assign) int numMarketplaceSalesUnredeemed;
@property (assign) int numPostsInMarketplace;

@property (retain) NSMutableArray *marketplaceEquipPosts;
@property (retain) NSMutableArray *marketplaceEquipPostsFromSender;

@property (retain) NSMutableDictionary *staticStructs;
@property (retain) NSMutableDictionary *staticTasks;
@property (retain) NSMutableDictionary *staticQuests;
@property (retain) NSMutableDictionary *staticCities;
@property (retain) NSMutableDictionary *staticEquips;
@property (retain) NSMutableDictionary *staticBuildStructJobs;
@property (retain) NSMutableDictionary *staticDefeatTypeJobs;
@property (retain) NSMutableDictionary *staticPossessEquipJobProto;
@property (retain) NSMutableDictionary *staticUpgradeStructJobProto;

@property (retain) NSMutableArray *carpenterStructs;
@property (retain) NSMutableArray *armoryEquips;

@property (retain) NSMutableArray *myEquips;
@property (retain) NSMutableArray *myStructs;

@property (retain) NSMutableArray *attackList;

+ (GameState *) sharedGameState;

- (void) updateUser:(FullUserProto *)user;

- (FullEquipProto *) equipWithId:(int)equipId;
- (FullStructureProto *) structWithId:(int)structId;

- (void) addToMyEquips:(NSArray *)myEquips;
- (void) addToMyStructs:(NSArray *)myStructs;

@end
