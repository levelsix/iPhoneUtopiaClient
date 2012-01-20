//
//  BattleLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/23/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

#import "BattleLayer.h"

@implementation BattleLayer

@synthesize left, right, flash;

- (id) init {
  if ((self = [super initWithColor:ccc4(0, 0, 255, 30)])) {
    left = [CCSprite spriteWithFile:@"left.png"];
    right = [CCSprite spriteWithFile:@"right.png"];
    flash = [CCLayerColor layerWithColor:ccc4(255,255,255,255)];
    
    left.position = ccp(-left.contentSize.width/2, left.contentSize.height/2);
    right.position = ccp([[CCDirector sharedDirector] winSize].width+left.contentSize.width/2, right.contentSize.height/2);
    
    [self addChild:left];
    [self addChild:right];
    [self addChild:flash];
    
    [flash setVisible:NO];
    
    [self setVisible:NO];
  }
  return self;
}

- (void) setInvisible {
  self.visible = NO;
}

- (void) removeFlash {
  flash.visible = NO;
}

- (void) shakeAndFlash {
  flash.visible = YES;
  [flash runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.02f],
                    [CCCallFuncN actionWithTarget:self selector:@selector(removeFlash)], nil]];
  
  
  [self runAction:[CCSequence actions:
                   [CCShaky3D actionWithRange:1 shakeZ:NO grid:ccg(20,30) duration:0.3],
                   [CCStopGrid action],nil]];
}

- (void) doAttackAnimation {
  self.visible = YES;
  
  [left runAction: [CCSequence actions: 
                    // Move to position
                    [CCMoveBy actionWithDuration:0.4 position:ccp(left.contentSize.width,0)], 
                    // Wait for right sprite to move
                    [CCDelayTime actionWithDuration:0.7],
                    // Move a little back to ready an attack
                    [CCMoveBy actionWithDuration:0.2 position:ccp(-50, 0)],
                    // Delay so it looks like we're ready
                    [CCDelayTime actionWithDuration:0.1],
                    // ATTACK!!
                    [CCMoveBy actionWithDuration:0.02 position:ccp(50, 0)],
                    // Flash screen and shake!
                    [CCCallFunc actionWithTarget:self selector:@selector(shakeAndFlash)],
                    // Wait for right sprite to move away
                    [CCDelayTime actionWithDuration:0.5],
                    // Fade out and scale, attack done
                    [CCSpawn actions:
                     [CCScaleBy actionWithDuration:0.1 scale:1.2],
                     [CCFadeTo actionWithDuration:0.1 opacity:40],
                     nil],
                    // Set this layer to invisible
                    [CCCallFunc actionWithTarget:self selector:@selector(setInvisible)],
                    nil]];
  
  [right runAction: [CCSequence actions: 
                     [CCDelayTime actionWithDuration:0.4],
                     [CCMoveBy actionWithDuration:0.5 position:ccp(-right.contentSize.width,0)],
                     [CCDelayTime actionWithDuration:0.65],
                     [CCMoveBy actionWithDuration:0.2 position:ccp(right.contentSize.width, 0)],
                     nil]];
}

@end
