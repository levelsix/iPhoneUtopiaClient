//
//  EventController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Protocols.pb.h"

@interface IncomingEventController : NSObject

+ (IncomingEventController *) sharedIncomingEventController;
- (Class) getClassForType: (EventProtocolResponse) type;
- (void) receivedResponseForMessage:(int)tag;

@end
