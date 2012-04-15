//
//  SocketCommunication.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/21/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

#import "GCDAsyncSocket.h"

#import "Event.pb.h"
#import "Protocols.pb.h"

@interface SocketCommunication : NSObject <GCDAsyncSocketDelegate, UIAlertViewDelegate> {
	GCDAsyncSocket *_asyncSocket;
  BOOL _shouldReconnect;
  MinimumUserProto *_sender;
  int _currentTagNum;
  int _nextMsgType;
  
  int _numDisconnects;
}

@property (readonly) int currentTagNum;

- (void) rebuildSender;

+ (SocketCommunication *)sharedSocketCommunication;
- (void) initNetworkCommunication;
- (void) closeDownConnection;
- (void) readHeader;
- (void) messageReceived:(NSData *)buffer withType:(EventProtocolResponse)eventType tag:(int)tag;

// Send different event messages
- (void) sendUserCreateMessageWithName:(NSString *)name type:(UserType)type lat:(CGFloat)lat lon:(CGFloat)lon referralCode:(NSString *)refCode deviceToken:(NSString *)deviceToken attack:(int)attack defense:(int)defense health:(int)health energy:(int)energy stamina:(int)stamina timeOfStructPurchase:(uint64_t)timeOfStructPurchase timeOfStructBuild:(uint64_t)timeOfStructBuild structX:(int)structX structY:(int)structY usedDiamonds:(BOOL)usedDiamondsToBuild;

- (void) sendChatMessage:(NSString *)message recipient:(int)recipient;
- (void) sendVaultMessage:(int)amount requestType: (VaultRequestProto_VaultRequestType) type;
- (void) sendBattleMessage:(MinimumUserProto *)defender result:(BattleResult)result curTime:(uint64_t)curTime city:(int)city equips:(NSArray *)equips;
- (void) sendArmoryMessage:(ArmoryRequestProto_ArmoryRequestType)requestType quantity:(int)quantity equipId:(int)equipId;
- (void) sendStartupMessage:(uint64_t)clientTime;
- (void) sendTaskActionMessage:(int) taskId curTime:(uint64_t)clientTime ;
- (void) sendInAppPurchaseMessage: (NSString *) receipt;

// Marketplace messages
- (void) sendRetrieveCurrentMarketplacePostsMessageBeforePostId:(int)postId fromSender:(BOOL)fromSender;
- (void) sendEquipPostToMarketplaceMessage:(int)equipId coins:(int)coins diamonds:(int)diamonds;
- (void) sendRetractMarketplacePostMessage: (int)postId;
- (void) sendPurchaseFromMarketplaceMessage: (int)postId poster:(int)posterId;
- (void) sendRedeemMarketplaceEarningsMessage;
- (void) sendPurchaseMarketplaceLicenseMessage: (uint64_t)clientTime type:(PurchaseMarketplaceLicenseRequestProto_LicenseType)type;

- (void) sendGenerateAttackListMessage:(int)numEnemies latUpperBound:(CGFloat)latUpperBound latLowerBound:(CGFloat)latLowerBound lonUpperBound:(CGFloat)lonUpperBound lonLowerBound:(CGFloat)lonLowerBound;
- (void) sendUseSkillPointMessage: (UseSkillPointRequestProto_BoostType) boostType;

- (void) sendRefillStatWaitTimeComplete:(RefillStatWaitCompleteRequestProto_RefillStatWaitCompleteType)type curTime:(uint64_t)curTime;
- (void) sendRefillStatWithDiamondsMessage:(RefillStatWithDiamondsRequestProto_StatType)statType;

// Norm Struct messages
- (void) sendPurchaseNormStructureMessage:(int)structId x:(int)x y:(int)y time:(uint64_t)time;
- (void) sendMoveNormStructureMessage:(int)userStructId x:(int)x y:(int)y;
- (void) sendRotateNormStructureMessage:(int)userStructId orientation:(StructOrientation)orientation;
- (void) sendCritStructPlace:(CritStructType)type x:(int)x y:(int)y;
- (void) sendCritStructMove:(CritStructType)type x:(int)x y:(int)y;
- (void) sendCritStructRotate:(CritStructType)type orientation:(StructOrientation)orientation;
- (void) sendUpgradeNormStructureMessage:(int)userStructId time:(uint64_t)curTime;
- (void) sendNormStructBuildsCompleteMessage:(NSArray *)userStructIds time:(uint64_t)curTime;
- (void) sendFinishNormStructBuildWithDiamondsMessage:(int)userStructId time:(uint64_t)milliseconds type:(FinishNormStructWaittimeWithDiamondsRequestProto_NormStructWaitTimeType) type;
- (void) sendRetrieveCurrencyFromNormStructureMessage:(int)userStructId time:(uint64_t)milliseconds;
- (void) sendSellNormStructureMessage:(int)userStructId;

- (void) sendLoadPlayerCityMessage:(MinimumUserProto *)mup;
- (void) sendLoadNeutralCityMessage:(int)cityId;

- (void) sendRetrieveStaticDataMessageWithStructIds:(NSArray *)structIds taskIds:(NSArray *)taskIds questIds:(NSArray *)questIds cityIds:(NSArray *)cityIds equipIds:(NSArray *)equipIds buildStructJobIds:(NSArray *)buildStructJobIds defeatTypeJobIds:(NSArray *)defeatTypeJobIds possessEquipJobIds:(NSArray *)possessEquipJobIds upgradeStructJobIds:(NSArray *)upgradeStructJobIds;
- (void) sendRetrieveStaticDataFromShopMessage:(RetrieveStaticDataForShopRequestProto_RetrieveForShopType)type;

- (void) sendEquipEquipmentMessage:(int) equipId;
- (void) sendChangeUserLocationMessageWithLatitude:(CGFloat)lat longitude:(CGFloat)lon;

- (void) sendLevelUpMessage;

- (void) sendQuestAcceptMessage:(int)questId;
- (void) sendQuestRedeemMessage:(int)questId;
- (void) sendUserQuestDetailsMessage:(int)questId;

- (void) sendRetrieveUserEquipForUserMessage:(int)userId;
- (void) sendRetrieveUsersForUserIds:(NSArray *)userIds;

@end