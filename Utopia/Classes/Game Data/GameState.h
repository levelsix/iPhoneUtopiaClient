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
  
  NSMutableArray *_notifications;
  NSMutableArray *_wallPosts;
  NSMutableArray *_globalChatMessages;
  NSMutableArray *_clanChatMessages;
  
  NSTimer *_enhanceTimer;
  
  NSDate *_lastLogoutTime;
  
  uint64_t _lastUserUpdate;
  
  NSArray *_allies;
  
  // For the tagging scheme
  NSMutableArray *_unrespondedUpdates;
  
  NSDate *_lastGoldmineRetrieval;
  NSTimer *_goldmineTimer;
  
  MinimumClanProto *_clan;
  NSMutableArray *_requestedClans;
  
  NSTimer *_expansionTimer;
}

@property (nonatomic, assign) BOOL isTutorial;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, assign) int userId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) UserType type;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int defense;
@property (nonatomic, assign) int attack;
@property (nonatomic, assign) int currentEnergy;
@property (nonatomic, assign) int maxEnergy;
@property (nonatomic, assign) int currentStamina;
@property (nonatomic, assign) int maxStamina;
@property (nonatomic, assign) int gold;
@property (nonatomic, assign) int silver;
@property (nonatomic, assign) int vaultBalance;
@property (nonatomic, retain) NSString *referralCode;
@property (nonatomic, assign) int battlesWon;
@property (nonatomic, assign) int battlesLost;
@property (nonatomic, assign) int flees;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, assign) int skillPoints;
@property (nonatomic, assign) int experience;
@property (nonatomic, assign) int tasksCompleted;
@property (nonatomic, assign) int numReferrals;
@property (nonatomic, assign) int marketplaceGoldEarnings;
@property (nonatomic, assign) int marketplaceSilverEarnings;
@property (nonatomic, assign) int numMarketplaceSalesUnredeemed;
@property (nonatomic, assign) int numPostsInMarketplace;
@property (nonatomic, assign) int weaponEquipped;
@property (nonatomic, assign) int armorEquipped;
@property (nonatomic, assign) int amuletEquipped;
@property (nonatomic, assign) int weaponEquipped2;
@property (nonatomic, assign) int armorEquipped2;
@property (nonatomic, assign) int amuletEquipped2;
@property (nonatomic, assign) int playerHasBoughtInAppPurchase;
@property (nonatomic, retain) NSDate *lastEnergyRefill;
@property (nonatomic, retain) NSDate *lastStaminaRefill;
@property (nonatomic, assign) int numAdColonyVideosWatched;
@property (nonatomic, assign) int numGroupChatsRemaining;
@property (nonatomic, assign) BOOL isAdmin;
@property (nonatomic, retain) NSDate *createTime;
@property (nonatomic, assign) BOOL hasReceivedfbReward;
@property (nonatomic, assign) int prestigeLevel;
@property (nonatomic, assign) int numAdditionalForgeSlots;
@property (nonatomic, assign) int numBeginnerSalesPurchased;
@property (nonatomic, assign) BOOL hasActiveShield;

@property (nonatomic, retain) NSString *kabamNaid;

@property (nonatomic, retain) NSString *deviceToken;

@property (nonatomic, retain) NSDate *lastShortLicensePurchaseTime;
@property (nonatomic, retain) NSDate *lastLongLicensePurchaseTime;

@property (nonatomic, assign) int expRequiredForCurrentLevel;
@property (nonatomic, assign) int expRequiredForNextLevel;

@property (nonatomic, retain) NSMutableArray *marketplaceEquipPosts;
@property (nonatomic, retain) NSMutableArray *marketplaceEquipPostsFromSender;

@property (nonatomic, retain) NSMutableDictionary *staticStructs;
@property (nonatomic, retain) NSMutableDictionary *staticTasks;
@property (nonatomic, retain) NSMutableDictionary *staticBosses;
@property (nonatomic, retain) NSMutableDictionary *staticQuests;
@property (nonatomic, retain) NSMutableDictionary *staticCities;
@property (nonatomic, retain) NSMutableDictionary *staticEquips;
@property (nonatomic, retain) NSMutableDictionary *staticBuildStructJobs;
@property (nonatomic, retain) NSMutableDictionary *staticDefeatTypeJobs;
@property (nonatomic, retain) NSMutableDictionary *staticPossessEquipJobs;
@property (nonatomic, retain) NSMutableDictionary *staticUpgradeStructJobs;
@property (nonatomic, retain) NSMutableArray *staticLockBoxEvents;
@property (nonatomic, retain) NSMutableArray *staticGoldSales;
@property (nonatomic, retain) NSMutableArray *staticBossEvents;
@property (nonatomic, retain) NSMutableArray *staticTournaments;

@property (nonatomic, retain) NSArray *carpenterStructs;
@property (nonatomic, retain) NSArray *armoryWeapons;
@property (nonatomic, retain) NSArray *armoryArmor;
@property (nonatomic, retain) NSArray *armoryAmulets;
@property (nonatomic, retain) NSArray *boosterPacks;

