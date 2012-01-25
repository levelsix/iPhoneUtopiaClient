//
//  SocketCommunication.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/21/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

#import "SocketCommunication.h"
#import "SynthesizeSingleton.h"
#import "Protocols.pb.h"
#import "EventController.h"
#import "UIDevice+IdentifierAddition.h"

#define HOST_NAME @"localhost"
#define HOST_PORT 8888

// Tags for keeping state
#define READING_HEADER_TAG -1

@implementation SocketCommunication

SYNTHESIZE_SINGLETON_FOR_CLASS(SocketCommunication);

- (void) connectToSocket {
	NSError *error = nil;
  NSString *host = HOST_NAME;
  uint16_t port = HOST_PORT;
  
  // Make connection to host
	if (![_asyncSocket connectToHost:host onPort:port error:&error])
	{
		NSLog(@"Unable to connect to due to invalid configuration: %@", error);
	}
	else
	{
		NSLog(@"Connecting to \"%@\" on port %hu...", host, port);
	}
}

- (void) initNetworkCommunication {
  _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
  [self connectToSocket];
  
  _sender = [[[[[[MinimumUserProto builder] 
                 setUserId:2] 
                setName:@"Ashwin"] 
               setUserType: UserTypeBadArcher] 
              build] retain];
  
  //  for (int i = 0; i < 100; i++) {
  //    [self sendCoinPostToMarketplaceMessage:10 wood:arc4random()%30 coins:arc4random()%100 diamonds:arc4random()%20];
  //  }
  [self sendRetrieveCurrentMarketplacePostsMessageFromSenderBeforePostId:30];
  //  [self sendStartupMessage];
  //  [self sendVaultMessage:4 requestType:VaultRequestProto_VaultRequestTypeWithdraw];
  //  [self sendVaultMessage:2 requestType:VaultRequestProto_VaultRequestTypeDeposit];
  //  [self sendVaultMessage:2 requestType:VaultRequestProto_VaultRequestTypeDeposit];
  //  [self sendTaskActionMessage:2];
}

- (void) readHeader {
  NSLog(@"Reading header");
  [_asyncSocket readDataToLength:8 withTimeout:-1 tag:READING_HEADER_TAG];
}

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
  NSLog(@"Connected to host");
  
  [self readHeader];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  if (tag == READING_HEADER_TAG) {
    uint8_t *header = (uint8_t *)[data bytes];
    
    // Get the next 4 bytes for the payload size
    NSLog(@"Found header");
    [_asyncSocket readDataToLength:*(int *)(header+4) withTimeout:-1 tag:*(int *)(header)];
  } else {
    // Tag will be the message type
    [self messageReceived:data withType:tag];
    [self readHeader];
  }
}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	NSLog(@"socketDidDisconnect:withError: \"%@\"", err);
  NSLog(@"Attempting to reconnect..");
  //  [self connectToSocket];
}

-(void) messageReceived:(NSData *)data withType:(EventProtocolResponse) eventType {
  EventController *ec = [EventController sharedEventController];
  
  // Get the proto class for this event type
  Class typeClass = [ec getClassForType:eventType];
  if (!typeClass) {
    return;
  }
  
  // Call handle<Proto Class> method in event controller
  SEL handleMethod = NSSelectorFromString([NSString stringWithFormat:@"handle%@:", [typeClass description]]);
  if ([ec respondsToSelector:handleMethod]) {
    [ec performSelector:handleMethod withObject:[typeClass parseFromData: data]];
  }
  
}

-(void) sendData:(NSData *)data withMessageType: (int) type{
  NSMutableData *messageWithHeader = [NSMutableData data];
  
  // Need to reverse bytes for size and type(to account for endianness??)
  uint8_t header[8];
  header[3] = type & 0xFF;
  header[2] = (type & 0xFF00) >> 8;
  header[1] = (type & 0xFF0000) >> 16;
  header[0] = (type & 0xFF000000) >> 24;
  
  int size = [data length];
  header[7] = size & 0xFF;
  header[6] = (size & 0xFF00) >> 8;
  header[5] = (size & 0xFF0000) >> 16;
  header[4] = (size & 0xFF000000) >> 24;
  
  [messageWithHeader appendBytes:header length:8];
  [messageWithHeader appendData:data];
  [_asyncSocket writeData:messageWithHeader withTimeout:-1 tag:0];
  
  uint8_t *x;
  x = (uint8_t *)[messageWithHeader bytes];
}

