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
#import "LockBoxMenuController.h"
#import "ThreeCardMonteViewController.h"
#import "Amplitude.h"
#import "BossEventMenuController.h"
#import "TournamentMenuController.h"
#import "ArmoryViewController.h"

#define CHART_BOOST_APP_ID @"500674d49c890d7455000005"
#define CHART_BOOST_APP_SIGNATURE @"061147e1537ade60161207c29179ec95bece5f9c"

#define FADE_ANIMATION_DURATION 0.2f

#define ENERGY_BAR_POSITION ccp(53,15)
#define STAMINA_BAR_POSITION ccp(149,15)

#define BOTTOM_BUTTON_OFFSET 2

#define TOOL_TIP_SHADOW_OPACITY 80

#define MIN_LEVEL_FOR_POPUPS 4

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
@synthesize dbi;
@synthesize inGameNotification, chatBottomView;

- (id) init {
  if ((self = [super init])) {
    _enstBgd = [CCSprite spriteWithFile:@"enstbg.png"];
    [self addChild:_enstBgd z:2 tag:ENST_BAR_TAG];
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
    [self addChild:_coinBar z:2 tag:COIN_BAR_TAG];
    
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
    _mapButton = [CCMenuItemSprite itemFromNormalSprite:s selectedSprite:nil target:self selector:@selector(mapClicked)];
    _mapButton.position = ccp(self.contentSize.width-s.contentSize.width/2-BOTTOM_BUTTON_OFFSET, s.contentSize.height/2+BOTTOM_BUTTON_OFFSET);
    
    s = [CCSprite spriteWithFile:@"bazaarbutton.png"];
    _bazaarButton = [CCMenuItemSprite itemFromNormalSprite:s selectedSprite:nil target:self selector:@selector(bazaarClicked)];
    _bazaarButton.position = ccp(_mapButton.position.x, _mapButton.position.y+_mapButton.contentSize.height/2+_bazaarButton.contentSize.height/2);
    
    s = [CCSprite spriteWithFile:@"mycity.png"];
    _homeButton = [CCMenuItemSprite itemFromNormalSprite:s selectedSprite:nil target:self selector:@selector(homeClicked)];
    _homeButton.position = ccp(_bazaarButton.position.x, _bazaarButton.position.y+_bazaarButton.contentSize.height/2+_homeButton.contentSize.height/2);
    
    s = [CCSprite spriteWithFile:@"attack.png"];
    _attackButton = [CCMenuItemSprite itemFromNormalSprite:s selectedSprite:nil target:self selector:@selector(attackClicked)];
    _attackButton.position = ccp(_mapButton.position.x-_mapButton.contentSize.width/2-_attackButton.contentSize.width/2, s.contentSize.height/2+BOTTOM_BUTTON_OFFSET);
    
    s = [CCSprite spriteWithFile:@"quests.png"];
    _questButton = [CCMenuItemSprite itemFromNormalSprite:s selectedSprite:nil target:self selector:@selector(questButtonClicked)];
    _questButton.position = ccp(_mapButton.position.x, self.contentSize.height-_coinBar.contentSize.height-_questButton.contentSize.height/2-BOTTOM_BUTTON_OFFSET);
    
    s = [CCSprite spriteWithFile:@"tblockbox.png"];
    _lockBoxButton = [CCMenuItemSprite itemFromNormalSprite:s selectedSprite:nil target:self selector:@selector(lockBoxButtonClicked)];
    _lockBoxButton.position = ccp(_questButton.position.x, _questButton.position.y-_questButton.contentSize.height/2-_lockBoxButton.contentSize.height/2-BOTTOM_BUTTON_OFFSET);
    
    s = [CCSprite spriteWithFile:@"bossicon.png"];
    _bossEventButton = [CCMenuItemSprite itemFromNormalSprite:s selectedSprite:nil target:self selector:@selector(bossEventButtonClicked)];
    _bossEventButton.position = _lockBoxButton.position;
    
    s = [CCSprite spriteWithFile:@"tourneyicon.png"];
    _tournamentButton = [CCMenuItemSprite itemFromNormalSprite:s selectedSprite:nil target:self selector:@selector(tournamentButtonClicked)];
    _tournamentButton.position = _lockBoxButton.position;
    
    s = [CCSprite spriteWithFile:@"towericon.png"];
    _towerButton = [CCMenuItemSprite itemFromNormalSprite:s selectedSprite:nil target:self selector:@selector(towerButtonClicked)];
    _towerButton.position = ccp(s.contentSize.width/2+BOTTOM_BUTTON_OFFSET, 3*s.contentSize.height/2+2*BOTTOM_BUTTON_OFFSET);
    
    _bottomButtons = [CCMenu menuWithItems: _mapButton, _attackButton, _bazaarButton, _homeButton, _questButton, _lockBoxButton, _bossEventButton, _tournamentButton, _towerButton, nil];
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
    
    _lockBoxBadge = [CCSprite spriteWithFile:@"badgeforquests.png"];
    [_lockBoxButton addChild:_lockBoxBadge];
    _lockBoxBadge.visible = NO;
    _lockBoxBadge.position = ccp(4, _lockBoxButton.contentSize.height-4);
    
    CCLabelTTF *lockBoxLabel = [CCLabelTTF labelWithString:@"1" fontName:@"AJensonPro-BoldCapt" fontSize:fontSize];
    [_lockBoxBadge addChild:lockBoxLabel];
    lockBoxLabel.position = ccp(_lockBoxBadge.contentSize.width/2, _lockBoxBadge.contentSize.height/2-2);
    
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
    
    CGRect r = chatBottomView.frame;
    r.origin.x = BOTTOM_BUTTON_OFFSET;
    r.origin.y = chatBottomView.superview.frame.size.height-r.size.height-BOTTOM_BUTTON_OFFSET;
    r.size.width = _attackButton.position.x-_attackButton.contentSize.width/2-2*BOTTOM_BUTTON_OFFSET;
    chatBottomView.frame = r;
    
    chatBottomView.hidden = YES;
    
    _lockBoxButton.visible = NO;
    _bossEventButton.visible = NO;
    _tournamentButton.visible = NO;
    _towerButton.visible = NO;
  }
  return self;
}

