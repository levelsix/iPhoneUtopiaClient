//
//  SocketCommunication.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/21/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "SocketCommunication.h"
#import "LNSynthesizeSingleton.h"
#import "IncomingEventController.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "Globals.h"
//#import "Apsalar.h"
#import "ClientProperties.h"
#import "FullEvent.h"
#import "GameViewController.h"
#import "GenericPopupController.h"
#import "GameState.h"
#import <AdSupport/AdSupport.h>

// Tags for keeping state
#define READING_HEADER_TAG -1
#define HEADER_SIZE 12

#define RECONNECT_TIMEOUT 0.5f
#define NUM_SILENT_RECONNECTS 1

@implementation SocketCommunication

SYNTHESIZE_SINGLETON_FOR_CLASS(SocketCommunication);

static NSString *udid = nil;

- (NSString *)getIPAddress
{
  NSURL *url = [[[NSURL alloc] initWithString:@"http://checkip.dyndns.com/"] autorelease];
  NSString *contents = [NSString stringWithContentsOfURL:url encoding:NSStringEncodingConversionAllowLossy error:nil];
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\d+\\.\\d+\\.\\d+\\.\\d+" options:NSRegularExpressionCaseInsensitive error:nil];
  NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:contents options:0 range:NSMakeRange(0, [contents length])];
  if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
    NSString *substringForFirstMatch = [contents substringWithRange:rangeOfFirstMatch];
    LNLog(@"IP Address: %@", substringForFirstMatch);
    return substringForFirstMatch;
  }
  return nil;
}

- (NSString *)getMacAddress
{
  int                 mgmtInfoBase[6];
  char                *msgBuffer = NULL;
  size_t              length;
  unsigned char       macAddress[6];
  struct if_msghdr    *interfaceMsgStruct;
  struct sockaddr_dl  *socketStruct;
  NSString            *errorFlag = NULL;
  
  // Setup the management Information Base (mib)
  mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
  mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
  mgmtInfoBase[2] = 0;
  mgmtInfoBase[3] = AF_LINK;        // Request link layer information
  mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
  
  // With all configured interfaces requested, get handle index
  if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
    errorFlag = @"if_nametoindex failure";
  else
  {
    // Get the size of the data available (store in len)
    if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
      errorFlag = @"sysctl mgmtInfoBase failure";
    else
    {
      // Alloc memory based on above call
      if ((msgBuffer = malloc(length)) == NULL)
        errorFlag = @"buffer allocation failure";
      else
      {
        // Get system information, store in buffer
        if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
          errorFlag = @"sysctl msgBuffer failure";
      }
    }
  }
  
  // Befor going any further...
  if (errorFlag != NULL)
  {
    free(msgBuffer);
    NSLog(@"Error: %@", errorFlag);
    return errorFlag;
  }
  
  // Map msgbuffer to interface message structure
  interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
  
  // Map to link-level socket structure
  socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
  
  // Copy link layer address data in socket structure to an array
  memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
  
  // Read from char array into a string object, into traditional Mac address format
  NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                macAddress[0], macAddress[1], macAddress[2],
                                macAddress[3], macAddress[4], macAddress[5]];
  
  // Release the buffer memory
  free(msgBuffer);
  
  return macAddressString;
}

- (NSString *) getIFA {
  ASIdentifierManager *as = [ASIdentifierManager sharedManager];
  NSString *advertiserId = as.advertisingIdentifier.UUIDString;
  return advertiserId;
}

- (id) init {
  if ((self = [super init])) {
#ifdef FORCE_TUTORIAL
    udid = [[NSString stringWithFormat:@"%d%d%d", arc4random(), arc4random(), arc4random()] retain];
#else
    udid = [UDID retain];
#endif
  }
  return self;
}

- (void) rebuildSender {
  int oldClanId = _sender.clan.clanId;
  [_sender release];
  GameState *gs = [GameState sharedGameState];
  _sender = [gs.minUser retain];
  
  // if clan changes, reload the queue
  if (oldClanId != _sender.clan.clanId) {
    [self reloadClanMessageQueue];
  }
}

- (void) initNetworkCommunication {
  _connectionThread = [[AMQPConnectionThread alloc] init];
  [_connectionThread start];
  _connectionThread.delegate = self;
  [_connectionThread connect:udid];
  
  [self rebuildSender];
  _currentTagNum = 1;
  _shouldReconnect = YES;
  _numDisconnects = 0;
  
  self.structRetrievals = [NSMutableArray array];
}

- (void) reloadClanMessageQueue {
  [_connectionThread reloadClanMessageQueue];
}

- (void) connectedToHost {
  LNLog(@"Connected to host");
  
  GameState *gs = [GameState sharedGameState];
  if (!gs.connected) {
    [[OutgoingEventController sharedOutgoingEventController] startup];
    [[GameViewController sharedGameViewController] connectedToHost];
    
    _flushTimer = [[NSTimer timerWithTimeInterval:10.f target:self selector:@selector(flush) userInfo:nil repeats:YES] retain];
    [[NSRunLoop mainRunLoop] addTimer:_flushTimer forMode:NSRunLoopCommonModes];
  } else if (!gs.isTutorial) {
    [[OutgoingEventController sharedOutgoingEventController] reconnect];
  }
  
  _numDisconnects = 0;
}

- (void) initUserIdMessageQueue {
  [_connectionThread startUserIdQueue];
  
  LNLog(@"Created user id queue");
}

- (void) tryReconnect {
  [_connectionThread connect:udid];
}

- (void) unableToConnectToHost:(NSString *)error
{
	ContextLogError(LN_CONTEXT_COMMUNICATION, @"Unable to connect: %@", error);
  
  if (_shouldReconnect) {
    _numDisconnects++;
    if (_numDisconnects > NUM_SILENT_RECONNECTS) {
      ContextLogWarn(LN_CONTEXT_COMMUNICATION, @"Asking to reconnect..");
      [GenericPopupController displayNotificationViewWithText:@"Sorry, we are unable to connect to the server. Please try again." title:@"Disconnected!" okayButton:@"Reconnect" target:self selector:@selector(tryReconnect)];
      _numDisconnects = 0;
    } else {
      ContextLogWarn(LN_CONTEXT_COMMUNICATION, @"Silently reconnecting..");
      [self tryReconnect];
    }
  }
}

