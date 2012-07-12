//
//  UserData.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/9/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"

@interface UserEquip : NSObject

@property (nonatomic, assign) int userId;
@property (nonatomic, assign) int equipId;
@property (nonatomic, assign) int quantity;

+ (id) userEquipWithProto:(FullUserEquipProto *)proto;

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

@interface CritStruct : NSObject 

@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) CritStructType type;
@property (nonatomic, assign) CGSize size;

- (id) initWithType:(CritStructType)t;
- (void) openMenu;

@end

typedef enum {
  kNotificationBattle = 1,
  kNotificationMarketplace,
  kNotificationReferral
} NotificationType;

@interface UserNotification : NSObject

@property (nonatomic, retain) MinimumUserProto *otherPlayer;
@property (nonatomic, assign) NotificationType type;
@property (nonatomic, retain) NSDate *time;
@property (nonatomic, retain) FullMarketplacePostProto *marketPost;
@property (nonatomic, assign) BattleResult battleResult;
@property (nonatomic, assign) int coinsStolen;
@property (nonatomic, assign) int stolenEquipId;
@property (nonatomic, assign) BOOL hasBeenViewed;

- (id) initBattleNotificationAtStartup:(StartupResponseProto_AttackedNotificationProto *)proto;
- (id) initMarketplaceNotificationAtStartup:(StartupResponseProto_MarketplacePostPurchasedNotificationProto *)proto;
- (id) initReferralNotificationAtStartup:(StartupResponseProto_ReferralNotificationProto *)proto;
- (id) initWithBattleResponse:(BattleResponseProto *)proto;
- (id) initWithMarketplaceResponse:(PurchaseFromMarketplaceResponseProto *)proto;
- (id) initWithReferralResponse:(ReferralCodeUsedResponseProto *)proto;

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
