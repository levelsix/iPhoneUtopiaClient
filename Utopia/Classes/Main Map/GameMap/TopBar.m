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
#import "LNSynthesizeSingleton.h"
#import "GameLayer.h"
#import "GameMap.h"
#import "HomeMap.h"
#import "MapViewController.h"
#import "QuestLogController.h"
#import "ActivityFeedController.h"
#import "GameViewController.h"
#import "AttackMenuController.h"
#import "Crittercism.h"
#import "LeaderboardController.h"
#import "TutorialQuestLogController.h"
#import "ChatMenuController.h"
#import "ClanMenuController.h"

#define CHART_BOOST_APP_ID @"500674d49c890d7455000005"
#define CHART_BOOST_APP_SIGNATURE @"061147e1537ade60161207c29179ec95bece5f9c"


#define FADE_ANIMATION_DURATION 0.2f

#define ENERGY_BAR_POSITION ccp(53,15)
#define STAMINA_BAR_POSITION ccp(149,15)

#define BOTTOM_BUTTON_OFFSET 2

#define TOOL_TIP_SHADOW_OPACITY 80

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
          spr4.opacity = opacity/255.f*TOOL_TIP_SHADOW_OPACITY;
        }
      }
    }
  }
}

@end

@implementation TopBar

SYNTHESIZE_SINGLETON_FOR_CLASS(TopBar);

@synthesize profilePic = _profilePic;
@synthesize energyTimer = _energyTimer;
@synthesize staminaTimer = _staminaTimer;
@synthesize isStarted;
@synthesize dbmc;
@synthesize inGameNotification, chatBottomView;

