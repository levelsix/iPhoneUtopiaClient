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
#import "RefillMenuController.h"
#import "OutgoingEventController.h"
#import "SynthesizeSingleton.h"

#define FADE_ANIMATION_DURATION 0.2f

@implementation ToolTip

- (void) setOpacity:(GLubyte)opacity {
  [super setOpacity:opacity];
  for (CCSprite *spr in self.children) {
    spr.opacity = opacity;
    // To account for fill button's children
    for (CCSprite *spr2 in spr.children) {
      spr2.opacity = opacity;
      for (CCSprite *spr3 in spr2.children) {
        spr3.opacity = opacity;
        for (CCSprite *spr4 in spr3.children) {
          spr4.opacity = opacity;
        }
      }
    }
  }
}

@end

@implementation TopBar

SYNTHESIZE_SINGLETON_FOR_CLASS(TopBar);

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
    _goldLabel.position = ccp(127, 15);
    
    _goldButton = [CCSprite spriteWithFile:@"plus.png"];
    [_coinBar addChild:_goldButton z:-1];
    CGPoint finalgoldButtonPos = ccp(155, _goldButton.contentSize.height/2+2);
    _goldButton.position = ccp(100, _goldButton.contentSize.height/2);
    [_goldButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1], [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:1.5 position:finalgoldButtonPos]], nil]];
    
    // Adjust the labels
    [Globals adjustFontSizeForSize:12 CCLabelTTFs:_silverLabel, _goldLabel, nil];
    
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
    
    _bigToolTip = [ToolTip spriteWithFile:@"quantleftwithtimer.png"];
    [_enstBgd addChild:_bigToolTip z:2];
    
    int fontSize = 12;
    _bigCurValLabel = [CCLabelTTF labelWithString:@"" fontName:[Globals font] fontSize:fontSize];
    _bigCurValLabel.position = ccp(_bigToolTip.contentSize.width/2, 47);
    [_bigToolTip addChild:_bigCurValLabel];
    [Globals adjustFontSizeForCCLabelTTF:_bigCurValLabel size:fontSize];
    
    fontSize = 8;
    _bigTimerLabel = [CCLabelTTF labelWithString:@"+1 in 2:31" fontName:[Globals font] fontSize:fontSize];
    _bigTimerLabel.position = ccp(_bigToolTip.contentSize.width/2, 34);
    _bigTimerLabel.color = ccc3(120, 120, 120);
    [_bigToolTip addChild:_bigTimerLabel];
    [Globals adjustFontSizeForCCLabelTTF:_bigTimerLabel size:fontSize];
    
    CCSprite *fillButtonSprite = [ToolTip spriteWithFile:@"fillbutton.png"];
    CCMenuItemSprite *fillButton = [CCMenuItemSprite itemFromNormalSprite:fillButtonSprite selectedSprite:nil target:self selector:@selector(fillClicked)];
    
    CCMenu *menu = [CCMenu menuWithItems:fillButton,nil];
    [_bigToolTip addChild:menu];
    menu.position = ccp(_bigToolTip.contentSize.width/2, 15.f);
    
    CCSprite *coin = [CCSprite spriteWithFile:@"goldcoin.png"];
    coin.scale = 0.8;
    coin.position = ccp(9, fillButton.contentSize.height/2+1);
    [fillButton addChild:coin];
    
    fontSize = 8;
    _bigGoldCostLabel = [CCLabelTTF labelWithString:@"12" fontName:[Globals font] fontSize:fontSize];
    _bigGoldCostLabel.anchorPoint = ccp(0, 0.5);
    _bigGoldCostLabel.position = ccp(16, fillButton.contentSize.height/2+1);
    [fillButton addChild:_bigGoldCostLabel];
    _bigGoldCostLabelShadow = [CCLabelTTF labelWithString:@"12" fontName:[Globals font] fontSize:fontSize];
    _bigGoldCostLabelShadow.color = ccc3(100, 60, 0);
    _bigGoldCostLabelShadow.position = ccp(_bigGoldCostLabel.contentSize.width/2+1, _bigGoldCostLabel.contentSize.height/2-1);
    [_bigGoldCostLabel addChild:_bigGoldCostLabelShadow z:-1];
    
    CCLabelTTF *fillLabel = [CCLabelTTF labelWithString:@"FILL" fontName:[Globals font] fontSize:fontSize];
    fillLabel.anchorPoint = ccp(1, 0.5);
    fillLabel.position = ccp(fillButton.contentSize.width-5.f, fillButton.contentSize.height/2+1);
    [fillButton addChild:fillLabel];
    CCLabelTTF *fillLabelShadow = [CCLabelTTF labelWithString:@"FILL" fontName:[Globals font] fontSize:fontSize];
    fillLabelShadow.color = ccc3(100, 60, 0);
    fillLabelShadow.position = ccp(fillLabel.contentSize.width/2+1, fillLabel.contentSize.height/2-1);
    [fillLabel addChild:fillLabelShadow z:-1];
    
    [Globals adjustFontSizeForSize:fontSize CCLabelTTFs:_bigGoldCostLabel, fillLabel, nil];
    
    _littleToolTip = [ToolTip spriteWithFile:@"quantleftclick.png"];
    [_enstBgd addChild:_littleToolTip z:2];
    
    fontSize = 12;
    _littleCurValLabel = [CCLabelTTF labelWithString:@"" fontName:[Globals font] fontSize:fontSize];
    _littleCurValLabel.position = ccp(_bigToolTip.contentSize.width/2, 10);
    [_littleToolTip addChild:_littleCurValLabel];
    [Globals adjustFontSizeForCCLabelTTF:_littleCurValLabel size:fontSize];
    
    _bigToolTip.visible = NO;
    _littleToolTip.visible = NO;
    
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    _trackingEnstBar = NO;
    _trackingCoinBar = NO;
    
    [self schedule:@selector(update)];
    