- (int) sendData:(PBGeneratedMessage *)msg withMessageType:(int)type flush:(BOOL)flush {
  if (flush) {
    [self flush];
  }
  
  NSMutableData *messageWithHeader = [NSMutableData data];
  NSData *data = [msg data];
  
  if (_sender.userId == 0) {
    if (type != EventProtocolRequestCStartupEvent&& type != EventProtocolRequestCUserCreateEvent) {
      ContextLogError(LN_CONTEXT_COMMUNICATION, @"User id is 0!!!");
      ContextLogError(LN_CONTEXT_COMMUNICATION, @"Did not send event.");
      return 0;
    }
  }
  
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
  
  [_connectionThread sendData:messageWithHeader];
  
  int tag = _currentTagNum;
  _currentTagNum++;
  return tag;
}

- (int) sendData:(PBGeneratedMessage *)msg withMessageType:(int)type {
  return [self sendData:msg withMessageType:type flush:YES];
}

- (void) amqpConsumerThreadReceivedNewMessage:(AMQPMessage *)theMessage {
  NSData *data = theMessage.body;
  uint8_t *header = (uint8_t *)[data bytes];
  // Get the next 4 bytes for the payload size
  int nextMsgType = *(int *)(header);
  int tag = *(int *)(header+4);
  //  int size = *(int *)(header+8); // No longer used
  NSData *payload = [data subdataWithRange:NSMakeRange(HEADER_SIZE, data.length-HEADER_SIZE)];
  
  [self messageReceived:payload withType:nextMsgType tag:tag];
}

-(void) messageReceived:(NSData *)data withType:(EventProtocolResponse)eventType tag:(int)tag {
  IncomingEventController *iec = [IncomingEventController sharedIncomingEventController];
  
  // Get the proto class for this event type
  Class typeClass = [iec getClassForType:eventType];
  if (!typeClass) {
    ContextLogError(LN_CONTEXT_COMMUNICATION, @"Unable to find controller for event type: %d", eventType);
    return;
  }
  
  // Call handle<Proto Class> method in event controller
  NSString *selectorStr = [NSString stringWithFormat:@"handle%@:", [typeClass description]];
  SEL handleMethod = NSSelectorFromString(selectorStr);
  if ([iec respondsToSelector:handleMethod]) {
    FullEvent *fe = [FullEvent createWithEvent:(PBGeneratedMessage *)[typeClass parseFromData:data] tag:tag];
    [iec performSelectorOnMainThread:handleMethod withObject:fe waitUntilDone:NO];
  } else {
    ContextLogError(LN_CONTEXT_COMMUNICATION, @"Unable to find %@ in IncomingEventController", selectorStr);
  }
}

- (int) sendUserCreateMessageWithName:(NSString *)name type:(UserType)type lat:(CGFloat)lat lon:(CGFloat)lon referralCode:(NSString *)refCode deviceToken:(NSString *)deviceToken attack:(int)attack defense:(int)defense energy:(int)energy stamina:(int)stamina structX:(int)structX structY:(int)structY usedDiamonds:(BOOL)usedDiamondsToBuild {
  UserCreateRequestProto_Builder *bldr = [UserCreateRequestProto builder];
  
  bldr.udid = udid;
  bldr.name = name;
  bldr.type = type;
  
  if (lat != 0 || lon != 0) {
    bldr.userLocation = [[[[LocationProto builder] setLatitude:lat] setLongitude:lon] build];
  }
  
  if (refCode) {
    bldr.referrerCode = refCode;
  }
  
  if (deviceToken) {
    bldr.deviceToken = deviceToken;
  }
  
  bldr.attack = attack;
  bldr.defense = defense;
  bldr.energy = energy;
  bldr.stamina = stamina;
  bldr.structCoords = [[[[CoordinateProto builder] setX:structX] setY:structY] build];
  bldr.usedDiamondsToBuilt = usedDiamondsToBuild;
  
  UserCreateRequestProto *req = [bldr build];
  return [self sendData:req withMessageType:EventProtocolRequestCUserCreateEvent];
}

- (int) sendStartupMessage:(uint64_t)clientTime {
  NSString *advertiserId = [self getIFA];
  NSString *mac = [self getMacAddress];
  StartupRequestProto_Builder *bldr = [[[[StartupRequestProto builder]
                                          setUdid:udid]
                                         setVersionNum:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue]]
                                       setMacAddress:mac];
  
  if (advertiserId) {
    [bldr setAdvertiserId:advertiserId];
  }
  
  StartupRequestProto *req = [bldr build];
  
  LNLog(@"Sent over udid: %@", udid);
  LNLog(@"Mac Address: %@", mac);
  LNLog(@"Advertiser ID: %@", advertiserId);
  return [self sendData:req withMessageType:EventProtocolRequestCStartupEvent];
}

- (int) sendReconnectMessage {
  ReconnectRequestProto *req = [[[ReconnectRequestProto builder]
                                 setSender:_sender]
                                build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCReconnectEvent];
}

- (int) sendLogoutMessage {
  LogoutRequestProto *req = [[[LogoutRequestProto builder]
                              setSender:_sender]
                             build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCLogoutEvent];
}

- (int) sendChatMessage:(NSString *)message recipient:(int)recipient {
  ChatRequestProto *req = [[[[[ChatRequestProto builder]
                              setMessage:message]
                             setSender:_sender]
                            addRecipients:[[[MinimumUserProto builder] setUserId:recipient] build]]
                           build];
  return [self sendData:req withMessageType:EventProtocolRequestCChatEvent];
}

- (int) sendVaultMessage:(int)amount requestType: (VaultRequestProto_VaultRequestType) type {
  VaultRequestProto *req = [[[[[VaultRequestProto builder]
                               setAmount:amount]
                              setSender:_sender]
                             setRequestType:type]
                            build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCVaultEvent];
}

- (int) sendBattleMessage:(MinimumUserProto *)defender result:(BattleResult)result curTime:(uint64_t)curTime city:(int)city equips:(NSArray *)equips isTutorialBattle:(BOOL)isTutorialBattle {
  BattleRequestProto_Builder *builder = [[[[[[[BattleRequestProto builder]
                                             setAttacker:_sender]
                                            setDefender:defender]
                                           setBattleResult:result]
                                           setIsTutorialBattle:isTutorialBattle]
                                          setClientTime:curTime]
                                         addAllDefenderUserEquips:equips];
  if (city != -1) {
    [builder setNeutralCityId:city];
  }
  
  BattleRequestProto *req = [builder build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCBattleEvent];
}

- (int) sendArmoryMessage:(ArmoryRequestProto_ArmoryRequestType)requestType quantity:(int)quantity equipId:(int)equipId {
  ArmoryRequestProto *req = [[[[[[ArmoryRequestProto builder]
                                 setSender:_sender]
                                setRequestType:requestType]
                               setQuantity:quantity]
                              setEquipId:equipId]
                             build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCArmoryEvent];
}

