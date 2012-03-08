//
//  SocketCommunication.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/21/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

#import "SocketCommunication.h"
#import "SynthesizeSingleton.h"
#import "IncomingEventController.h"
#import "UIDevice+IdentifierAddition.h"
#import "GameState.h"
#import "OutgoingEventController.h"

#define HOST_NAME @"10.1.10.16"
#define HOST_PORT 8888

// Tags for keeping state
#define READING_HEADER_TAG -1
#define HEADER_SIZE 12

#define RECONNECT_TIMEOUT 100

@implementation SocketCommunication

SYNTHESIZE_SINGLETON_FOR_CLASS(SocketCommunication);

@synthesize currentTagNum = _currentTagNum;

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

- (void) rebuildSender {
  [_sender release];
  GameState *gs = [GameState sharedGameState];
  _sender = [[[[[[MinimumUserProto builder] 
                 setUserId:gs.userId] 
                setName:gs.name] 
               setUserType:gs.type] 
              build] retain];
}

- (void) initNetworkCommunication {
  _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
  [self connectToSocket];
  [self rebuildSender];
  _currentTagNum = 1;
  
  [[OutgoingEventController sharedOutgoingEventController] startup];
}

- (void) readHeader {
  [_asyncSocket readDataToLength:HEADER_SIZE withTimeout:-1 tag:READING_HEADER_TAG];
}

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
  NSLog(@"Connected to host");
  
  [self readHeader];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  if (tag == READING_HEADER_TAG) {
    uint8_t *header = (uint8_t *)[data bytes];
    // Get the next 4 bytes for the payload size
    _nextMsgType = *(int *)(header);
    [_asyncSocket readDataToLength:*(int *)(header+8) withTimeout:-1 tag:*(int *)(header+4)];
  } else {
    [self messageReceived:data withType:_nextMsgType tag:tag];
    _nextMsgType = -1;
    [self readHeader];
  }
}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	NSLog(@"socketDidDisconnect:withError: \"%@\"", err);
  NSLog(@"Attempting to reconnect..");
  [[NSRunLoop mainRunLoop] addTimer:[NSTimer timerWithTimeInterval:RECONNECT_TIMEOUT target:self selector:@selector(connectToSocket) userInfo:nil repeats:NO] forMode:NSRunLoopCommonModes];
}

-(void) messageReceived:(NSData *)data withType:(EventProtocolResponse) eventType tag:(int)tag {
  IncomingEventController *ec = [IncomingEventController sharedIncomingEventController];
  [ec receivedResponseForMessage:tag];
  
  // Get the proto class for this event type
  Class typeClass = [ec getClassForType:eventType];
  if (!typeClass) {
    NSLog(@"Unable to find controller for event type: %d", eventType);
    return;
  }
  
  // Call handle<Proto Class> method in event controller
  NSString *selectorStr = [NSString stringWithFormat:@"handle%@:", [typeClass description]];
  SEL handleMethod = NSSelectorFromString(selectorStr);
  if ([ec respondsToSelector:handleMethod]) {
    [ec performSelectorOnMainThread:handleMethod withObject:[typeClass parseFromData: data] waitUntilDone:NO];
  } else {
    NSLog(@"Unable to find %@ in IncomingEventController", selectorStr);
  }
}

-(void) sendData:(NSData *)data withMessageType: (int) type {
  NSMutableData *messageWithHeader = [NSMutableData data];
  
  // Need to reverse bytes for size and type(to account for endianness??)
  uint8_t header[HEADER_SIZE];
  header[3] = type & 0xFF;
  header[2] = (type & 0xFF00) >> 8;
  header[1] = (type & 0xFF0000) >> 16;
  header[0] = (type & 0xFF000000) >> 24;
  
  header[7] = _currentTagNum & 0xFF;
  header[6] = (_currentTagNum & 0xFF00) >> 8;
  header[5] = (_currentTagNum & 0xFF0000) >> 16;
  header[4] = (_currentTagNum & 0xFF000000) >> 24;
  
  int size = [data length];
  header[11] = size & 0xFF;
  header[10] = (size & 0xFF00) >> 8;
  header[9] = (size & 0xFF0000) >> 16;
  header[8] = (size & 0xFF000000) >> 24;
  
  [messageWithHeader appendBytes:header length:sizeof(header)];
  [messageWithHeader appendData:data];
  [_asyncSocket writeData:messageWithHeader withTimeout:-1 tag:0];
  
  _currentTagNum++;
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

- (void) sendBattleMessage:(int)defender {
  BattleRequestProto *battleReq = [[[[BattleRequestProto builder]
                                     setAttacker:_sender]
                                    setDefender:[[[MinimumUserProto builder] setUserId:defender] build]]
                                   build];
  [self sendData:[battleReq data] withMessageType:EventProtocolRequestCBattleEvent];
}

- (void) sendArmoryMessage:(ArmoryRequestProto_ArmoryRequestType)requestType quantity:(int)quantity equipId:(int)equipId {
  ArmoryRequestProto *arpReq = [[[[[[ArmoryRequestProto builder]
                                    setSender:_sender]
                                   setRequestType:requestType]
                                  setQuantity:quantity]
                                 setEquipId:equipId]
                                build];
  
  [self sendData:[arpReq data] withMessageType:EventProtocolRequestCArmoryEvent];
}

- (void) sendStartupMessage:(uint64_t)clientTime {
  NSString *udid = @"42d1cadaa64dbf3c3e8133e652a2df06";//[[UIDevice currentDevice] uniqueDeviceIdentifier];
  StartupRequestProto *startReq = [[[[StartupRequestProto builder] 
                                     setUdid:udid]
                                    setVersionNum:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue]]
                                   build];
  
  NSLog(@"Sent over udid: %@", udid);
  
  [self sendData:[startReq data] withMessageType:EventProtocolRequestCStartupEvent];
}