@property (nonatomic, retain) NSMutableArray *myEquips;
@property (nonatomic, retain) NSMutableArray *myStructs;
@property (nonatomic, retain) NSMutableDictionary *myCities;
@property (nonatomic, retain) NSMutableDictionary *myLockBoxEvents;
@property (nonatomic, retain) NSMutableDictionary *myBoosterPacks;

@property (nonatomic, retain) NSMutableDictionary *inProgressCompleteQuests;
@property (nonatomic, retain) NSMutableDictionary *inProgressIncompleteQuests;
@property (nonatomic, retain) NSMutableDictionary *availableQuests;

@property (nonatomic, retain) NSMutableArray *attackBotList;
@property (nonatomic, retain) NSMutableArray *attackPlayersList;
@property (nonatomic, retain) NSMutableArray *notifications;
@property (nonatomic, retain) NSMutableArray *wallPosts;
@property (nonatomic, retain) NSMutableArray *globalChatMessages;
@property (nonatomic, retain) NSMutableArray *clanChatMessages;
@property (nonatomic, retain) NSMutableArray *boosterPurchases;
@property (nonatomic, retain) NSMutableArray *privateChats;

@property (nonatomic, retain) NSMutableArray *unrespondedUpdates;

@property (nonatomic, retain) NSDate *lastLogoutTime;

@property (nonatomic, retain) NSArray *allies;

@property (nonatomic, retain) NSMutableArray *forgeAttempts;
@property (nonatomic, retain) NSArray *forgeTimers;
@property (nonatomic, retain) EquipEnhancementProto *equipEnhancement;

@property (nonatomic, retain) NSDate *lastGoldmineRetrieval;

@property (nonatomic, retain) MinimumClanProto *clan;
@property (nonatomic, retain) NSMutableArray *requestedClans;

@property (nonatomic, copy) NSArray *mktSearchEquips;

@property (nonatomic, nonatomic, retain) UserExpansion *userExpansion;

@property (nonatomic, retain) NSMutableArray *lockBoxEventTimers;
@property (nonatomic, retain) NSMutableArray *goldSaleTimers;
@property (nonatomic, retain) NSMutableArray *bossEventTimers;
@property (nonatomic, retain) NSMutableArray *tournamentTimers;

@property (nonatomic, retain) NSDictionary *clanTierLevels;

@property (nonatomic, retain) NSArray *clanTowers;
@property (nonatomic, retain) NSMutableArray *clanTowerUserBattles;

@property (nonatomic, assign) int clanChatBadgeNum;

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
- (BoosterPackProto *) boosterPackForId:(int)packId;

- (int) weaponEquippedId;
- (int) armorEquippedId;
- (int) amuletEquippedId;
- (int) weaponEquippedId2;
- (int) armorEquippedId2;
- (int) amuletEquippedId2;

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
- (void) clanChatViewed;
- (void) addBoosterPurchase:(RareBoosterPurchaseProto *)bp;

- (UserEquip *) myEquipWithId:(int)equipId level:(int)level;
- (NSArray *) myEquipsWithId:(int)equipId level:(int)level;
- (NSArray *) myEquipsWithEquipId:(int)equipId;
- (UserEquip *) myEquipWithUserEquipId:(int)userEquipId;  
- (int) quantityOfEquip:(int)equipId;
- (int) quantityOfEquip:(int)equipId level:(int)level;
- (UserStruct *) myStructWithId:(int)structId;
- (UserCity *) myCityWithId:(int)cityId;
- (UserBoosterPackProto *) myBoosterPackForId:(int)packId;

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
- (void) addToClanTierLevels:(NSArray *)tiers;
- (void) addStaticBoosterPacks:(NSArray *)bpps userBoosterPacks:(NSArray *)ubpps;

- (ClanTierLevelProto *) clanTierForLevel:(int)level;
- (int) maxClanTierLevel;

- (void) addUnrespondedUpdate:(id<GameStateUpdate>)up;
- (void) addUnrespondedUpdates:(id<GameStateUpdate>)field1, ... NS_REQUIRES_NIL_TERMINATION;
- (void) removeAndUndoAllUpdatesForTag:(int)tag;
- (void) removeFullUserUpdatesForTag:(int)tag;
- (void) removeNonFullUserUpdatesForTag:(int)tag;

- (BOOL) hasValidLicense;

- (void) beginForgeTimers;
- (void) stopForgeTimers;
- (ForgeAttempt *) forgeAttemptForSlot:(int)slotNum;
- (ForgeAttempt *) forgeAttemptForBlacksmithId:(int)blacksmithId;
- (void) addForgeAttempt:(ForgeAttempt *)u;
- (void) removeForgeAttempt:(int)blacksmithId;

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
- (void) addClanTowerUserBattle:(ClanTowerUserBattle *)ctub;
- (void) removeClanTowerUserBattlesForTowerId:(int)towerId;
- (NSArray *) clanTowerUserBattlesForTowerId:(int)towerId;

- (void) resetGoldSaleTimers;
- (GoldSaleProto *) getCurrentGoldSale;

- (BOOL) isEngagedInClanTowerWar;

- (NSArray *) mktSearchEquipsSimilarToString:(NSString *)string;

- (NSArray *) getUserEquipArray;
- (BOOL) hasBeginnerShield;

- (void) purgeStaticData;
- (void) reretrieveStaticData;
- (void) clearAllData;

@end
