//
//  UVHelper.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/16/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "UVHelper.h"
#import "cocos2d.h"
#import "LNSynthesizeSingleton.h"
#import "GameState.h"
#import "GameViewController.h"

#define UV_KEY @"yn0sMSQNm7eP0FJwTZVNCw"
#define UV_SECRET @"zSkMY4WSpWw8Ofh2URg9P8aBLdSbOy9yf3ZFpUvmk"

@implementation UVHelper

SYNTHESIZE_SINGLETON_FOR_CLASS(UVHelper);

- (id) init {
  if ((self = [super init])) {
    [UserVoice setDelegate:self];
  }
  return self;
}

- (void) openUserVoice {
//  [[CCDirector sharedDirector] pause];
  GameState *gs = [GameState sharedGameState];
  [UserVoice presentUserVoiceModalViewControllerForParent:[GameViewController sharedGameViewController]
                                                  andSite:@"lvl6.uservoice.com"
                                                   andKey:UV_KEY
                                                andSecret:UV_SECRET
                                                 andEmail:[NSString stringWithFormat:@"%@_%@@lostnations.com", gs.name, gs.referralCode] 
                                           andDisplayName:gs.name 
                                                  andGUID:[NSString stringWithFormat:@"%d", gs.userId]];
}

- (void) userVoiceWasDismissed {
//  [[CCDirector sharedDirector] resume];
}

@end
