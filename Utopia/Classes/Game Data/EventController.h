//
//  EventController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"

@interface EventController : NSObject

+ (EventController *) sharedEventController;
- (Class) getClassForType: (EventProtocolResponse) type;

@end
