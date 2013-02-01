//
//  SocketCommunication.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/21/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

//#import "GCDAsyncSocket.h"

#import "Event.pb.h"
#import "Protocols.pb.h"
#import "StoreKit/StoreKit.h"

#import "AMQPWrapper.h"
#import "AMQPConnectionThread.h"
#import "AMQPConnectionThreadDelegate.h"

@interface SocketCommunication : NSObject <UIAlertViewDelegate, AMQPConnectionThreadDelegate> {
  BOOL _shouldReconnect;
  MinimumUserProto *_sender;
  int _currentTagNum;
  int _nextMsgType;
  
  AMQPConnectionThread *_connectionThread;
  
  int _numDisconnects;
}

@property (nonatomic, assign) int attackPoints;
@property (nonatomic, assign) int defensePoints;
@property (nonatomic, assign) int energyPoints;
@property (nonatomic, assign) int staminaPoints;

@property (nonatomic, retain) NSMutableArray *structRetrievals;

- (void) reloadClanMessageQueue;
- (void) rebuildSender;

+ (SocketCommunication *)sharedSocketCommunication;
- (void) initNetworkCommunication;
- (void) initUserIdMessageQueue;
- (void) closeDownConnection;
- (void) messageReceived:(NSData *)buffer withType:(EventProtocolResponse)eventType tag:(int)tag;

// Send different event messages
- (int) sendUserCreateMessageWithName:(NSString *)name type:(UserType)type lat:(CGFloat)lat lon:(CGFloat)lon referralCode:(NSString *)refCode deviceToken:(NSString *)deviceToken attack:(int)attack defense:(int)defense energy:(int)energy stamina:(int)stamina timeOfStructPurchase:(uint64_t)timeOfStructPurchase timeOfStructBuild:(uint64_t)timeOfStructBuild structX:(int)structX structY:(int)structY usedDiamonds:(BOOL)usedDiamondsToBuild;

- (int) sendChatMessage:(NSString *)message recipient:(int)recipient;
- (int) sendVaultMessage:(int)amount requestType: (VaultRequestProto_VaultRequestType) type;
- (int) sendBattleMessage:(MinimumUserProto *)defender result:(BattleResult)result curTime:(uint64_t)curTime city:(int)city equips:(NSArray *)equips;
- (int) sendArmoryMessage:(ArmoryRequestProto_ArmoryRequestType)requestType quantity:(int)quantity equipId:(int)equipId;
- (int) sendStartupMessage:(uint64_t)clientTime;
- (int) sendReconnectMessage;
- (int) sendLogoutMessage;
- (int) sendTaskActionMessage:(int) taskId curTime:(uint64_t)clientTime ;
- (int) sendInAppPurchaseMessage:(NSString *)receipt product:(SKProduct *)product;

// Marketplace messages
- (int) sendRetrieveCurrentMarketplacePostsMessageWithCurNumEntries:(int)curNumEntries filter:(RetrieveCurrentMarketplacePostsRequestProto_RetrieveCurrentMarketplacePostsFilter)filter commonEquips:(BOOL)commonEquips uncommonEquips:(BOOL)uncommonEquips rareEquips:(BOOL)rareEquips epicEquips:(BOOL)epicEquips legendaryEquips:(BOOL)legendaryEquips myClassOnly:(BOOL)myClassOnly minEquipLevel:(int)minEquipLevel maxEquipLevel:(int)maxEquipLevel minForgeLevel:(int)minForgeLevel maxForgeLevel:(int)maxForgeLevel sortOrder:(RetrieveCurrentMarketplacePostsRequestProto_RetrieveCurrentMarketplacePostsSortingOrder)sortOrder specificEquipId:(int)specificEquipId;
- (int) sendRetrieveCurrentMarketplacePostsMessageFromSenderWithCurNumEntries:(int)curNumEntries;
- (int) sendEquipPostToMarketplaceMessage:(int)equipId coins:(int)coins diamonds:(int)diamonds;
- (int) sendRetractMarketplacePostMessage:(int)postId curTime:(uint64_t)curTime;
- (int) sendPurchaseFromMarketplaceMessage:(int)postId poster:(int)posterId clientTime:(uint64_t)clientTime;
- (int) sendRedeemMarketplaceEarningsMessage;
- (int) sendPurchaseMarketplaceLicenseMessage: (uint64_t)clientTime type:(PurchaseMarketplaceLicenseRequestProto_LicenseType)type;

