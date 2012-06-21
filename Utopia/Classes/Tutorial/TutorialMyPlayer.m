//
//  TutorialMyPlayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/20/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TutorialMyPlayer.h"
#import "GameState.h"
#import "Globals.h"

@implementation TutorialMyPlayer

- (void) setUpAnimations {
  GameState *gs = [GameState sharedGameState];
  NSString *prefix = [Globals animatedSpritePrefix:gs.type];
  
  [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@WalkNF.plist",prefix]];
  
  //Creating animation for Near
  NSMutableArray *walkAnimN= [NSMutableArray array];
  for(int i = 0; true; ++i) {
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@WalkN%02d.png",prefix, i]];
    if (frame) {
      [walkAnimN addObject:frame];
    } else {
      break;
    }
  }
  
  CCAnimation *walkAnimationN = [CCAnimation animationWithFrames:walkAnimN delay:ANIMATATION_DELAY];
  self.walkActionN = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationN restoreOriginalFrame:NO]];
  
  //Creating animation for far
  NSMutableArray *walkAnimF= [NSMutableArray array];
  for(int i = 0; true; ++i) {
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@WalkF%02d.png",prefix, i]];
    if (frame) {
      [walkAnimF addObject:frame];
    } else {
      break;
    }
  }
  CCAnimation *walkAnimationF = [CCAnimation animationWithFrames:walkAnimF delay:ANIMATATION_DELAY];
  self.walkActionF = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimationF restoreOriginalFrame:NO]];
}

- (void) moveToLocation:(CGRect)loc {
  return;
}

@end