//    [self setUpEnergyTimer];
//    [self setUpStaminaTimer];
  }
  return self;
}

- (void) fillClicked {
  if (_bigToolTipState == kEnergy) {
    [[OutgoingEventController sharedOutgoingEventController] refillEnergyWithDiamonds];
  } else if (_bigToolTipState == kStamina) {
    [[OutgoingEventController sharedOutgoingEventController] refillStaminaWithDiamonds];
  }
}

- (void) setUpEnergyTimer {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  // Invalidate old timer
  [_energyTimer invalidate];
  
  if (!gs.connected) {
    return;
  }
  
  // Only fire timers if it is less than the current time
  if (gs.currentEnergy < gs.maxEnergy) {
    NSTimeInterval energyComplete = gs.lastEnergyRefill.timeIntervalSinceNow+60*gl.energyRefillWaitMinutes;
    _energyTimer = [NSTimer timerWithTimeInterval:energyComplete target:self selector:@selector(energyRefillWaitComplete) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_energyTimer forMode:NSRunLoopCommonModes];
    NSLog(@"Firing up energy timer with time %f..", energyComplete);
  } else {
    NSLog(@"Reached max energy..");
    _energyTimer = nil;
  }
  
  if (_bigToolTipState == kEnergy) {
    [_toolTipTimerDate release];
    _toolTipTimerDate = [[gs.lastEnergyRefill dateByAddingTimeInterval:gl.energyRefillWaitMinutes*60] retain];
  }
}

- (void) setUpStaminaTimer {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  // Invalidate old timer
  [_staminaTimer invalidate];
  
  if (!gs.connected) {
    return;
  }
  
  if (gs.currentStamina < gs.maxStamina) {
    NSTimeInterval staminaComplete = gs.lastStaminaRefill.timeIntervalSinceNow+60*gl.staminaRefillWaitMinutes;
    _staminaTimer = [NSTimer timerWithTimeInterval:staminaComplete target:self selector:@selector(staminaRefillWaitComplete) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_staminaTimer forMode:NSRunLoopCommonModes];
    NSLog(@"Firing up stamina timer with time %f..", staminaComplete);
  } else {
    NSLog(@"Reached max stamina..");
    _staminaTimer = nil;
  }
  
  if (_bigToolTipState == kStamina) {
    [_toolTipTimerDate release];
    _toolTipTimerDate = [[gs.lastStaminaRefill dateByAddingTimeInterval:gl.staminaRefillWaitMinutes*60] retain];
  }
}

- (void) energyRefillWaitComplete {
  [[OutgoingEventController sharedOutgoingEventController] refillEnergyWaitComplete];
  [self setUpEnergyTimer];
}