- (int) sendTaskActionMessage:(int)taskId curTime:(uint64_t)clientTime {
  TaskActionRequestProto *req = [[[[[TaskActionRequestProto builder]
                                    setTaskId:taskId]
                                   setSender:_sender]
                                  setCurTime:clientTime]
                                 build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCTaskActionEvent];
}

- (int) sendInAppPurchaseMessage:(NSString *)receipt product:(SKProduct *)product {
  InAppPurchaseRequestProto *req = [[[[[[[[InAppPurchaseRequestProto builder]
                                          setReceipt:receipt]
                                         setLocalcents:[NSString stringWithFormat:@"%d", (int)(product.price.doubleValue*100.)]]
                                        setLocalcurrency:[product.priceLocale objectForKey:NSLocaleCurrencyCode]]
                                       setLocale:[product.priceLocale objectForKey:NSLocaleCountryCode]]
                                      setSender:_sender]
                                     setIpaddr:[self getIPAddress]]
                                    build];
  return [self sendData:req withMessageType:EventProtocolRequestCInAppPurchaseEvent];
}

- (int) sendRetrieveCurrentMarketplacePostsMessageWithCurNumEntries:(int)curNumEntries filter:(RetrieveCurrentMarketplacePostsRequestProto_RetrieveCurrentMarketplacePostsFilter)filter commonEquips:(BOOL)commonEquips uncommonEquips:(BOOL)uncommonEquips rareEquips:(BOOL)rareEquips superRareEquips:(BOOL)superRareEquips epicEquips:(BOOL)epicEquips legendaryEquips:(BOOL)legendaryEquips myClassOnly:(BOOL)myClassOnly minEquipLevel:(int)minEquipLevel maxEquipLevel:(int)maxEquipLevel minForgeLevel:(int)minForgeLevel maxForgeLevel:(int)maxForgeLevel sortOrder:(RetrieveCurrentMarketplacePostsRequestProto_RetrieveCurrentMarketplacePostsSortingOrder)sortOrder specificEquipId:(int)specificEquipId {
  RetrieveCurrentMarketplacePostsRequestProto_Builder *bldr = [[RetrieveCurrentMarketplacePostsRequestProto builder] setSender:_sender];
  
  bldr.currentNumOfEntries = curNumEntries;
  bldr.filter = filter;
  bldr.commonEquips = commonEquips;
  bldr.uncommonEquips = uncommonEquips;
  bldr.rareEquips = rareEquips;
  bldr.superRareEquips = superRareEquips;
  bldr.epicEquips = epicEquips;
  bldr.legendaryEquips = legendaryEquips;
  bldr.myClassOnly = myClassOnly;
  bldr.minEquipLevel = minEquipLevel;
  bldr.maxEquipLevel = maxEquipLevel;
  bldr.minForgeLevel = minForgeLevel;
  bldr.maxForgeLevel = maxForgeLevel;
  bldr.sortOrder = sortOrder;
  if (specificEquipId > 0) bldr.specificEquipId = specificEquipId;
  
  RetrieveCurrentMarketplacePostsRequestProto *req = bldr.build;
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveCurrentMarketplacePostsEvent];
}

- (int) sendRetrieveCurrentMarketplacePostsMessageFromSenderWithCurNumEntries:(int)curNumEntries {
  RetrieveCurrentMarketplacePostsRequestProto_Builder *bldr = [[RetrieveCurrentMarketplacePostsRequestProto builder] setSender:_sender];
  
  bldr.fromSender = YES;
  bldr.currentNumOfEntries = curNumEntries;
  
  RetrieveCurrentMarketplacePostsRequestProto *req = bldr.build;
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveCurrentMarketplacePostsEvent];
}

- (int) sendEquipPostToMarketplaceMessage:(int)equipId coins:(int)coins diamonds:(int)diamonds {
  PostToMarketplaceRequestProto *req = [[[[[[PostToMarketplaceRequestProto builder]
                                            setUserEquipId:equipId]
                                           setCoinCost:coins]
                                          setDiamondCost:diamonds]
                                         setSender:_sender]
                                        build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPostToMarketplaceEvent];
}

- (int) sendRetractMarketplacePostMessage:(int)postId curTime:(uint64_t)curTime {
  RetractMarketplacePostRequestProto *req = [[[[[RetractMarketplacePostRequestProto builder]
                                                setSender:_sender]
                                               setMarketplacePostId:postId]
                                              setCurTime:curTime]
                                             build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetractPostFromMarketplaceEvent];
}

- (int) sendPurchaseFromMarketplaceMessage: (int)postId poster:(int)posterId clientTime:(uint64_t)clientTime {
  PurchaseFromMarketplaceRequestProto *req = [[[[[[PurchaseFromMarketplaceRequestProto builder]
                                                  setSender:_sender]
                                                 setMarketplacePostId:postId]
                                                setPosterId:posterId]
                                               setCurTime:clientTime]
                                              build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPurchaseFromMarketplaceEvent];
}

- (int) sendRedeemMarketplaceEarningsMessage {
  RedeemMarketplaceEarningsRequestProto *req = [[[RedeemMarketplaceEarningsRequestProto builder]
                                                 setSender:_sender]
                                                build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRedeemMarketplaceEarningsEvent];
}

- (int) sendPurchaseMarketplaceLicenseMessage: (uint64_t)clientTime type:(PurchaseMarketplaceLicenseRequestProto_LicenseType)type {
  PurchaseMarketplaceLicenseRequestProto *req = [[[[[PurchaseMarketplaceLicenseRequestProto builder]
                                                    setSender:_sender]
                                                   setClientTime:clientTime]
                                                  setLicenseType:type]
                                                 build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPurchaseMarketplaceLicenseEvent];
}

- (int) sendGenerateAttackListMessage:(int)numEnemies latUpperBound:(CGFloat)latUpperBound latLowerBound:(CGFloat)latLowerBound lonUpperBound:(CGFloat)lonUpperBound lonLowerBound:(CGFloat)lonLowerBound {
  GenerateAttackListRequestProto *req = [[[[[[[[[GenerateAttackListRequestProto builder]
                                                setSender:_sender]
                                               setNumEnemies:numEnemies]
                                              setLatLowerBound:latLowerBound]
                                             setLatUpperBound:latUpperBound]
                                            setLongLowerBound:lonLowerBound]
                                           setLongUpperBound:lonUpperBound]
                                          setForMap:YES]
                                         build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCGenerateAttackListEvent];
}