- (id) init {
  if ((self = [super init])) {
    _enstBgd = [CCSprite spriteWithFile:@"enstbg.png"];
    [self addChild:_enstBgd z:2];
    _enstBgd.position = ccp(197, self.contentSize.height+_enstBgd.contentSize.height/2);
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
    _coinBar.position = ccp(373, self.contentSize.height+_coinBar.contentSize.height/2);
    
    NSString *fontName = [Globals font];
    _silverLabel = [CCLabelTTF labelWithString:@"0" fontName:fontName fontSize:12];
    [_coinBar addChild:_silverLabel];
    _silverLabel.color = ccc3(212,210,199);
    _silverLabel.position = ccp(55, 16);
    
    _goldLabel = [CCLabelTTF labelWithString:@"0" fontName:fontName fontSize:12];
    [_coinBar addChild:_goldLabel];
    _goldLabel.color = ccc3(212,210,199);
    _goldLabel.position = ccp(127, 16);
    
    _goldButton = [CCSprite spriteWithFile:@"plus.png"];
    [_coinBar addChild:_goldButton z:-1];
    CGPoint finalgoldButtonPos = ccp(155, _goldButton.contentSize.height/2+2);
    _goldButton.position = ccp(100, _goldButton.contentSize.height/2);
    [_goldButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1], [CCEaseExponentialOut actionWithAction:[CCMoveTo actionWithDuration:1.5 position:finalgoldButtonPos]], nil]];
    
    // Adjust the labels
    [Globals adjustFontSizeForSize:12 CCLabelTTFs:_silverLabel, _goldLabel, nil];
    
    
    GameState *gs = [GameState sharedGameState];
    self.profilePic = [ProfilePicture profileWithType:gs.type];
    [self addChild:_profilePic z:2];
    _profilePic.position = ccp(50, self.contentSize.height-50);
    
    // At this point, the bars are still above the screen so subtract 3/2 * width
    _enstBarRect = CGRectMake(_enstBgd.position.x-_enstBgd.contentSize.width/2, _enstBgd.position.y-3*_enstBgd.contentSize.height/2, _enstBgd.contentSize.width, _enstBgd.contentSize.height);
    // For coin bar remember to add in the gold button at the right side. Right most x of gold
    // button will suffice since it is a child of the coin bar.
    int rightMostX = finalgoldButtonPos.x+_goldButton.contentSize.width/2;
    _coinBarRect = CGRectMake(_coinBar.position.x-_coinBar.contentSize.width/2, _coinBar.position.y-3*_coinBar.contentSize.height/2, rightMostX, _coinBar.contentSize.height);
    
    _bigToolTip = [ToolTip spriteWithFile:@"quantleftwithtimer.png"];
    [_enstBgd addChild:_bigToolTip z:2];
    
    int fontSize = 12;
    _bigCurValLabel = [CCLabelTTF labelWithString:@"0" fontName:[Globals font] fontSize:fontSize];
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
    coin.scale = 0.4;
    coin.position = ccp(9, fillButton.contentSize.height/2+1);
    [fillButton addChild:coin];
    
    fontSize = 8;
    _bigGoldCostLabel = [CCLabelTTF labelWithString:@"12" fontName:[Globals font] fontSize:fontSize];
    _bigGoldCostLabel.anchorPoint = ccp(0, 0.5);
    _bigGoldCostLabel.position = ccp(16, fillButton.contentSize.height/2+1);
    [fillButton addChild:_bigGoldCostLabel];
    _bigGoldCostLabelShadow = [CCLabelTTF labelWithString:@"12" fontName:[Globals font] fontSize:fontSize];
    _bigGoldCostLabelShadow.color = ccc3(0, 0, 0);
    _bigGoldCostLabelShadow.opacity = TOOL_TIP_SHADOW_OPACITY;
    _bigGoldCostLabelShadow.position = ccp(_bigGoldCostLabel.contentSize.width/2, _bigGoldCostLabel.contentSize.height/2-1);
    [_bigGoldCostLabel addChild:_bigGoldCostLabelShadow z:-1];
    
    CCLabelTTF *fillLabel = [CCLabelTTF labelWithString:@"FILL" fontName:[Globals font] fontSize:fontSize];
    fillLabel.anchorPoint = ccp(1, 0.5);
    fillLabel.position = ccp(fillButton.contentSize.width-5.f, fillButton.contentSize.height/2+1);
    [fillButton addChild:fillLabel];
    CCLabelTTF *fillLabelShadow = [CCLabelTTF labelWithString:@"FILL" fontName:[Globals font] fontSize:fontSize];
    fillLabelShadow.color = ccc3(0, 0, 0);
    fillLabelShadow.opacity = TOOL_TIP_SHADOW_OPACITY;
    fillLabelShadow.position = ccp(fillLabel.contentSize.width/2, fillLabel.contentSize.height/2-1);
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
    
    s = [CCSprite spriteWithFile:@"map.png"];
    CCMenuItemSprite *mapButton = [CCMenuItemSprite itemFromNormalSprite:s selectedSprite:nil target:self selector:@selector(mapClicked)];
    mapButton.position = ccp(self.contentSize.width-s.contentSize.width/2-BOTTOM_BUTTON_OFFSET, s.contentSize.height/2+BOTTOM_BUTTON_OFFSET);
    
    s = [CCSprite spriteWithFile:@"bazaarbutton.png"];
    _bazaarButton = [CCMenuItemSprite itemFromNormalSprite:s selectedSprite:nil target:self selector:@selector(bazaarClicked)];
    _bazaarButton.position = ccp(mapButton.position.x, mapButton.position.y+mapButton.contentSize.height/2+_bazaarButton.contentSize.height/2);
    
    s = [CCSprite spriteWithFile:@"mycity.png"];
    _homeButton = [CCMenuItemSprite itemFromNormalSprite:s selectedSprite:nil target:self selector:@selector(homeClicked)];
    _homeButton.position = ccp(_bazaarButton.position.x, _bazaarButton.position.y+_bazaarButton.contentSize.height/2+_homeButton.contentSize.height/2);
    
    s = [CCSprite spriteWithFile:@"attack.png"];
    CCMenuItemSprite *attackButton = [CCMenuItemSprite itemFromNormalSprite:s selectedSprite:nil target:self selector:@selector(attackClicked)];
    attackButton.position = ccp(mapButton.position.x-mapButton.contentSize.width/2-attackButton.contentSize.width/2, s.contentSize.height/2+BOTTOM_BUTTON_OFFSET);
    
    s = [CCSprite spriteWithFile:@"quests.png"];
    _questButton = [CCMenuItemSprite itemFromNormalSprite:s selectedSprite:nil target:self selector:@selector(questButtonClicked)];
    _questButton.position = ccp(mapButton.position.x, self.contentSize.height-_coinBar.contentSize.height-_questButton.contentSize.height/2-BOTTOM_BUTTON_OFFSET);
    
    _bottomButtons = [CCMenu menuWithItems: mapButton, attackButton, _bazaarButton, _homeButton, _questButton, nil];
    _bottomButtons.contentSize = CGSizeZero;
    _bottomButtons.position = CGPointZero;
    [self addChild:_bottomButtons z:10];
    
    _questNewArrow = [CCSprite spriteWithFile:@"new.png"];
    [self addChild:_questNewArrow];
    _questNewArrow.opacity = 0;
    _questNewArrow.anchorPoint = ccp(1.f, 0.5f);
    
    _questProgArrow = [CCSprite spriteWithFile:@"progress.png"];
    [self addChild:_questProgArrow];
    _questProgArrow.opacity = 0;
    _questProgArrow.anchorPoint = ccp(1.f, 0.5f);
    
    _questNewBadge = [CCSprite spriteWithFile:@"badgeforquests.png"];
    [_questButton addChild:_questNewBadge];
    _questNewBadge.visible = NO;
    _questNewBadge.position = ccp(4, _questButton.contentSize.height-4);
    
    fontSize = 12.f;
    _questNewLabel = [CCLabelTTF labelWithString:@"1" fontName:@"AJensonPro-BoldCapt" fontSize:fontSize];
    [_questNewBadge addChild:_questNewLabel];
    _questNewLabel.position = ccp(_questNewBadge.contentSize.width/2, _questNewBadge.contentSize.height/2-2);
    
    _trackingEnstBar = NO;
    _trackingCoinBar = NO;
    
    [self setUpEnergyTimer];
    [self setUpStaminaTimer];
    
    [self setStaminaBarPercentage:0.f];
    [self setEnergyBarPercentage:0.f];
    
    self.isTouchEnabled = YES;
    
    self.isStarted = NO;
    
    _notificationsToDisplay = [[NSMutableArray alloc] init];
    
    [[NSBundle mainBundle] loadNibNamed:@"ChatBottomView" owner:self options:nil];
    // Put chatBottomView right above openGlView
    [[[[CCDirector sharedDirector] openGLView] superview] insertSubview:self.chatBottomView atIndex:1];
    chatBottomView.center = CGPointMake(chatBottomView.frame.size.width/2+5.f, chatBottomView.superview.frame.size.height-chatBottomView.frame.size.height/2-2.f);
    chatBottomView.hidden = YES;
  }
  return self;
}

