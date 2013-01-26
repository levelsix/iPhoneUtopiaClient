//
//  UserData.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/9/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"
#import "GoldMineView.h"

@class ForgeAttempt;

@interface UserEquip : NSObject

@property (nonatomic, assign) int userEquipId;
@property (nonatomic, assign) int userId;
@property (nonatomic, assign) int equipId;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int durability;
@property (nonatomic, assign) int enhancementPercentage;

+ (id) userEquipWithProto:(FullUserEquipProto *)proto;
+ (id) userEquipWithEquipEnhancementItemProto:(EquipEnhancementItemProto *)proto;

@end

typedef enum {
  kRetrieving = 1,
  kWaitingForIncome,
  kUpgrading,
  kBuilding
} UserStructState;

@interface UserStruct : NSObject 

@property (nonatomic, assign) int userStructId;
@property (nonatomic, assign) int userId;
@property (nonatomic, assign) int structId;
@property (nonatomic, retain) NSDate *lastRetrieved;
@property (nonatomic, assign) CGPoint coordinates;
@property (nonatomic, assign) int level;
@property (nonatomic, retain) NSDate *purchaseTime;
@property (nonatomic, retain) NSDate *lastUpgradeTime;
@property (nonatomic, assign) BOOL isComplete;
@property (nonatomic, assign) StructOrientation orientation;

+ (id) userStructWithProto:(FullUserStructureProto *)proto;
- (UserStructState) state;
- (FullStructureProto *) fsp;

@end

@interface UserCity : NSObject

@property (nonatomic, assign) int curRank;
@property (nonatomic, assign) int cityId;
@property (nonatomic, assign) int numTasksComplete;

+ (id) userCityWithProto:(FullUserCityProto *)proto;

@end

typedef enum {
  BazaarStructTypeAviary = 994,
  BazaarStructTypeCarpenter,
  BazaarStructTypeVault,
  BazaarStructTypeArmory,
  BazaarStructTypeMarketplace,
  BazaarStructTypeBlacksmith,
  BazaarStructTypeLeaderboard,
  BazaarStructTypeClanHouse,
  BazaarStructTypeGoldMine
} BazaarStructType;

@interface CritStruct : NSObject 

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) BazaarStructType type;
@property (nonatomic, assign) int minLevel;

@property (nonatomic, retain) IBOutlet GoldMineView *goldMineView;

- (id) initWithType:(BazaarStructType)t;
- (void) openMenu;

@end

typedef enum {
  kNotificationBattle = 1,
  kNotificationMarketplace,
  kNotificationReferral,
  kNotificationForge,
  kNotificationEnhance,
  kNotificationWallPost,
  kNotificationGoldmine,
  kNotificationGeneral
} NotificationType;

@interface UserNotification : NSObject

@property (nonatomic, retain) MinimumUserProto *otherPlayer;
@property (nonatomic, assign) NotificationType type;
@property (nonatomic, retain) NSDate *time;
@property (nonatomic, retain) FullMarketplacePostProto *marketPost;
@property (nonatomic, assign) BOOL sellerHadLicense;
@property (nonatomic, assign) BattleResult battleResult;
@property (nonatomic, assign) int coinsStolen;
@property (nonatomic, assign) int stolenEquipId;
@property (nonatomic, assign) int stolenEquipLevel;
@property (nonatomic, assign) int forgeEquipId;
@property (nonatomic, assign) BOOL goldmineCollect;
@property (nonatomic, assign) BOOL hasBeenViewed;
@property (nonatomic, retain) NSString *wallPost;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) UIColor *color;

- (id) initBattleNotificationAtStartup:(StartupResponseProto_AttackedNotificationProto *)proto;
- (id) initMarketplaceNotificationAtStartup:(StartupResponseProto_MarketplacePostPurchasedNotificationProto *)proto;
- (id) initReferralNotificationAtStartup:(StartupResponseProto_ReferralNotificationProto *)proto;
- (id) initWithBattleResponse:(BattleResponseProto *)proto;
- (id) initWithMarketplaceResponse:(PurchaseFromMarketplaceResponseProto *)proto;
- (id) initWithReferralResponse:(ReferralCodeUsedResponseProto *)proto;
- (id) initWithForgeAttempt:(ForgeAttempt *)fa;
- (id) initWithEnhancement:(EquipEnhancementProto *)ee;
- (id) initWithWallPost:(PlayerWallPostProto *)proto;
- (id) initWithGoldmineRetrieval:(NSDate *)goldmineStart;
- (id) initWithTitle:(NSString *)t subtitle:(NSString *)st color:(UIColor *)c;