- (int) sendGenerateAttackListMessage:(int)numEnemies realPlayersOnly:(BOOL)realPlayersOnly {
  GenerateAttackListRequestProto *req = [[[[[GenerateAttackListRequestProto builder]
                                            setSender:_sender]
                                           setNumEnemies:numEnemies]
                                          setShowRealPlayers:realPlayersOnly]
                                         build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCGenerateAttackListEvent];
}

- (int) sendRefillStatWithDiamondsMessage:(RefillStatWithDiamondsRequestProto_StatType) statType {
  RefillStatWithDiamondsRequestProto *req = [[[[RefillStatWithDiamondsRequestProto builder]
                                               setSender:_sender]
                                              setStatType:statType]
                                             build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRefillStatWithDiamondsEvent];
}

- (int) sendPurchaseNormStructureMessage:(int)structId x:(int)x y:(int)y time:(uint64_t)time{
  PurchaseNormStructureRequestProto *req = [[[[[[PurchaseNormStructureRequestProto builder]
                                                setSender:_sender]
                                               setStructId:structId]
                                              setStructCoordinates:[[[[CoordinateProto builder] setX:x] setY:y] build]]
                                             setTimeOfPurchase:time]
                                            build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPurchaseNormStructureEvent];
}

- (int) sendMoveNormStructureMessage:(int)userStructId x:(int)x y:(int)y {
  MoveOrRotateNormStructureRequestProto *req =
  [[[[[[MoveOrRotateNormStructureRequestProto builder]
       setSender:_sender]
      setUserStructId:userStructId]
     setType:MoveOrRotateNormStructureRequestProto_MoveOrRotateNormStructTypeMove]
    setCurStructCoordinates:[[[[CoordinateProto builder] setX:x] setY:y] build]]
   build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCMoveOrRotateNormStructureEvent];
}

- (int) sendRotateNormStructureMessage:(int)userStructId orientation:(StructOrientation)orientation {
  MoveOrRotateNormStructureRequestProto *req =
  [[[[[[MoveOrRotateNormStructureRequestProto builder]
       setSender:_sender]
      setUserStructId:userStructId]
     setType:MoveOrRotateNormStructureRequestProto_MoveOrRotateNormStructTypeRotate]
    setNewOrientation:orientation]
   build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCMoveOrRotateNormStructureEvent];
}

- (int) sendUpgradeNormStructureMessage:(int)userStructId time:(uint64_t)curTime {
  UpgradeNormStructureRequestProto *req = [[[[[UpgradeNormStructureRequestProto builder]
                                              setSender:_sender]
                                             setUserStructId:userStructId]
                                            setTimeOfUpgrade:curTime]
                                           build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCUpgradeNormStructureEvent];
}

- (int) sendNormStructBuildsCompleteMessage:(NSArray *)userStructIds time:(uint64_t)curTime {
  NormStructWaitCompleteRequestProto *req = [[[[[NormStructWaitCompleteRequestProto builder]
                                                setSender:_sender]
                                               addAllUserStructId:userStructIds]
                                              setCurTime:curTime]
                                             build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCNormStructWaitCompleteEvent];
}

- (int) sendFinishNormStructBuildWithDiamondsMessage:(int)userStructId time:(uint64_t)milliseconds type:(FinishNormStructWaittimeWithDiamondsRequestProto_NormStructWaitTimeType) type {
  FinishNormStructWaittimeWithDiamondsRequestProto *req =
  [[[[[[FinishNormStructWaittimeWithDiamondsRequestProto builder]
       setSender:_sender]
      setUserStructId:userStructId]
     setTimeOfSpeedup:milliseconds]
    setWaitTimeType:type]
   build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCFinishNormStructWaittimeWithDiamondsEvent];
}

- (int) sendSellNormStructureMessage:(int)userStructId {
  SellNormStructureRequestProto *req = [[[[SellNormStructureRequestProto builder]
                                          setSender:_sender]
                                         setUserStructId:userStructId]
                                        build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCSellNormStructureEvent];
}

- (int) sendLoadPlayerCityMessage:(int)userId {
  LoadPlayerCityRequestProto *req = [[[[LoadPlayerCityRequestProto builder]
                                       setSender:_sender]
                                      setCityOwnerId:userId]
                                     build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCLoadPlayerCityEvent];
}

- (int) sendRetrieveStaticDataMessageWithStructIds:(NSArray *)structIds taskIds:(NSArray *)taskIds questIds:(NSArray *)questIds cityIds:(NSArray *)cityIds equipIds:(NSArray *)equipIds buildStructJobIds:(NSArray *)buildStructJobIds defeatTypeJobIds:(NSArray *)defeatTypeJobIds possessEquipJobIds:(NSArray *)possessEquipJobIds upgradeStructJobIds:(NSArray *)upgradeStructJobIds events:(BOOL)events clanTierLevels:(BOOL)clanTierLevels bossIds:(NSArray *)bossIds {
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
  if (events) {
    [blder setCurrentLockBoxEvents:YES];
    [blder setCurrentBossEvents:YES];
    [blder setCurrentLeaderboardEvents:YES];
  }
  if (clanTierLevels) {
    [blder setClanTierLevels:YES];
  }
  if (bossIds) {
    [blder addAllBossIds:bossIds];
  }
  
  [blder setSender:_sender];
  RetrieveStaticDataRequestProto *req = [blder build];
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveStaticDataEvent];
}

- (int) sendRetrieveStaticDataFromShopMessage:(RetrieveStaticDataForShopRequestProto_RetrieveForShopType) type {
  RetrieveStaticDataForShopRequestProto *req = [[[[RetrieveStaticDataForShopRequestProto builder]
                                                  setSender:_sender]
                                                 setType:type]
                                                build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveStaticDataForShopEvent];
}

- (int) sendEquipEquipmentMessage:(int)equipId forPrestigeSlot:(BOOL)forPrestigeSlot {
  EquipEquipmentRequestProto *req = [[[[[EquipEquipmentRequestProto builder]
                                       setSender:_sender]
                                      setUserEquipId:equipId]
                                      setForPrestigeEquipSlot:forPrestigeSlot]
                                     build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCEquipEquipmentEvent];
}

- (int) sendChangeUserLocationMessageWithLatitude:(CGFloat)lat longitude:(CGFloat)lon {
  ChangeUserLocationRequestProto *req = [[[[ChangeUserLocationRequestProto builder]
                                           setSender:_sender]
                                          setUserLocation:
                                          [[[[LocationProto builder]
                                             setLatitude:lat]
                                            setLongitude:lon]
                                           build]]
                                         build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCChangeUserLocationEvent];
}

