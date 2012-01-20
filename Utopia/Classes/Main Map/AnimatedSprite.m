//
//  AnimatedSprite.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "AnimatedSprite.h"

@implementation AnimatedSprite

@synthesize sprite = _sprite;
@synthesize walkAction = _walkAction;
@synthesize moveAction = _moveAction;

-(id) init {
  if((self = [super init])) {
    
    // This loads an image of the same name (but ending in png), and goes through the
    // plist to add definitions of each frame to the cache.
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sora_default.plist"];        
    
    // Create a sprite sheet with the Happy Bear images
    CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"sora_default.png"];
    [self addChild:spriteSheet];
    
    // Load up the frames of our animation
    NSMutableArray *walkAnimFrames = [NSMutableArray array];
    for(int i = 2; i <= 9; ++i) {
      [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"sora%d.png", i]]];
    }
    CCAnimation *walkAnim = [CCAnimation animationWithFrames:walkAnimFrames delay:0.1f];
    
    // Create a sprite for our bear
    CGSize winSize = [CCDirector sharedDirector].winSize;
    self.sprite = [CCSprite spriteWithSpriteFrameName:@"sora2.png"];        
    _sprite.position = ccp(winSize.width/2, winSize.height/2);
    self.walkAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnim restoreOriginalFrame:NO]];
    [_sprite runAction:_walkAction];
    [spriteSheet addChild:_sprite];
    
    self.isTouchEnabled = YES;
    
  }
  return self;
}

@end