- (void) mapClicked {
  if (_isForBattleLossTutorial) {
    return;
  }
  [MapViewController displayMissionMap];
}

- (void) attackClicked {
  if (_isForBattleLossTutorial) {
    return;
  }
  [AttackMenuController displayView];
}

- (void) questButtonClicked {
  if (_isForBattleLossTutorial) {
    return;
  }
  [[QuestLogController sharedQuestLogController] loadQuestLog];
}

- (void) lockBoxButtonClicked {
  if (_isForBattleLossTutorial) {
    return;
  }
  [LockBoxMenuController displayView];
}

- (void) bossEventButtonClicked {
  if (_isForBattleLossTutorial) {
    return;
  }
  GameState *gs = [GameState sharedGameState];
  BossEventProto *lbe = [gs getCurrentBossEvent];
  
  if (lbe) {
    // Assume boss is asset 1
    [[OutgoingEventController sharedOutgoingEventController] loadNeutralCity:lbe.cityId asset:1];
  } else {
    [Globals popupMessage:@"Woops! The event has ended! Try again next time."];
  }
}

- (void) towerButtonClicked {
  if (_isForBattleLossTutorial) {
    return;
  }
  GameState *gs = [GameState sharedGameState];
  BOOL foundMoreThanOne = NO;
  int towerId = 0;
  
  for (ClanTowerProto *ctp in gs.clanTowers) {
    if (ctp.hasTowerAttacker && ctp.hasTowerOwner) {
      if (ctp.towerAttacker.clanId == gs.clan.clanId || ctp.towerOwner.clanId == gs.clan.clanId) {
        if (towerId > 0) {
          foundMoreThanOne = YES;
        } else {
          towerId = ctp.towerId;
        }
      }
    }
  }
  
  [ClanMenuController displayView];
  if (!foundMoreThanOne && towerId > 0) {
    [[ClanMenuController sharedClanMenuController] viewTower:towerId];
  } else {
    [[ClanMenuController sharedClanMenuController] setState:kClanTower];
  }
}