- (int) sendLoadNeutralCityMessage:(int)cityId {
  LoadNeutralCityRequestProto *req = [[[[LoadNeutralCityRequestProto builder]
                                        setSender:_sender]
                                       setCityId:cityId]
                                      build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCLoadNeutralCityEvent];
}

- (int) sendLevelUpMessage {
  LevelUpRequestProto *req = [[[LevelUpRequestProto builder]
                               setSender:_sender]
                              build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCLevelUpEvent];
}

- (int) sendRefillStatWaitTimeComplete:(RefillStatWaitCompleteRequestProto_RefillStatWaitCompleteType)type curTime:(uint64_t)curTime {
  RefillStatWaitCompleteRequestProto *req = [[[[[RefillStatWaitCompleteRequestProto builder]
                                                setSender:_sender]
                                               setType:type]
                                              setCurTime:curTime]
                                             build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRefillStatWaitCompleteEvent];
}

- (int) sendQuestAcceptMessage:(int)questId {
  QuestAcceptRequestProto *req = [[[[QuestAcceptRequestProto builder]
                                    setSender:_sender]
                                   setQuestId:questId]
                                  build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCQuestAcceptEvent];
}

- (int) sendQuestRedeemMessage:(int)questId {
  QuestRedeemRequestProto *req = [[[[QuestRedeemRequestProto builder]
                                    setSender:_sender]
                                   setQuestId:questId]
                                  build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCQuestRedeemEvent];
}

- (int) sendUserQuestDetailsMessage:(int)questId {
  UserQuestDetailsRequestProto_Builder *builder = [[UserQuestDetailsRequestProto builder]
                                                   setSender:_sender];
  
  if (questId != 0) {
    [builder setQuestId:questId];
  }
  UserQuestDetailsRequestProto *req = [builder build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCUserQuestDetailsEvent];
}

- (int) sendRetrieveUserEquipForUserMessage:(int)userId {
  RetrieveUserEquipForUserRequestProto *req = [[[[RetrieveUserEquipForUserRequestProto builder]
                                                 setSender:_sender]
                                                setRelevantUserId:userId]
                                               build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveUserEquipForUser];
}

- (int) sendRetrieveUsersForUserIds:(NSArray *)userIds includePotentialPoints:(BOOL)points {
  RetrieveUsersForUserIdsRequestProto *req = [[[[[RetrieveUsersForUserIdsRequestProto builder]
                                                 setSender:_sender]
                                                setIncludePotentialPointsForClanTowers:points]
                                               addAllRequestedUserIds:userIds]
                                              build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveUsersForUserIdsEvent];
}

- (int) sendRetrievePlayerWallPostsMessage:(int)playerId beforePostId:(int)beforePostId {
  RetrievePlayerWallPostsRequestProto_Builder *bldr = [[[RetrievePlayerWallPostsRequestProto builder]
                                                        setSender:_sender]
                                                       setRelevantUserId:playerId];
  
  if (beforePostId > 0) {
    [bldr setBeforeThisPostId:beforePostId];
  }
  
  RetrievePlayerWallPostsRequestProto *req = [bldr build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrievePlayerWallPostsEvent];
}

- (int) sendPostOnPlayerWallMessage:(int)playerId withContent:(NSString *)content {
  PostOnPlayerWallRequestProto *req = [[[[[PostOnPlayerWallRequestProto builder]
                                          setSender:_sender]
                                         setWallOwnerId:playerId]
                                        setContent:content]
                                       build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPostOnPlayerWallEvent];
}

- (int) sendAPNSMessage:(NSString *)deviceToken {
  EnableAPNSRequestProto *req = [[[[EnableAPNSRequestProto builder]
                                   setSender:_sender]
                                  setDeviceToken:deviceToken]
                                 build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCEnableApnsEvent];
}

- (int) sendEarnFreeDiamondsKiipMessageClientTime:(uint64_t)time receipt:(NSString *)receipt {
  EarnFreeDiamondsRequestProto *req = [[[[[[EarnFreeDiamondsRequestProto builder]
                                           setSender:_sender]
                                          setFreeDiamondsType:EarnFreeDiamondsTypeKiip]
                                         setClientTime:time]
                                        setKiipReceipt:receipt]
                                       build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCEarnFreeDiamondsEvent];
}

- (int) sendEarnFreeDiamondsAdColonyMessageClientTime:(uint64_t)time digest:(NSString *)digest amount:(int)amount type:(EarnFreeDiamondsRequestProto_AdColonyRewardType)type {
  EarnFreeDiamondsRequestProto *req = [[[[[[[[EarnFreeDiamondsRequestProto builder]
                                             setSender:_sender]
                                            setFreeDiamondsType:EarnFreeDiamondsTypeAdcolony]
                                           setClientTime:time]
                                          setAdColonyDigest:digest]
                                         setAdColonyAmountEarned:amount]
                                        setAdColonyRewardType:type]
                                       build];
  return [self sendData:req withMessageType:EventProtocolRequestCEarnFreeDiamondsEvent];
}

- (int) sendEarnFreeDiamondsFBConnectMessageClientTime:(uint64_t)time {
  EarnFreeDiamondsRequestProto *req = [[[[[EarnFreeDiamondsRequestProto builder]
                                           setSender:_sender]
                                          setFreeDiamondsType:EarnFreeDiamondsTypeFbConnect]
                                         setClientTime:time]
                                       build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCEarnFreeDiamondsEvent];
}

- (int) sendSubmitEquipsToBlacksmithMessageWithUserEquipId:(int)equipOne userEquipId:(int)equipTwo slotNumber:(int)slotNumber guaranteed:(BOOL)guaranteed clientTime:(uint64_t)time {
  SubmitEquipsToBlacksmithRequestProto *req = [[[[[[[[SubmitEquipsToBlacksmithRequestProto builder]
                                                    setSender:_sender]
                                                   setUserEquipOne:equipOne]
                                                  setUserEquipTwo:equipTwo]
                                                 setPaidToGuarantee:guaranteed]
                                                 setForgeSlotNumber:slotNumber]
                                                setStartTime:time]
                                               build];
  return [self sendData:req withMessageType:EventProtocolRequestCSubmitEquipsToBlacksmith];
}

- (int) sendForgeAttemptWaitCompleteMessageWithBlacksmithId:(int)blacksmithId clientTime:(uint64_t)time {
  ForgeAttemptWaitCompleteRequestProto *req = [[[[[ForgeAttemptWaitCompleteRequestProto builder]
                                                  setBlacksmithId:blacksmithId]
                                                 setCurTime:time]
                                                setSender:_sender]
                                               build];
  return [self sendData:req withMessageType:EventProtocolRequestCForgeAttemptWaitComplete];
}

