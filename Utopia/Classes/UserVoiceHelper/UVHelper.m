//
//  UVHelper.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/16/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "UVHelper.h"
#import "cocos2d.h"
#import "SynthesizeSingleton.h"
#import "GameState.h"
#import "GameViewController.h"
#import "UIDevice+IdentifierAddition.h"

@implementation UVHelper

SYNTHESIZE_SINGLETON_FOR_CLASS(UVHelper);

- (id) init {
  if ((self = [super init])) {
    [UserVoice setDelegate:self];
  }
  return self;
}

- (void) openUserVoice {
  [[CCDirector sharedDirector] pause];
  GameState *gs = [GameState sharedGameState];
  [UserVoice presentUserVoiceModalViewControllerForParent:[GameViewController sharedGameViewController]
                                                  andSite:@"lvl6.uservoice.com"
                                                   andKey:@"yn0sMSQNm7eP0FJwTZVNCw"
                                                andSecret:@"zSkMY4WSpWw8Ofh2URg9P8aBLdSbOy9yf3ZFpUvmk"
                                                 andEmail:[NSString stringWithFormat:@"%@@lostnations.com", gs.name] 
                                           andDisplayName:gs.name 
                                                  andGUID:[[UIDevice currentDevice] uniqueDeviceIdentifier]];
}

- (void) userVoiceWasDismissed {
  [[CCDirector sharedDirector] resume];
}

@end
