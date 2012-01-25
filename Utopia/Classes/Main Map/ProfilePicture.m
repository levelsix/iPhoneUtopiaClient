//
//  ProfilePicture.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/4/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ProfilePicture.h"
#import "GameState.h"
#import "MaskedSprite.h"
#import "QuestLogController.h"
#import "ArmoryViewController.h"

#define DELAY_BETWEEN_BUTTONS 0.03
#define TOTAL_ROTATION_ANGLE 1080
#define START_ANGLE -20.f
#define TOTAL_ANGLE -85.f
#define BUTTON_DISTANCE 46.f

@implementation ExperienceCircle

@synthesize expPercentage = _expPercentage;
@synthesize level = _level;

+ (id) circle {
  return [[[self alloc] initCircle] autorelease];
}

- (id) initCircle {
  if ((self = [super initWithFile:@"expring.png"])) {
    _expBar = [CCProgressTimer progressWithFile:@"expringover.png"];
    _expBar.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    _expBar.type = kCCProgressTimerTypeRadialCW;
    _expBar.percentage = 1;
    [self addChild:_expBar];
    
    _levelCircle = [CCSprite spriteWithFile:@"levelnumberbg.png"];
    _levelCircle.position = ccp(21.5, 25.5);
    [self addChild:_levelCircle];
    
    _levelLabel = [CCLabelTTF labelWithString:@"" fontName:[GameState font] fontSize:12];
    _levelLabel.position = ccp(_levelCircle.contentSize.width/2, _levelCircle.contentSize.height/2);
    [_levelCircle addChild:_levelLabel];
    
    self.level = 1;
    self.expPercentage = 0;
  }
  
  return self;
}

- (void) setRotation:(float)rotation {
  _levelCircle.rotation = -rotation;
  _expBar.rotation = -rotation;
  [super setRotation:rotation];
}

- (void) setExpPercentage:(float)perc {
  perc = clampf(perc, 0, 100);
  _expBar.percentage = perc;
  _expPercentage = perc;
}

- (void) setLevel:(int)level {
  [_levelLabel setString:[NSString stringWithFormat:@"%d", level]];
  _level = level;
}

@end

@implementation ProfilePicture 

+ (id) profileWithType: (UserType) type {
  return [[[self alloc] initWithType: type] autorelease];
}

- (id) initWithType:(UserType)type {
  if ((self = [super initWithFile:@"healthcenter.png"])) {
    _inAction = NO;
    _menuOut = NO;
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    
    _expCircle = [ExperienceCircle circle];
    [self addChild:_expCircle z:2];
    _expCircle.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    
    CCSprite *health = [CCSprite spriteWithFile:@"healthgreen.png"];
    CCSprite *mask = [CCSprite spriteWithFile:@"healthmask.png"];
    _healthBar = [[MaskedHealth alloc] initHealthWithFile:health andMask:mask];
    _healthBar.percentage = 30;
    CCSprite *s = [_healthBar updateSprite];
    [self addChild:s z:0 tag:1];
    s.position = ccp(s.contentSize.width/2, s.contentSize.height/2);
    
    _menuItems = [[[NSMutableArray alloc] init] retain];
    
    CCMenuItemImage *button1 = [CCMenuItemImage itemFromNormalImage:@"circleButton.png" selectedImage:nil target:self selector:@selector(buttonClicked:)];
    button1.visible = NO;
    [_menuItems addObject:button1];
    
    CCMenuItemImage *button2 = [CCMenuItemImage itemFromNormalImage:@"circleButton.png" selectedImage:nil target:self selector:@selector(buttonClicked:)];
    button2.visible = NO;
    [_menuItems addObject:button2];
    
    CCMenuItemImage *button3 = [CCMenuItemImage itemFromNormalImage:@"circleButton.png" selectedImage:nil target:self selector:@selector(buttonClicked:)];
    button3.visible = NO;
    [_menuItems addObject:button3];
    
    CCMenuItemImage *button4 = [CCMenuItemImage itemFromNormalImage:@"circleButton.png" selectedImage:nil target:self selector:@selector(buttonClicked:)];
    button4.visible = NO;
    [_menuItems addObject:button4];
    
    CCMenu *menu = [CCMenu menuWithItems:button1, button2, button3, button4, nil];
    menu.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    
    [self addChild:menu z:-1];
    
//    CCSprite *charImage = [CCSprite spriteWithFile:@"dude.png"];
//    charImage.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
//    [self addChild:charImage z:1];
    
    [self schedule:@selector(update)];
  }
  return self;
}

- (void) update {
  _expCircle.expPercentage += 1;
  
  if (_expCircle.expPercentage >= 100) {
    _expCircle.level += 1;
    _expCircle.expPercentage = 0;
  }
  
  [self removeChildByTag:1 cleanup:YES];
  
  [_healthBar flow];
  CCSprite *s = [_healthBar updateSprite];
  [self addChild:s z:0 tag:1];
  s.position = ccp(s.contentSize.width/2, s.contentSize.height/2);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint pt = [_expCircle convertTouchToNodeSpace:touch];
  if (!CGRectContainsPoint(CGRectMake(0, 0, _expCircle.contentSize.width, _expCircle.contentSize.height), pt)) {
    if (!_inAction && _menuOut) {
      [self popInButtons];
    }
    return NO;
  }
  
  return YES;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint pt = [_expCircle convertTouchToNodeSpace:touch];
  
  if (_inAction)
    return;
  
  if (!CGRectContainsPoint(CGRectMake(0, 0, _expCircle.contentSize.width, _expCircle.contentSize.height), pt)) {
    if (_menuOut) {
      [self popInButtons];
    }
    return;
  }
  
  if (_menuOut) {
    [self popInButtons];
  } else {
    [self popOutButtons];
  }
}