- (void) mapClicked {
  [MapViewController displayMissionMap];
}

- (void) attackClicked {
  [AttackMenuController displayView];
}

- (void) questButtonClicked {
  [[QuestLogController sharedQuestLogController] loadQuestLog];
}
  
- (void) bazaarClicked {
  [[GameLayer sharedGameLayer] loadBazaarMap];
}

- (void) homeClicked {
  [[GameLayer sharedGameLayer] loadHomeMap];
}

- (void) loadHomeConfiguration {
  _homeButton.visible = NO;
  _bazaarButton.visible = YES;
}

- (void) loadBazaarConfiguration {
  _bazaarButton.visible = NO;
  _homeButton.visible = YES;
  _homeButton.position = _bazaarButton.position;
}

- (void) loadNormalConfiguration {
  _homeButton.visible = YES;
  _bazaarButton.visible = YES;
  _homeButton.position = ccp(_bazaarButton.position.x, _bazaarButton.position.y+_bazaarButton.contentSize.height/2+_homeButton.contentSize.height/2);
}

- (void) start {
  // Drop the bars down
  [_enstBgd runAction:[CCEaseBounceOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, -_enstBgd.contentSize.height)]]];
  [_coinBar runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2], [CCEaseBounceOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, -_coinBar.contentSize.height)]], nil]];
  
  if (![[GameState sharedGameState] isTutorial]) {
    [[HomeMap sharedHomeMap] beginTimers];
    chatBottomView.hidden = NO;
  }
  
  if (dbmc) {
    [Globals displayUIView:dbmc.view];
    self.dbmc = nil;
  }
  
  BOOL showActFeed = NO;
  NSArray *notifications = [[GameState sharedGameState] notifications];
  for (UserNotification *un in notifications) {
    if (!un.hasBeenViewed) {
      showActFeed = YES;
      break;
    }
  }
  if (showActFeed) {
    [ActivityFeedController displayView];
  }
  
  self.isStarted = YES;
  
  GameState *gs = [GameState sharedGameState];
  
