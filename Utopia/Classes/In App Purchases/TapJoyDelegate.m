//
//  TapjoyDelegate.m
//  Utopia
//
//  Created by Kevin Calloway on 5/23/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TapjoyDelegate.h"
#import "TapjoyConnect.h"
#import "SimpleAudioEngine.h"
#import "InAppPurchaseData.h"

#define TAPJOY_APPID         @"a5128a5f-1a9f-4a03-9a5d-1304489f08e1"
#define TAPJOY_SECRET        @"sZH7jGPnzX1MhVyjmDyg"

@implementation TapjoyDelegate

- (void)videoAdBegan
{
  [[SimpleAudioEngine sharedEngine] setMute:YES];
}

- (void)videoAdClosed
{
  [[SimpleAudioEngine sharedEngine] setMute:NO];
  [InAppPurchaseData postAdTakeoverResignedNotificationForSender:self];
}

+(id<TJCVideoAdDelegate>) createTapJoyDelegate
{
  TapjoyDelegate *delegate = [[TapjoyDelegate alloc] init];
  [TapjoyConnect requestTapjoyConnect:TAPJOY_APPID secretKey:TAPJOY_SECRET];
  [TapjoyConnect initVideoAdWithDelegate:delegate];
  [delegate autorelease];
  return delegate;
}

@end
