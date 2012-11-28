//
//  AMQPConnectionThreadDelegate.h
//  Utopia
//
//  Created by Ashwin Kamath on 11/19/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AMQPConsumerThreadDelegate.h"

@protocol AMQPConnectionThreadDelegate <AMQPConsumerThreadDelegate>

@optional
- (void) connectedToHost;
- (void) unableToConnectToHost:(NSString *)error;

@end
