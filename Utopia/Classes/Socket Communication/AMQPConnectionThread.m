//
//  AMQPConnectionThread.m
//  Utopia
//
//  Created by Ashwin Kamath on 11/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "AMQPConnectionThread.h"

@implementation AMQPConnectionThread

- (void) connect {
  [self performSelector:@selector(initConnection) onThread:self withObject:nil waitUntilDone:NO];
}

- (void) initConnection {
  
}

@end
