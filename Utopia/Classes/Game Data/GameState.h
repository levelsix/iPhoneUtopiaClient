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
#import "FullUserUpdates.h"

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
  int _playerHasBoughtInAppPurchase;
  NSDate *_lastEnergyRefill;
  NSDate *_lastStaminaRefill;
  NSDate *_lastShortLicensePurchaseTime;
  NSDate *_lastLongLicensePurchaseTime;
  
  int _numAdColonyVideosWatched;
  int _numGroupChatsRemaining;
  
  NSString *_deviceToken;
  
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
  NSMutableDictionary *_myCities;
  
  NSMutableDictionary *_inProgressIncompleteQuests;
  NSMutableDictionary *_inProgressCompleteQuests;
  NSMutableDictionary *_availableQuests;
  
  NSMutableArray *_attackList;
  NSMutableArray *_attackMapList;
  NSMutableArray *_notifications;
  NSMutableArray *_wallPosts;
  NSMutableArray *_globalChatMessages;
  NSMutableArray *_clanChatMessages;
  
  NSDate *_lastLogoutTime;
  
  uint64_t _lastUserUpdate;
  
  NSArray *_allies;
  
  // For the tagging scheme
  NSMutableArray *_unrespondedUpdates;
  
  ForgeAttempt *_forgeAttempt;
  NSTimer *_forgeTimer;
  
  NSDate *_lastGoldmineRetrieval;
  NSTimer *_goldmineTimer;
  
  MinimumClanProto *_clan;
  NSMutableArray *_requestedClans;
  
  NSTimer *_expansionTimer;
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
@property (assign) int playerHasBoughtInAppPurchase;
@property (retain) NSDate *lastEnergyRefill;
@property (retain) NSDate *lastStaminaRefill;
@property (assign) int numAdColonyVideosWatched;
@property (assign) int numGroupChatsRemaining;
@property (assign) BOOL isAdmin;

@property (retain) NSString *deviceToken;

@property (retain) NSDate *lastShortLicensePurchaseTime;
@property (retain) NSDate *lastLongLicensePurchaseTime;

@property (assign) int expRequiredForCurrentLevel;
@property (assign) int expRequiredForNextLevel;

@property (retain) NSMutableArray *marketplaceEquipPosts;
@property (retain) NSMutableArray *marketplaceEquipPostsFromSender;

@property (retain) NSMutableDictionary *staticStructs;
@property (retain) NSMutableDictionary *staticTasks;
@property (retain) NSMutableDictionary *staticBosses;
@property (retain) NSMutableDictionary *staticQuests;
@property (retain) NSMutableDictionary *staticCities;
@property (retain) NSMutableDictionary *staticEquips;
@property (retain) NSMutableDictionary *staticBuildStructJobs;
@property (retain) NSMutableDictionary *staticDefeatTypeJobs;
@property (retain) NSMutableDictionary *staticPossessEquipJobs;
@property (retain) NSMutableDictionary *staticUpgradeStructJobs;
@property (retain) NSMutableArray *staticLockBoxEvents;
@property (retain) NSMutableArray *staticGoldSales;
@property (retain) NSMutableArray *staticBossEvents;
@property (retain) NSMutableArray *staticTournaments;

@property (retain) NSArray *carpenterStructs;
@property (retain) NSArray *armoryWeapons;
@property (retain) NSArray *armoryArmor;
@property (retain) NSArray *armoryAmulets;

@property (retain) NSMutableArray *myEquips;
@property (retain) NSMutableArray *myStructs;
@property (retain) NSMutableDictionary *myCities;
@property (retain) NSMutableDictionary *myLockBoxEvents;

@property (retain) NSMutableDictionary *inProgressCompleteQuests;
@property (retain) NSMutableDictionary *inProgressIncompleteQuests;
@property (retain) NSMutableDictionary *availableQuests;

@property (retain) NSMutableArray *attackList;
@property (retain) NSMutableArray *attackMapList;
@property (retain) NSMutableArray *notifications;
@property (retain) NSMutableArray *wallPosts;
@property (retain) NSMutableArray *globalChatMessages;
@property (retain) NSMutableArray *clanChatMessages;

@property (retain) NSMutableArray *unrespondedUpdates;

@property (retain) NSDate *lastLogoutTime;

@property (retain) NSArray *allies;

@property (retain) ForgeAttempt *forgeAttempt;
@property (retain) EquipEnhancementProto *equipEnhancement;

@property (retain) NSDate *lastGoldmineRetrieval;

@property (retain) MinimumClanProto *clan;
@property (retain) NSMutableArray *requestedClans;

@property (nonatomic, copy) NSArray *mktSearchEquips;

@property (nonatomic, retain) UserExpansion *userExpansion;

@property (retain) NSMutableArray *lockBoxEventTimers;
@property (retain) NSMutableArray *goldSaleTimers;
@property (retain) NSMutableArray *bossEventTimers;
@property (retain) NSMutableArray *tournamentTimers;

@property (retain) NSDictionary *clanTierLevels;

@property (retain) NSArray *clanTowers;

