//
//  BattleLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/23/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

#import "BattleLayer.h"
#import "Globals.h"

#define HEALTH_BAR_VELOCITY 30.f

#define ATTACK_BUTTON_ANIMATION 4.f

#define MIN_COMBO_BAR_DURATION 0.8f
#define MAX_COMBO_BAR_DURATION 1.8f

@implementation BattleLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
  
  CCSprite *sprite = [CCSprite spriteWithFile:@"battlebackground1.png"];
  sprite.anchorPoint = ccp(0,0);
  [scene addChild:sprite];
	
	// 'layer' is an autorelease object.
	BattleLayer *layer = [BattleLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init {
  if ((self = [super init])) {
    _left = [CCSprite spriteWithFile:@"goodarcher.png"];
    _right = [CCSprite spriteWithFile:@"badarcher.png"];
    
    _left.position = ccp(-_left.contentSize.width/2, _left.contentSize.height/2);
    _right.position = ccp([[CCDirector sharedDirector] winSize].width+_left.contentSize.width/2, _right.contentSize.height/2);
    
    [self addChild:_left z:1];
    [self addChild:_right z:1];
    
    CCSprite *_leftHealthBarBg = [CCSprite spriteWithFile:@"healthbarbg.png"];
    _leftHealthBarBg.position = ccp(_leftHealthBarBg.contentSize.width/2, self.contentSize.height-_leftHealthBarBg.contentSize.height/2);
    [self addChild:_leftHealthBarBg];
    
    _leftHealthBar = [CCSprite spriteWithFile:@"healthbar.png"];
    _leftHealthBar.anchorPoint = ccp(0, 0.5f);
    _leftHealthBar.position = ccp(0, _leftHealthBarBg.contentSize.height/2);
    [_leftHealthBarBg addChild:_leftHealthBar];
    
    CCSprite *_rightHealthBarBg = [CCSprite spriteWithTexture:_leftHealthBarBg.texture];
    _rightHealthBarBg.flipX = YES;
    _rightHealthBarBg.position = ccp(self.contentSize.width-_leftHealthBarBg.contentSize.width/2, self.contentSize.height-_leftHealthBarBg.contentSize.height/2);
    [self addChild:_rightHealthBarBg];
    
    _rightHealthBar = [CCSprite spriteWithTexture:_leftHealthBar.texture];
    _rightHealthBar.anchorPoint = ccp(1, 0.5f);
    _rightHealthBar.position = ccp(_rightHealthBarBg.contentSize.width, _rightHealthBarBg.contentSize.height/2);
    _rightHealthBar.flipX = YES;
    [_rightHealthBarBg addChild:_rightHealthBar];
    
    _attackButton = [CCSprite spriteWithFile:@"attackbg.png"];
    _attackButton.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    [self addChild:_attackButton];
    
    _attackProgressTimer = [CCProgressTimer progressWithFile:@"yellowtimer.png"];
    _attackProgressTimer.position = ccp(_attackButton.contentSize.width/2, _attackButton.contentSize.height/2);
    _attackProgressTimer.type = kCCProgressTimerTypeRadialCCW;
    _attackProgressTimer.percentage = 42;
    [_attackButton addChild:_attackProgressTimer];
    
    CCSprite *attackImage = [CCSprite spriteWithFile:@"circleattackbutton.png"];
    CCMenuItemSprite *attackImageButton = [CCMenuItemSprite itemFromNormalSprite:attackImage selectedSprite:nil target:self selector:@selector(attackStart)];
    
    CCMenu *menu = [CCMenu menuWithItems:attackImageButton,nil];
    [_attackButton addChild:menu];
    menu.position = ccp(_attackButton.contentSize.width/2, _attackButton.contentSize.height/2);
    
    _comboBar = [CCSprite spriteWithFile:@"attackcirclebg.png"];
    _comboBar.position = ccp(100, self.contentSize.height/2);
    [self addChild:_comboBar];
    
    _comboProgressTimer = [CCProgressTimer progressWithFile:@"attackchecks.png"];
    _comboProgressTimer.position = ccp(_comboBar.contentSize.width/2-2, _comboBar.contentSize.height/2);
    _comboProgressTimer.type = kCCProgressTimerTypeRadialCW;
    _comboProgressTimer.percentage = 75;
    _comboProgressTimer.rotation = 180;
    [_comboBar addChild:_comboProgressTimer];
    
    CCSprite *max = [CCSprite spriteWithFile:@"max.png"];
    max.position = ccp(_comboBar.contentSize.width+max.contentSize.width/2, _comboBar.contentSize.height/2);
    [_comboBar addChild:max];
    
    CCSprite *pause = [CCSprite spriteWithFile:@"pause.png"];
    CCMenuItemSprite *pauseButton = [CCMenuItemSprite itemFromNormalSprite:pause selectedSprite:nil target:self selector:@selector(pauseClicked)];
    pauseButton.anchorPoint = ccp(1, 0);
    
    CCSprite *flee = [CCSprite spriteWithFile:@"flee.png"];
    CCMenuItemSprite *fleeButton = [CCMenuItemSprite itemFromNormalSprite:flee selectedSprite:nil target:self selector:@selector(fleeClicked)];
    fleeButton.anchorPoint = ccp(0,0);
    
    _bottomMenu = [CCMenu menuWithItems:pauseButton, fleeButton, nil];
    _bottomMenu.position = ccp(self.contentSize.width/2, 0);
    [self addChild:_bottomMenu];
    
    [self setleftHealthBarPercentage:0.1];
    [self setrightHealthBarPercentage:0.1];
    
    self.isTouchEnabled = YES;
    
    [self startTurn];
  }
  return self;
}

- (void) setleftHealthBarPercentage:(float)percentage {
  float width = _leftHealthBar.contentSize.width;
  float endPos = width * percentage;
  
  CGPoint finalPt = ccp(endPos-width, _leftHealthBar.position.y);
  float dist = ccpDistance(finalPt, _leftHealthBar.position);
  [_leftHealthBar runAction:[CCMoveTo actionWithDuration:dist/HEALTH_BAR_VELOCITY position:finalPt]];
}

- (void) fleeClicked {
  NSLog(@"flee");
}

- (void) pauseClicked {
  NSLog(@"pause");
}

- (void) attackStart {
  [_attackProgressTimer stopAllActions];
  
  _bottomMenu.visible = NO;
  _attackButton.visible = NO;
  _comboBar.visible = YES;
  _comboBarMoving = YES;
  
  float duration = (((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX)*(MAX_COMBO_BAR_DURATION-MIN_COMBO_BAR_DURATION))+MIN_COMBO_BAR_DURATION;
  [_comboProgressTimer runAction:[CCSequence actionOne:[CCEaseIn actionWithAction:[CCProgressFromTo actionWithDuration:duration from:0 to:100] rate:2.5]
                                                    two:[CCCallFunc actionWithTarget:self selector:@selector(comboMissed)]]];
}

- (void) comboBarClicked {
  if (_comboBarMoving) {
    [_comboProgressTimer stopAllActions];
    _comboBarMoving = NO;
    NSLog(@"Clicked at percent: %f", _comboProgressTimer.percentage);
    
    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:0.5] two:[CCCallFunc actionWithTarget:self selector:@selector(doAttackAnimation)]]];
  }
}