- (void) sendTaskActionMessage:(int)taskId curTime:(uint64_t)clientTime {
  TaskActionRequestProto *taskReq = [[[[[TaskActionRequestProto builder]
                                        setTaskId:taskId]
                                       setSender:_sender]
                                      setCurTime:clientTime]
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

- (void) sendRetrieveCurrentMarketplacePostsMessageBeforePostId: (int)postId fromSender:(BOOL)fromSender{
  RetrieveCurrentMarketplacePostsRequestProto_Builder *mktReq = [[[RetrieveCurrentMarketplacePostsRequestProto builder] setSender:_sender] setFromSender:fromSender];
  
  if (postId) {
    [mktReq setBeforeThisPostId:postId];
  }
  
  [self sendData:[[mktReq build] data] withMessageType:EventProtocolRequestCRetrieveCurrentMarketplacePostsEvent];
}

- (void) sendEquipPostToMarketplaceMessage:(int)equipId coins:(int)coins diamonds:(int)diamonds {
  PostToMarketplaceRequestProto *mktReq = [[[[[[PostToMarketplaceRequestProto builder]
                                               setPostedEquipId:equipId]
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

- (void) sendRedeemMarketplaceEarningsMessage {
  RedeemMarketplaceEarningsRequestProto *redReq = [[[RedeemMarketplaceEarningsRequestProto builder]
                                                    setSender:_sender]
                                                   build];
  
  [self sendData:[redReq data] withMessageType:EventProtocolRequestCRedeemMarketplaceEarningsEvent];
}

- (void) sendUseSkillPointMessage:(UseSkillPointRequestProto_BoostType) boostType {
  UseSkillPointRequestProto *skillReq = [[[[UseSkillPointRequestProto builder]
                                           setSender:_sender]
                                          setBoostType:boostType]
                                         build];
  
  [self sendData:[skillReq data] withMessageType:EventProtocolRequestCUseSkillPointEvent];
}

- (void) sendGenerateAttackListMessage:(int)numEnemies latUpperBound:(CGFloat)latUpperBound latLowerBound:(CGFloat)latLowerBound lonUpperBound:(CGFloat)lonUpperBound lonLowerBound:(CGFloat)lonLowerBound {
  GenerateAttackListRequestProto *attReq = [[[[[[[[GenerateAttackListRequestProto builder]
                                                  setSender:_sender]
                                                 setNumEnemies:numEnemies]
                                                setLatLowerBound:latLowerBound]
                                               setLatUpperBound:latUpperBound]
                                              setLongLowerBound:lonLowerBound]
                                             setLongUpperBound:lonUpperBound]
                                            build];
  
  [self sendData:[attReq data] withMessageType:EventProtocolRequestCGenerateAttackListEvent];
}

- (void) sendRefillStatWithDiamondsMessage:(RefillStatWithDiamondsRequestProto_StatType) statType {
  RefillStatWithDiamondsRequestProto *refReq = [[[[RefillStatWithDiamondsRequestProto builder]
                                                  setSender:_sender]
                                                 setStatType:statType]
                                                build];
  
  [self sendData:[refReq data] withMessageType:EventProtocolRequestCRefillStatWithDiamondsEvent];
}

- (void) sendPurchaseNormStructureMessage:(int)structId x:(int)x y:(int)y time:(uint64_t)time{
  PurchaseNormStructureRequestProto *purReq = [[[[[[PurchaseNormStructureRequestProto builder]
                                                   setSender:_sender]
                                                  setStructId:structId]
                                                 setStructCoordinates:[[[[CoordinateProto builder] setX:x] setY:y] build]]
                                                setTimeOfPurchase:time]
                                               build];
  
  [self sendData:[purReq data] withMessageType:EventProtocolRequestCPurchaseNormStructureEvent];
}

- (void) sendMoveNormStructureMessage:(int)userStructId x:(int)x y:(int)y {
  MoveOrRotateNormStructureRequestProto *req = 
  [[[[[[MoveOrRotateNormStructureRequestProto builder]
       setSender:_sender]
      setUserStructId:userStructId]
     setType:MoveOrRotateNormStructureRequestProto_MoveOrRotateNormStructTypeMove]
    setCurStructCoordinates:[[[[CoordinateProto builder] setX:x] setY:y] build]]
   build];
  
  [self sendData:[req data] withMessageType:EventProtocolRequestCMoveOrRotateNormStructureEvent];
}

- (void) sendRotateNormStructureMessage:(int)userStructId orientation:(StructOrientation)orientation {
  MoveOrRotateNormStructureRequestProto *req = 
  [[[[[[MoveOrRotateNormStructureRequestProto builder]
       setSender:_sender]
      setUserStructId:userStructId]
     setType:MoveOrRotateNormStructureRequestProto_MoveOrRotateNormStructTypeRotate]
    setNewOrientation:orientation]
   build];
  
  [self sendData:[req data] withMessageType:EventProtocolRequestCMoveOrRotateNormStructureEvent];
}

- (void) sendUpgradeNormStructureMessage:(int)userStructId time:(uint64_t)curTime {
  UpgradeNormStructureRequestProto *upReq = [[[[[UpgradeNormStructureRequestProto builder]
                                                setSender:_sender]
                                               setUserStructId:userStructId]
                                              setTimeOfUpgrade:curTime]
                                             build];
  
  [self sendData:[upReq data] withMessageType:EventProtocolRequestCUpgradeNormStructureEvent];
}

- (void) sendNormStructBuildsCompleteMessage:(NSArray *)userStructIds time:(uint64_t)curTime {
  NormStructWaitCompleteRequestProto *buildReq = [[[[[NormStructWaitCompleteRequestProto builder]
                                                     setSender:_sender]
                                                    addAllUserStructId:userStructIds]
                                                   setCurTime:curTime]
                                                  build];
  
  [self sendData:[buildReq data] withMessageType:EventProtocolRequestCNormStructWaitCompleteEvent];
}

- (void) sendFinishNormStructBuildWithDiamondsMessage:(int)userStructId time:(uint64_t)milliseconds type:(FinishNormStructWaittimeWithDiamondsRequestProto_NormStructWaitTimeType) type {
  FinishNormStructWaittimeWithDiamondsRequestProto *finReq = 
  [[[[[[FinishNormStructWaittimeWithDiamondsRequestProto builder]
       setSender:_sender]
      setUserStructId:userStructId]
     setTimeOfPurchase:milliseconds]
    setWaitTimeType:type]
   build];
  
  [self sendData:[finReq data] withMessageType:EventProtocolRequestCFinishNormStructWaittimeWithDiamondsEvent];
}

- (void) sendRetrieveCurrencyFromNormStructureMessage:(int)userStructId time:(uint64_t)milliseconds {
  RetrieveCurrencyFromNormStructureRequestProto *retReq = [[[[[RetrieveCurrencyFromNormStructureRequestProto builder]
                                                              setSender:_sender]
                                                             setUserStructId:userStructId]
                                                            setTimeOfRetrieval:milliseconds]
                                                           build];
  
  [self sendData:[retReq data] withMessageType:EventProtocolRequestCRetrieveCurrencyFromNormStructureEvent];
}

- (void) sendSellNormStructureMessage:(int)userStructId {
  SellNormStructureRequestProto *sellReq = [[[[SellNormStructureRequestProto builder]
                                              setSender:_sender]
                                             setUserStructId:userStructId]
                                            build];
  
  [self sendData:[sellReq data] withMessageType:EventProtocolRequestCSellNormStructureEvent];
}

- (void) sendLoadPlayerCityMessage:(MinimumUserProto *)mup {
  LoadPlayerCityRequestProto *loadReq = [[[[LoadPlayerCityRequestProto builder]
                                           setSender:_sender]
                                          setCityOwner:mup]
                                         build];
  
  [self sendData:[loadReq data] withMessageType:EventProtocolRequestCLoadPlayerCityEvent];
}

- (void) sendRetrieveStaticDataMessageWithStructIds:(NSArray *)structIds taskIds:(NSArray *)taskIds questIds:(NSArray *)questIds cityIds:(NSArray *)cityIds equipIds:(NSArray *)equipIds buildStructJobIds:(NSArray *)buildStructJobIds defeatTypeJobIds:(NSArray *)defeatTypeJobIds possessEquipJobIds:(NSArray *)possessEquipJobIds upgradeStructJobIds:(NSArray *)upgradeStructJobIds {
  RetrieveStaticDataRequestProto_Builder *blder = [RetrieveStaticDataRequestProto builder];
  
  if (structIds) {
    [blder addAllStructIds:structIds];
  }
  if (taskIds) {
    [blder addAllTaskIds:taskIds];
  }
  if (questIds) {
    [blder addAllQuestIds:questIds];
  }
  if (cityIds) {
    [blder addAllCityIds:cityIds];
  }
  if (equipIds) {
    [blder addAllEquipIds:equipIds];
  }
  if (buildStructJobIds) {
    [blder addAllBuildStructJobIds:buildStructJobIds];
  }
  if (defeatTypeJobIds) {
    [blder addAllDefeatTypeJobIds:defeatTypeJobIds];
  }
  if (possessEquipJobIds) {
    [blder addAllPossessEquipJobIds:possessEquipJobIds];
  }
  if (upgradeStructJobIds) {
    [blder addAllUpgradeStructJobIds:upgradeStructJobIds];
  }
  
  [blder setSender:_sender];
  RetrieveStaticDataRequestProto *retReq = [blder build];
  [self sendData:[retReq data] withMessageType:EventProtocolRequestCRetrieveStaticDataEvent];
}

- (void) sendRetrieveStaticDataFromShopMessage:(RetrieveStaticDataForShopRequestProto_RetrieveForShopType) type {
  RetrieveStaticDataForShopRequestProto *retReq = [[[[RetrieveStaticDataForShopRequestProto builder]
                                                     setSender:_sender]
                                                    setType:type]
                                                   build];
  
  [self sendData:[retReq data] withMessageType:EventProtocolRequestCRetrieveStaticDataForShopEvent];
}

- (void) sendEquipEquipmentMessage:(int) equipId {
  EquipEquipmentRequestProto *req = [[[[EquipEquipmentRequestProto builder]
                                       setSender:_sender]
                                      setEquipId:equipId]
                                     build];
  
  [self sendData:[req data] withMessageType:EventProtocolRequestCEquipEquipmentEvent];
}

- (void) sendChangeUserLocationMessageWithLatitude:(CGFloat)lat longitude:(CGFloat)lon {
  ChangeUserLocationRequestProto *req = [[[[ChangeUserLocationRequestProto builder]
                                           setSender:_sender]
                                          setUserLocation:
                                          [[[[LocationProto builder]
                                             setLatitude:lat]
                                            setLongitude:lon]
                                           build]]
                                         build];
  
  [self sendData:[req data] withMessageType:EventProtocolRequestCChangeUserLocationEvent];
}

- (void) sendLoadNeutralCityMessage:(int)cityId {
  LoadNeutralCityRequestProto *req = [[[[LoadNeutralCityRequestProto builder]
                                        setSender:_sender]
                                       setCityId:cityId]
                                      build];
  
  [self sendData:[req data] withMessageType:EventProtocolRequestCLoadNeutralCityEvent];
}

- (void) sendLevelUpMessage {
  LevelUpRequestProto *req = [[[LevelUpRequestProto builder]
                               setSender:_sender]
                              build];
  
  [self sendData:[req data] withMessageType:EventProtocolRequestCLevelUpEvent];
}

- (void) sendRefillStatWaitTimeComplete:(RefillStatWaitCompleteRequestProto_RefillStatWaitCompleteType)type curTime:(uint64_t)curTime {
  RefillStatWaitCompleteRequestProto *req = [[[[[RefillStatWaitCompleteRequestProto builder]
                                                setSender:_sender]
                                               setType:type]
                                              setCurTime:curTime]
                                             build];
  
  [self sendData:[req data] withMessageType:EventProtocolRequestCRefillStatWaitCompleteEvent];
}

- (void) sendQuestAcceptMessage:(int)questId {
  QuestAcceptRequestProto *req = [[[[QuestAcceptRequestProto builder]
                                    setSender:_sender]
                                   setQuestId:questId]
                                  build];
  
  [self sendData:[req data] withMessageType:EventProtocolRequestCQuestAcceptEvent];
}

- (void) sendQuestRedeemMessage:(int)questId {
  QuestRedeemRequestProto *req = [[[[QuestRedeemRequestProto builder]
                                    setSender:_sender]
                                   setQuestId:questId]
                                  build];
  
  [self sendData:[req data] withMessageType:EventProtocolRequestCQuestRedeemEvent];
}

- (void) sendQuestLogDetailsMessage {
  QuestLogDetailsRequestProto *req = [[[QuestLogDetailsRequestProto builder]
                                       setSender:_sender]
                                      build];
  
  [self sendData:[req data] withMessageType:EventProtocolRequestCQuestLogDetailsEvent];
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