- (int) sendGenerateAttackListMessage:(int)numEnemies;
- (int) sendGenerateAttackListMessage:(int)numEnemies latUpperBound:(CGFloat)latUpperBound latLowerBound:(CGFloat)latLowerBound lonUpperBound:(CGFloat)lonUpperBound lonLowerBound:(CGFloat)lonLowerBound;

- (int) sendRefillStatWaitTimeComplete:(RefillStatWaitCompleteRequestProto_RefillStatWaitCompleteType)type curTime:(uint64_t)curTime;
- (int) sendRefillStatWithDiamondsMessage:(RefillStatWithDiamondsRequestProto_StatType)statType;

// Norm Struct messages
- (int) sendPurchaseNormStructureMessage:(int)structId x:(int)x y:(int)y time:(uint64_t)time;
- (int) sendMoveNormStructureMessage:(int)userStructId x:(int)x y:(int)y;
- (int) sendRotateNormStructureMessage:(int)userStructId orientation:(StructOrientation)orientation;
- (int) sendUpgradeNormStructureMessage:(int)userStructId time:(uint64_t)curTime;
- (int) sendNormStructBuildsCompleteMessage:(NSArray *)userStructIds time:(uint64_t)curTime;
- (int) sendFinishNormStructBuildWithDiamondsMessage:(int)userStructId time:(uint64_t)milliseconds type:(FinishNormStructWaittimeWithDiamondsRequestProto_NormStructWaitTimeType) type;
- (int) sendSellNormStructureMessage:(int)userStructId;

- (int) sendLoadPlayerCityMessage:(int)userId;
- (int) sendLoadNeutralCityMessage:(int)cityId;

- (int) sendRetrieveStaticDataMessageWithStructIds:(NSArray *)structIds taskIds:(NSArray *)taskIds questIds:(NSArray *)questIds cityIds:(NSArray *)cityIds equipIds:(NSArray *)equipIds buildStructJobIds:(NSArray *)buildStructJobIds defeatTypeJobIds:(NSArray *)defeatTypeJobIds possessEquipJobIds:(NSArray *)possessEquipJobIds upgradeStructJobIds:(NSArray *)upgradeStructJobIds events:(BOOL)events clanTierLevels:(BOOL)clanTierLevels bossIds:(NSArray *)bossIds;
- (int) sendRetrieveStaticDataFromShopMessage:(RetrieveStaticDataForShopRequestProto_RetrieveForShopType)type;

- (int) sendEquipEquipmentMessage:(int) equipId;
- (int) sendChangeUserLocationMessageWithLatitude:(CGFloat)lat longitude:(CGFloat)lon;

- (int) sendLevelUpMessage;

- (int) sendQuestAcceptMessage:(int)questId;
- (int) sendQuestRedeemMessage:(int)questId;
- (int) sendUserQuestDetailsMessage:(int)questId;

- (int) sendRetrieveUserEquipForUserMessage:(int)userId;
- (int) sendRetrieveUsersForUserIds:(NSArray *)userIds includePotentialPoints:(BOOL)points;

- (int) sendRetrievePlayerWallPostsMessage:(int)playerId beforePostId:(int)beforePostId;
- (int) sendPostOnPlayerWallMessage:(int)playerId withContent:(NSString *)content;

- (int) sendAPNSMessage:(NSString *)deviceToken;

- (int) sendEarnFreeDiamondsKiipMessageClientTime:(uint64_t)time receipt:(NSString *)receipt;
- (int) sendEarnFreeDiamondsAdColonyMessageClientTime:(uint64_t)time digest:(NSString *)digest amount:(int)amount type:(EarnFreeDiamondsRequestProto_AdColonyRewardType)type;

