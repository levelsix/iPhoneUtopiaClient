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
#define TEST_ADZONE2        @"vz9ade786d670a40dab44a4f"
#define PRODUCTION_ADZONE1  @"vze3ac5bd63ba3403db44644"
#define PRODUCTION_ADZONE2  @"vzfeba1867fad84dc294b7db"
#ifdef DEBUG
#define ADZONE1   TEST_ADZONE1
#define ADZONE2   TEST_ADZONE2
#else
#define ADZONE1   PRODUCTION_ADZONE1
#define ADZONE2   PRODUCTION_ADZONE2
#endif 

@interface AdColonyDelegate : NSObject <AdColonyDelegate>
+(id<AdColonyDelegate>) createAdColonyDelegate;
@end
