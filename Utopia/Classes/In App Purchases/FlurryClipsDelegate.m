//
//  FlurryClipsDelegate.m
//  Utopia
//
//  Created by Kevin Calloway on 5/24/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "FlurryClipsDelegate.h"
#import "FlurryClips.h"
#import "SimpleAudioEngine.h"
#import "InAppPurchaseData.h"

@implementation FlurryClipsDelegate

/*
 called when video data is available
 */
- (void)videoAvailable
{
  [InAppPurchaseData postAdTakeoverResignedNotificationForSender:self];
}

/*
 called when video data is unavailable
 */
- (void)videoUnavailable
{
  [InAppPurchaseData postAdTakeoverResignedNotificationForSender:self]; 
}

/*
 called before takeover displays
 code to pause app states can be set here
 */
- (void)takeoverWillDisplay:(NSString *)hook
{
  [[SimpleAudioEngine sharedEngine] setMute:YES];
}

/*
 called before takeover closes
 code to resume app states can be set here
 */
- (void)takeoverWillClose
{
  [[SimpleAudioEngine sharedEngine] setMute:NO];
  [InAppPurchaseData postAdTakeoverResignedNotificationForSender:self];
}

+(id<FlurryAdDelegate>) createFlurryClipsDelegate
{
  FlurryClipsDelegate *delegate = [[FlurryClipsDelegate alloc] init];
  [FlurryClips setVideoAdsEnabled:YES];
  [FlurryClips setVideoDelegate:delegate];
  [delegate autorelease];
  return delegate;
}
@end