- (int) sendFinishForgeAttemptWaittimeWithDiamondsWithBlacksmithId:(int)blacksmithId clientTime:(uint64_t)time {
  FinishForgeAttemptWaittimeWithDiamondsRequestProto *req = [[[[[FinishForgeAttemptWaittimeWithDiamondsRequestProto builder]
                                                                setBlacksmithId:blacksmithId]
                                                               setTimeOfSpeedup:time]
                                                              setSender:_sender]
                                                             build];
  return [self sendData:req withMessageType:EventProtocolRequestCFinishForgeAttemptWaittimeWithDiamonds];
}

- (int) sendCollectForgeEquipsWithBlacksmithId:(int)blacksmithId {
  CollectForgeEquipsRequestProto *req = [[[[CollectForgeEquipsRequestProto builder]
                                           setBlacksmithId:blacksmithId]
                                          setSender:_sender]
                                         build];
  return [self sendData:req withMessageType:EventProtocolRequestCCollectForgeEquips ];
}

- (int) sendPurchaseForgeSlot {
  PurchaseForgeSlotRequestProto *req = [[[PurchaseForgeSlotRequestProto builder]
                                         setSender:_sender]
                                        build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPurchaseForgeSlotEvent];
}

- (int) sendCharacterModWithType:(CharacterModType)modType newType:(UserType)userType newName:(NSString *)name {
  CharacterModRequestProto_Builder *bldr = [[[CharacterModRequestProto builder]
                                             setModType:modType]
                                            setSender:_sender];
  
  if (modType == CharacterModTypeChangeName && name) {
    [bldr setFutureName:name];
  }
  
  if (modType == CharacterModTypeChangeCharacterType) {
    [bldr setFutureUserType:userType];
  }
  
  CharacterModRequestProto *req = [bldr build];
  return [self sendData:req withMessageType:EventProtocolRequestCCharacterModEvent];
}

- (int) sendRetrieveLeaderboardMessage:(LeaderboardType)type afterRank:(int)rank {
  RetrieveLeaderboardRequestProto *req = [[[[[RetrieveLeaderboardRequestProto builder]
                                             setLeaderboardType:type]
                                            setAfterThisRank:rank]
                                           setSender:_sender]
                                          build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveLeaderboardEvent];
}

- (int) sendGroupChatMessage:(GroupChatScope)scope message:(NSString *)msg clientTime:(uint64_t)clientTime {
  SendGroupChatRequestProto *req = [[[[[[SendGroupChatRequestProto builder]
                                        setScope:scope]
                                       setChatMessage:msg]
                                      setSender:_sender]
                                     setClientTime:clientTime]
                                    build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCSendGroupChatEvent];
}

- (int) sendPurchaseGroupChatMessage {
  SendGroupChatRequestProto *req = [[[SendGroupChatRequestProto builder]
                                     setSender:_sender]
                                    build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPurchaseGroupChatEvent];
}

- (int) sendCreateClanMessage:(NSString *)clanName tag:(NSString *)tag {
  CreateClanRequestProto *req = [[[[[CreateClanRequestProto builder]
                                    setSender:_sender]
                                   setName:clanName]
                                  setTag:tag]
                                 build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCCreateClanEvent];
}

- (int) sendLeaveClanMessage {
  LeaveClanRequestProto *req = [[[LeaveClanRequestProto builder]
                                 setSender:_sender]
                                build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCLeaveClanEvent];
}

- (int) sendRequestJoinClanMessage:(int)clanId {
  RequestJoinClanRequestProto *req = [[[[RequestJoinClanRequestProto builder]
                                        setSender:_sender]
                                       setClanId:clanId]
                                      build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRequestJoinClanEvent];
}

- (int) sendRetractRequestJoinClanMessage:(int)clanId {
  RetractRequestJoinClanRequestProto *req = [[[[RetractRequestJoinClanRequestProto builder]
                                               setSender:_sender]
                                              setClanId:clanId]
                                             build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetractRequestJoinClanEvent];
}

- (int) sendApproveOrRejectRequestToJoinClan:(int)requesterId accept:(BOOL)accept {
  ApproveOrRejectRequestToJoinClanRequestProto *req = [[[[[ApproveOrRejectRequestToJoinClanRequestProto builder]
                                                          setSender:_sender]
                                                         setRequesterId:requesterId]
                                                        setAccept:accept]
                                                       build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCApproveOrRejectRequestToJoinClanEvent];
}

- (int) sendTransferClanOwnership:(int)newClanOwnerId {
  TransferClanOwnershipRequestProto *req = [[[[TransferClanOwnershipRequestProto builder]
                                              setSender:_sender]
                                             setNewClanOwnerId:newClanOwnerId]
                                            build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCTransferClanOwnership];
}

- (int) sendChangeClanDescription:(NSString *)description {
  ChangeClanDescriptionRequestProto *req = [[[[ChangeClanDescriptionRequestProto builder]
                                              setSender:_sender]
                                             setDescription:description]
                                            build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCChangeClanDescriptionEvent];
}

- (int) sendChangeClanJoinType:(BOOL)requestToJoinRequired {
  ChangeClanJoinTypeRequestProto *req = [[[[ChangeClanJoinTypeRequestProto builder]
                                              setSender:_sender]
                                             setRequestToJoinRequired:requestToJoinRequired]
                                            build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCChangeClanJoinTypeEvent];
}

- (int) sendRetrieveClanInfoMessage:(NSString *)clanName clanId:(int)clanId grabType:(RetrieveClanInfoRequestProto_ClanInfoGrabType)grabType isForBrowsingList:(BOOL)isForBrowsingList beforeClanId:(int)beforeClanId {
  RetrieveClanInfoRequestProto_Builder *bldr = [[[[RetrieveClanInfoRequestProto builder]
                                                  setSender:_sender]
                                                 setGrabType:grabType]
                                                setIsForBrowsingList:isForBrowsingList];
  
  if (clanName) bldr.clanName = clanName;
  if (clanId) bldr.clanId = clanId;
  if (beforeClanId) bldr.beforeThisClanId = beforeClanId;
  
  RetrieveClanInfoRequestProto *req = [bldr build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveClanInfoEvent];
}

- (int) sendBootPlayerFromClan:(int)playerId {
  BootPlayerFromClanRequestProto *req = [[[[BootPlayerFromClanRequestProto builder]
                                           setSender:_sender]
                                          setPlayerToBoot:playerId]
                                         build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCBootPlayerFromClanEvent];
}