- (void) sendChatMessage:(NSString *)message recipient:(int)recipient {
  ChatRequestProto *c = [[[[[ChatRequestProto builder] 
                            setMessage:message] 
                           setSender:_sender] 
                          addRecipients:[[[MinimumUserProto builder] setUserId:recipient] build]]
                         build];
  [self sendData:[c data] withMessageType:EventProtocolRequestCChatEvent];
}

- (void) sendVaultMessage:(int)amount requestType: (VaultRequestProto_VaultRequestType) type {
  VaultRequestProto *vaultReq = [[[[[VaultRequestProto builder] 
                                    setAmount:amount] 
                                   setSender:_sender] 
                                  setRequestType:type] 
                                 build];
  [self sendData:[vaultReq data] withMessageType:EventProtocolRequestCVaultEvent];
}

- (void) sendTasksForCityMessage: (int) cityId {
  RetrieveTasksForCityRequestProto *retReq = [[[[RetrieveTasksForCityRequestProto builder]
                                                setCityId:cityId]
                                               setSender:_sender]
                                              build];
  [self sendData:[retReq data] withMessageType:EventProtocolRequestCRetrieveTasksForCityEvent];
}

- (void) sendBattleMessage:(int)defender {
  BattleRequestProto *battleReq = [[[[BattleRequestProto builder]
                                     setAttacker:_sender]
                                    setDefender:[[[MinimumUserProto builder] setUserId:defender] build]]
                                   build];
  [self sendData:[battleReq data] withMessageType:EventProtocolRequestCBattleEvent];
}

- (void) sendClericMessage {
  ClericHealRequestProto *clerReq = [[[ClericHealRequestProto builder] setSender:_sender] build];
  [self sendData:[clerReq data] withMessageType:EventProtocolRequestCClericHealEvent];
}

- (void) sendStartupMessage {
  StartupRequestProto *startReq = [[[[StartupRequestProto builder] 
                                     setUdid:[[UIDevice currentDevice] uniqueDeviceIdentifier]] 
                                    setVersionNum:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue]] build];
  
  [self sendData:[startReq data] withMessageType:EventProtocolRequestCStartupEvent];
}

- (void) sendTaskActionMessage:(int)taskId {
  TaskActionRequestProto *taskReq = [[[[TaskActionRequestProto builder]
                                       setTaskId:1]
                                      setSender:_sender]
                                     build];
  [self sendData:[taskReq data] withMessageType:EventProtocolRequestCTaskActionEvent];
}

- (void) sendInAppPurchaseMessage:(NSString *)receipt {
  InAppPurchaseRequestProto *iapReq = [[[[InAppPurchaseRequestProto builder]
                                         setReceipt:receipt]
                                        setSender:_sender]
                                       build];
  [self sendData:[iapReq data] withMessageType:EventProtocolRequestCInAppPurchaseEvent];
}

- (void) sendRetrieveCurrentMarketplacePostsMessageBeforePostId: (int)postId {
  RetrieveCurrentMarketplacePostsRequestProto_Builder *mktReq = [[RetrieveCurrentMarketplacePostsRequestProto builder] setSender:_sender];
  
  if (postId) {
    [mktReq setBeforeThisPostId:postId];
  }
  
  [self sendData:[[mktReq build] data] withMessageType:EventProtocolRequestCRetrieveCurrentMarketplacePostsEvent];
}

- (void) sendRetrieveCurrentMarketplacePostsMessageFromSenderBeforePostId: (int)postId {
  RetrieveCurrentMarketplacePostsRequestProto_Builder *mktReq = [[[RetrieveCurrentMarketplacePostsRequestProto builder] setSender:_sender] setFromSender:YES];
  
  if (postId) {
    [mktReq setBeforeThisPostId:postId];
  }
  
  [self sendData:[[mktReq build] data] withMessageType:EventProtocolRequestCRetrieveCurrentMarketplacePostsEvent];
}