- (void) tournamentButtonClicked {
  if (_isForBattleLossTutorial) {
    return;
  }
  [TournamentMenuController displayView];
}

- (void) bazaarClicked {
  [[GameLayer sharedGameLayer] loadBazaarMap];
}

- (void) homeClicked {
  if (_isForBattleLossTutorial) {
    return;
  }
  [[GameLayer sharedGameLayer] loadHomeMap];
}

- (void) lowerAllOpacities {
  _questButton.normalImage.opacity = BUTTON_OPACITY;
  _questButton.selectedImage.opacity = BUTTON_OPACITY;
  _mapButton.normalImage.opacity = BUTTON_OPACITY;
  _mapButton.selectedImage.opacity = BUTTON_OPACITY;
  _homeButton.normalImage.opacity = BUTTON_OPACITY;
  _homeButton.selectedImage.opacity = BUTTON_OPACITY;
  _attackButton.normalImage.opacity = BUTTON_OPACITY;
  _attackButton.selectedImage.opacity = BUTTON_OPACITY;
  _bazaarButton.normalImage.opacity = BUTTON_OPACITY;
  _bazaarButton.selectedImage.opacity = BUTTON_OPACITY;
  _lockBoxButton.normalImage.opacity = BUTTON_OPACITY;
  _lockBoxButton.selectedImage.opacity = BUTTON_OPACITY;
  _bossEventButton.normalImage.opacity = BUTTON_OPACITY;
  _bossEventButton.selectedImage.opacity = BUTTON_OPACITY;
  _tournamentButton.normalImage.opacity = BUTTON_OPACITY;
  _tournamentButton.selectedImage.opacity = BUTTON_OPACITY;
  _towerButton.normalImage.opacity = BUTTON_OPACITY;
  _towerButton.selectedImage.opacity = BUTTON_OPACITY;
}

- (void) resetAllOpacities {
  _questButton.normalImage.opacity = 255;
  _questButton.selectedImage.opacity = 255;
  _mapButton.normalImage.opacity = 255;
  _mapButton.selectedImage.opacity = 255;
  _homeButton.normalImage.opacity = 255;
  _homeButton.selectedImage.opacity = 255;
  _attackButton.normalImage.opacity = 255;
  _attackButton.selectedImage.opacity = 255;
  _bazaarButton.normalImage.opacity = 255;
  _bazaarButton.selectedImage.opacity = 255;
  _lockBoxButton.normalImage.opacity = 255;
  _lockBoxButton.selectedImage.opacity = 255;
  _bossEventButton.normalImage.opacity = 255;
  _bossEventButton.selectedImage.opacity = 255;
  _tournamentButton.normalImage.opacity = 255;
  _tournamentButton.selectedImage.opacity = 255;
  _towerButton.normalImage.opacity = 255;
  _towerButton.selectedImage.opacity = 255;
}

- (void) goToBazaarForFirstLossTutorial {
  [self lowerAllOpacities];
  
  _bazaarButton.normalImage.opacity = 255;
  _bazaarButton.selectedImage.opacity = 255;
  
  _arrow = [[CCSprite spriteWithFile:@"3darrow.png"] retain];
  [self addChild:_arrow];
  _arrow.position = ccpAdd(_bazaarButton.position, ccp(-_bazaarButton.contentSize.width/2-_arrow.contentSize.width/2, 0));
  [Globals animateCCArrow:_arrow atAngle:0];
  
  self.isTouchEnabled = NO;
  self.profilePic.isTouchEnabled = NO;
  self.chatBottomView.hidden = YES;
  
  _isForBattleLossTutorial = YES;
}

