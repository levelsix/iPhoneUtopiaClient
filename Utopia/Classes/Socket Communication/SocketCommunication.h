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
}

+ (SocketCommunication *)sharedSocketCommunication;
- (void) initNetworkCommunication;
- (void) readHeader;
- (void) messageReceived:(NSData *)buffer withType:(EventProtocolResponse) eventType;

// Send different event messages
- (void) sendChatMessage:(NSString *)message recipient:(int)recipient;
- (void) sendVaultMessage:(int)amount requestType: (VaultRequestProto_VaultRequestType) type;
- (void) sendTasksForCityMessage: (int) cityId;
- (void) sendBattleMessage:(int)defender;
- (void) sendStartupMessage;
- (void) sendTaskActionMessage:(int) taskId;
- (void) sendInAppPurchaseMessage: (NSString *) receipt;

// Marketplace messages
- (void) sendRetrieveCurrentMarketplacePostsMessageBeforePostId:(int)postId fromSender:(BOOL)fromSender;
- (void) sendCoinPostToMarketplaceMessage:(int)coinPost wood:(int)wood coins:(int)coins diamonds:(int)diamonds;
- (void) sendWoodPostToMarketplaceMessage:(int)woodPost wood:(int)wood coins:(int)coins diamonds:(int)diamonds;
- (void) sendDiamondPostToMarketplaceMessage:(int)dmdPost wood:(int)wood coins:(int)coins diamonds:(int)diamonds;
- (void) sendEquipPostToMarketplaceMessage:(int)equipId wood:(int)wood coins:(int)coins diamonds:(int)diamonds;
- (void) sendRetractMarketplacePostMessage: (int)postId;
- (void) sendPurchaseFromMarketplaceMessage: (int)postId poster:(int)posterId;
- (void) sendRedeemMarketplaceEarningsMessage;

- (void) sendGenerateAttackListMessage;
- (void) sendUseSkillPointMessage: (UseSkillPointRequestProto_BoostType) boostType;

- (void) sendRefillStatWithDiamondsMessage: (RefillStatWithDiamondsRequestProto_StatType) statType;

// Norm Struct messages
- (void) sendPurchaseNormStructureMessage:(int)structId x:(int)x y:(int)y;
- (void) sendMoveNormStructureMessage:(int)userStructId x:(int)x y:(int)y;
- (void) sendUpgradeNormStructureMessage:(int)userStructId;
- (void) sendFinishNormStructBuildWithDiamondsMessage:(int)userStructId time:(long)seconds type:(FinishNormStructWaittimeWithDiamondsRequestProto_NormStructWaitTimeType) type;
- (void) sendRetrieveCurrencyFromNormStructureMessage:(int)userStructId time:(long)seconds;
- (void) sendSellNormStructureMessage:(int)userStructId;

- (void) sendLoadPlayerCityMessage:(MinimumUserProto *)mup;

@end
