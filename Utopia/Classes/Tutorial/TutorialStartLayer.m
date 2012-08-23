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
#import "TutorialTopBar.h"
#import "GameLayer.h"
#import "SimpleAudioEngine.h"
#import "TutorialCarpenterMenuController.h"
#import "TutorialHomeMap.h"
#import "ProfileViewController.h"

#ifdef DEBUG
#define PAN_DURATION 25.f
#else
#define PAN_DURATION 25.f
#endif

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
    gs.gold = tc.initGold;
    gs.silver = tc.initSilver;
    
    [[TopBar sharedTopBar] update];
    
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    
    _backButton = [CCMenuItemImage itemFromNormalImage:@"backbutton.png" selectedImage:nil target:self selector:@selector(skipPan)];
    int fontSize = 15;
    CCLabelTTF *skip = [CCLabelTTF labelWithString:@"Skip" fontName:@"Trajan Pro" fontSize:fontSize];
    [_backButton addChild:skip];
    skip.position = ccp(_backButton.contentSize.width/2, _backButton.contentSize.height/2);
    [Globals adjustFontSizeForCCLabelTTF:skip size:fontSize];
    
    CCMenu *menu = [CCMenu menuWithItems:_backButton, nil];
    [self addChild:menu];
    _backButton.visible = NO;
    _backButton.position = ccp(menu.contentSize.width/2-_backButton.contentSize.width/2-10, menu.contentSize.height/2-_backButton.contentSize.height/2-10);
    
    _curLabel = 0;
  }
  return self;
}

- (void) start {
  [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Mission_Enemy_song.m4a"];
  
  _incrementor = 0;
  [_bgd runAction: [CCSequence actions:
                    [CCMoveTo actionWithDuration:PAN_DURATION position:ccp(-_bgd.contentSize.width+self.contentSize.width, 0)],
                    [CCCallFunc actionWithTarget:self selector:@selector(firstPartOfPanDone)], nil]];
  
  NSArray *text = [[TutorialConstants sharedTutorialConstants] duringPanTexts];
  int delayTime = (PAN_DURATION+4.f)/(text.count)-0.4f;
  CCSequence *seq = [CCSequence actions:
                     [CCFadeTo actionWithDuration:0.2f opacity:0],
                     [CCCallFunc actionWithTarget:self selector:@selector(changeLabel)],
                     [CCFadeTo actionWithDuration:0.2f opacity:255],
                     [CCDelayTime actionWithDuration:delayTime], nil];
  [_label runAction:[CCRepeat actionWithAction:seq times:text.count]];
  
  [_backButton runAction:[CCSequence actions:
                          [CCDelayTime actionWithDuration:1.f],
                          [CCCallBlock actionWithBlock:
                           ^{
                             _backButton.visible = YES;
                           }], nil]];
}

- (void) firstPartOfPanDone {
  _backButton.visible = NO;
  [_bgd runAction: [CCSequence actions:
                    [CCMoveTo actionWithDuration:1.f position:ccp(-_bgd.contentSize.width/2+self.contentSize.width/2, 0)],
                    [CCCallFunc actionWithTarget:self selector:@selector(panDone)], nil]];
}

- (void) skipPan {
  [_bgd stopAllActions];
  [_label stopAllActions];
  
  float curPos = _bgd.position.x;
  float finalPos = -_bgd.contentSize.width+self.contentSize.width;
  [_bgd runAction: [CCSequence actions:
                    [CCMoveTo actionWithDuration:(finalPos-curPos)/finalPos*1.f position:ccp(finalPos,0)],
                    [CCCallFunc actionWithTarget:self selector:@selector(firstPartOfPanDone)], nil]];
  
  _backButton.visible = NO;
  _label.string = nil;
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
  _label.string = nil;
  // This will stop the shaking as well
  [self removeChild:_bgd cleanup:YES];
  [[CCDirector sharedDirector] purgeCachedData];
}

- (void) flashComplete {
  NSString *text = [[TutorialConstants sharedTutorialConstants] beforeCharSelectionText];
  _label.string = text;
  [_label runAction:[CCFadeIn actionWithDuration:0.3f]];
  [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.f], [CCCallFunc actionWithTarget:self selector:@selector(showTapToContinue)], nil]];
  _beforeCharSelectPhase = YES;
}

- (void) showTapToContinue {
  if (_beforeCharSelectPhase) {
    CCLabelFX *tap = [CCLabelFX labelWithString:@"Tap to continue..." 
                                     dimensions:CGSizeMake(self.contentSize.width-40, 40) 
                                      alignment:UITextAlignmentCenter
                                       fontName:@"Trajan Pro"
                                       fontSize:15.f 
                                   shadowOffset:CGSizeMake(0, -1)
                                     shadowBlur:1.f];
    tap.color = ccc3(255, 200, 0);
    [self addChild:tap z:0 tag:30];
    tap.position = _label.position;
    
    tap.opacity = 0;
    [tap runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.6f opacity:255], [CCFadeTo actionWithDuration:0.6f opacity:120], nil]]];
    [_label runAction:[CCMoveBy actionWithDuration:0.2f position:ccp(0, 50)]];
  }
}

- (void) beginCharSelection {
  CharSelectionViewController *csvc = [[CharSelectionViewController alloc] initWithNibName:nil bundle:nil];
  [Globals displayUIView:csvc.view];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  if (_beforeCharSelectPhase) {
    _beforeCharSelectPhase = NO;
    [self beginCharSelection];
    [_label runAction:[CCFadeOut actionWithDuration:0.3f]];
    
    CCNode *node = [self getChildByTag:30];
    [node stopAllActions];
    [node runAction:[CCFadeOut actionWithDuration:0.3f]];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
  }
  return YES;
}

@end