- (void) endBazaarFirstLossTutorial {
  [self resetAllOpacities];
  
  self.isTouchEnabled = YES;
  self.profilePic.isTouchEnabled = YES;
  self.chatBottomView.hidden = NO;
  self.chatBottomView.alpha = 1.f;
  
  _isForBattleLossTutorial = NO;
}

- (void) loadHomeConfiguration {
  _homeButton.visible = NO;
  _bazaarButton.visible = YES;
}

- (void) loadBazaarConfiguration {
  _bazaarButton.visible = NO;
  _homeButton.visible = YES;
  _homeButton.position = _bazaarButton.position;
  
  if (_isForBattleLossTutorial) {
    [_arrow removeFromParentAndCleanup:YES];
    [_arrow release];
    _arrow = nil;
    [self lowerAllOpacities];
  }
}

- (void) loadNormalConfiguration {
  _homeButton.visible = YES;
  _bazaarButton.visible = YES;
  _homeButton.position = ccp(_bazaarButton.position.x, _bazaarButton.position.y+_bazaarButton.contentSize.height/2+_homeButton.contentSize.height/2);
}

- (void) start {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  _enstBgd.position = ccp(self.contentSize.width-283.f, self.contentSize.height+_enstBgd.contentSize.height/2);
  _coinBar.position = ccp(self.contentSize.width-107.f, self.contentSize.height+_coinBar.contentSize.height/2);
  
  // At this point, the bars are still above the screen so subtract 3/2 * width
  _enstBarRect = CGRectMake(_enstBgd.position.x-_enstBgd.contentSize.width/2, _enstBgd.position.y-3*_enstBgd.contentSize.height/2, _enstBgd.contentSize.width, _enstBgd.contentSize.height);
  // For coin bar remember to add in the gold button at the right side. Right most x of gold
  // button will suffice since it is a child of the coin bar.
  int rightMostX = 155+_goldButton.contentSize.width/2;
  _coinBarRect = CGRectMake(_coinBar.position.x-_coinBar.contentSize.width/2, _coinBar.position.y-3*_coinBar.contentSize.height/2, rightMostX, _coinBar.contentSize.height);
  
  // Drop the bars down
  [_enstBgd runAction:[CCEaseBounceOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, -_enstBgd.contentSize.height)]]];
  [_coinBar runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2], [CCEaseBounceOut actionWithAction:[CCMoveBy actionWithDuration:1 position:ccp(0, -_coinBar.contentSize.height)]], nil]];
  
  BOOL showActFeed = NO;
  BOOL showThreeCardMonte = NO;
  BOOL showGoldSale = NO;
  BOOL showLockBox = NO;
  BOOL showBossEvent = NO;
  BOOL showTournament = NO;
  BOOL showDailyBonus = NO;
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDate *curDate = [NSDate date];
  NSArray *notifications = [[GameState sharedGameState] notifications];
  for (UserNotification *un in notifications) {
    if (!un.hasBeenViewed) {
      showActFeed = YES;
      break;
    }
  }
  
  [self displayGoldSaleBadge];
  if ([gs getCurrentGoldSale] && gs.level >= MIN_LEVEL_FOR_POPUPS) {
    NSDate *date = [defaults objectForKey:LAST_GOLD_SALE_POPUP_TIME_KEY];
    NSDate *nextShowDate = [date dateByAddingTimeInterval:3600*gl.numHoursBeforeReshowingGoldSale];
    if (!date || [nextShowDate compare:curDate] == NSOrderedAscending) {
      showGoldSale = YES;
      [defaults setObject:curDate forKey:LAST_GOLD_SALE_POPUP_TIME_KEY];
    }
  }
  
  if ([gs getCurrentLockBoxEvent] && gs.level >= MIN_LEVEL_FOR_POPUPS) {
    NSDate *date = [defaults objectForKey:LAST_LOCK_BOX_POPUP_TIME_KEY];
    NSDate *nextShowDate = [date dateByAddingTimeInterval:3600*gl.numHoursBeforeReshowingLockBox];
    if (!date || [nextShowDate compare:curDate] == NSOrderedAscending) {
      [LockBoxMenuController sharedLockBoxMenuController];
      showLockBox = YES;
      [defaults setObject:curDate forKey:LAST_LOCK_BOX_POPUP_TIME_KEY];
    }
  }
  
  if ([gs getCurrentBossEvent] && gs.level >= MIN_LEVEL_FOR_POPUPS) {
    NSDate *date = [defaults objectForKey:LAST_BOSS_EVENT_POPUP_TIME_KEY];
    NSDate *nextShowDate = [date dateByAddingTimeInterval:3600*gl.numHoursBeforeReshowingBossEvent];
    if (!date || [nextShowDate compare:curDate] == NSOrderedAscending) {
      [BossEventMenuController sharedBossEventMenuController];
      showBossEvent = YES;
      [defaults setObject:curDate forKey:LAST_BOSS_EVENT_POPUP_TIME_KEY];
    }
  }
  
  if ([gs getCurrentTournament] && gs.level >= MIN_LEVEL_FOR_POPUPS) {
    NSDate *date = [defaults objectForKey:LAST_TOURNAMENT_POPUP_TIME_KEY];
    NSDate *nextShowDate = [date dateByAddingTimeInterval:3600*gl.numHoursBeforeReshowingBossEvent];
    if (!date || [nextShowDate compare:curDate] == NSOrderedAscending) {
      [TournamentMenuController sharedTournamentMenuController];
      showTournament = YES;
      [defaults setObject:curDate forKey:LAST_TOURNAMENT_POPUP_TIME_KEY];
    }
  }
  
  DailyBonusMenuController *dbmc = nil;
  if (dbi) {
    showDailyBonus = YES;
    
    dbmc = [[DailyBonusMenuController alloc] init];
    [dbmc loadForDailyBonusInfo:dbi];
  }
  
  if (gs.level >= gl.minLevelToDisplayThreeCardMonte && gl.minLevelToDisplayThreeCardMonte > 0) {
    [ThreeCardMonteViewController sharedThreeCardMonteViewController];
    showThreeCardMonte = YES;
  }
  
  [[GameState sharedGameState] resetLockBoxTimers];
  
  if (![[GameState sharedGameState] isTutorial]) {
    [[HomeMap sharedHomeMap] refresh];
    [[HomeMap sharedHomeMap] beginTimers];
    chatBottomView.hidden = NO;
  }
  
  // Display the views: Will have downloaded by now
  if (showActFeed) {
    [ActivityFeedController displayView];
  } if (showGoldSale) {
    [GoldShoppeViewController displayView];
  } if (showLockBox) {
    [[LockBoxMenuController sharedLockBoxMenuController] infoClicked:nil];
  } if (showBossEvent) {
    [BossEventMenuController displayView];
  } if (showTournament) {
    [TournamentMenuController displayView];
  } if (showThreeCardMonte) {
    [ThreeCardMonteViewController displayView];
  } if (showDailyBonus) {
    [Globals displayUIView:dbmc.view];
    self.dbi = nil;
  }
  
  self.isStarted = YES;
  
