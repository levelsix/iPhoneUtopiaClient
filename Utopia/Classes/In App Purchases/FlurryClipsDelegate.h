//
//  FlurryClipsDelegate.h
//  Utopia
//
//  Created by Kevin Calloway on 5/24/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlurryAdDelegate.h"

@interface FlurryClipsDelegate : NSObject <FlurryAdDelegate>
+(id<FlurryAdDelegate>) createFlurryClipsDelegate;
@end
