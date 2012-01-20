//
//  SocketCommunication.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/21/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

#import "cocos2d.h"
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
- (void) sendClericMessage;
- (void) sendStartupMessage;
- (void) sendTaskActionMessage:(int) taskId;
- (void) sendInAppPurchaseMessage: (NSString *) receipt;

// Marketplace messages
- (void) sendRetrieveCurrentMarketplacePostsMessage;
- (void) sendCoinPostToMarketplaceMessage:(int)coinPost wood:(int)wood coins:(int)coins diamonds:(int)diamonds;
- (void) sendWoodPostToMarketplaceMessage:(int)woodPost wood:(int)wood coins:(int)coins diamonds:(int)diamonds;
- (void) sendDiamondPostToMarketplaceMessage:(int)dmdPost wood:(int)wood coins:(int)coins diamonds:(int)diamonds;
- (void) sendEquipPostToMarketplaceMessage:(int)equipId wood:(int)wood coins:(int)coins diamonds:(int)diamonds;
- (void) sendRetractMarketplacePostMessage: (int)postId;
- (void) sendPurchaseFromMarketplaceMessage: (int)postId poster:(int)posterId;

@end