- (void) staminaRefillWaitComplete {
  [[OutgoingEventController sharedOutgoingEventController] refillStaminaWaitComplete];
  [self setUpStaminaTimer];
}

- (void) fadeInBigToolTip:(BOOL)isEnergy {
  if (_bigToolTipState == kNotShowing) {
    [_bigToolTip runAction:[CCFadeIn actionWithDuration:FADE_ANIMATION_DURATION]];
  }
  _bigToolTip.visible = YES;
  _bigToolTipState = isEnergy ? kEnergy : kStamina;
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (isEnergy) {
    _toolTipTimerDate = [[gs.lastEnergyRefill dateByAddingTimeInterval:gl.energyRefillWaitMinutes*60] retain];
    _bigGoldCostLabel.string = [NSString stringWithFormat:@"%d", gl.energyRefillCost];
    _bigGoldCostLabelShadow.string = [NSString stringWithFormat:@"%d", gl.energyRefillCost];
  } else {
    _toolTipTimerDate = [[gs.lastStaminaRefill dateByAddingTimeInterval:gl.staminaRefillWaitMinutes*60] retain];
    _bigGoldCostLabel.string = [NSString stringWithFormat:@"%d", gl.staminaRefillCost];
    _bigGoldCostLabelShadow.string = [NSString stringWithFormat:@"%d", gl.staminaRefillCost];
  }
}

- (void) fadeInLittleToolTip:(BOOL)isEnergy {
  if (_littleToolTipState == kNotShowing) {
    [_littleToolTip runAction:[CCFadeIn actionWithDuration:FADE_ANIMATION_DURATION]];
  }
  _littleToolTip.visible = YES;
  _littleToolTipState = isEnergy ? kEnergy : kStamina;
}

- (void) fadeOutToolTip:(BOOL)big {
  CCNode *toolTip = big ? _bigToolTip : _littleToolTip;
  
  if (toolTip.visible) {
    [toolTip runAction:[CCSequence actions:
                        [CCFadeOut actionWithDuration:FADE_ANIMATION_DURATION],
                        [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)], nil]];
  }
}

- (void) setInvisible:(CCNode *)sender {
  sender.visible = NO;
  [_toolTipTimerDate release];
  _toolTipTimerDate = nil;
  
  if (sender == _bigToolTip) {
    _bigToolTipState = kNotShowing;
  } else if (sender == _littleToolTip) {
    _littleToolTipState = kNotShowing;
  } else {
    NSLog(@"ERROR IN TOOL TIPS!!!");
  }
}

- (void) energyBarClicked {
  GameState *gs = [GameState sharedGameState];
  if (gs.currentEnergy >= gs.maxEnergy) {
    if (_bigToolTipState != kNotShowing) {
      [self fadeOutToolTip:YES];
    }
    [self fadeInLittleToolTip:YES];
  } else {
    if (_littleToolTipState != kNotShowing) {
      [self fadeOutToolTip:NO];
    }
    [self fadeInBigToolTip:YES];
  }
}

- (void) staminaBarClicked {
  GameState *gs = [GameState sharedGameState];
  if (gs.currentStamina >= gs.maxStamina) {
    if (_bigToolTipState != kNotShowing) {
      [self fadeOutToolTip:YES];
    }
    [self fadeInLittleToolTip:NO];
  } else {
    if (_littleToolTipState != kNotShowing) {
      [self fadeOutToolTip:NO];
    }
    [self fadeInBigToolTip:NO];
  }
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
  } else {
    if (_bigToolTipState != kNotShowing) {
      [self fadeOutToolTip:YES];
    }
    if (_littleToolTipState != kNotShowing) {
      [self fadeOutToolTip:NO];
    }
  }
  return NO;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
  // No need to include profile pic because it takes care of itself
  CGPoint pt = [self convertTouchToNodeSpace:touch];
  
  CGRect enBar = _enstBarRect, stamBar = _enstBarRect;
  enBar.size.width /= 2;
  stamBar.size.width /= 2;
  stamBar.origin.x += stamBar.size.width;
  
  if (_trackingEnstBar && CGRectContainsPoint(enBar, pt)) {
    [self energyBarClicked];
  } else if (_trackingEnstBar && CGRectContainsPoint(stamBar, pt)) {
    [self staminaBarClicked];
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
    [_enstBgd removeChild:_curEnergyBar cleanup:YES];
    _energyBar.percentage = perc;
    _curEnergyBar = [_energyBar updateSprite];
    [_enstBgd addChild:_curEnergyBar z:1 tag:1];
    _curEnergyBar.position = ccp(53,15);
  }
}