- (void) popOutButtons {
  
  _inAction = YES;
  _menuOut = YES;
  
  [_expCircle runAction: [CCRotateBy actionWithDuration:0.2 angle:90]];
  
  // Move out right to bottom 
  float step = TOTAL_ANGLE/([_menuItems count]-1);
  float dist = self.contentSize.height/2 + BUTTON_DISTANCE;
  
  // Save the duration of the last action
  float dur;
  
  // Use this so that we can have buttons relative to center point
  for (int i = 0; i < [_menuItems count]; i++) {
    float degree = CC_DEGREES_TO_RADIANS(START_ANGLE + i * step);
    CCMenuItemImage *button = [_menuItems objectAtIndex:[_menuItems count]-i-1];
    [button stopAllActions];
    CGPoint pt = ccp(dist*cosf(degree), dist*sinf(degree));
    
    button.scale = 1;
    button.position = ccp(0,0);
    button.opacity = 255;
    
    CCFiniteTimeAction *bounceAction = [CCSequence actions:[CCDelayTime actionWithDuration:i*DELAY_BETWEEN_BUTTONS], [CCEaseBackOut actionWithAction:[CCMoveBy actionWithDuration:0.2 position:pt]], nil];
//    CCFiniteTimeAction *bounceAction = [CCEaseSineOut actionWithAction:
//                                        [CCSequence actions: 
//                                         [CCMoveBy actionWithDuration:0.2 position:ccpMult(pt, 1.2)], 
//                                         [CCMoveBy actionWithDuration:0.02 position:ccpMult(pt, -0.2)], 
//                                         nil]];
    CCFiniteTimeAction *fullAction = [CCSpawn actions:bounceAction, 
                                       [CCRotateTo actionWithDuration:[bounceAction duration]/1.5 angle:TOTAL_ROTATION_ANGLE], 
                                       nil];
    [button runAction:fullAction];
    
    dur = [fullAction duration];
    
    button.visible = YES;
  }
  
  [self runAction:
   [CCSequence actions:
    [CCDelayTime actionWithDuration:dur], 
    [CCCallFunc actionWithTarget:self selector:@selector(enableButton)], nil]];
}

- (void) popInButtons {
  _inAction = YES;
  _menuOut = NO;
  
  float dur; 
  
  [_expCircle runAction: [CCRotateBy actionWithDuration:0.2 angle:-90]];
  
  // Use this so that we can have buttons relative to center point
  for (int i = 0; i < [_menuItems count]; i++) {
    CCMenuItem *button = [_menuItems objectAtIndex:i];
    [button stopAllActions];
    
    CCFiniteTimeAction *bounceAction = [CCSequence actions:[CCDelayTime actionWithDuration:i*DELAY_BETWEEN_BUTTONS], [CCEaseBackIn actionWithAction:[CCMoveTo actionWithDuration:0.2 position:ccp(0,0)]], nil];
    
//    CGPoint pt = button.position;
//    CCFiniteTimeAction *bounceAction = [CCEaseSineIn actionWithAction:
//                                        [CCSequence actions: 
//                                         [CCMoveBy actionWithDuration:0.02 position:ccpMult(pt, 0.2)], 
//                                         [CCMoveBy actionWithDuration:0.2 position:ccpMult(pt, -1.2)], 
//                                         nil]];
    
    CCFiniteTimeAction *fullAction = [CCSequence actions:
                                      [CCSpawn actions:bounceAction, 
                                       [CCRotateBy actionWithDuration:[bounceAction duration] angle:-TOTAL_ROTATION_ANGLE], 
                                       nil], 
                                      [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)], nil];
    
    [button runAction:fullAction];
    
    dur = [fullAction duration];
  }
  
  [self runAction: [CCSequence actions:
                    [CCDelayTime actionWithDuration:dur], 
                    [CCCallFunc actionWithTarget:self selector:@selector(enableButton)],
                    [CCCallFunc actionWithTarget:self selector:@selector(openArmory)], nil]];
}

- (void) buttonClicked: (CCMenuItem *) clickedButton {
  if (_inAction || !_menuOut) {
    return;
  }
  
  [_expCircle runAction: [CCRotateBy actionWithDuration:0.2 angle:-90]];
  
  _inAction = YES;
  _menuOut = NO;
  
  [clickedButton runAction:[CCSequence actions:
                            [CCSpawn actions:
                             [CCFadeTo actionWithDuration:0.3 opacity:0],
                             [CCScaleTo actionWithDuration:0.3 scale:2]
                             , nil],
                            [CCCallFunc actionWithTarget:self selector:@selector(enableButton)],
                            [CCCallFunc actionWithTarget:self selector:@selector(openQuestLog)],
                            [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                            nil]];
  
  for (CCMenuItem *button in _menuItems) {
    if (button != clickedButton) {
      [button runAction:[CCSequence actions:
                         [CCSpawn actions:
                          [CCFadeTo actionWithDuration:0.3 opacity:0],
                          [CCScaleTo actionWithDuration:0.3 scale:0.4]
                          , nil],
                         [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                         nil]];
    }
  }
}

- (void) openQuestLog {
  [QuestLogController displayView];
}

- (void) openArmory {
  [ArmoryViewController displayView];
}

- (void) enableButton {
  _inAction = NO;
}

- (void) setInvisible: (CCMenuItem *) sender {
  sender.visible = NO;
}

- (void) dealloc {
  [_menuItems release];
  [_healthBar release];
  [super dealloc];
}

@end