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

#define UDID_KEY [NSString stringWithFormat:@"client_udid_%@", _udid]
#define USER_ID_KEY [NSString stringWithFormat:@"client_userid_%d", gs.userId]


@implementation AMQPConnectionThread

- (void) connect:(NSString *)udid {
  self.udid = udid;
  [self performSelector:@selector(initConnection) onThread:self withObject:nil waitUntilDone:NO];
}

- (void) initConnection {
  NSLog(@"Initializing connection..");
  @try {
    [self endConnection];
    _connection = [[AMQPConnection alloc] init];
    [_connection connectToHost:@"robot.lvl6.com" onPort:5672];
    [_connection loginAsUser:@"lvl6client" withPassword:@"devclient" onVHost:@"devageofchaos"];
    _exchange = [[AMQPExchange alloc] initDirectExchangeWithName:@"gamemessages" onChannel:[_connection openChannel] isPassive:NO isDurable:YES];
    
    NSString *udidKey = UDID_KEY;
    _udidQueue = [[AMQPQueue alloc] initWithName:[udidKey stringByAppendingString:@"_queue"] onChannel:[_connection openChannel] isPassive:NO isExclusive:NO isDurable:YES getsAutoDeleted:YES];
    [_udidQueue bindToExchange:_exchange withKey:udidKey];
    _udidConsumer = [[_udidQueue startConsumerWithAcknowledgements:NO isExclusive:NO receiveLocalMessages:YES] retain];
    
    if ([_delegate respondsToSelector:@selector(connectedToHost)]) {
      [_delegate performSelectorOnMainThread:@selector(connectedToHost) withObject:nil waitUntilDone:NO];
    }
  } @catch (NSException *exception) {
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
  _useridQueue = [[AMQPQueue alloc] initWithName:[useridKey stringByAppendingString:@"_queue"] onChannel:[_connection openChannel] isPassive:NO isExclusive:NO isDurable:YES getsAutoDeleted:YES];
  [_useridQueue bindToExchange:_exchange withKey:useridKey];
  _useridConsumer = [[_useridQueue startConsumerWithAcknowledgements:NO isExclusive:NO receiveLocalMessages:YES] retain];
  
  LNLog(@"Created user id queue");
}

- (void) sendData:(NSData *)data {
  [self performSelector:@selector(postDataToExchange:) onThread:self withObject:data waitUntilDone:NO];
}

- (void) postDataToExchange:(NSData *)data {
  [_exchange publishMessageWithData:data usingRoutingKey:@"messagesFromPlayers"];
}

- (void) closeDownConnection {
  [self performSelector:@selector(endConnection) onThread:self withObject:nil waitUntilDone:NO];
}

- (void) endConnection {
  GameState *gs = [GameState sharedGameState];
  [_useridConsumer release];
  [_udidConsumer release];
  [_udidQueue unbindFromExchange:_exchange withKey:UDID_KEY];
  [_useridQueue unbindFromExchange:_exchange withKey:USER_ID_KEY];
  [_udidQueue release];
  [_useridQueue release];
  [_exchange release];
  [_connection release];
  
  _useridConsumer = nil;
  _udidConsumer = nil;
  _useridQueue = nil;
  _udidQueue = nil;
  _exchange = nil;
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
    //    NSLog(@"Next");
		
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    
    if (_connection) {
      if (amqp_data_available(_connection.internalConnection)) {
        AMQPMessage *message = [_udidConsumer pop];
        if(message)
        {
          [_delegate performSelectorOnMainThread:@selector(amqpConsumerThreadReceivedNewMessage:) withObject:message waitUntilDone:NO];
        }
      }
    }
		
		[localPool drain];
	}
}

@end