- (void) comboMissed {
  _comboBarMoving = NO;
  [self startTurn];
}

- (void) startTurn {
  _attackButton.visible = YES;
  _comboBar.visible = NO;
  _bottomMenu.visible = YES;
  
  [_attackProgressTimer runAction:[CCSequence actionOne:[CCProgressFromTo actionWithDuration:ATTACK_BUTTON_ANIMATION from:100 to:0]
                                   two:[CCCallFunc actionWithTarget:self selector:@selector(turnMissed)]]];
}

- (void) turnMissed {
  [self startTurn];
  NSLog(@"Turn missed.");
}

- (void) setrightHealthBarPercentage:(float)percentage {
  float width = _rightHealthBar.contentSize.width;
  float endPos = width * percentage;
  
  CGPoint finalPt = ccp(_rightHealthBar.parent.contentSize.width+width-endPos, _rightHealthBar.position.y);
  float dist = ccpDistance(finalPt, _rightHealthBar.position);
  [_rightHealthBar runAction:[CCMoveTo actionWithDuration:dist/HEALTH_BAR_VELOCITY position:finalPt]];
}

- (void) setInvisible {
  [self startTurn];
}

- (void) doAttackAnimation {
  self.visible = YES;
  _left.position = ccp(-_left.contentSize.width/2, _left.contentSize.height/2);
  _left.opacity = 255;
  _left.scale = 1;
  _right.position = ccp([[CCDirector sharedDirector] winSize].width+_left.contentSize.width/2, _right.contentSize.height/2);
  
  [_left runAction: [CCSequence actions: 
                    // Move to position
                    [CCMoveBy actionWithDuration:0.4 position:ccp(3*_left.contentSize.width/4,0)], 
                    // Wait for _right sprite to move
                    [CCDelayTime actionWithDuration:0.7],
                    // Move a little back to ready an attack
                    [CCMoveBy actionWithDuration:0.2 position:ccp(-50, 0)],
                    // Delay so it looks like we're ready
                    [CCDelayTime actionWithDuration:0.1],
                    // ATTACK!!
                    [CCMoveBy actionWithDuration:0.02 position:ccp(50, 0)],
                    // Wait for _right sprite to move away
                    [CCDelayTime actionWithDuration:0.5],
                    // Fade out and scale, attack done
                    [CCSpawn actions:
                     [CCScaleBy actionWithDuration:0.1 scale:1.2],
                     [CCFadeOut actionWithDuration:0.1],
                     nil],
                    // Set this layer to invisible
                    [CCCallFunc actionWithTarget:self selector:@selector(setInvisible)],
                    nil]];
  
  [_right runAction: [CCSequence actions: 
                     [CCDelayTime actionWithDuration:0.4],
                     [CCMoveBy actionWithDuration:0.5 position:ccp(-3*_right.contentSize.width/4,0)],
                     [CCDelayTime actionWithDuration:0.65],
                     [CCMoveBy actionWithDuration:0.2 position:ccp(3*_right.contentSize.width/4, 0)],
                     nil]];
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_comboBarMoving) {
    [self comboBarClicked];
  }
}

@end
