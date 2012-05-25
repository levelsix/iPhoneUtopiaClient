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

@implementation FlurryClipsDelegate

///*
// called when video data is available
// */
//- (void)videoAvailable;
//
///*
// called when video data is unavailable
// */
//- (void)videoUnavailable;
//
//
///*
// called before takeover displays
// code to pause app states can be set here
// */
- (void)takeoverWillDisplay:(NSString *)hook
{
  NSLog(@"takeover displayed\n");
  [[SimpleAudioEngine sharedEngine] setMute:YES];
}

///*
// called before takeover closes
// code to resume app states can be set here
// */
- (void)takeoverWillClose
{
  [[SimpleAudioEngine sharedEngine] setMute:NO];
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