- (int) sendSubmitEquipsToBlacksmithMessageWithUserEquipId:(int)equipOne userEquipId:(int)equipTwo guaranteed:(BOOL)guaranteed clientTime:(uint64_t)time;
- (int) sendForgeAttemptWaitCompleteMessageWithBlacksmithId:(int)blacksmithId clientTime:(uint64_t)time;
- (int) sendFinishForgeAttemptWaittimeWithDiamondsWithBlacksmithId:(int)blacksmithId clientTime:(uint64_t)time;
- (int) sendCollectForgeEquipsWithBlacksmithId:(int)blacksmithId;

- (int) sendCharacterModWithType:(CharacterModType)modType newType:(UserType)userType newName:(NSString *)name;

- (int) sendRetrieveLeaderboardMessage:(LeaderboardType)type afterRank:(int)rank;

- (int) sendGroupChatMessage:(GroupChatScope)scope message:(NSString *)msg clientTime:(uint64_t)clientTime;
- (int) sendPurchaseGroupChatMessage;

- (int) sendCreateClanMessage:(NSString *)clanName tag:(NSString *)tag;
- (int) sendLeaveClanMessage;
- (int) sendRequestJoinClanMessage:(int)clanId;
- (int) sendRetractRequestJoinClanMessage:(int)clanId;
- (int) sendApproveOrRejectRequestToJoinClan:(int)requesterId accept:(BOOL)accept;
- (int) sendTransferClanOwnership:(int)newClanOwnerId;
- (int) sendChangeClanDescription:(NSString *)description;
- (int) sendRetrieveClanInfoMessage:(NSString *)clanName clanId:(int)clanId grabType:(RetrieveClanInfoRequestProto_ClanInfoGrabType)grabType isForBrowsingList:(BOOL)isForBrowsingList beforeClanId:(int)beforeClanId;
- (int) sendBootPlayerFromClan:(int)playerId;
- (int) sendPostOnClanBulletinMessage:(NSString *)content;
- (int) sendRetrieveClanBulletinPostsMessage:(int)beforeThisClanId;
- (int) sendUpgradeClanTierLevelMessage;

- (int) sendBeginGoldmineTimerMessage:(uint64_t)clientTime reset:(BOOL)reset;
- (int) sendCollectFromGoldmineMessage:(uint64_t)clientTime;

- (int) sendRetrieveThreeCardMonteMessage;

- (int) sendPickLockBoxMessage:(int)eventId method:(PickLockBoxRequestProto_PickLockBoxMethod)method clientTime:(uint64_t)clientTime;

- (int) sendPurchaseCityExpansionMessage:(ExpansionDirection)direction timeOfPurchase:(uint64_t)time;
- (int) sendExpansionWaitCompleteMessage:(BOOL)speedUp curTime:(uint64_t)time;

- (int) sendRetrieveThreeCardMonteMessage;
- (int) sendPlayThreeCardMonteMessage:(int)cardId;

- (int) sendBossActionMessage:(int)bossId isSuperAttack:(BOOL)isSuperAttack curTime:(uint64_t)curTime;

- (int) sendBeginClanTowerWarMessage:(int)towerId claiming:(BOOL)claiming clientTime:(uint64_t)clientTime;
- (int) sendConcedeClanTowerWar:(int)towerId clientTime:(uint64_t)clientTime;

- (int) sendRetrieveLeaderboardRankingsMessage:(int)eventId afterThisRank:(int)afterThisRank;

- (int) sendSubmitEquipEnhancementMessage:(int)enhancingId feeders:(NSArray *)feeders clientTime:(uint64_t)clientTime;
- (int) sendCollectEquipEnhancementMessage:(int)enhancementId speedup:(BOOL)speedup time:(uint64_t)clientTime;

- (int) sendRetrieveClanTowerScoresMessage:(int)towerId;

- (int) addAttackSkillPoint;
- (int) addDefenseSkillPoint;
- (int) addEnergySkillPoint;
- (int) addStaminaSkillPoint;
- (int) sendUseSkillPointMessage;
- (int) retrieveCurrencyFromStruct:(int)userStructId time:(uint64_t)time;
- (void) flush:(int)type;

@end