#ifndef DEBUG
  [Crittercism setUsername:gs.name];
  [Crittercism setValue:gs.referralCode forKey:@"Referral Code"];
  [Amplitude setUserId:[NSString stringWithFormat:@"%d", gs.userId]];
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
  
  
  //  NSMutableDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:gs.name, @"alias", nil];
  //  [[KPManager sharedManager] updateUserInfo:userInfo];
  
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
    NSTimeInterval energyComplete = gs.lastEnergyRefill.timeIntervalSinceNow+60*gl.energyRefillWaitMinutes+0.1;
    _energyTimer = [NSTimer timerWithTimeInterval:energyComplete target:self selector:@selector(energyRefillWaitComplete) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_energyTimer forMode:NSRunLoopCommonModes];
    LNLog(@"Firing up energy timer with time %f. Cur: %d, Max: %d", energyComplete, gs.currentEnergy, gs.maxEnergy);
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
    NSTimeInterval staminaComplete = gs.lastStaminaRefill.timeIntervalSinceNow+60*gl.staminaRefillWaitMinutes+0.1;
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
  return CGRectContainsPoint(_enstBarRect, pt) || CGRectContainsPoint(_coinBarRect, pt);
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
    int gold = gs.gold-[[[GameLayer sharedGameLayer] currentMap] goldOnMap];
    if (gold != _curGold) {
      int diff = gold - _curGold;
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
    
    GameState *gs = [GameState sharedGameState];
    int times = gs.level < 10 ? 14 : 6;
    
    CCMoveBy *action = [CCMoveBy actionWithDuration:0.4f position:ccp(-10, 0)];
    [_questNewArrow runAction:[CCSequence actions:
                               [CCFadeIn actionWithDuration:0.2f],
                               [CCRepeat actionWithAction:
                                [CCSequence actions:
                                 [CCEaseSineInOut actionWithAction:action],
                                 [CCEaseSineInOut actionWithAction:action.reverse],
                                 nil] times:times],
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
  
  CGRect r = view.frame;
  r.origin = chatBottomView.frame.origin;
  view.frame = r;
  
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

- (void) displayGoldSaleBadge {
  GameState *gs = [GameState sharedGameState];
  GoldSaleProto *sale = [gs getCurrentGoldSale];
  
  if (_goldSaleBanner) {
    if (!sale) {
      [_goldSaleBanner runAction:[CCSequence actions:
                                  [CCMoveTo actionWithDuration:0.3f position:ccp(_goldSaleBanner.position.x, _coinBar.contentSize.height/2-5)],
                                  [CCCallBlock actionWithBlock:
                                   ^{
                                     [_goldSaleBanner removeFromParentAndCleanup:YES];
                                     _goldSaleBanner = nil;
                                   }], nil]];
    }
  } else {
    if (sale) {
      _goldSaleBanner = [CCSprite spriteWithFile:sale.goldBarImageName];
      if (_goldSaleBanner) {
        [_coinBar addChild:_goldSaleBanner z:-1];
        _goldSaleBanner.position = ccp(_coinBar.contentSize.width/2-5, _coinBar.contentSize.height/2-5);
        [_goldSaleBanner runAction:[CCEaseBounceOut actionWithAction:[CCMoveBy actionWithDuration:0.7f position:ccp(0, -22)]]];
      }
    }
  }
}

- (ChatBottomView *) chatBottomView {
  return chatBottomView;
}

- (void) shouldDisplayLockBoxButton:(BOOL)button andBadge:(BOOL)badge {
  _lockBoxButton.visible = button;
  _lockBoxBadge.visible = badge;
}

- (void) shouldDisplayBossEventButton:(BOOL)button {
  _bossEventButton.visible = button;
}

- (void) shouldDisplayTournamentButton:(BOOL)button {
  _tournamentButton.visible = button;
}

- (void) shouldDisplayTowerButton:(BOOL)button {
  _towerButton.visible = button;
}

- (void) onEnter {
  [super onEnter];
  GameState *gs = [GameState sharedGameState];
  if (!gs.isTutorial && !_isForBattleLossTutorial) {
    self.chatBottomView.hidden = NO;
    self.chatBottomView.alpha = 0.f;
    [UIView animateWithDuration:1.f delay:0.5f options:UIViewAnimationOptionTransitionNone animations:^{
      self.chatBottomView.alpha = 1.f;
    } completion:nil];
  }
}

- (void) dealloc {
  // These were the only things actually retained
  [self invalidateTimers];
  [_energyBar release];
  [_staminaBar release];
  [_toolTipTimerDate release];
  self.profilePic = nil;
  self.dbi = nil;
  self.inGameNotification = nil;
  self.chatBottomView = nil;
  [_notificationsToDisplay release];
  [super dealloc];
}

@end