+ (GameState *) sharedGameState;
+ (void) purgeSingleton;

- (MinimumUserProto *) minUser;
- (void) updateUser:(FullUserProto *)user timestamp:(uint64_t)time;

- (id) getStaticDataFrom:(NSDictionary *)dict withId:(int)itemId;
- (FullEquipProto *) equipWithId:(int)equipId;
- (FullStructureProto *) structWithId:(int)structId;
- (FullCityProto *)cityWithId:(int)cityId;
- (FullTaskProto *) taskWithId:(int)taskId;
- (FullBossProto *) bossWithId:(int)taskId;
- (FullQuestProto *) questForQuestId:(int)questId;
- (LockBoxEventProto *) lockBoxEventWithId:(int)eventId;

- (int) weaponEquippedId;
- (int) armorEquippedId;
- (int) amuletEquippedId;

- (void) addToMyEquips:(NSArray *)myEquips;
- (void) addToMyStructs:(NSArray *)myStructs;
- (void) addToMyCities:(NSArray *)cities;
- (void) addToMyLockBoxEvents:(NSArray *)events;
- (void) addToAvailableQuests:(NSArray *)quests;
- (void) addToInProgressCompleteQuests:(NSArray *)quests;
- (void) addToInProgressIncompleteQuests:(NSArray *)quests;
- (void) addNotification:(UserNotification *)un;
- (void) addWallPost:(PlayerWallPostProto *)wallPost;
- (void) addChatMessage:(MinimumUserProto *)sender message:(NSString *)msg scope:(GroupChatScope)scope isAdmin:(BOOL)isAdmin;
- (void) addChatMessage:(ChatMessage *)cm scope:(GroupChatScope) scope;

- (UserEquip *) myEquipWithId:(int)equipId level:(int)level;
- (NSArray *) myEquipsWithId:(int)equipId level:(int)level;
- (NSArray *) myEquipsWithEquipId:(int)equipId;
- (UserEquip *) myEquipWithUserEquipId:(int)userEquipId;  
- (int) quantityOfEquip:(int)equipId;
- (int) quantityOfEquip:(int)equipId level:(int)level;
- (UserStruct *) myStructWithId:(int)structId;
- (UserCity *) myCityWithId:(int)cityId;

- (void) addToStaticStructs:(NSArray *)arr;
- (void) addToStaticTasks:(NSArray *)arr;
- (void) addToStaticBosses:(NSArray *)arr;
- (void) addToStaticQuests:(NSArray *)arr;
- (void) addToStaticCities:(NSArray *)arr;
- (void) addToStaticEquips:(NSArray *)arr;
- (void) addToStaticBuildStructJobs:(NSArray *)arr;
- (void) addToStaticDefeatTypeJobs:(NSArray *)arr;
- (void) addToStaticPossessEquipJobs:(NSArray *)arr;
- (void) addToStaticUpgradeStructJobs:(NSArray *)arr;
- (void) addNewStaticLockBoxEvents:(NSArray *)events;
- (void) addNewStaticBossEvents:(NSArray *)events;
- (void) addNewStaticTournaments:(NSArray *)events;
- (void) addToClanTierLevels:(NSArray *) tiers;

- (ClanTierLevelProto *) clanTierForLevel:(int)level;
- (int) maxClanTierLevel;

- (void) addUnrespondedUpdate:(id<GameStateUpdate>)up;
- (void) addUnrespondedUpdates:(id<GameStateUpdate>)field1, ... NS_REQUIRES_NIL_TERMINATION;
- (void) removeAndUndoAllUpdatesForTag:(int)tag;
- (void) removeFullUserUpdatesForTag:(int)tag;
- (void) removeNonFullUserUpdatesForTag:(int)tag;

- (BOOL) hasValidLicense;

- (void) beginForgeTimer;
- (void) stopForgeTimer;

- (void) beginEnhancementTimer;
- (void) stopEnhancementTimer;

- (void) beginGoldmineTimer;
- (void) goldmineTimeComplete;
- (void) stopGoldmineTimer;

- (void) beginExpansionTimer;
- (void) stopExpansionTimer;

- (void) addToRequestedClans:(NSArray *)arr;

- (void) resetLockBoxTimers;
- (LockBoxEventProto *) getCurrentLockBoxEvent;
- (void) addToNumLockBoxesForEvent:(int)eventId;
- (void) updateLockBoxButton;

- (void) resetBossEventTimers;
- (BossEventProto *) getCurrentBossEvent;
- (void) updateBossEventButton;

- (void) resetTournamentTimers;
- (LeaderboardEventProto *) getCurrentTournament;
- (void) updateTournamentButton;

- (void) updateClanTowers:(NSArray *)arr;
- (ClanTowerProto *) clanTowerWithId:(int)towerId;

- (void) resetGoldSaleTimers;
- (GoldSaleProto *) getCurrentGoldSale;

- (BOOL) isEngagedInClanTowerWar;

- (NSArray *) mktSearchEquipsSimilarToString:(NSString *)string;

- (void) purgeStaticData;
- (void) reretrieveStaticData;
- (void) clearAllData;

@end