- (int) sendPostOnClanBulletinMessage:(NSString *)content {
  PostOnClanBulletinRequestProto *req = [[[[PostOnClanBulletinRequestProto builder]
                                           setSender:_sender]
                                          setContent:content]
                                         build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPostOnClanBulletinEvent];
}

- (int) sendRetrieveClanBulletinPostsMessage:(int)beforeThisClanId {
  RetrieveClanInfoRequestProto_Builder *bldr = [[RetrieveClanInfoRequestProto builder] setSender:_sender];
  
  if (beforeThisClanId > 0) {
    [bldr setBeforeThisClanId:beforeThisClanId];
  }
  
  RetrieveClanInfoRequestProto *req = [bldr build];
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveClanBulletinPostsEvent];
}

- (int) sendUpgradeClanTierLevelMessage {
  UpgradeClanTierLevelRequestProto *req = [[[[UpgradeClanTierLevelRequestProto builder]
                                             setSender:_sender]
                                            setClanId:_sender.clan.clanId]
                                           build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCUpgradeClanTierEvent];
}

- (int) sendBeginGoldmineTimerMessage:(uint64_t)clientTime reset:(BOOL)reset {
  BeginGoldmineTimerRequestProto *req = [[[[[BeginGoldmineTimerRequestProto builder]
                                            setSender:_sender]
                                           setClientTime:clientTime]
                                          setReset:reset]
                                         build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCBeginGoldmineTimerEvent];
}

- (int) sendCollectFromGoldmineMessage:(uint64_t)clientTime {
  CollectFromGoldmineRequestProto *req = [[[[CollectFromGoldmineRequestProto builder]
                                            setSender:_sender]
                                           setClientTime:clientTime]
                                          build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCCollectFromGoldmineEvent];
}

- (int) sendPickLockBoxMessage:(int)eventId method:(PickLockBoxRequestProto_PickLockBoxMethod)method clientTime:(uint64_t)clientTime {
  PickLockBoxRequestProto *req = [[[[[[PickLockBoxRequestProto builder]
                                      setSender:_sender]
                                     setMethod:method]
                                    setClientTime:clientTime]
                                   setLockBoxEventId:eventId]
                                  build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPickLockBoxEvent];
}

- (int) sendPurchaseCityExpansionMessage:(ExpansionDirection)direction timeOfPurchase:(uint64_t)time {
  PurchaseCityExpansionRequestProto *req = [[[[[PurchaseCityExpansionRequestProto builder]
                                               setSender:_sender]
                                              setDirection:direction]
                                             setTimeOfPurchase:time]
                                            build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPurchaseCityExpansionEvent];
}

- (int) sendExpansionWaitCompleteMessage:(BOOL)speedUp curTime:(uint64_t)time {
  ExpansionWaitCompleteRequestProto *req = [[[[[ExpansionWaitCompleteRequestProto builder]
                                               setSender:_sender]
                                              setSpeedUp:speedUp]
                                             setCurTime:time]
                                            build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCExpansionWaitCompleteEvent];
}

- (int) sendRetrieveThreeCardMonteMessage {
  RetrieveThreeCardMonteRequestProto *req = [[[RetrieveThreeCardMonteRequestProto builder] setSender:_sender] build];
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveThreeCardMonteEvent];
}

- (int) sendPlayThreeCardMonteMessage:(int)cardId {
  PlayThreeCardMonteRequestProto *req = [[[[PlayThreeCardMonteRequestProto builder]setSender:_sender]setCardId:cardId]build];
  return [self sendData:req withMessageType:EventProtocolRequestCPlayThreeCardMonteEvent];
}

- (int) sendBossActionMessage:(int)bossId isSuperAttack:(BOOL)isSuperAttack curTime:(uint64_t)curTime {
  BossActionRequestProto *req = [[[[[[BossActionRequestProto builder]
                                     setSender:_sender]
                                    setBossId:bossId]
                                   setCurTime:curTime]
                                  setIsSuperAttack:isSuperAttack]
                                 build];
  return [self sendData:req withMessageType:EventProtocolRequestCBossActionEvent];
}

- (int) sendBeginClanTowerWarMessage:(int)towerId claiming:(BOOL)claiming clientTime:(uint64_t)clientTime {
  BeginClanTowerWarRequestProto *req = [[[[[[BeginClanTowerWarRequestProto builder]
                                            setSender:_sender]
                                           setTowerId:towerId]
                                          setClaiming:claiming]
                                         setCurTime:clientTime]
                                        build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCBeginClanTowerWar];
}

- (int) sendConcedeClanTowerWar:(int)towerId clientTime:(uint64_t)clientTime {
  ConcedeClanTowerWarRequestProto *req = [[[[[ConcedeClanTowerWarRequestProto builder]
                                             setSender:_sender]
                                            setTowerId:towerId]
                                           setCurTime:clientTime]
                                          build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCConcedeClanTowerWar];
}

- (int) sendRetrieveLeaderboardRankingsMessage:(int)eventId afterThisRank:(int)afterThisRank {
  RetrieveLeaderboardRankingsRequestProto *req = [[[[[RetrieveLeaderboardRankingsRequestProto builder]
                                                     setSender:_sender]
                                                    setEventId:eventId]
                                                   setAfterThisRank:afterThisRank]
                                                  build];
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveLeaderboardRankingsEvent];
}

- (int) sendSubmitEquipEnhancementMessage:(int)enhancingId feeders:(NSArray *)feeders clientTime:(uint64_t)clientTime {
  SubmitEquipEnhancementRequestProto *req = [[[[[[SubmitEquipEnhancementRequestProto builder]
                                                 setSender:_sender]
                                                setEnhancingUserEquipId:enhancingId]
                                               setClientTime:clientTime]
                                              addAllFeederUserEquipIds:feeders]
                                             build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCSubmitEquipEnhancementEvent];
}

- (int) sendCollectEquipEnhancementMessage:(int)enhancementId speedup:(BOOL)speedup time:(uint64_t)clientTime {
  CollectEquipEnhancementRequestProto *req = [[[[[[CollectEquipEnhancementRequestProto builder]
                                                  setSender:_sender]
                                                 setEquipEnhancementId:enhancementId]
                                                setSpeedUp:speedup]
                                               setClientTime:clientTime]
                                              build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCCollectEquipEnhancementEvent];
}

- (int) sendRetrieveClanTowerScoresMessage:(int)towerId {
  RetrieveClanTowerScoresRequestProto *req = [[[[RetrieveClanTowerScoresRequestProto builder]
                                                setSender:_sender]
                                               setTowerId:towerId]
                                              build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveClanTowerScoresEvent];
}

