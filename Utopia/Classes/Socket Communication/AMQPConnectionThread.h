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
  AMQPExchange *_exchange;
  AMQPConnection *_connection;
  AMQPQueue *_udidQueue;
  AMQPQueue *_useridQueue;
  AMQPConsumer *_udidConsumer;
  AMQPConsumer *_useridConsumer;
}

@property (assign) NSObject<AMQPConnectionThreadDelegate> *delegate;

@property (copy) NSString *udid;

@end
