//
//  TutorialStartLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/13/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TutorialStartLayer.h"
#import "Globals.h"
#import "DialogMenuController.h"
#import "CharSelectionViewController.h"
#import "GameViewController.h"
#import "GameState.h"
#import "TutorialConstants.h"

@implementation TutorialStartLayer

+ (id) scene {
  CCScene *scene = [CCScene node];
  [scene addChild:[self node]];
  return scene;
}

- (id) init {
  // Init with black
  if ((self = [super initWithColor:ccc4(0, 0, 0, 255)])) {
    _bgd = [CCSprite spriteWithFile:@"warbg.jpg"];
    _bgd.anchorPoint = ccp(0,0);
    _incrementor = 0;
    
    [self addChild:_bgd];
    [_bgd runAction: [CCSequence actions:
                     [CCMoveTo actionWithDuration:2 position:ccp(-_bgd.contentSize.width+self.contentSize.width, 0)],
                     [CCMoveTo actionWithDuration:0.5 position:ccp(-_bgd.contentSize.width/2+self.contentSize.width/2, 0)],
                     [CCCallFunc actionWithTarget:self selector:@selector(panDone)], nil]];
    
    // Set up the game state
    GameState *gs = [GameState sharedGameState];
//    TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
    
    gs.level = 1;
    gs.experience = 0;
    gs.currentEnergy = 5;
    gs.maxEnergy = 5;
    gs.currentStamina = 1;
    gs.maxStamina = 1;
  }
  return self;
}

- (void) panDone {
  CCLayerColor *white = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 0)];
  [self addChild:white z:0 tag:2];
  
  float dur = 3;
  _origPos = _bgd.position;
  [self shakeMoar];
  [white runAction:[CCSequence actions:
                    [CCEaseIn actionWithAction:[CCFadeTo actionWithDuration:dur opacity:255] rate:4],
                    [CCCallFunc actionWithTarget:self selector:@selector(removeBg)],
                    [CCFadeTo actionWithDuration:0.5 opacity:0],
                    [CCDelayTime actionWithDuration:2],
                    [CCCallFunc actionWithTarget:self selector:@selector(flashComplete)],
                    nil]];
}

- (void) shakeMoar {
  CGPoint diff = ccpSub(_bgd.position, _origPos);
  diff = ccp(-2*diff.x,0);
  
  // Every 4 iterations, interval gets a bit bigger
  _incrementor = (_incrementor+1)%4;
  if (_incrementor == 0) {
    diff.x++;
  }
  
  [_bgd runAction:[CCSequence actions:[CCMoveBy actionWithDuration:0.01f position:diff],
                   [CCCallFunc actionWithTarget:self selector:@selector(shakeMoar)], nil]];
}

- (void) removeBg {
  [self removeChild:_bgd cleanup:YES];
}

- (void) flashComplete {
  NSString *text = @"Somebody help me! Weary soldier! Who are you? What is your name?";
  [DialogMenuController displayViewForText:text progress:0];
  [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5],
                   [CCCallFunc actionWithTarget:self selector:@selector(beginCharSelection)],nil]];
}

- (void) beginCharSelection {
  [DialogMenuController closeView];
  UINavigationController *nv = [[GameViewController sharedGameViewController] navigationController];
  CharSelectionViewController *csvc = [[CharSelectionViewController alloc] initWithNibName:nil bundle:nil];
  [nv pushViewController:csvc animated:NO];
}

@end
