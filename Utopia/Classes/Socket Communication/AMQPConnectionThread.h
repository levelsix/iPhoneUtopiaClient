//
//  AMQPConnectionThread.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/19/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMQPWrapper.h"
#import "AMQPConnectionThreadDelegate.h"

@interface AMQPConnectionThread : NSThread {
  AMQPExchange *_directExchange;
  AMQPExchange *_topicExchange;
  AMQPConnection *_connection;
  AMQPQueue *_udidQueue;
  AMQPQueue *_useridQueue;
  AMQPQueue *_chatQueue;
  AMQPQueue *_clanQueue;
  AMQPConsumer *_udidConsumer;
  AMQPConsumer *_useridConsumer;
  AMQPConsumer *_chatConsumer;
  AMQPConsumer *_clanConsumer;
}

@property (assign) NSObject<AMQPConnectionThreadDelegate> *delegate;

@property (copy) NSString *udid;
@property (retain) NSString *lastClanKey;

- (void) reloadClanMessageQueue;
- (void) connect:(NSString *)udid;
- (void) sendData:(NSData *)data;
- (void) startUserIdQueue;
- (void) closeDownConnection;
- (void) end;

@end
