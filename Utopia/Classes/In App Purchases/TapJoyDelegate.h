//
//  TapjoyDelegate.h
//  Utopia
//
//  Created by Kevin Calloway on 5/23/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TJCVideoAdProtocol.h"

@interface TapjoyDelegate : NSObject <TJCVideoAdDelegate>
+(id<TJCVideoAdDelegate>) createTapJoyDelegate;
@end
