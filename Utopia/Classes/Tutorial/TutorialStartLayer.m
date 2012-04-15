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
#import "TopBar.h"
#import "GameLayer.h"
#import "SimpleAudioEngine.h"
#import "TutorialMapViewController.h"
#import "TutorialHomeMap.h"

#define PAN_DURATION 1.f//25.f

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
    [self addChild:_bgd];
    
    _label = [CCLabelFX labelWithString:@"" 
                             dimensions:CGSizeMake(self.contentSize.width-40, 40) 
                              alignment:UITextAlignmentCenter
                               fontName:@"Trajan Pro"
                               fontSize:15.f 
                           shadowOffset:CGSizeMake(0, -1)
                             shadowBlur:1.f];
    [self addChild:_label];
    _label.position = ccp(self.contentSize.width/2, 40);
    
    // Set up the game state
    GameState *gs = [GameState sharedGameState];
    TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
    
    gs.level = 1;
    gs.experience = 0;
    gs.currentEnergy = tc.initEnergy;
    gs.maxEnergy = tc.initEnergy;
    gs.currentStamina = tc.initStamina;
    gs.maxStamina = tc.initStamina;
    gs.maxHealth = tc.initHealth;
    gs.gold = tc.initGold;
    gs.silver = tc.initSilver;
    
    [[TopBar sharedTopBar] update];
    
    _curLabel = 0;
  }
  return self;
}

- (void) start {
  [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Mission_Enemy_song.m4a"];
  
  _incrementor = 0;
  [_bgd runAction: [CCSequence actions:
                    [CCMoveTo actionWithDuration:PAN_DURATION position:ccp(-_bgd.contentSize.width+self.contentSize.width, 0)],
                    [CCMoveTo actionWithDuration:1.f position:ccp(-_bgd.contentSize.width/2+self.contentSize.width/2, 0)],
                    [CCCallFunc actionWithTarget:self selector:@selector(panDone)], nil]];
  
  NSArray *text = [[TutorialConstants sharedTutorialConstants] duringPanTexts];
  int delayTime = (PAN_DURATION+4.f)/(text.count)-0.4f;
  CCSequence *seq = [CCSequence actions:
                     [CCFadeTo actionWithDuration:0.2f opacity:0],
                     [CCCallFunc actionWithTarget:self selector:@selector(changeLabel)],
                     [CCFadeTo actionWithDuration:0.2f opacity:255],
                     [CCDelayTime actionWithDuration:delayTime], nil];
  [_label runAction:[CCRepeat actionWithAction:seq times:text.count]];
}

- (void) changeLabel {
  NSArray *text = [[TutorialConstants sharedTutorialConstants] duringPanTexts];
  _label.string = [text objectAtIndex:_curLabel]; 
  _curLabel++;
}

- (void) panDone {
  CCLayerColor *white = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 0)];
  [self addChild:white z:0 tag:2];
  
  float dur = 3.f;
  _origPos = _bgd.position;
  [self shakeMoar];
  [white runAction:[CCSequence actions:
                    [CCEaseIn actionWithAction:[CCFadeTo actionWithDuration:dur opacity:255] rate:4],
                    [CCCallFunc actionWithTarget:self selector:@selector(removeBg)],
                    [CCFadeTo actionWithDuration:0.5 opacity:0],
                    [CCDelayTime actionWithDuration:2],
                    [CCCallFunc actionWithTarget:self selector:@selector(flashComplete)],
                    nil]];
  
  [Analytics tutorialPanDone];
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
  [self removeChild:_label cleanup:YES];
  [self removeChild:_bgd cleanup:YES];
  [[CCDirector sharedDirector] purgeCachedData];
}

- (void) flashComplete {
  NSString *text = [[TutorialConstants sharedTutorialConstants] beforeCharSelectionText];
  [DialogMenuController displayViewForBeginningText:text callbackTarget:self action:@selector(beginCharSelection)];
}

- (void) beginCharSelection {
  CharSelectionViewController *csvc = [[CharSelectionViewController alloc] initWithNibName:nil bundle:nil];
  [[[[CCDirector sharedDirector] openGLView] superview] addSubview:csvc.view];
//  [[CCDirector sharedDirector] replaceScene:[GameLayer scene]];
//  [[TutorialHomeMap sharedHomeMap] performSelectorInBackground:@selector(backgroundRefresh) withObject:nil];
//  [TutorialMapViewController sharedMapViewController];
//  [TutorialMapViewController displayView];
//  [[GameState sharedGameState] setSilver:150];
}

- (void) dealloc {
  [super dealloc];
}

@end
