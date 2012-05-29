//
//  AdColonyDelegate.h
//  Utopia
//
//  Created by Kevin Calloway on 5/23/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdColonyPublic.h"

#define TEST_ADZONE1        @"vzdf3190ec43a042ab83fa7d"
#define PRODUCTION_ADZONE1  @"vze3ac5bd63ba3403db44644"
#ifdef DEBUG
#define ADZONE1   TEST_ADZONE1
#else
#define ADZONE1   PRODUCTION_ADZONE1
#endif 

@interface AdColonyDelegate : NSObject <AdColonyDelegate>
+(id<AdColonyDelegate>) createAdColonyDelegate;
@end
