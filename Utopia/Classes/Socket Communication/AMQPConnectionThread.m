//
//  AMQPConnectionThread.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/19/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "AMQPConnectionThread.h"

#import "amqp.h"
#import "amqp_framing.h"
#import "Gamestate.h"
#import "ClientProperties.h"

#define UDID_KEY [NSString stringWithFormat:@"client_udid_%@", _udid]
#define USER_ID_KEY [NSString stringWithFormat:@"client_userid_%d", gs.userId]
#define CHAT_KEY @"chat_global"
#define CLAN_KEY [NSString stringWithFormat:@"clan_%d", gs.clan.clanId]

@implementation AMQPConnectionThread

static int sessionId;

- (void) connect:(NSString *)udid {
  self.udid = udid;
  [self performSelector:@selector(initConnection) onThread:self withObject:nil waitUntilDone:NO];
}

- (void) initConnection {
  LNLog(@"Initializing connection..");
  @try {
    sessionId = arc4random();
    [self endConnection];
    
    _connection = [[AMQPConnection alloc] init];
    [_connection connectToHost:HOST_NAME onPort:HOST_PORT];
    [_connection loginAsUser:MQ_USERNAME withPassword:MQ_PASSWORD onVHost:MQ_VHOST];
    AMQPChannel *channel = [_connection openChannel];
    _directExchange = [[AMQPExchange alloc] initDirectExchangeWithName:@"gamemessages" onChannel:channel isPassive:NO isDurable:YES];
    
    _topicExchange = [[AMQPExchange alloc] initTopicExchangeWithName:@"chatmessages" onChannel:channel isPassive:NO isDurable:YES];
    
    NSString *udidKey = UDID_KEY;
    _udidQueue = [[AMQPQueue alloc] initWithName:[udidKey stringByAppendingFormat:@"_%d_queue", sessionId] onChannel:channel isPassive:NO isExclusive:NO isDurable:YES getsAutoDeleted:YES];
    [_udidQueue bindToExchange:_directExchange withKey:udidKey];
    _udidConsumer = [[_udidQueue startConsumerWithAcknowledgements:NO isExclusive:NO receiveLocalMessages:YES] retain];
    
    if ([_delegate respondsToSelector:@selector(connectedToHost)]) {
      [_delegate performSelectorOnMainThread:@selector(connectedToHost) withObject:nil waitUntilDone:NO];
    }
  } @catch (NSException *exception) {
    _connection = nil;
    if ([_delegate respondsToSelector:@selector(unableToConnectToHost:)]) {
      [_delegate performSelectorOnMainThread:@selector(unableToConnectToHost:) withObject:exception.reason waitUntilDone:NO];
    }
  }
}

- (void) startUserIdQueue {
  [self performSelector:@selector(initUserIdMessageQueue) onThread:self withObject:nil waitUntilDone:YES];
}

- (void) initUserIdMessageQueue {
  GameState *gs = [GameState sharedGameState];
  NSString *useridKey = USER_ID_KEY;
  _useridQueue = [[AMQPQueue alloc] initWithName:[useridKey stringByAppendingFormat:@"_%d_queue", sessionId]  onChannel:_udidConsumer.channel  isPassive:NO isExclusive:NO isDurable:YES getsAutoDeleted:YES];
  [_useridQueue bindToExchange:_directExchange withKey:useridKey];
  _useridConsumer = [[_useridQueue startConsumerWithAcknowledgements:NO isExclusive:NO receiveLocalMessages:YES] retain];
  
  NSString *udidKey = USER_ID_KEY;
  _chatQueue = [[AMQPQueue alloc] initWithName:[udidKey stringByAppendingFormat:@"_%d_chat_queue", sessionId] onChannel:[_connection openChannel] isPassive:NO isExclusive:NO isDurable:YES getsAutoDeleted:YES];
  [_chatQueue bindToExchange:_topicExchange withKey:CHAT_KEY];
  _chatConsumer = [[_chatQueue startConsumerWithAcknowledgements:NO isExclusive:NO receiveLocalMessages:YES] retain];
  
  LNLog(@"Created queues");
}

- (void) reloadClanMessageQueue {
  [self performSelector:@selector(initClanMessageQueue) onThread:self withObject:nil waitUntilDone:NO];
}

- (void) initClanMessageQueue {
  GameState *gs = [GameState sharedGameState];
  [self destroyClanMessageQueue];
  if (gs.clan.clanId) {
    NSString *useridKey = USER_ID_KEY;
    self.lastClanKey = CLAN_KEY;
    _clanQueue = [[AMQPQueue alloc] initWithName:[useridKey stringByAppendingFormat:@"_%d_clan_queue", sessionId] onChannel:[_connection openChannel] isPassive:NO isExclusive:NO isDurable:YES getsAutoDeleted:YES];
    [_clanQueue bindToExchange:_topicExchange withKey:self.lastClanKey];
    _clanConsumer = [[_clanQueue startConsumerWithAcknowledgements:NO isExclusive:NO receiveLocalMessages:YES] retain];
  }
}
  
- (void) destroyClanMessageQueue {
  [_clanConsumer release];
  [_clanQueue release];
  _clanConsumer = nil;
  _clanQueue = nil;
}

- (void) sendData:(NSData *)data {
  [self performSelector:@selector(postDataToExchange:) onThread:self withObject:data waitUntilDone:NO];
}

- (void) postDataToExchange:(NSData *)data {
  [_directExchange publishMessageWithData:data usingRoutingKey:@"messagesFromPlayers"];
}

- (void) closeDownConnection {
  [self performSelector:@selector(endConnection) onThread:self withObject:nil waitUntilDone:NO];
}

- (void) endConnection {
  [self destroyClanMessageQueue];
  [_useridConsumer release];
  [_udidConsumer release];
  [_chatConsumer release];
  
//  GameState *gs = [GameState sharedGameState];
//  [_udidQueue unbindFromExchange:_directExchange withKey:UDID_KEY];
//  [_useridQueue unbindFromExchange:_directExchange withKey:USER_ID_KEY];
//  [_chatQueue unbindFromExchange:_topicExchange withKey:CHAT_KEY];
  [_udidQueue release];
  [_useridQueue release];
  [_chatQueue release];
  [_directExchange release];
  [_topicExchange release];
  [_connection release];
  
  _chatConsumer = nil;
  _chatQueue = nil;
  _useridConsumer = nil;
  _udidConsumer = nil;
  _useridQueue = nil;
  _udidQueue = nil;
  _directExchange = nil;
  _topicExchange = nil;
  _connection = nil;
}

- (void) end {
  [self closeDownConnection];
  [self cancel];
}

- (void)main
{
	NSAutoreleasePool *localPool;
	
	while(![self isCancelled])
	{
		localPool = [[NSAutoreleasePool alloc] init];
		
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    
    if (_connection) {
      if (amqp_data_available(_connection.internalConnection) || amqp_data_in_buffer(_connection.internalConnection)) {
        AMQPMessage *message = [_udidConsumer pop];
        if(message)
        {
          [_delegate performSelectorOnMainThread:@selector(amqpConsumerThreadReceivedNewMessage:) withObject:message waitUntilDone:NO];
        }
      }
    }
		
		[localPool drain];
	}
  
  
  [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

@end