- (void) sendCoinPostToMarketplaceMessage:(int)coinPost wood:(int)wood coins:(int)coins diamonds:(int)diamonds {
  PostToMarketplaceRequestProto *mktReq = [[[[[[[[PostToMarketplaceRequestProto builder]
                                                 setPostType:MarketplacePostTypeCoinPost]
                                                setPostedCoins:coinPost]
                                               setWoodCost:wood]
                                              setCoinCost:coins]
                                             setDiamondCost:diamonds]
                                            setSender:_sender]
                                           build];
  
  [self sendData:[mktReq data] withMessageType:EventProtocolRequestCPostToMarketplaceEvent];
}

- (void) sendWoodPostToMarketplaceMessage:(int)woodPost wood:(int)wood coins:(int)coins diamonds:(int)diamonds {
  PostToMarketplaceRequestProto *mktReq = [[[[[[[[PostToMarketplaceRequestProto builder]
                                                 setPostType:MarketplacePostTypeWoodPost]
                                                setPostedWood:woodPost]
                                               setWoodCost:wood]
                                              setCoinCost:coins]
                                             setDiamondCost:diamonds]
                                            setSender:_sender]
                                           build];
  
  [self sendData:[mktReq data] withMessageType:EventProtocolRequestCPostToMarketplaceEvent];
}

- (void) sendDiamondPostToMarketplaceMessage:(int)dmdPost wood:(int)wood coins:(int)coins diamonds:(int)diamonds {
  PostToMarketplaceRequestProto *mktReq = [[[[[[[[PostToMarketplaceRequestProto builder]
                                                 setPostType:MarketplacePostTypeDiamondPost]
                                                setPostedDiamonds:dmdPost]
                                               setWoodCost:wood]
                                              setCoinCost:coins]
                                             setDiamondCost:diamonds]
                                            setSender:_sender]
                                           build];
  
  [self sendData:[mktReq data] withMessageType:EventProtocolRequestCPostToMarketplaceEvent];
}

- (void) sendEquipPostToMarketplaceMessage:(int)equipId wood:(int)wood coins:(int)coins diamonds:(int)diamonds {
  PostToMarketplaceRequestProto *mktReq = [[[[[[[[PostToMarketplaceRequestProto builder]
                                                 setPostType:MarketplacePostTypeEquipPost]
                                                setPostedEquipId:equipId]
                                               setWoodCost:wood]
                                              setCoinCost:coins]
                                             setDiamondCost:diamonds]
                                            setSender:_sender]
                                           build];
  
  [self sendData:[mktReq data] withMessageType:EventProtocolRequestCPostToMarketplaceEvent];
}

- (void) sendRetractMarketplacePostMessage: (int)postId {
  RetractMarketplacePostRequestProto *mktReq = [[[[RetractMarketplacePostRequestProto builder]
                                                  setSender:_sender]
                                                 setMarketplacePostId:postId]
                                                build];
  
  [self sendData:[mktReq data] withMessageType:EventProtocolRequestCRetractPostFromMarketplaceEvent];
}

- (void) sendPurchaseFromMarketplaceMessage: (int)postId poster:(int)posterId {
  PurchaseFromMarketplaceRequestProto *mktReq = [[[[[PurchaseFromMarketplaceRequestProto builder]
                                                    setSender:_sender]
                                                   setMarketplacePostId:postId]
                                                  setPosterId:posterId]
                                                 build];
  
  [self sendData:[mktReq data] withMessageType:EventProtocolRequestCPurchaseFromMarketplaceEvent];
}

- (void) closeDownConnection {
  if (_asyncSocket) {
    [_asyncSocket disconnect];
    [_asyncSocket release];
  }
}

- (void) dealloc {
  [_sender release];
  [self closeDownConnection];
  [super dealloc];
}

@end