- (void) setStaminaBarPercentage:(float)perc {
  if (perc != _staminaBar.percentage) {
    [_enstBgd removeChild:_curStaminaBar cleanup:YES];
    _staminaBar.percentage = perc;
    _curStaminaBar = [_staminaBar updateSprite];
    [_enstBgd addChild:_curStaminaBar z:1 tag:2];
    _curStaminaBar.position = ccp(149,15);
  }
}

- (void) update {
  GameState *gs = [GameState sharedGameState];
  _silverLabel.string = [Globals commafyNumber:gs.silver];
  _goldLabel.string = [Globals commafyNumber:gs.gold];
  [self setEnergyBarPercentage:gs.currentEnergy/((float)gs.maxEnergy)];
  [self setStaminaBarPercentage:gs.currentStamina/((float)gs.maxStamina)];
  [_profilePic setExpPercentage:(gs.experience-gs.expRequiredForCurrentLevel)/(float)(gs.expRequiredForNextLevel-gs.expRequiredForCurrentLevel)];
  [_profilePic setLevel:gs.level];
  
  if (_bigToolTipState == kEnergy) {
    _bigToolTip.position = ccp((_curEnergyBar.position.x-_curEnergyBar.contentSize.width/2)+_curEnergyBar.contentSize.width*_energyBar.percentage, _curEnergyBar.position.y-_curEnergyBar.contentSize.height/2-_bigToolTip.contentSize.height/2);
    _bigCurValLabel.string = [NSString stringWithFormat:@"%d/%d", gs.currentEnergy, gs.maxEnergy];
    if (gs.currentEnergy >= gs.maxEnergy) {
      [self fadeOutToolTip:YES];
    } else {
      int time = [_toolTipTimerDate timeIntervalSinceDate:[NSDate date]];
      _bigTimerLabel.string = [NSString stringWithFormat:@"+1 in %01d:%02d", time/60, time%60];
    }
  } else if (_bigToolTipState == kStamina) { 
    _bigCurValLabel.string = [NSString stringWithFormat:@"%d/%d", gs.currentStamina, gs.maxStamina];
    if (gs.currentStamina >= gs.maxStamina) {
      [self fadeOutToolTip:YES];
    } else {
      int time = [_toolTipTimerDate timeIntervalSinceDate:[NSDate date]];
      _bigTimerLabel.string = [NSString stringWithFormat:@"+1 in %01d:%02d", time/60, time%60];
    }
  }
  
  if (_littleToolTipState == kEnergy) {
    _littleToolTip.position = ccp((_curEnergyBar.position.x-_curEnergyBar.contentSize.width/2)+_curEnergyBar.contentSize.width*_energyBar.percentage, _curEnergyBar.position.y-_curEnergyBar.contentSize.height/2-_littleToolTip.contentSize.height/2);
    _littleCurValLabel.string = [NSString stringWithFormat:@"%d/%d", gs.currentEnergy, gs.maxEnergy];
  } else if (_littleToolTipState == kStamina) {
    _littleToolTip.position = ccp((_curStaminaBar.position.x-_curStaminaBar.contentSize.width/2)+_curStaminaBar.contentSize.width*_staminaBar.percentage, _curStaminaBar.position.y-_curStaminaBar.contentSize.height/2-_littleToolTip.contentSize.height/2);
    _littleCurValLabel.string = [NSString stringWithFormat:@"%d/%d", gs.currentStamina, gs.maxStamina];
  }
  
  if (gs.connected) {
    if (gs.experience >= gs.expRequiredForNextLevel) {
      [[OutgoingEventController sharedOutgoingEventController] levelUp];
    }
    // Check if timers need to be instantiated
//    if (!_energyTimer && gs.currentEnergy < gs.maxEnergy) {
//      [self setUpEnergyTimer];
//    }
//    if (!_staminaTimer && gs.currentStamina < gs.maxStamina) {
//      [self setUpStaminaTimer];
//    }
  }
}

@end