- (int) sendRetrieveBoosterPackMessage {
  RetrieveBoosterPackRequestProto *req = [[[RetrieveBoosterPackRequestProto builder]
                                           setSender:_sender]
                                          build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveBoosterPackEvent];
}

- (int) sendPurchaseBoosterPackMessage:(int)boosterPackId purchaseOption:(PurchaseOption)purchaseOption clientTime:(uint64_t)clientTime {
  PurchaseBoosterPackRequestProto *req = [[[[[[PurchaseBoosterPackRequestProto builder]
                                              setSender:_sender]
                                             setBoosterPackId:boosterPackId]
                                            setClientTime:clientTime]
                                           setPurchaseOption:purchaseOption]
                                          build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPurchaseBoosterPackEvent];
}

- (int) sendResetBoosterPackMessage:(int)boosterPackId {
  ResetBoosterPackRequestProto *req = [[[[ResetBoosterPackRequestProto builder]
                                         setSender:_sender]
                                        setBoosterPackId:boosterPackId]
                                       build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCResetBoosterPackEvent];
}

- (int) sendPrestigeMessage {
  PrestigeRequestProto *req = [[[PrestigeRequestProto builder]
                                setSender:_sender]
                               build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPrestigeEvent];
}

- (int) sendPrivateChatPostMessage:(int)recipientId content:(NSString *)content {
  PrivateChatPostRequestProto *req = [[[[[PrivateChatPostRequestProto builder]
                                         setSender:_sender]
                                        setRecipientId:recipientId]
                                       setContent:content]
                                      build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCPrivateChatPostEvent];
}

- (int) sendRetrievePrivateChatPostsMessage:(int)otherUserId {
  RetrievePrivateChatPostsRequestProto *req = [[[[RetrievePrivateChatPostsRequestProto builder]
                                                 setOtherUserId:otherUserId]
                                                setSender:_sender]
                                               build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrievePrivateChatPostEvent];
}

- (int) sendRedeemUserLockBoxItemsMessage:(int)lockBoxEventId {
  RedeemUserLockBoxItemsRequestProto *req = [[[[RedeemUserLockBoxItemsRequestProto builder]
                                               setLockBoxEventId:lockBoxEventId]
                                              setSender:_sender]
                                             build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRedeemUserLockBoxItemsEvent];
}

- (int) sendRedeemUserCityGemsMessage:(int)cityId {
  RedeemUserCityGemsRequestProto *req = [[[[RedeemUserCityGemsRequestProto builder]
                                           setCityId:cityId]
                                          setSender:_sender]
                                         build];
  
  return [self sendData:req withMessageType:EventProtocolRequestCRedeemUserCityGemsEvent];
}

- (int) addAttackSkillPoint {
  [self flushWithInt:EventProtocolRequestCUseSkillPointEvent];
  self.attackPoints++;
  return _currentTagNum;
}

- (int) addDefenseSkillPoint {
  [self flushWithInt:EventProtocolRequestCUseSkillPointEvent];
  self.defensePoints++;
  return _currentTagNum;
}

- (int) addEnergySkillPoint {
  [self flushWithInt:EventProtocolRequestCUseSkillPointEvent];
  self.energyPoints++;
  return _currentTagNum;
}

- (int) addStaminaSkillPoint {
  [self flushWithInt:EventProtocolRequestCUseSkillPointEvent];
  self.staminaPoints++;
  return _currentTagNum;
}

- (int) retrieveCurrencyFromStruct:(int)userStructId time:(uint64_t)time {
  [self flushWithInt:EventProtocolRequestCRetrieveCurrencyFromNormStructureEvent];
  RetrieveCurrencyFromNormStructureRequestProto_StructRetrieval *sr = [[[[RetrieveCurrencyFromNormStructureRequestProto_StructRetrieval builder]
                                                                         setUserStructId:userStructId]
                                                                        setTimeOfRetrieval:time]
                                                                       build];
  [self.structRetrievals addObject:sr];
  return _currentTagNum;
}

- (int) sendUseSkillPointMessage {
  UseSkillPointRequestProto *req = [[[[[[[UseSkillPointRequestProto builder]
                                         setSender:_sender]
                                        setAttackIncrease:_attackPoints]
                                       setDefenseIncrease:_defensePoints]
                                      setEnergyIncrease:_energyPoints]
                                     setStaminaIncrease:_staminaPoints]
                                    build];
  
  LNLog(@"Sending use skill points message. A:%d, D:%d, E:%d, S:%d", _attackPoints, _defensePoints, _energyPoints, _staminaPoints);
  
  return [self sendData:req withMessageType:EventProtocolRequestCUseSkillPointEvent flush:NO];
}

- (int) sendRetrieveCurrencyFromNormStructureMessage {
  RetrieveCurrencyFromNormStructureRequestProto *req = [[[[RetrieveCurrencyFromNormStructureRequestProto builder]
                                                          setSender:_sender]
                                                         addAllStructRetrievals:self.structRetrievals]
                                                        build];
  
  LNLog(@"Sending retrieve currency message with %d structs.", self.structRetrievals.count);
  
  return [self sendData:req withMessageType:EventProtocolRequestCRetrieveCurrencyFromNormStructureEvent flush:NO];
}

- (void) flush {
  [self flushWithInt:-1];
}

- (void) flushWithInt:(int)val {
  [self flush:[NSNumber numberWithInt:val]];
}

- (void) flush:(NSNumber *)num {
  int type = num.intValue;
  if (type != EventProtocolRequestCUseSkillPointEvent) {
    if (_attackPoints > 0 || _defensePoints > 0 || _energyPoints > 0 || _staminaPoints > 0) {
      [self sendUseSkillPointMessage];
      self.attackPoints = 0;
      self.defensePoints = 0;
      self.energyPoints = 0;
      self.staminaPoints = 0;
    }
  }
  
  if (type != EventProtocolRequestCRetrieveCurrencyFromNormStructureEvent) {
    if (self.structRetrievals.count > 0) {
      [self sendRetrieveCurrencyFromNormStructureMessage];
      [self.structRetrievals removeAllObjects];
    }
  }
}

- (void) closeDownConnection {
  [_flushTimer invalidate];
  [_flushTimer release];
  _flushTimer = nil;
  [self flush];
  [_connectionThread end];
  _connectionThread = nil;
  [_sender release];
  _sender = nil;
  
  LNLog(@"Disconnected from host..");
}

- (void) dealloc {
  [udid release];
  udid = nil;
  [_sender release];
  [self closeDownConnection];
  [super dealloc];
}

@end