@end


typedef enum {
  kTask = 1,
  kDefeatTypeJob,
  kBuildStructJob,
  kUpgradeStructJob,
  kPossessEquipJob,
  kCoinRetrievalJob,
  kSpecialJob
} JobItemType;

typedef enum {
  WARRIOR_T,
  ARCHER_T,
  MAGE_T
} PlayerClassType;

@interface UserJob : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, assign) int numCompleted;
@property (nonatomic, assign) int total;
@property (nonatomic, assign) JobItemType jobType;
@property (nonatomic, assign) int jobId;

- (id) initWithTask:(FullTaskProto *)p;
- (id) initWithDefeatTypeJob:(DefeatTypeJobProto *)p;
- (id) initWithPossessEquipJob:(PossessEquipJobProto *)p;
- (id) initWithBuildStructJob:(BuildStructJobProto *)p;
- (id) initWithUpgradeStructJob:(UpgradeStructJobProto *)p;
- (id) initWithCoinRetrieval:(int)amount questId:(int)questId;
+ (NSArray *)jobsForQuest:(FullQuestProto *)fqp;

@end

@interface ForgeAttempt : NSObject

@property (nonatomic, assign) int blacksmithId;
@property (nonatomic, assign) int equipId;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) BOOL guaranteed;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, assign) BOOL isComplete;
@property (nonatomic, retain) NSDate *speedupTime;

+ (id) forgeAttemptWithUnhandledBlacksmithAttemptProto:(UnhandledBlacksmithAttemptProto *)attempt;

@end

@interface ChatMessage : NSObject

@property (nonatomic, retain) MinimumUserProto *sender;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, assign) BOOL isAdmin;

- (id) initWithProto:(GroupChatMessageProto *)p;

@end

@interface UserExpansion : NSObject

@property (nonatomic, assign) int userId;
@property (nonatomic, assign) int farLeftExpansions;
@property (nonatomic, assign) int farRightExpansions;
@property (nonatomic, assign) int nearLeftExpansions;
@property (nonatomic, assign) int nearRightExpansions;
@property (nonatomic, assign) BOOL isExpanding;
@property (nonatomic, retain) NSDate *lastExpandTime;
@property (nonatomic, assign) ExpansionDirection lastExpandDirection;

+ (id) userExpansionWithFullUserCityExpansionDataProto:(FullUserCityExpansionDataProto *)proto;
- (int) numCompletedExpansions;

@end

@class UserBoss;

@protocol UserBossDelegate <NSObject>

- (void) bossRespawned:(UserBoss *)boss;
- (void) bossTimeUp:(UserBoss *)boss;

@end

@interface UserBoss : NSObject

@property (nonatomic, assign) int bossId;
@property (nonatomic, assign) int userId;
@property (nonatomic, assign) int curHealth;
@property (nonatomic, assign) int numTimesKilled;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *lastKilledTime;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, assign) id<UserBossDelegate> delegate;

+ (id) userBossWithFullUserBossProto:(FullUserBossProto *)ub;
- (BOOL) isAlive;
- (BOOL) hasBeenAttacked;
- (NSDate *) nextRespawnTime;
- (NSDate *) timeUpDate;
- (void) createTimer;

@end

@interface BossReward : NSObject

typedef enum {
  kSilverDrop = 1,
  kGoldDrop = 2,
  kEquipDrop = 3
} BossDropType;

@property (nonatomic, assign) BossDropType type;
@property (nonatomic, assign) int value;

@end

@interface ClanTowerUserBattle : NSObject

@property (nonatomic, retain) MinimumUserProto *attacker;
@property (nonatomic, retain) MinimumUserProto *defender;
@property (nonatomic, assign) BOOL attackerWon;
@property (nonatomic, assign) int pointsGained;
@property (nonatomic, assign) int towerId;
@property (nonatomic, retain) NSDate *date;

@end