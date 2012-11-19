//
//  AMQPConnectionThread.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "AMQPConsumerThread.h"
#import "AMQPWrapper.h"

@interface AMQPConnectionThread : NSThread {
  AMQPExchange *_exchange;
  AMQPConnection *_connection;
  AMQPQueue *_udidQueue;
  AMQPQueue *_useridQueue;
  AMQPConsumerThread *_udidThread;
  AMQPConsumerThread *_useridThread;
}

- (void) connect;

@end
