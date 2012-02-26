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

@interface SocketCommunication : NSObject <GCDAsyncSocketDelegate> {
	GCDAsyncSocket *_asyncSocket;
  BOOL readyToRead;
  MinimumUserProto *_sender;
  int _currentTagNum;
  int _nextMsgType;
}

@property (readonly) int currentTagNum;

- (void) rebuildSender;

+ (SocketCommunication *)sharedSocketCommunication;
- (void) initNetworkCommunication;
- (void) readHeader;
- (void) messageReceived:(NSData *)buffer withType:(EventProtocolResponse)eventType tag:(int)tag;

// Send different event messages
- (void) sendChatMessage:(NSString *)message recipient:(int)recipient;
- (void) sendVaultMessage:(int)amount requestType: (VaultRequestProto_VaultRequestType) type;
- (void) sendTasksForCityMessage: (int) cityId;
- (void) sendBattleMessage:(int)defender;
- (void) sendStartupMessage:(uint64_t)clientTime;
- (void) sendTaskActionMessage:(int) taskId;
- (void) sendInAppPurchaseMessage: (NSString *) receipt;

// Marketplace messages
- (void) sendRetrieveCurrentMarketplacePostsMessageBeforePostId:(int)postId fromSender:(BOOL)fromSender;
- (void) sendEquipPostToMarketplaceMessage:(int)equipId coins:(int)coins diamonds:(int)diamonds;
- (void) sendRetractMarketplacePostMessage: (int)postId;
- (void) sendPurchaseFromMarketplaceMessage: (int)postId poster:(int)posterId;
- (void) sendRedeemMarketplaceEarningsMessage;

- (void) sendGenerateAttackListMessage:(int)numEnemies latUpperBound:(int)latUpperBound latLowerBound:(int)latLowerBound lonUpperBound:(int)lonUpperBound lonLowerBound:(int)lonLowerBound;
- (void) sendUseSkillPointMessage: (UseSkillPointRequestProto_BoostType) boostType;

- (void) sendRefillStatWithDiamondsMessage: (RefillStatWithDiamondsRequestProto_StatType) statType;

// Norm Struct messages
- (void) sendPurchaseNormStructureMessage:(int)structId x:(int)x y:(int)y time:(uint64_t)time;
- (void) sendMoveNormStructureMessage:(int)userStructId x:(int)x y:(int)y;
- (void) sendUpgradeNormStructureMessage:(int)userStructId time:(uint64_t)curTime;
- (void) sendNormStructBuildsCompleteMessage:(NSArray *)userStructIds time:(uint64_t)curTime;
- (void) sendFinishNormStructBuildWithDiamondsMessage:(int)userStructId time:(uint64_t)milliseconds type:(FinishNormStructWaittimeWithDiamondsRequestProto_NormStructWaitTimeType) type;
- (void) sendRetrieveCurrencyFromNormStructureMessage:(int)userStructId time:(uint64_t)milliseconds;
- (void) sendSellNormStructureMessage:(int)userStructId;

- (void) sendLoadPlayerCityMessage:(MinimumUserProto *)mup;

- (void) sendRetrieveStaticDataMessageWithStructIds:(NSArray *)structIds taskIds:(NSArray *)taskIds questIds:(NSArray *)questIds cityIds:(NSArray *)cityIds equipIds:(NSArray *)equipIds buildStructJobIds:(NSArray *)buildStructJobIds defeatTypeJobIds:(NSArray *)defeatTypeJobIds possessEquipJobIds:(NSArray *)possessEquipJobIds upgradeStructJobIds:(NSArray *)upgradeStructJobIds;
- (void) sendRetrieveStaticDataFromShopMessage:(RetrieveStaticDataForShopRequestProto_RetrieveForShopType)type;

@end
