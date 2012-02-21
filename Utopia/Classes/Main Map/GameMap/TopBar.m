








































































































































































































































































































































//
//  TopBar.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/20/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TopBar.h"
#import "Globals.h"
#import "GoldShoppeViewController.h"
#import "GameState.h"

@implementation TopBar

- (id) init {
  if ((self = [super init])) {
    _enstBgd = [CCSprite spriteWithFile:@"enstbg.png"];
    [self addChild:_enstBgd z:2];
    _enstBgd.position = ccp(190, self.contentSize.height+_enstBgd.contentSize.height/2);
    _enstBgd.visible = YES;
    
    // Make the progress bars and place them on top of the background image
    CCSprite *staminaBar = [CCSprite spriteWithFile:@"stambar.png"];
    CCSprite *topBarMask = [CCSprite spriteWithFile:@"barmask.png"];
    // For some reason, the name energybar.png DOES NOT WORK!! why??
    CCSprite *energyBar = [CCSprite spriteWithFile:@"engybar.png"];
    _energyBar = [[MaskedBar maskedBarWithFile:energyBar andMask:topBarMask] retain];
    _staminaBar = [[MaskedBar maskedBarWithFile:staminaBar andMask:topBarMask] retain];
    _energyBar.percentage = 0;
    _staminaBar.percentage = 0;
    
    // Just add the sprites so it doesnt complain when we try to remove to update
    // Must set them to invisible or they end up showing up for a split second in the wrong position
    CCSprite *e = [_energyBar updateSprite];
    e.visible = NO;
    [_enstBgd addChild:e z:1 tag:1];
    CCSprite *s = [_staminaBar updateSprite];
    s.visible = NO;
    [_enstBgd addChild:s z:1 tag:2];
    
    // TODO: DONT HARDCODE THESE VALUES
    _coinBar = [CCSprite spriteWithFile:@"coinbar.png"];
    [self addChild:_coinBar z:2];
    _coinBar.position = ccp(370, self.contentSize.height+_coinBar.contentSize.height/2);
    
    NSString *fontName = [Globals font];
    _silverLabel = [CCLabelTTF labelWithString:@"2,000,000" fontName:fontName fontSize:12];
    [_coinBar addChild:_silverLabel];
    _silverLabel.color = ccc3(212,210,199);
    _silverLabel.position = ccp(55, 15);
    
    _goldLabel = [CCLabelTTF labelWithString:@"30" fontName:fontName fontSize:12];
    [_coinBar addChild:_goldLabel];
    _goldLabel.color = ccc3(212,210,199);
    _goldLabel.position = ccp(125, 15);
    
    _goldButton = [CCSprite spriteWithFile:@"plus.png"];
    [_coinBar addChild:_goldButton z:-1];
    CGPoint finalgoldButtonPos = ccp(155, _goldButton.contentSize.height/2+2);
    _goldButton.position = ccp(100, _goldButton.contentSize.height/2);
    [_goldButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1], [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:1.5 position:finalgoldButtonPos]], nil]];
    
    // Drop the bars down
    [_enstBgd runAction:[CCEaseBounceOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, -_enstBgd.contentSize.height)]]];
    [_coinBar runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2], [CCEaseBounceOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, -_coinBar.contentSize.height)]], nil]];
    
    _profilePic = [ProfilePicture profileWithType:UserTypeBadMage];
    [self addChild:_profilePic z:2];
    _profilePic.position = ccp(45, self.contentSize.height-45);
    
    // At this point, the bars are still above the screen so subtract 3/2 * width
    _enstBarRect = CGRectMake(_enstBgd.position.x-_enstBgd.contentSize.width/2, _enstBgd.position.y-3*_enstBgd.contentSize.height/2, _enstBgd.contentSize.width, _enstBgd.contentSize.height);
    // For coin bar remember to add in the gold button at the right side. Right most x of gold
    // button will suffice since it is a child of the coin bar.
    int rightMostX = finalgoldButtonPos.x+_goldButton.contentSize.width/2;
    _coinBarRect = CGRectMake(_coinBar.position.x-_coinBar.contentSize.width/2, _coinBar.position.y-3*_coinBar.contentSize.height/2, rightMostX, _coinBar.contentSize.height);
    
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    _trackingEnstBar = NO;
    _trackingCoinBar = NO;
    
    [self schedule:@selector(update)];
  }
  return self;
}

- (void) enstBarClicked {
  //Do something here
}

- (void) coinBarClicked {
  [GoldShoppeViewController displayView];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint pt = [self convertTouchToNodeSpace:touch];
  
  if (CGRectContainsPoint(_enstBarRect, pt)) {
    _trackingEnstBar = YES;
    return YES;
  } else if (CGRectContainsPoint(_coinBarRect, pt)){
    _trackingCoinBar = YES;
    return YES;
  }
  return NO;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
  // No need to include profile pic because it takes care of itself
  CGPoint pt = [self convertTouchToNodeSpace:touch];
  if (_trackingEnstBar && CGRectContainsPoint(_enstBarRect, pt)) {
    [self enstBarClicked];
  } else if (_trackingCoinBar && CGRectContainsPoint(_coinBarRect, pt)) {
    [self coinBarClicked];
  }
  _trackingEnstBar = NO;
  _trackingCoinBar = NO;
}

- (BOOL) isPointInArea:(CGPoint)pt {
  pt = [self convertToNodeSpace:pt];
  return CGRectContainsPoint(_enstBarRect, pt) && CGRectContainsPoint(_coinBarRect, pt);
}

- (void) setEnergyBarPercentage:(float)perc {
  if (perc != _energyBar.percentage) {
    [_enstBgd removeChildByTag:1 cleanup:YES];
    _energyBar.percentage = perc;
    CCSprite *e = [_energyBar updateSprite];
    [_enstBgd addChild:e z:1 tag:1];
    e.position = ccp(53,15);
  }
}

- (void) setStaminaBarPercentage:(float)perc {
  if (perc != _staminaBar.percentage) {
    [_enstBgd removeChildByTag:2 cleanup:YES];
    _staminaBar.percentage = perc;
    CCSprite *s = [_staminaBar updateSprite];
    [_enstBgd addChild:s z:1 tag:2];
    s.position = ccp(149,15);
  }
}

- (void) update {
  GameState *gs = [GameState sharedGameState];
  _silverLabel.string = [Globals commafyNumber:gs.silver];
  _goldLabel.string = [Globals commafyNumber:gs.gold];
  [self setEnergyBarPercentage:gs.currentEnergy/((float)gs.maxEnergy)];
  [self setStaminaBarPercentage:gs.currentStamina/((float)gs.maxStamina)];
  [_profilePic setExpPercentage:gs.experience/100.f];
  [_profilePic setLevel:gs.level];
}

@end