#ifndef DEBUG
  [Crittercism setUsername:gs.name];
  [Crittercism setValue:gs.referralCode forKey:@"Referral Code"];
#endif
  
  if (gs.availableQuests.count > 0) {
    [self displayNewQuestArrow];
  }
  
//#ifndef DEBUG
//  if (!gs.playerHasBoughtInAppPurchase && !gs.isTutorial) {
//    // Configure Chartboost
//    Chartboost *cb = [Chartboost sharedChartboost];
//    cb.appId = CHART_BOOST_APP_ID;
//    cb.appSignature = CHART_BOOST_APP_SIGNATURE;
//    
//    // Notify the beginnin g of a user session
//    [cb startSession];
//    // Show an interstitial
//    [cb showInterstitial];
//  }
//#endif
  
  _curSilver = 0;
  _curGold = 0;
  _curEnergy = 0;
  _curStamina = 0;
  _curExp = gs.expRequiredForCurrentLevel;
  
  [self schedule:@selector(update)];
}

- (void) registerWithTouchDispatcher {
  [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void) fillClicked {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (_bigToolTipState == kEnergy) {
    [Analytics clickedFillEnergy];
    if (gs.gold >= gl.energyRefillCost) {
      if (gs.currentEnergy < gs.maxEnergy) {
        [[OutgoingEventController sharedOutgoingEventController] refillEnergyWithDiamonds];
      }
    } else {
      [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:gl.energyRefillCost];
      [Analytics notEnoughGoldToRefillEnergyTopBar];
    }
  } else if (_bigToolTipState == kStamina) {
    [Analytics clickedFillStamina];
    if (gs.gold >= gl.staminaRefillCost) {
      if (gs.currentStamina < gs.maxStamina) {
        [[OutgoingEventController sharedOutgoingEventController] refillStaminaWithDiamonds];
      }
    } else {
      [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:gl.staminaRefillCost];
      [Analytics notEnoughGoldToRefillStaminaTopBar];
    }
  }
}

- (void) setUpEnergyTimer {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  // Invalidate old timer
  [_energyTimer invalidate];
  _energyTimer = nil;
  
  if (!gs.connected) {
    return;
  }
  
  // Only fire timers if it is less than the current time
  if (gs.currentEnergy < gs.maxEnergy) {
    NSTimeInterval energyComplete = gs.lastEnergyRefill.timeIntervalSinceNow+60*gl.energyRefillWaitMinutes;
    _energyTimer = [NSTimer timerWithTimeInterval:energyComplete target:self selector:@selector(energyRefillWaitComplete) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_energyTimer forMode:NSRunLoopCommonModes];
    DDLogVerbose(@"Firing up energy timer with time %f. Cur: %d, Max: %d", energyComplete, gs.currentEnergy, gs.maxEnergy);
  } else {
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
  _staminaTimer = nil;
  
  if (!gs.connected) {
    return;
  }
  
  if (gs.currentStamina < gs.maxStamina) {
    NSTimeInterval staminaComplete = gs.lastStaminaRefill.timeIntervalSinceNow+60*gl.staminaRefillWaitMinutes;
    _staminaTimer = [NSTimer timerWithTimeInterval:staminaComplete target:self selector:@selector(staminaRefillWaitComplete) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_staminaTimer forMode:NSRunLoopCommonModes];
    DDLogVerbose(@"Firing up stamina timer with time %f. Cur: %d, Max: %d", staminaComplete, gs.currentStamina, gs.maxStamina);
  } else {
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
    [_bigToolTip stopAllActions];
    [_bigToolTip runAction:[CCFadeIn actionWithDuration:FADE_ANIMATION_DURATION]];
  }
  _bigToolTip.visible = YES;
  _bigToolTipState = isEnergy ? kEnergy : kStamina;
  
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  if (isEnergy) {
    [_toolTipTimerDate release];
    _toolTipTimerDate = [[gs.lastEnergyRefill dateByAddingTimeInterval:gl.energyRefillWaitMinutes*60] retain];
    _bigGoldCostLabel.string = [NSString stringWithFormat:@"%d", gl.energyRefillCost];
    _bigGoldCostLabelShadow.string = [NSString stringWithFormat:@"%d", gl.energyRefillCost];
  } else {
    [_toolTipTimerDate release];
    _toolTipTimerDate = [[gs.lastStaminaRefill dateByAddingTimeInterval:gl.staminaRefillWaitMinutes*60] retain];
    _bigGoldCostLabel.string = [NSString stringWithFormat:@"%d", gl.staminaRefillCost];
    _bigGoldCostLabelShadow.string = [NSString stringWithFormat:@"%d", gl.staminaRefillCost];
  }
}

- (void) fadeInLittleToolTip:(BOOL)isEnergy {
  [_littleToolTip stopAllActions];
  [_littleToolTip runAction:[CCFadeTo actionWithDuration:FADE_ANIMATION_DURATION*(255-_littleToolTip.opacity)/255 opacity:255]];
  _littleToolTip.visible = YES;
  _littleToolTipState = isEnergy ? kEnergy : kStamina;
}

- (void) fadeOutToolTip:(BOOL)big {
  CCSprite *toolTip = big ? _bigToolTip : _littleToolTip;
  
  if (toolTip.opacity >= 255) {
    [toolTip runAction:[CCSequence actions:
                        [CCFadeTo actionWithDuration:FADE_ANIMATION_DURATION*toolTip.opacity/255 opacity:0],
                        [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)], nil]];
  }
}

- (void) setInvisible:(CCNode *)sender {
  sender.visible = NO;
  
  if (sender == _bigToolTip) {
    _bigToolTipState = kNotShowing;
  } else if (sender == _littleToolTip) {
    _littleToolTipState = kNotShowing;
  } else {
    DDLogError(@"ERROR IN TOOL TIPS!!! sender = %@", [sender description]);
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
  [Analytics viewedGoldShopFromTopMenu];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  if (!isRunning_) {
    return NO;
  }
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
    GameMap *gm = [[GameLayer sharedGameLayer] currentMap];
    if (![gm.selected isKindOfClass:[MissionBuilding class]]) {
      if (_littleToolTipState != kNotShowing) {
        [self fadeOutToolTip:NO];
      }
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
  if (!_curEnergyBar || perc != _energyBar.percentage) {
    [_enstBgd removeChild:_curEnergyBar cleanup:YES];
    _energyBar.percentage = perc;
    _curEnergyBar = [_energyBar updateSprite];
    [_enstBgd addChild:_curEnergyBar z:1 tag:1];
    _curEnergyBar.position = ENERGY_BAR_POSITION;
  }
}

- (void) setStaminaBarPercentage:(float)perc {
  // Want to create it anyways if stamina perc is nil
  if (!_curStaminaBar || perc != _staminaBar.percentage) {
    [_enstBgd removeChild:_curStaminaBar cleanup:YES];
    _staminaBar.percentage = perc;
    _curStaminaBar = [_staminaBar updateSprite];
    [_enstBgd addChild:_curStaminaBar z:1 tag:2];
    _curStaminaBar.position = STAMINA_BAR_POSITION;
  }
}

- (void) invalidateTimers {
  [_staminaTimer invalidate];
  _staminaTimer = nil;
  [_energyTimer invalidate];
  _energyTimer = nil;
}

- (void) update {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (gs.connected) {
    if (gs.experience >= gs.expRequiredForNextLevel && gs.level < gl.maxLevelForUser) {
      [[OutgoingEventController sharedOutgoingEventController] levelUp];
    }
    // Check if timers need to be instantiated
    if (!_energyTimer && gs.currentEnergy < gs.maxEnergy) {
      [self setUpEnergyTimer];
    }
    if (!_staminaTimer && gs.currentStamina < gs.maxStamina) {
      [self setUpStaminaTimer];
    }
    
    int silver = gs.silver-[[[GameLayer sharedGameLayer] currentMap] silverOnMap];
    if (silver != _curSilver) {
      int diff = silver - _curSilver;
      int change = 0;
      if (diff > 0) {
        change = MAX((int)(0.1*diff), 1);
      } else if (diff < 0) {
        change = MIN((int)(0.1*diff), -1);
      }
      _silverLabel.string = [Globals commafyNumber:_curSilver+change];
      _curSilver += change;
    }
    if (gs.gold != _curGold) {
      int diff = gs.gold - _curGold;
      int change = 0;
      if (diff > 0) {
        change = MAX((int)(0.1*diff), 1);
      } else if (diff < 0) {
        change = MIN((int)(0.1*diff), -1);
      }
      _goldLabel.string = [Globals commafyNumber:_curGold+change];
      _curGold += change;
    }
    
    if (gs.currentEnergy != _curEnergy) {
      int diff = gs.currentEnergy - _curEnergy;
      int change = 0;
      if (diff > 0) {
        change = MAX(MIN((int)(0.02*gs.maxEnergy), diff), 1);
      } else if (diff < 0) {
        change = MIN(MAX((int)(-0.02*gs.maxEnergy), diff), -1);
      }
      [self setEnergyBarPercentage:(_curEnergy+change)/((float)gs.maxEnergy)];
      _curEnergy += change;
    }
    
    if (gs.currentStamina != _curStamina) {
      int diff = gs.currentStamina - _curStamina;
      int change = 0;
      if (diff > 0) {
        change = MAX(MIN((int)(0.02*gs.maxStamina), diff), 1);
      } else if (diff < 0) {
        change = MIN(MAX((int)(-0.02*gs.maxStamina), diff), -1);
      }
      [self setStaminaBarPercentage:(_curStamina+change)/((float)gs.maxStamina)];
      _curStamina += change;
    }
    
    // Must do this outside if statement in case level up occurred
    int levelDiff = gs.expRequiredForNextLevel-gs.expRequiredForCurrentLevel;
    int diff = gs.experience - _curExp;
    int change = 0;
    if (diff > 0) {
      change = MAX(MIN((int)(0.01*levelDiff), diff), 1);
    } else if (diff < 0) {
      change = MIN(MAX((int)(0.01*levelDiff), diff), -1);
    }
    [_profilePic setExpPercentage:(_curExp+change-gs.expRequiredForCurrentLevel)/(float)(gs.expRequiredForNextLevel-gs.expRequiredForCurrentLevel)];
    _curExp += change;
    
    [_profilePic setLevel:gs.level];
    
    if (_profilePic.expLabelTop.visible) {
      [_profilePic.expLabelTop setString:[NSString stringWithFormat:@"%d/", _curExp-gs.expRequiredForCurrentLevel]];
      [_profilePic.expLabelBot setString:[NSString stringWithFormat:@"%d", gs.expRequiredForNextLevel-gs.expRequiredForCurrentLevel]];
    }
    
    if (_bigToolTipState == kEnergy) {
      _bigToolTip.position = ccp((_curEnergyBar.position.x-_curEnergyBar.contentSize.width/2)+_curEnergyBar.contentSize.width*_energyBar.percentage, _curEnergyBar.position.y-_curEnergyBar.contentSize.height/2-_bigToolTip.contentSize.height/2);
      _bigCurValLabel.string = [NSString stringWithFormat:@"%d/%d", _curEnergy, gs.maxEnergy];
      if (_curEnergy >= gs.maxEnergy) {
        [self fadeOutToolTip:YES];
      } else {
        int time = [_toolTipTimerDate timeIntervalSinceDate:[NSDate date]];
        _bigTimerLabel.string = [NSString stringWithFormat:@"+1 in %01d:%02d", time/60, time%60];
      }
    } else if (_bigToolTipState == kStamina) {
      _bigToolTip.position = ccp((_curStaminaBar.position.x-_curStaminaBar.contentSize.width/2)+_curStaminaBar.contentSize.width*_staminaBar.percentage, _curStaminaBar.position.y-_curStaminaBar.contentSize.height/2-_bigToolTip.contentSize.height/2);
      _bigCurValLabel.string = [NSString stringWithFormat:@"%d/%d", _curStamina, gs.maxStamina];
      if (_curStamina >= gs.maxStamina) {
        [self fadeOutToolTip:YES];
      } else {
        int time = [_toolTipTimerDate timeIntervalSinceDate:[NSDate date]];
        _bigTimerLabel.string = [NSString stringWithFormat:@"+1 in %01d:%02d", time/60, time%60];
      }
    }
    
    if (_littleToolTipState == kEnergy) {
      _littleToolTip.position = ccp((_curEnergyBar.position.x-_curEnergyBar.contentSize.width/2)+_curEnergyBar.contentSize.width*_energyBar.percentage, _curEnergyBar.position.y-_curEnergyBar.contentSize.height/2-_littleToolTip.contentSize.height/2);
      _littleCurValLabel.string = [NSString stringWithFormat:@"%d/%d", _curEnergy, gs.maxEnergy];
    } else if (_littleToolTipState == kStamina) {
      _littleToolTip.position = ccp((_curStaminaBar.position.x-_curStaminaBar.contentSize.width/2)+_curStaminaBar.contentSize.width*_staminaBar.percentage, _curStaminaBar.position.y-_curStaminaBar.contentSize.height/2-_littleToolTip.contentSize.height/2);
      _littleCurValLabel.string = [NSString stringWithFormat:@"%d/%d", _curStamina, gs.maxStamina];
    }
    
    // Display notifications
    if (!inGameNotification && _notificationsToDisplay.count > 0) {
      UserNotification *un = [_notificationsToDisplay objectAtIndex:0];
      [[NSBundle mainBundle] loadNibNamed:@"InGameNotification" owner:self options:nil];
      [self.inGameNotification updateForNotification:un];
      [_notificationsToDisplay removeObjectAtIndex:0];
      [Globals displayUIView:self.inGameNotification];
      self.inGameNotification.center = ccp(self.inGameNotification.superview.frame.size.width/2,-self.inGameNotification.frame.size.height/2);
      [UIView animateWithDuration:0.3f animations:^{
        self.inGameNotification.center = ccp(self.inGameNotification.superview.frame.size.width/2,self.inGameNotification.frame.size.height/2+5);
      } completion:^(BOOL finished) {
        // Animate back up after 5 seconds.
        // Must use block otherwise can't interact with view for 5s
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5.f * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
          [UIView animateWithDuration:0.3f animations:^{
            self.inGameNotification.center = ccp(self.inGameNotification.superview.frame.size.width/2,-self.inGameNotification.frame.size.height/2);
          } completion:^(BOOL finished) {
            [self.inGameNotification removeFromSuperview];
            self.inGameNotification = nil;
          }];
        });
      }];
    }
  }
}

- (void) addNotificationToDisplayQueue:(UserNotification *)un {
  [_notificationsToDisplay addObject:un];
}

- (void) displayProgressQuestArrow {
  [self stopProgressArrow];
  [self stopQuestArrow];
  
  _questProgArrow.scale = 1.f;
  _questProgArrow.position = ccpAdd(_questButton.position, ccp(-_questButton.contentSize.width/2-2, 0));
  _questProgArrow.opacity = 0;
  
  CCMoveBy *action = [CCMoveBy actionWithDuration:0.4f position:ccp(-10, 0)];
  [_questProgArrow runAction:[CCSequence actions:
                              [CCFadeIn actionWithDuration:0.2f],
                              [CCRepeat actionWithAction:
                               [CCSequence actions:
                                [CCEaseSineInOut actionWithAction:action], 
                                [CCEaseSineInOut actionWithAction:action.reverse], 
                                nil] times:3],
                              [CCSpawn actions:
                               [CCFadeOut actionWithDuration:0.3f],
                               [CCScaleBy actionWithDuration:0.3f scale:1.4f], 
                               nil], nil]];
}

- (void) displayNewQuestArrow {
  if (self.isStarted) {
    [self stopProgressArrow];
    [self stopQuestArrow];
    _questNewArrow.scale = 1.f;
    _questNewArrow.position = ccpAdd(_questButton.position, ccp(-_questButton.contentSize.width/2-2, 0));
    _questNewArrow.opacity = 0;
    
    CCMoveBy *action = [CCMoveBy actionWithDuration:0.4f position:ccp(-10, 0)];
    [_questNewArrow runAction:[CCSequence actions:
                               [CCFadeIn actionWithDuration:0.2f],
                               [CCRepeat actionWithAction:
                                [CCSequence actions:
                                 [CCEaseSineInOut actionWithAction:action], 
                                 [CCEaseSineInOut actionWithAction:action.reverse], 
                                 nil] times:6],
                               [CCCallBlock actionWithBlock:
                                ^{
                                  [self setQuestBadgeAnimated:YES];
                                }],
                               [CCSpawn actions:
                                [CCFadeOut actionWithDuration:0.3f],
                                [CCScaleBy actionWithDuration:0.3f scale:1.4f], 
                                nil], nil]];
  }
}

- (void) stopProgressArrow {
  [_questProgArrow stopAllActions];
  _questProgArrow.opacity = 0;
}

- (void) stopQuestArrow {
  [_questNewArrow stopAllActions];
  
  if (_questNewArrow.opacity > 0) {
    _questNewArrow.opacity = 0;
    [self setQuestBadgeAnimated:NO];
  }
}

- (void) setQuestBadgeAnimated:(BOOL)animated {
  int newBadge = [[GameState sharedGameState] availableQuests].count;
  
  if (_questNewBadgeNum != newBadge) {
    _questNewBadgeNum = newBadge;
    
    if (animated) {
      CCSprite *popQuestBadge = [CCSprite spriteWithFile:@"badgeforquests.png"];
      [_questNewBadge.parent addChild:popQuestBadge];
      popQuestBadge.position = _questNewBadge.position;
      
      float fontSize = 12.f;
      CCLabelTTF *label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", newBadge] fontName:@"AJensonPro-BoldCapt" fontSize:fontSize];
      [popQuestBadge addChild:label];
      label.position = ccp(popQuestBadge.contentSize.width/2, popQuestBadge.contentSize.height/2-1);
      
      popQuestBadge.scale = 3.f;
      [popQuestBadge runAction:[CCSpawn actions:
                                [CCFadeIn actionWithDuration:0.3f], 
                                [CCScaleTo actionWithDuration:0.3f scale:1.f],
                                nil]];
      [label runAction:[CCSequence actions:
                        [CCFadeIn actionWithDuration:0.3f],
                        [CCCallBlock actionWithBlock:
                         ^{
                           _questNewBadge.visible = YES;
                           _questNewLabel.string = [NSString stringWithFormat:@"%d", newBadge];
                           [label removeFromParentAndCleanup:YES];
                           [popQuestBadge removeFromParentAndCleanup:YES];
                         }],
                        nil]];
    } else {
      if (newBadge > 0) {
        _questNewBadge.visible = YES;
        _questNewLabel.string = [NSString stringWithFormat:@"%d", newBadge];
      } else {
        _questNewBadge.visible = NO;
      }
    }
  }
}

- (void) fadeInMenuOverChatView:(UIView *)view {
  view.alpha = 0.f;
  view.center = self.chatBottomView.center;
  
  [UIView animateWithDuration:0.3f animations:^{
    view.alpha = 1.f;
    chatBottomView.alpha = 0.f;
  }];
}

- (void) fadeOutMenuOverChatView:(UIView *)view {
  [UIView animateWithDuration:0.3f animations:^{
    view.alpha = 0.f;
    chatBottomView.alpha = 1.f;
  }];
}

- (void) onEnterTransitionDidFinish {
  // Battle layer will have to hide it on the fade out
  [super onEnterTransitionDidFinish];
  
  GameState *gs = [GameState sharedGameState];
  if (!gs.isTutorial) {
    self.chatBottomView.hidden = NO;
  }
}

- (void) dealloc {
  // These were the only things actually retained
  [self invalidateTimers];
  [_energyBar release];
  [_staminaBar release];
  [_toolTipTimerDate release];
  self.profilePic = nil;
  self.dbmc = nil;
  self.inGameNotification = nil;
  self.chatBottomView = nil;
  [_notificationsToDisplay release];
  [super dealloc];
}

@end
