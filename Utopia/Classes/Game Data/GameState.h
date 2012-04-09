//
//  GameState.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/2/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Info.pb.h"
#import "UserData.h"
#import <CoreLocation/CoreLocation.h>

@interface GameState : NSObject {
  BOOL _isTutorial;
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
  NSString *_referralCode;
  int _battlesWon;
  int _battlesLost;
  int _flees;
  CLLocationCoordinate2D _location;
  int _skillPoints;
  int _experience;
  int _tasksCompleted;
  int _numReferrals;
  int _marketplaceGoldEarnings;
  int _marketplaceSilverEarnings;
  int _numMarketplaceSalesUnredeemed;
  int _numPostsInMarketplace;
  int _weaponEquipped;
  int _armorEquipped;
  int _amuletEquipped;
  NSDate *_lastEnergyRefill;
  NSDate *_lastStaminaRefill;
  NSDate *_lastShortLicensePurchaseTime;
  NSDate *_lastLongLicensePurchaseTime;
  
  int _maxCity;
  int _expRequiredForCurrentLevel;
  int _expRequiredForNextLevel;
  
  NSMutableArray *_marketplaceEquipPosts;
  NSMutableArray *_marketplaceEquipPostsFromSender;
  
  NSMutableDictionary *_staticStructs;
  NSMutableDictionary *_staticTasks;
  NSMutableDictionary *_staticQuests;
  NSMutableDictionary *_staticCities;
  NSMutableDictionary *_staticEquips;
  NSMutableDictionary *_staticBuildStructJobs;
  NSMutableDictionary *_staticDefeatTypeJobs;
  NSMutableDictionary *_staticPossessEquipJobs;
  NSMutableDictionary *_staticUpgradeStructJobs;
  
  NSArray *_carpenterStructs;
  NSArray *_armoryWeapons;
  NSArray *_armoryArmor;
  NSArray *_armoryAmulets;
  
  NSMutableArray *_myEquips;
  NSMutableArray *_myStructs;
  NSMutableArray *_myCritStructs;
  NSMutableDictionary *_myCities;
  
  NSMutableDictionary *_inProgressQuests;
  NSMutableDictionary *_availableQuests;
  
  NSMutableArray *_attackList;
  
  NSMutableArray *_notifications;
}

@property (assign) BOOL isTutorial;
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
@property (retain) NSString *referralCode;
@property (assign) int battlesWon;
@property (assign) int battlesLost;
@property (assign) int flees;
@property (assign) CLLocationCoordinate2D location;
@property (assign) int skillPoints;
@property (assign) int experience;
@property (assign) int tasksCompleted;
@property (assign) int numReferrals;
@property (assign) int marketplaceGoldEarnings;
@property (assign) int marketplaceSilverEarnings;
@property (assign) int numMarketplaceSalesUnredeemed;
@property (assign) int numPostsInMarketplace;
@property (assign) int weaponEquipped;
@property (assign) int armorEquipped;
@property (assign) int amuletEquipped;
@property (retain) NSDate *lastEnergyRefill;
@property (retain) NSDate *lastStaminaRefill;

@property (retain) NSDate *lastShortLicensePurchaseTime;
@property (retain) NSDate *lastLongLicensePurchaseTime;

@property (assign) int maxCity;
@property (assign) int expRequiredForCurrentLevel;
@property (assign) int expRequiredForNextLevel;

@property (retain) NSMutableArray *marketplaceEquipPosts;
@property (retain) NSMutableArray *marketplaceEquipPostsFromSender;

@property (retain) NSMutableDictionary *staticStructs;
@property (retain) NSMutableDictionary *staticTasks;
@property (retain) NSMutableDictionary *staticQuests;
@property (retain) NSMutableDictionary *staticCities;
@property (retain) NSMutableDictionary *staticEquips;
@property (retain) NSMutableDictionary *staticBuildStructJobs;
@property (retain) NSMutableDictionary *staticDefeatTypeJobs;
@property (retain) NSMutableDictionary *staticPossessEquipJobs;
@property (retain) NSMutableDictionary *staticUpgradeStructJobs;

@property (retain) NSArray *carpenterStructs;
@property (retain) NSArray *armoryWeapons;
@property (retain) NSArray *armoryArmor;
@property (retain) NSArray *armoryAmulets;

@property (retain) NSMutableArray *myEquips;
@property (retain) NSMutableArray *myStructs;
@property (retain) NSMutableArray *myCritStructs;
@property (retain) NSMutableDictionary *myCities;

@property (retain) NSMutableDictionary *inProgressQuests;
@property (retain) NSMutableDictionary *availableQuests;

@property (retain) NSMutableArray *attackList;
@property (retain) NSMutableArray *notifications;

+ (GameState *) sharedGameState;
+ (void) purgeSingleton;

- (void) updateUser:(FullUserProto *)user;

- (id) getStaticDataFrom:(NSDictionary *)dict withId:(int)itemId;
- (FullEquipProto *) equipWithId:(int)equipId;
- (FullStructureProto *) structWithId:(int)structId;
- (FullCityProto *)cityWithId:(int)cityId;
- (FullTaskProto *) taskWithId:(int)taskId;

- (void) addToMyEquips:(NSArray *)myEquips;
- (void) addToMyStructs:(NSArray *)myStructs;
- (void) addToMyCritStructs:(NSArray *)structs;
- (void) addToMyCities:(NSArray *)cities;
- (void) addToAvailableQuests:(NSArray *)quests;
- (void) addToInProgressQuests:(NSArray *)quests;
- (void) addNotification:(UserNotification *)un;

- (UserEquip *) myEquipWithId:(int)equipId;
- (UserStruct *) myStructWithId:(int)structId;
- (UserCity *) myCityWithId:(int)cityId;

- (void) addToStaticStructs:(NSArray *)arr;
- (void) addToStaticTasks:(NSArray *)arr;
- (void) addToStaticQuests:(NSArray *)arr;
- (void) addToStaticCities:(NSArray *)arr;
- (void) addToStaticEquips:(NSArray *)arr;
- (void) addToStaticBuildStructJobs:(NSArray *)arr;
- (void) addToStaticDefeatTypeJobs:(NSArray *)arr;
- (void) addToStaticPossessEquipJobs:(NSArray *)arr;
- (void) addToStaticUpgradeStructJobs:(NSArray *)arr;

- (BOOL) hasValidLicense;
- (void) changeQuantityForEquip:(int)equipId by:(int)qDelta;

- (void) purgeStaticData;

@end
