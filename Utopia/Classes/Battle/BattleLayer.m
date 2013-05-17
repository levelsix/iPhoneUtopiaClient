//
//  BattleLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/23/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

#import "BattleLayer.h"
#import "GameState.h"
#import "Globals.h"
#import "LNSynthesizeSingleton.h"
#import "GameLayer.h"
#import "OutgoingEventController.h"
#import "ProfileViewController.h"
#import "RefillMenuController.h"
#import "AttackMenuController.h"
#import "SoundEngine.h"
#import "MissionMap.h"
#import "MarketplaceViewController.h"
#import "Downloader.h"
#import "LeaderboardController.h"
#import "TopBar.h"
#import "GenericPopupController.h"
#import "ClanMenuController.h"
#import "ChatMenuController.h"
//#import "KiipDelegate.h"
#import "TournamentMenuController.h"
#import "ArmoryViewController.h"
#import "AppDelegate.h"
#import <Twitter/Twitter.h>
#import "GameViewController.h"

#define FAKE_PLAYER_RAND 6
#define NAME_LABEL_FONT_SIZE 11.f

#define TRANSITION_DURATION 1.5f

#define NUM_BACKGROUND_IMAGES 8

#define FINAL_BATTLE_WORLD_SCALE 1.4f

#define MAX_NUM_WINS 3

#define BATTLE_USER_DEFAULTS_KEY [NSString stringWithFormat:@"Battle%d", _fup.userId]

#define BATTLE_WON_KIIP_REWARD @"battle_win"

#define DEATH_PS_TAG 992

@implementation BattleLayer

@synthesize summaryView, stolenEquipView, gainedEquipView, gainedLockBoxView, brp, enemyEquips;

SYNTHESIZE_SINGLETON_FOR_CLASS(BattleLayer);

+ (NSString *) getAvailableBackground {
  NSMutableArray *validImages = [NSMutableArray arrayWithCapacity:NUM_BACKGROUND_IMAGES];
  for (int i = 1; i <= NUM_BACKGROUND_IMAGES; i++) {
    BOOL imageExists = YES;
    NSString *path = [NSString stringWithFormat:@"battle%d.png", i];
    
    NSString *resName = [CCFileUtils getDoubleResolutionImage:path validate:NO];
    NSString *fullpath = [[NSBundle mainBundle] pathForResource:resName ofType:nil];
    
    if (!fullpath) {
      // Image not in NSBundle: look in documents
      NSArray *paths = NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES);
      NSString *documentsPath = [paths objectAtIndex:0];
      fullpath = [documentsPath stringByAppendingPathComponent:resName];
      
      if (![[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
        // Image not in docs: download it
        [[Downloader sharedDownloader] asyncDownloadFile:fullpath.lastPathComponent completion:nil];
        imageExists = NO;
      }
    }
    
    if (imageExists) {
      [validImages addObject:path];
    }
  }
  
  int i = arc4random() % validImages.count;
  NSString *validImg = [validImages objectAtIndex:i];
  return validImg;
}

+ (CCScene *) scene
{
  // 'layer' is a singleton object.
  BattleLayer *layer = [self sharedBattleLayer];
  
  if (!layer.parent) {
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // When this scene is removed, it will be deallocated so the background will change..
    
    CCTexture2DPixelFormat oldPixelFormat = [CCTexture2D defaultAlphaPixelFormat];
    [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
    
    CCSprite *sprite = [CCSprite spriteWithFile:[self getAvailableBackground]];
    sprite.anchorPoint = ccp(0,0);
    [scene addChild:sprite];
    sprite.scaleX = scene.contentSize.width/sprite.contentSize.width;
    
    [CCTexture2D setDefaultAlphaPixelFormat:oldPixelFormat];
    
    
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
  }
  return (CCScene *)layer.parent;
}

- (id) init {
  if ((self = [super init])) {
    CCSprite *leftHealthBarBg = [CCSprite spriteWithFile:@"healthbarbg.png"];
    leftHealthBarBg.position = ccp(leftHealthBarBg.contentSize.width/2, self.contentSize.height-leftHealthBarBg.contentSize.height/2);
    [self addChild:leftHealthBarBg];
    
    _leftHealthBar = [CCSprite spriteWithFile:@"healthbar.png"];
    _leftHealthBar.anchorPoint = ccp(0, 0.5f);
    _leftHealthBar.position = ccp(0, leftHealthBarBg.contentSize.height/2);
    [leftHealthBarBg addChild:_leftHealthBar];
    
    _leftNameBg = [CCSprite spriteWithFile:@"nametag.png"];
    _leftNameBg.anchorPoint = ccp(1,1);
    [leftHealthBarBg addChild:_leftNameBg];
    _leftNameBg.position = ccp(_leftNameBg.contentSize.width, 1);
    
    _leftNameLabel = [CCLabelTTF labelWithString:@"" fontName:@"Trajan Pro" fontSize:NAME_LABEL_FONT_SIZE];
    _leftNameLabel.anchorPoint = ccp(1, 0.5);
    _leftNameLabel.position = ccp(_leftNameBg.contentSize.width-30, _leftNameBg.contentSize.height/2-2);
    _leftNameLabel.color = ccc3(255, 200, 0);
    [_leftNameBg addChild:_leftNameLabel];
    
    CCSprite *rightHealthBarBg = [CCSprite spriteWithTexture:leftHealthBarBg.texture];
    rightHealthBarBg.flipX = YES;
    rightHealthBarBg.position = ccp(self.contentSize.width-leftHealthBarBg.contentSize.width/2, self.contentSize.height-leftHealthBarBg.contentSize.height/2);
    [self addChild:rightHealthBarBg];
    
    _rightHealthBar = [CCSprite spriteWithTexture:_leftHealthBar.texture];
    _rightHealthBar.anchorPoint = ccp(1, 0.5f);
    _rightHealthBar.position = ccp(rightHealthBarBg.contentSize.width, rightHealthBarBg.contentSize.height/2);
    _rightHealthBar.flipX = YES;
    [rightHealthBarBg addChild:_rightHealthBar];
    
    CCSprite *spr = [CCSprite spriteWithFile:@"nametag.png"];
    spr.flipX = YES;
    
    CCMenuItemSprite *menuSpr = [CCMenuItemSprite itemFromNormalSprite:spr selectedSprite:nil target:self selector:@selector(profileButtonClicked:)];
    ((CCSprite *)menuSpr.selectedImage).flipX = YES;
    
    _rightNameBg = [CCSprite node];
    _rightNameBg.contentSize = spr.contentSize;
    _rightNameBg.anchorPoint = ccp(0,1);
    [rightHealthBarBg addChild:_rightNameBg];
    
    CCMenu *nameMenu = [CCMenu menuWithItems:menuSpr, nil];
    nameMenu.position = ccp(spr.contentSize.width/2, spr.contentSize.height/2+1);
    [_rightNameBg addChild:nameMenu];
    
    CCSprite *profButton = [CCSprite spriteWithFile:@"profilebutton.png"];
    profButton.position = ccp(30, _rightNameBg.contentSize.height/2);
    profButton.anchorPoint = ccp(0.2,0.5);
    [_rightNameBg addChild:profButton];
    
    _rightNameLabel = [CCLabelTTF labelWithString:@"" fontName:@"Trajan Pro" fontSize:NAME_LABEL_FONT_SIZE];
    _rightNameLabel.color = ccc3(255, 0, 0);
    _rightNameLabel.anchorPoint = ccp(0, 0.5);
    _rightNameLabel.position = ccp(profButton.position.x+profButton.contentSize.width, _rightNameBg.contentSize.height/2-2);
    [_rightNameBg addChild:_rightNameLabel];
    
    _attackButton = [CCSprite spriteWithFile:@"attackbg.png"];
    _attackButton.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    [self addChild:_attackButton z:2];
    
    _attackProgressTimer = [CCProgressTimer progressWithFile:@"yellowtimer.png"];
    _attackProgressTimer.position = ccp(_attackButton.contentSize.width/2, _attackButton.contentSize.height/2);
    _attackProgressTimer.type = kCCProgressTimerTypeRadialCCW;
    _attackProgressTimer.percentage = 0;
    [_attackProgressTimer.sprite.texture setAntiAliasTexParameters];
    [_attackButton addChild:_attackProgressTimer];
    
    CCSprite *attackImage = [CCSprite spriteWithFile:@"circleattackbutton.png"];
    CCMenuItemSprite *attackImageButton = [CCMenuItemSprite itemFromNormalSprite:attackImage selectedSprite:nil target:self selector:@selector(attackStart)];
    
    CCMenu *menu = [CCMenu menuWithItems:attackImageButton,nil];
    [_attackButton addChild:menu];
    menu.position = ccp(_attackButton.contentSize.width/2, _attackButton.contentSize.height/2);
    
    _comboBar = [CCSprite spriteWithFile:@"combobar.png"];
    _comboBar.position = ccp(COMBO_BAR_X_POSITION, self.contentSize.height/2);
    [self addChild:_comboBar z:3];
    
    _triangle = [CCSprite spriteWithFile:@"triangle.png"];
    _triangle.position = ccp(_comboBar.contentSize.width/2, _comboBar.contentSize.height/2);
    _triangle.anchorPoint = ccp(0.5, _comboBar.contentSize.height/_triangle.contentSize.height/2+0.4);
    [_comboBar addChild:_triangle z:1];
    
    CCSprite *maxLine = [CCSprite spriteWithFile:@"maxyellow.png"];
    maxLine.position = ccp(_comboBar.contentSize.width/2, _comboBar.contentSize.height-10.f);
    [_comboBar addChild:maxLine];
    
    CCSprite *max = [CCSprite spriteWithFile:@"max.png"];
    max.position = ccp(_comboBar.contentSize.width/2, _comboBar.contentSize.height-30.f);
    [_comboBar addChild:max];
    
    _flippedComboBar = [CCSprite spriteWithFile:@"combobar.png"];
    _flippedComboBar.flipX = YES;
    _flippedComboBar.position = ccp(self.contentSize.width-COMBO_BAR_X_POSITION, self.contentSize.height/2);
    [self addChild:_flippedComboBar z:3];
    
    _flippedTriangle = [CCSprite spriteWithFile:@"triangle.png"];
    _flippedTriangle.position = ccp(_flippedComboBar.contentSize.width/2, _flippedComboBar.contentSize.height/2);
    _flippedTriangle.anchorPoint = _triangle.anchorPoint;
    [_flippedComboBar addChild:_flippedTriangle z:1];
    
    CCSprite *flippedMaxLine = [CCSprite spriteWithFile:@"maxyellow.png"];
    flippedMaxLine.position = maxLine.position;
    [_flippedComboBar addChild:flippedMaxLine];
    
    CCSprite *flippedMax = [CCSprite spriteWithFile:@"max.png"];
    flippedMax.position = max.position;
    [_flippedComboBar addChild:flippedMax];
    
    CCSprite *pause = [CCSprite spriteWithFile:@"pause.png"];
    CCMenuItemSprite *pauseButton = [CCMenuItemSprite itemFromNormalSprite:pause selectedSprite:nil target:self selector:@selector(pauseClicked)];
    pauseButton.anchorPoint = ccp(1, 0);
    
    CCSprite *flee = [CCSprite spriteWithFile:@"flee.png"];
    CCMenuItemSprite *fleeButton = [CCMenuItemSprite itemFromNormalSprite:flee selectedSprite:nil target:self selector:@selector(fleeClicked)];
    fleeButton.anchorPoint = ccp(0,0);
    
    _bottomMenu = [CCMenu menuWithItems:pauseButton, fleeButton, nil];
    _bottomMenu.position = ccp(self.contentSize.width/2, 0);
    [self addChild:_bottomMenu];
    
    int yOffset = 5.f;
    _leftMaxHealthLabel = [CCLabelTTF labelWithString:@" / 100" fontName:@"DINCond-Black" fontSize:10];
    _leftMaxHealthLabel.anchorPoint = ccp(0,0);
    _leftMaxHealthLabel.position = ccp(leftHealthBarBg.contentSize.width/2, yOffset);
    [leftHealthBarBg addChild:_leftMaxHealthLabel];
    _leftCurHealthLabel = [CCLabelTTF labelWithString:@"100" fontName:@"DINCond-Black" fontSize:14];
    _leftCurHealthLabel.anchorPoint = ccp(1,0);
    _leftCurHealthLabel.position = ccp(leftHealthBarBg.contentSize.width/2, yOffset);
    [leftHealthBarBg addChild:_leftCurHealthLabel];
    
    _rightMaxHealthLabel = [CCLabelTTF labelWithString:@" / 100" fontName:@"DINCond-Black" fontSize:10];
    _rightMaxHealthLabel.anchorPoint = ccp(0,0);
    _rightMaxHealthLabel.position = ccp(rightHealthBarBg.contentSize.width/2, yOffset);
    [rightHealthBarBg addChild:_rightMaxHealthLabel];
    _rightCurHealthLabel = [CCLabelTTF labelWithString:@"100" fontName:@"DINCond-Black" fontSize:14];
    _rightCurHealthLabel.anchorPoint = ccp(1,0);
    _rightCurHealthLabel.position = ccp(rightHealthBarBg.contentSize.width/2, yOffset);
    [rightHealthBarBg addChild:_rightCurHealthLabel];
    
    _pausedLayer = [CCLayer node];
    [self addChild:_pausedLayer z:3];
    
    CCSprite *p = [CCSprite spriteWithFile:@"paused.png"];
    p.position = ccp(_pausedLayer.contentSize.width/2, _pausedLayer.contentSize.height/2+35);
    [_pausedLayer addChild:p];
    
    CCSprite *buttonImage = [CCSprite spriteWithFile:@"doneresume.png"];
    CCMenuItemSprite *button = [CCMenuItemSprite itemFromNormalSprite:buttonImage selectedSprite:nil target:self selector:@selector(resumeClicked)];
    
    menu = [CCMenu menuWithItems:button,nil];
    [_pausedLayer addChild:menu];
    menu.position = ccp(_pausedLayer.contentSize.width/2, _pausedLayer.contentSize.height/2-15);
    
    CCLabelTTF *resumeLabel = [CCLabelTTF labelWithString:@"Resume" fontName:@"Requiem Text-HTF-SmallCaps" fontSize:15];
    resumeLabel.color = ccc3(255, 200, 0);
    [button addChild:resumeLabel];
    resumeLabel.position = ccp(button.contentSize.width/2, button.contentSize.height/2);
    
    _fleeLayer = [CCLayer node];
    [self addChild:_fleeLayer z:3];
    
    p = [CCSprite spriteWithFile:@"youfled.png"];
    p.position = ccp(_fleeLayer.contentSize.width/2, _fleeLayer.contentSize.height/2+35);
    [_fleeLayer addChild:p];
    
    buttonImage = [CCSprite spriteWithFile:@"doneresume.png"];
    _fleeButton = [CCMenuItemSprite itemFromNormalSprite:buttonImage selectedSprite:nil target:self selector:@selector(doneClicked)];
    
    menu = [CCMenu menuWithItems:_fleeButton,nil];
    [_fleeLayer addChild:menu];
    menu.position = ccp(_fleeLayer.contentSize.width/2, _fleeLayer.contentSize.height/2-15);
    
    resumeLabel = [CCLabelTTF labelWithString:@"Done" fontName:@"Requiem Text-HTF-SmallCaps" fontSize:15];
    resumeLabel.color = ccc3(255, 200, 0);
    [_fleeButton addChild:resumeLabel];
    resumeLabel.position = ccp(_fleeButton.contentSize.width/2, _fleeButton.contentSize.height/2);
    
    _winLayer = [CCLayer node];
    [self addChild:_winLayer z:3];
    
    p = [CCSprite spriteWithFile:@"win.png"];
    p.position = ccp(_winLayer.contentSize.width/2, _winLayer.contentSize.height/2+35);
    [_winLayer addChild:p];
    
    buttonImage = [CCSprite spriteWithFile:@"doneresume.png"];
    _winButton = [CCMenuItemSprite itemFromNormalSprite:buttonImage selectedSprite:nil target:self selector:@selector(doneClicked)];
    
    menu = [CCMenu menuWithItems:_winButton,nil];
    [_winLayer addChild:menu];
    menu.position = ccp(_winLayer.contentSize.width/2, _winLayer.contentSize.height/2-15);
    
    CCLabelTTF *doneLabel = [CCLabelTTF labelWithString:@"Done" fontName:@"Requiem Text-HTF-SmallCaps" fontSize:15];
    doneLabel.color = ccc3(255, 200, 0);
    [_winButton addChild:doneLabel];
    doneLabel.position = ccp(_winButton.contentSize.width/2, _winButton.contentSize.height/2);
    
    _loseLayer = [CCLayer node];
    [self addChild:_loseLayer z:3];
    
    p = [CCSprite spriteWithFile:@"lost.png"];
    p.position = ccp(_loseLayer.contentSize.width/2, _loseLayer.contentSize.height/2+35);
    [_loseLayer addChild:p];
    
    buttonImage = [CCSprite spriteWithFile:@"doneresume.png"];
    _loseButton = [CCMenuItemSprite itemFromNormalSprite:buttonImage selectedSprite:nil target:self selector:@selector(doneClicked)];
    
    menu = [CCMenu menuWithItems:_loseButton,nil];
    [_loseLayer addChild:menu];
    menu.position = ccp(_loseLayer.contentSize.width/2, _loseLayer.contentSize.height/2-15);
    
    doneLabel = [CCLabelTTF labelWithString:@"Done" fontName:@"Requiem Text-HTF-SmallCaps" fontSize:15];
    doneLabel.color = ccc3(255, 200, 0);
    [_loseButton addChild:doneLabel];
    doneLabel.position = ccp(_loseButton.contentSize.width/2, _loseButton.contentSize.height/2);
    
    [[NSBundle mainBundle] loadNibNamed:@"BattleSummaryView" owner:self options:nil];
    
    self.isTouchEnabled = YES;
    
    _left = nil;
    _right = nil;
  }
  return self;
}

- (StolenEquipView *) gainedEquipView {
  if (!gainedEquipView) {
    [[NSBundle mainBundle] loadNibNamed:@"StolenEquipView" owner:self options:nil];
    self.gainedEquipView = self.stolenEquipView;
    self.stolenEquipView = nil;
  }
  return gainedEquipView;
}

- (StolenEquipView *) gainedLockBoxView {
  if (!gainedLockBoxView) {
    [[NSBundle mainBundle] loadNibNamed:@"StolenEquipView" owner:self options:nil];
    self.gainedLockBoxView = self.stolenEquipView;
    self.stolenEquipView = nil;
  }
  return gainedLockBoxView;
}

- (BattleTutorialView *) tutorialView {
  if (!_tutorialView) {
    [[NSBundle mainBundle] loadNibNamed:@"BattleTutorialView" owner:self options:nil];
  }
  return _tutorialView;
}

- (BOOL) beginBattleAgainst:(FullUserProto *)user {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (_isBattling) {
    return NO;
  }
  
  if (gs.currentStamina <= 0) {
    [[RefillMenuController sharedRefillMenuController] displayEnstView:NO];
    [Analytics notEnoughStaminaForBattle];
    return NO;
  }
  
  // Check if this is a clan tower battle
  int myClan = gs.clan.clanId;
  int enemyClan = user.clan.clanId;
  BOOL isClanTowerBattle = NO;
  if (myClan > 0 && enemyClan > 0) {
    for (ClanTowerProto *ctp in gs.clanTowers) {
      if (ctp.hasTowerAttacker && ctp.hasTowerOwner) {
        int ownerId = ctp.towerOwner.clanId;
        int attackerId = ctp.towerAttacker.clanId;
        
        if (myClan == ownerId && enemyClan == attackerId) {
          isClanTowerBattle = YES;
        }
        if (myClan == attackerId && enemyClan == ownerId) {
          isClanTowerBattle = YES;
        }
      }
    }
  }
  
  if (!isClanTowerBattle) {
    if (ABS(gs.level-user.level) > gl.maxLevelDiffForBattle) {
      [Globals popupMessage:@"The level difference is too much to start battle."];
      return NO;
    }
  }
  
  if (_fup != user) {
    [_fup release];
    _fup = [user retain];
  }
  
  if (![self battleOkayThroughUserDefaults]) {
    [Globals popupMessage:[NSString stringWithFormat:@"%@ has run away. Try again later.", user.name]];
    return NO;
  }
  
  if (user.isFake) {
    NSMutableArray *arr = [NSMutableArray array];
    if (user.hasWeaponEquippedUserEquip) [arr addObject:user.weaponEquippedUserEquip];
    if (user.hasArmorEquippedUserEquip) [arr addObject:user.armorEquippedUserEquip];
    if (user.hasAmuletEquippedUserEquip) [arr addObject:user.amuletEquippedUserEquip];
    self.enemyEquips = arr;
  } else {
    self.enemyEquips = nil;
    [[OutgoingEventController sharedOutgoingEventController] retrieveEquipsForUser:user.userId];
  }
  
  [self removeChild:_left cleanup:YES];
  [self removeChild:_right cleanup:YES];
  [self removeChildByTag:DEATH_PS_TAG cleanup:YES];
  
  _left = [CCSprite spriteWithFile:[Globals battleImageNameForUser:gs.type]];
  _right = [CCSprite spriteWithFile:[Globals battleImageNameForUser:user.userType]];
  _right.flipX = YES;
  
  _left.position = ccp(-_left.contentSize.width/2, _left.contentSize.height/2);
  _right.position = ccp([[CCDirector sharedDirector] winSize].width+_left.contentSize.width/2, _right.contentSize.height/2);
  
  [self addChild:_left z:1];
  [self addChild:_right z:1];
  
  _leftMaxHealth = [gl calculateHealthForLevel:gs.level];
  _leftCurrentHealth = _leftMaxHealth;
  _rightMaxHealth = [gl calculateHealthForLevel:user.level];
  _rightCurrentHealth = _rightMaxHealth;
  
  _leftNameLabel.string = gs.name;
  _leftNameBg.position = ccp(_leftNameBg.contentSize.width+_leftNameLabel.contentSize.width-_leftNameLabel.position.x+15, _leftNameBg.position.y);
  _rightNameLabel.string = user.name;
  _rightNameBg.position = ccp(_rightNameBg.parent.contentSize.width-_rightNameLabel.contentSize.width-_rightNameLabel.position.x-15, _rightNameBg.position.y);
  
  _rightCurHealthLabel.string = [NSString stringWithFormat:@"%d", _rightCurrentHealth];
  _rightMaxHealthLabel.string = [NSString stringWithFormat:@" / %d", _rightMaxHealth];
  _leftCurHealthLabel.string = [NSString stringWithFormat:@"%d", _leftCurrentHealth];
  _leftMaxHealthLabel.string = [NSString stringWithFormat:@" / %d", _leftMaxHealth];
  
  _enemyType = user.userType;
  
  _cityId = -1;
  
  CCDirector *dir = [CCDirector sharedDirector];
  if (!_isRunning) {
    GameLayer *gameLayer = [GameLayer sharedGameLayer];
    if (gameLayer.currentCity > 0) {
      GameMap *gm = gameLayer.currentMap;
      if ([gm enemyWithUserId:user.userId]) {
        _cityId = gameLayer.currentCity;
      }
    }
    
    _isRunning = YES;
    CCScene *scene = [BattleLayer scene];
    [dir pushScene:[CCTransitionFade transitionWithDuration:TRANSITION_DURATION scene:scene]];
    
    ChatBottomView *cbv = [TopBar sharedTopBar].chatBottomView;
    [UIView animateWithDuration:TRANSITION_DURATION animations:^{
      cbv.alpha = 0.f;
    } completion:^(BOOL finished) {
      cbv.hidden = YES;
    }];
    
    // Remove mapviewcontroller in case we were called from there
    // but record whether we came from there or not
    if ([AttackMenuController isInitialized]) {
      AttackMenuController *avc = [AttackMenuController sharedAttackMenuController];
      if (avc.view.superview) {
        [[AttackMenuController sharedAttackMenuController] close];
        _cameFromAviary = YES;
        
        // Set city id to 0 so that it works even in the event that you attack from profile
        _cityId = 0;
      } else {
        _cameFromAviary = NO;
      }
    } else {
      _cameFromAviary = NO;
    }
    
    if ([MarketplaceViewController isInitialized]) {
      [[MarketplaceViewController sharedMarketplaceViewController] backClicked:nil];
    }
    
    if ([LeaderboardController isInitialized]) {
      [[LeaderboardController sharedLeaderboardController] closeClicked:nil];
    }
    
    if ([ClanMenuController isInitialized]) {
      ClanMenuController *cmc = [ClanMenuController sharedClanMenuController];
      if (cmc.view.superview) {
        _cameFromClans = YES;
        [cmc close];
      } else {
        _cameFromClans = NO;
      }
    } else {
      _cameFromClans = NO;
    }
    
    if ([ChatMenuController isInitialized]) {
      [[ChatMenuController sharedChatMenuController] close];
    }
    
    if ([ActivityFeedController isInitialized]) {
      [[ActivityFeedController sharedActivityFeedController] close];
    }
    
    if ([TournamentMenuController isInitialized]) {
      TournamentMenuController *tmc = [TournamentMenuController sharedTournamentMenuController];
      if (tmc.view.superview) {
        [tmc closeClicked:nil];
        _cameFromTournament = YES;
      } else {
        _cameFromTournament = NO;
      }
    } else {
      _cameFromTournament = NO;
    }
  } else {
    [self startBattle];
  }
  
  self.brp = nil;
  
  // Close the menus
  [[GameLayer sharedGameLayer] closeMenus];
  
  _attackButton.visible = NO;
  _comboBar.visible = NO;
  _flippedComboBar.visible = NO;
  _bottomMenu.visible = NO;
  _pausedLayer.visible = NO;
  _fleeLayer.visible = NO;
  _winLayer.visible = NO;
  _loseLayer.visible = NO;
  _isBattling = YES;
  _guaranteeWin = NO;
  
  // Pop out the end views
  if (gainedEquipView.superview) {
    [Globals popOutView:gainedEquipView.mainView fadeOutBgdView:gainedEquipView.bgdView completion:^{
      [gainedEquipView removeFromSuperview];
    }];
  }
  if (gainedLockBoxView.superview) {
    [Globals popOutView:gainedLockBoxView.mainView fadeOutBgdView:gainedLockBoxView.bgdView completion:^{
      [gainedLockBoxView removeFromSuperview];
    }];
  }
  if (summaryView.superview) {
    [Globals popOutView:summaryView.mainView fadeOutBgdView:summaryView.bgdView completion:^{
      [summaryView removeFromSuperview];
    }];
  }
  
  _leftHealthBar.position = ccp(0, _leftHealthBar.parent.contentSize.height/2);
  _rightHealthBar.position = ccp(_rightHealthBar.parent.contentSize.width, _rightHealthBar.parent.contentSize.height/2);
  
  [_battleCalculator release];
  _battleCalculator = [BattleCalculator createWithRightStats:[UserBattleStats
                                                              createWithFullUserProto:_fup]
                                                andLeftStats:[UserBattleStats
                                                              createFromGameState]];
  [_battleCalculator retain];
  
  return YES;
}

- (void) onEnterTransitionDidFinish {
  [super onEnterTransitionDidFinish];
  [self startBattle];
}

- (BOOL) beginBattleAgainst:(FullUserProto *)user inCity:(int) cityId {
  BOOL ret = [self beginBattleAgainst:user];
  _cityId = cityId;
  return ret;
}

- (void) startBattle {
  _attackButton.visible = NO;
  _comboBar.visible = NO;
  _flippedComboBar.visible = NO;
  _bottomMenu.visible = NO;
  _pausedLayer.visible = NO;
  _fleeLayer.visible = NO;
  _winLayer.visible = NO;
  _loseLayer.visible = NO;
  _isBattling = YES;
  
  _leftHealthBar.position = ccp(0, _leftHealthBar.parent.contentSize.height/2);
  _rightHealthBar.position = ccp(_rightHealthBar.parent.contentSize.width, _rightHealthBar.parent.contentSize.height/2);
  
  [[SoundEngine sharedSoundEngine] playBattleMusic];
  
  [_left runAction: [CCMoveBy actionWithDuration:0.6 position:ccp(3*_left.contentSize.width/4,0)]];
  
  [_right runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:0.6],
                     [CCMoveBy actionWithDuration:0.5 position:ccp(-3*_right.contentSize.width/4,0)],
                     [CCCallFunc actionWithTarget:self selector:@selector(startMyTurn)],
                     nil]];
}

- (void) startMyTurn {
  if (_pausedLayer.visible) {
    // In case looking at profile
    return;
  }
  _attackButton.visible = YES;
  _comboBar.visible = NO;
  _bottomMenu.visible = YES;
  _isAnimating = NO;
  _attackMoving = YES;
  
  [_attackProgressTimer runAction:[CCSequence actionOne:[CCProgressFromTo actionWithDuration:ATTACK_BUTTON_ANIMATION from:100 to:0]
                                                    two:[CCCallFunc actionWithTarget:self selector:@selector(turnMissed)]]];
}

- (void) attackStart {
  if (!_attackMoving) {
    return;
  }
  _attackMoving = NO;
  [_attackProgressTimer stopAllActions];
  
  _bottomMenu.visible = NO;
  _attackButton.visible = NO;
  _isAnimating = YES;
  
  float duration = [self rand]*(MAX_COMBO_BAR_DURATION-MIN_COMBO_BAR_DURATION)+MIN_COMBO_BAR_DURATION;
  _triangle.rotation = START_TRIANGLE_ROTATION;
  [_triangle runAction:
   [CCSequence actionOne:[CCEaseIn actionWithAction:
                          [CCRotateBy actionWithDuration:duration angle:END_TRIANGLE_ROTATION-START_TRIANGLE_ROTATION] rate:2.5]
                     two:[CCCallFunc actionWithTarget:self selector:@selector(comboBarClicked)]]];
  
  [self runAction:[CCSequence actions:
                   [CCDelayTime actionWithDuration:DELAY_BEFORE_COMBO_BAR_WINDUP_SOUND],
                   [CCCallBlock actionWithBlock:
                    ^{
                      if (_comboBarMoving) {
                        [Globals playComboBarChargeupSound:[GameState sharedGameState].type];
                      }
                    }], nil]];
  
  _comboBar.visible = YES;
  _comboBarMoving = YES;
}

- (void) turnMissed {
  if (!_attackMoving) {
    return;
  }
  _attackButton.visible = NO;
  _attackMoving = NO;
  _isAnimating = YES;
  [[SoundEngine sharedSoundEngine] stopCharge];
  [self startEnemyTurn];
}

- (void) comboBarClicked {
  if (_comboBarMoving) {
    [_triangle stopAllActions];
    _comboBarMoving = NO;
    [self stopAllActions];
    
    [[SoundEngine sharedSoundEngine] stopCharge];
    
    float percentage = (_triangle.rotation-START_TRIANGLE_ROTATION)/(END_TRIANGLE_ROTATION-START_TRIANGLE_ROTATION)*100;
    _damageDone = [self calculateMyDamageForPercentage:percentage];
    
    if (_rightCurrentHealth - _damageDone <= 0) {
      [[OutgoingEventController sharedOutgoingEventController] battle:_fup result:BattleResultAttackerWin city:_cityId equips:enemyEquips];
      
      if (_cityId > 0 && [[GameLayer sharedGameLayer] currentCity] == _cityId) {
        [[[GameLayer sharedGameLayer] missionMap] killEnemy:_fup.userId];
      }
    }
    
    [self showBattleWordForPercentage:percentage];
    
    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:0.5] two:[CCCallFunc actionWithTarget:self selector:@selector(doAttackAnimation)]]];
  }
}

- (CCSprite *)spriteForPercentage:(float)percent {
  CombatDamageType dmgType = [_battleCalculator damageZoneForPercent:percent];
  SoundEngine *se = [SoundEngine sharedSoundEngine];
  switch (dmgType) {
    case DMG_TYPE_PERFECT:
      [se perfectAttack];
      return [CCSprite spriteWithFile:@"perfect.png"];
      break;
    case DMG_TYPE_GREAT:
      [se greatAttack];
      return [CCSprite spriteWithFile:@"great.png"];
      break;
    case DMG_TYPE_GOOD:
      [se goodAttack];
      return [CCSprite spriteWithFile:@"good.png"];
      break;
    case DMG_TYPE_MISS:
      [se missAttack];
      return [CCSprite spriteWithFile:@"miss.png"];
      break;
      
    default:
      break;
  }
}

- (void) showBattleWordForPercentage:(float)percent {
  CCSprite *battleWord = [self spriteForPercentage:percent];
  [_comboBar.parent addChild:battleWord];
  battleWord.position = _comboBar.position;
  
  battleWord.scale = 0.1f;
  [battleWord runAction: [CCSequence actions:
                          [CCEaseElasticOut actionWithAction:[CCScaleTo actionWithDuration:1.f scale:FINAL_BATTLE_WORLD_SCALE]],
                          [CCDelayTime actionWithDuration:0.2f],
                          [CCFadeOut actionWithDuration:0.6f],
                          [CCCallBlock actionWithBlock:^{[battleWord removeFromParentAndCleanup:YES];}],
                          nil]];
}

- (void) doAttackAnimation {
  _comboBar.visible = NO;
  
  [_left runAction: [CCSequence actions:
                     // Move a little back to ready an attack
                     [CCMoveBy actionWithDuration:0.2 position:ccp(-50, 0)],
                     // Delay so it looks like we're ready
                     [CCDelayTime actionWithDuration:0.1],
                     // ATTACK!!
                     [CCMoveBy actionWithDuration:0.02 position:ccp(50, 0)],
                     // Fade out and scale, attack done
                     [CCCallFunc actionWithTarget:self selector:@selector(leftClassSpecificAnimation)],
                     nil]];
  
}

- (CGPoint) startParticlePositionForType:(UserType) type {
  switch (type) {
    case UserTypeGoodArcher:
      return ccp(211,105);
      
    case UserTypeBadArcher:
      return ccp(211,112);
      
    case UserTypeGoodWarrior:
    case UserTypeBadWarrior:
      return ccp(self.contentSize.width-50, 55);
      
    case UserTypeBadMage:
    case UserTypeGoodMage:
      return ccp(211,105);
      
    default:
      break;
  }
  return ccp(0,0);
}

- (void) leftClassSpecificAnimation {
  [Globals playBattleAttackSound:[GameState sharedGameState].type];
  
  GameState *gs = [GameState sharedGameState];
  UserType type = gs.type;
  CCParticleSystemQuad *ps = [[CCParticleSystemQuad alloc] initWithFile:[Globals battleAnimationFileForUser:type]];
  [self addChild:ps z:2];
  ps.position = [self startParticlePositionForType:type];
  [ps release];
  
  if (type == UserTypeGoodWarrior || type == UserTypeBadWarrior) {
    [ps runAction:[CCSequence actions:
                   [CCDelayTime actionWithDuration:ps.duration+ps.life],
                   [CCCallFunc actionWithTarget:self selector:@selector(attackAnimationDone)],
                   nil]];
  } else if (type == UserTypeGoodMage) {
    [ps runAction:[CCSequence actions:
                   [CCMoveBy actionWithDuration:ps.duration position:ccp(220,0)],
                   [CCCallFunc actionWithTarget:self selector:@selector(attackAnimationDone)],
                   nil]];
  } else if (type == UserTypeGoodArcher) {
    [ps runAction:[CCSequence actions:
                   [CCMoveBy actionWithDuration:ps.duration position:ccp(220,0)],
                   [CCCallFunc actionWithTarget:self selector:@selector(attackAnimationDone)],
                   nil]];
  } else if (type == UserTypeBadMage) {
    [ps runAction:[CCSequence actions:
                   [CCMoveBy actionWithDuration:ps.duration position:ccp(220,0)],
                   [CCCallFunc actionWithTarget:self selector:@selector(attackAnimationDone)],
                   nil]];
  } else if (type == UserTypeBadArcher) {
    [ps runAction:[CCSequence actions:
                   [CCMoveBy actionWithDuration:ps.duration position:ccp(220,5)],
                   [CCCallFunc actionWithTarget:self selector:@selector(attackAnimationDone)],
                   nil]];
  }
  
}

- (void) attackAnimationDone {
  _rightCurrentHealth -= _damageDone;
  _rightCurrentHealth = MAX(0, _rightCurrentHealth);
  [self setRightHealthBarPercentage:((float)_rightCurrentHealth)/_rightMaxHealth*100];
  
  CCLabelTTF *damageLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"-%d", (int)_damageDone] fontName:@"DINCond-Black" fontSize:35];
  [self addChild:damageLabel z:3];
  damageLabel.position = ccp(self.contentSize.width-50, 180);
  damageLabel.color = ccc3(255, 0, 0);
  [damageLabel runAction:[CCSequence actions:
                          [CCSpawn actions:
                           [CCFadeOut actionWithDuration:1.f],
                           [CCMoveBy actionWithDuration:1.f position:ccp(0,40)],nil],
                          [CCCallBlock actionWithBlock:^{[damageLabel removeFromParentAndCleanup:YES];}], nil]];
  
  CCTintBy *tintAction = [CCTintBy actionWithDuration:0.25 red:0 green:-255 blue:-255];
  [_right runAction:[CCSpawn actions:
                     [CCRepeat actionWithAction:[CCSequence actions:tintAction, tintAction.reverse, nil] times:2],
                     nil]];
  
}

- (void) setRightHealthBarPercentage:(float)percentage {
  // Anchor point is (1,0.5)
  CGPoint finalPt;
  SEL afterAction;
  float width = _rightHealthBar.contentSize.width;
  if (percentage > 0) {
    float endPos = width * percentage / 100;
    finalPt = ccp(_rightHealthBar.parent.contentSize.width+width-endPos, _rightHealthBar.position.y);
    afterAction = @selector(startEnemyTurn);
  } else {
    finalPt = ccp(_rightHealthBar.parent.contentSize.width+width, _rightHealthBar.position.y);
    afterAction = @selector(myWin);
  }
  float dist = ccpDistance(finalPt, _rightHealthBar.position);
  [_rightHealthBar runAction:[CCSequence actions:
                              [CCEaseSineIn actionWithAction:[CCMoveTo actionWithDuration:dist/HEALTH_BAR_VELOCITY position:finalPt]],
                              [CCCallFuncN actionWithTarget:self selector:@selector(doneWithRightHealthBar)],
                              [CCDelayTime actionWithDuration:0.5],
                              [CCCallFunc actionWithTarget:self selector:afterAction], nil]];
  
  [self schedule:@selector(updateRightLabel)];
}

- (void) updateRightLabel {
  float width = _rightHealthBar.contentSize.width;
  float pos = _rightHealthBar.position.x;
  float percentage = (_rightHealthBar.parent.contentSize.width+width-pos)*100.f/width;
  _rightCurHealthLabel.string = [NSString stringWithFormat:@"%d", (int)(percentage/100*_rightMaxHealth)];
}

- (void) doneWithRightHealthBar {
  [self unschedule:@selector(updateRightLabel)];
  _rightCurHealthLabel.string = [NSString stringWithFormat:@"%d", _rightCurrentHealth];
}

- (void) startEnemyTurn {
  float perc = [self calculateEnemyPercentage];
  _damageDone = [self calculateEnemyDamageForPercentage:perc];
  
  if (_leftCurrentHealth - _damageDone <= 0) {
    [[OutgoingEventController sharedOutgoingEventController] battle:_fup result:BattleResultDefenderWin city:-1 equips:nil];
  }
  
  _bottomMenu.visible = NO;
  _attackButton.visible = NO;
  _flippedComboBar.visible = YES;
  float duration = [self rand]*(MAX_COMBO_BAR_DURATION-MIN_COMBO_BAR_DURATION)+MIN_COMBO_BAR_DURATION;
  float end = -START_TRIANGLE_ROTATION+(-END_TRIANGLE_ROTATION+START_TRIANGLE_ROTATION)*perc/100.f;
  _flippedTriangle.rotation = -START_TRIANGLE_ROTATION;
  [_flippedTriangle runAction:[CCSequence actions:
                               [CCEaseIn actionWithAction:
                                [CCRotateBy actionWithDuration:perc*duration/100 angle:end+START_TRIANGLE_ROTATION] rate:2.5],
                               [CCCallBlock actionWithBlock:^{[self showEnemyBattleWordForPercentage:perc];}],
                               [CCDelayTime actionWithDuration:0.5],
                               [CCCallFunc actionWithTarget:self selector:@selector(doEnemyAttackAnimation)],
                               nil]];
  
  [self runAction:[CCSequence actions:
                   [CCDelayTime actionWithDuration:DELAY_BEFORE_COMBO_BAR_WINDUP_SOUND],
                   [CCCallBlock actionWithBlock:^{
    [Globals playComboBarChargeupSound:_enemyType];
  }], nil]];
}

- (void) showEnemyBattleWordForPercentage:(float)percent {
  CCSprite *battleWord = [self spriteForPercentage:percent];
  [_flippedComboBar.parent addChild:battleWord];
  battleWord.position = _flippedComboBar.position;
  
  battleWord.scale = 0.1f;
  [battleWord runAction: [CCSequence actions:
                          [CCEaseElasticOut actionWithAction:[CCScaleTo actionWithDuration:1.f scale:FINAL_BATTLE_WORLD_SCALE]],
                          [CCDelayTime actionWithDuration:0.2f],
                          [CCFadeOut actionWithDuration:0.6f],
                          [CCCallBlock actionWithBlock:^{[battleWord removeFromParentAndCleanup:YES];}],
                          nil]];
}

- (void) doEnemyAttackAnimation {
  [[SoundEngine sharedSoundEngine] stopCharge];
  
  _flippedComboBar.visible = NO;
  [_right runAction: [CCSequence actions:
                      // Move a little back to ready an attack
                      [CCMoveBy actionWithDuration:0.2 position:ccp(50, 0)],
                      // Delay so it looks like we're ready
                      [CCDelayTime actionWithDuration:0.1],
                      // ATTACK!!
                      [CCMoveBy actionWithDuration:0.02 position:ccp(-50, 0)],
                      // Wait a bit before
                      // Call the done selector
                      [CCCallFunc actionWithTarget:self selector:@selector(rightClassSpecificAnimation)],
                      nil]];
}

- (void) rightClassSpecificAnimation {
  UserType type = _enemyType;
  CCParticleSystemQuad *ps = [[CCParticleSystemQuad alloc] initWithFile:[Globals battleAnimationFileForUser:type]];
  [self addChild:ps z:2];
  ps.angle = 180 - ps.angle;
  ps.gravity = ccp(-ps.gravity.x, ps.gravity.y);
  [ps release];
  
  [Globals playBattleAttackSound:_enemyType];
  
  CGPoint pos = [self startParticlePositionForType:type];
  ps.position = ccp(self.contentSize.width-pos.x, pos.y);
  
  if (type == UserTypeGoodWarrior || type == UserTypeBadWarrior) {
    [ps runAction:[CCSequence actions:
                   [CCDelayTime actionWithDuration:ps.duration+ps.life],
                   [CCCallFunc actionWithTarget:self selector:@selector(enemyAttackDone)],
                   nil]];
  } if (type == UserTypeGoodArcher) {
    [ps runAction:[CCSequence actions:
                   [CCMoveBy actionWithDuration:ps.duration position:ccp(-220,0)],
                   [CCCallFunc actionWithTarget:self selector:@selector(enemyAttackDone)],
                   nil]];
  } else if (type == UserTypeGoodMage) {
    [ps runAction:[CCSequence actions:
                   [CCMoveBy actionWithDuration:ps.duration position:ccp(-220,0)],
                   [CCCallFunc actionWithTarget:self selector:@selector(enemyAttackDone)],
                   nil]];
  } else if (type == UserTypeBadMage) {
    [ps runAction:[CCSequence actions:
                   [CCMoveBy actionWithDuration:ps.duration position:ccp(-220,0)],
                   [CCCallFunc actionWithTarget:self selector:@selector(enemyAttackDone)],
                   nil]];
  } else if (type == UserTypeBadArcher) {
    [ps runAction:[CCSequence actions:
                   [CCMoveBy actionWithDuration:ps.duration position:ccp(-220,5)],
                   [CCCallFunc actionWithTarget:self selector:@selector(enemyAttackDone)],
                   nil]];
  }
  
}

- (void) enemyAttackDone {
  _leftCurrentHealth -= _damageDone;
  _leftCurrentHealth = MAX(0, _leftCurrentHealth);
  [self setLeftHealthBarPercentage:((float)_leftCurrentHealth)/_leftMaxHealth*100];
  
  CCLabelTTF *damageLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"-%d", (int)_damageDone] fontName:@"DINCond-Black" fontSize:35];
  [self addChild:damageLabel z:3];
  damageLabel.position = ccp(50, 180);
  damageLabel.color = ccc3(255, 0, 0);
  [damageLabel runAction:[CCSequence actions:
                          [CCSpawn actions:
                           [CCFadeOut actionWithDuration:1.f],
                           [CCMoveBy actionWithDuration:1.f position:ccp(0,40)],nil],
                          [CCCallBlock actionWithBlock:^{[damageLabel removeFromParentAndCleanup:YES];}], nil]];
  
  
  CCTintBy *tintAction = [CCTintBy actionWithDuration:0.25 red:0 green:-255 blue:-255];
  [_left runAction:[CCSpawn actions:
                    [CCRepeat actionWithAction:[CCSequence actions:tintAction, tintAction.reverse, nil] times:2],
                    nil]];
}

- (float) calculateEnemyPercentage {
  return [_battleCalculator calculateEnemyPercentage];
}

- (int) calculateEnemyDamageForPercentage:(float)percent {
  if (!_guaranteeWin) {
    return [_battleCalculator rightAttackStrengthForPercent:percent];
  } else {
    return MIN([_battleCalculator rightAttackStrengthForPercent:percent], _leftCurrentHealth/3);
  }
}

- (int) calculateMyDamageForPercentage:(float)percent {
  if (!_isForTutorial) {
    return [_battleCalculator leftAttackStrengthForPercent:percent];
  } else {
    return MIN([_battleCalculator leftAttackStrengthForPercent:percent], _rightCurrentHealth/2);
  }
}

- (void) setLeftHealthBarPercentage:(float)percentage {
  // Anchor point is (0,0.5)
  CGPoint finalPt;
  SEL afterAction;
  float width = _leftHealthBar.contentSize.width;
  if (percentage > 0) {
    float endPos = width * percentage / 100;
    finalPt = ccp(endPos-width, _leftHealthBar.position.y);
    afterAction = @selector(startMyTurn);
  } else {
    finalPt = ccp(-width, _leftHealthBar.position.y);
    afterAction = @selector(myLoss);
  }
  
  float dist = ccpDistance(finalPt, _leftHealthBar.position);
  [_leftHealthBar runAction:[CCSequence actions:
                             [CCEaseSineIn actionWithAction:[CCMoveTo actionWithDuration:dist/HEALTH_BAR_VELOCITY position:finalPt]],
                             [CCCallFuncN actionWithTarget:self selector:@selector(doneWithLeftHealthBar)],
                             [CCCallFunc actionWithTarget:self selector:afterAction], nil]];
  [self schedule:@selector(updateLeftLabel)];
}

- (void) updateLeftLabel {
  float width = _leftHealthBar.contentSize.width;
  float pos = _leftHealthBar.position.x;
  float percentage = (pos+width)*100.f/width;
  _leftCurHealthLabel.string = [NSString stringWithFormat:@"%d", (int)(percentage/100*_leftMaxHealth)];
}

- (void) doneWithLeftHealthBar {
  [self unschedule:@selector(updateLeftLabel)];
  _leftCurHealthLabel.string = [NSString stringWithFormat:@"%d", _leftCurrentHealth];
}

- (void) myWin {
  _isAnimating = NO;
  [_right runAction:[CCSpawn actions:
                     [CCScaleBy actionWithDuration:0.3 scale:1.2],
                     [CCFadeOut actionWithDuration:0.3],
                     nil]];
  
  CCParticleSystemQuad *ps = [CCParticleSystemQuad particleWithFile:@"death.plist"];
  [self addChild:ps z:3 tag:DEATH_PS_TAG];
  
  _winLayer.visible = YES;
  _winLayer.scale = 1.5f;
  [_winLayer runAction:[CCScaleTo actionWithDuration:0.2f scale:1.f]];
  
  [[SoundEngine sharedSoundEngine] stopBackgroundMusic];
  [[SoundEngine sharedSoundEngine] battleVictory];
  
  // Set the city id to 0 if win, only want it to count as 1 win
  _cityId = -1;
  
  if (!brp) {
    _winButton.visible = NO;
    [self schedule:@selector(checkWinBrp)];
  }
}

- (void) checkWinBrp {
  if (brp) {
    _winButton.visible = YES;
    [self unschedule:@selector(checkWinBrp)];
  }
}

- (void) myLoss {
  _isAnimating = NO;
  [_left runAction:[CCSpawn actions:
                    [CCScaleBy actionWithDuration:0.3 scale:1.2],
                    [CCFadeOut actionWithDuration:0.3],
                    nil]];
  
  
  CCParticleSystemQuad *ps = [CCParticleSystemQuad particleWithFile:@"death.plist"];
  [self addChild:ps z:3];
  ps.position = ccp(self.contentSize.width-ps.position.x, ps.position.y);
  ps.angle = 180-ps.angle;
  
  _loseLayer.visible = YES;
  _loseLayer.scale = 1.5f;
  [_loseLayer runAction:[CCScaleTo actionWithDuration:0.2f scale:1.f]];
  
  [[SoundEngine sharedSoundEngine] stopBackgroundMusic];
  [[SoundEngine sharedSoundEngine] battleLoss];
  
  if (!brp) {
    _loseButton.visible = NO;
    [self schedule:@selector(checkLoseBrp)];
  }
  _loseButton.visible = YES;
}

- (void) checkLoseBrp {
  if (brp) {
    _loseButton.visible = YES;
    [self unschedule:@selector(checkLoseBrp)];
  }
}

- (void) fleeClicked {
  [self pauseClicked];
  [GenericPopupController displayConfirmationWithDescription:@"Are you sure you would like to flee from this battle?" title:@"Flee?" okayButton:@"Flee" cancelButton:@"Cancel" target:self selector:@selector(flee)];
}

- (void) flee {
  [[OutgoingEventController sharedOutgoingEventController] battle:_fup result:BattleResultAttackerFlee city:-1 equips:nil];
  [_attackProgressTimer stopAllActions];
  _attackButton.visible = NO;
  _pausedLayer.visible = NO;
  _fleeLayer.visible = YES;
  _bottomMenu.visible = NO;
  
  [[SoundEngine sharedSoundEngine] stopBackgroundMusic];
  [[SoundEngine sharedSoundEngine] battleLoss];
  
  if (!brp) {
    _fleeButton.visible = NO;
    [self schedule:@selector(checkFleeBrp)];
  }
  
  [Analytics fleeWithHealth:_leftCurrentHealth enemyHealth:_rightCurrentHealth];
}

- (void) checkFleeBrp {
  if (brp) {
    _fleeButton.visible = YES;
    [self unschedule:@selector(checkFleeBrp)];
  }
}

- (void) pauseClicked {
  if (_isBattling && !_winLayer.visible && !_loseLayer.visible && !_fleeLayer.visible) {
    _pausedLayer.visible = YES;
    _attackButton.visible = NO;
    [_attackProgressTimer pauseSchedulerAndActions];
  }
}

- (void) resumeClicked {
  if (_attackMoving) {
    _pausedLayer.visible = NO;
    _attackButton.visible = YES;
    [_attackProgressTimer resumeSchedulerAndActions];
  } else {
    _pausedLayer.visible = NO;
    [self startMyTurn];
  }
}

- (void) setBrp:(BattleResponseProto *)b {
  if (brp != b) {
    _clickedDone = NO;
    [brp release];
    brp = [b retain];
    
    if (brp) {
      [self registerBattleInUserDefaults];
    }
  }
}

- (void) registerBattleInUserDefaults {
  NSString *key = BATTLE_USER_DEFAULTS_KEY;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *arr = [defaults arrayForKey:key];
  NSMutableArray *mut = arr ? [[arr mutableCopy] autorelease] : [NSMutableArray array];
  [mut addObject:[NSDate date]];
  [defaults setObject:mut forKey:BATTLE_USER_DEFAULTS_KEY];
  [defaults synchronize];
}

- (BOOL) battleOkayThroughUserDefaults {
  Globals *gl = [Globals sharedGlobals];
  NSString *key = BATTLE_USER_DEFAULTS_KEY;
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *arr = [[[defaults arrayForKey:key] mutableCopy] autorelease];
  int origCount = arr.count;
  int numTimes = 0;
  NSMutableArray *x = [NSMutableArray array];
  if (arr.count >= gl.maxNumTimesAttackedByOneInProtectionPeriod) {
    for (NSDate *date in arr) {
      if ([date timeIntervalSinceNow] > -gl.hoursInAttackedByOneProtectionPeriod*3600) {
        numTimes++;
      } else {
        [x addObject:date];
      }
    }
  }
  [arr removeObjectsInArray:x];
  if (arr.count < origCount) {
    [defaults setObject:arr forKey:BATTLE_USER_DEFAULTS_KEY];
    [defaults synchronize];
  }
  
  if (numTimes < gl.maxNumTimesAttackedByOneInProtectionPeriod) {
    return YES;
  } else {
    return NO;
  }
}

- (void) doneClicked {
  if (_clickedDone) {
    return;
  }
  _clickedDone = YES;
  
  if (brp.shouldGiveKiipReward) {
    //    [KiipDelegate postAchievementNotificationAchievement:BATTLE_WON_KIIP_REWARD];
    
  }
  
  _isBattling = NO;
  if (_left.opacity > 0) {
    SEL completeAction = nil;
    if (brp.hasUserEquipGained) {
      completeAction = @selector(displayStolenEquip);
    } else if (brp.hasEventIdOfLockBoxGained) {
      completeAction = @selector(displayStolenLockBox);
    } else {
      completeAction = @selector(displaySummary);
    }
    [_left runAction: [CCSequence actions:
                       [CCDelayTime actionWithDuration:0.1],
                       [CCMoveBy actionWithDuration:0.4 position:ccp(-3*_right.contentSize.width/4, 0)],
                       [CCCallFunc actionWithTarget:self selector:completeAction],
                       nil]];
  } else {
    [_right runAction: [CCSequence actions:
                        [CCDelayTime actionWithDuration:0.1],
                        [CCMoveBy actionWithDuration:0.4 position:ccp(3*_right.contentSize.width/4, 0)],
                        [CCCallFunc actionWithTarget:self selector:@selector(displaySummary)],
                        nil]];
  }
}

- (void) displayStolenEquip {
  [self.gainedEquipView loadForEquip:brp.userEquipGained];
  [Globals displayUIView:self.gainedEquipView];
  [Globals bounceView:self.gainedEquipView.mainView fadeInBgdView:self.gainedEquipView.bgdView];
}

- (void) displayStolenLockBox {
  [self.gainedLockBoxView loadForLockBox:brp.eventIdOfLockBoxGained];
  [Globals displayUIView:self.gainedLockBoxView];
  [Globals bounceView:self.gainedLockBoxView.mainView fadeInBgdView:self.gainedLockBoxView.bgdView];
}

- (float) rand {
  return ((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX);
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_comboBarMoving) {
    [self comboBarClicked];
  }
}

- (IBAction) stolenEquipOkayClicked:(id)sender {
  if (gainedEquipView.superview) {
    [Globals popOutView:gainedEquipView.mainView fadeOutBgdView:gainedEquipView.bgdView completion:^{
      [gainedEquipView removeFromSuperview];
    }];
    if (brp.hasEventIdOfLockBoxGained) {
      [self displayStolenLockBox];
    } else {
      [self displaySummary];
    }
  } else if (gainedLockBoxView.superview) {
    [Globals popOutView:gainedLockBoxView.mainView fadeOutBgdView:gainedLockBoxView.bgdView completion:^{
      [gainedLockBoxView removeFromSuperview];
    }];
    [self displaySummary];
  }
}

- (void) displaySummary {
  [summaryView loadBattleSummaryForBattleResponse:brp enemy:_fup];
  [Globals displayUIView:summaryView];
  [Globals bounceView:summaryView.mainView fadeInBgdView:summaryView.bgdView];
  
  if (_isForTutorial) {
    [Globals displayUIView:self.tutorialView];
    [self.tutorialView displayInitialViewWithSummaryView:self.summaryView andAnalysisView:self.analysisView];
  }
}

- (IBAction)closeClicked:(id)sender {
  [self.summaryView close];
  [self closeScene];
}

- (IBAction) attackAgainClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  if (gs.currentStamina > 0) {
    [self beginBattleAgainst:_fup inCity:_cityId];
    
    [Analytics attackAgain];
  } else {
    [[RefillMenuController sharedRefillMenuController] displayEnstView:NO];
  }
}

- (IBAction)analysisClicked:(id)sender {
  [Globals bounceView:self.analysisView.mainView fadeInBgdView:self.analysisView.bgdView];
  [Globals displayUIView:self.analysisView];
  [self.analysisView loadForEnemy:_fup];
}

- (IBAction)viewChestInArmoryClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  if (!_isForTutorial) {
    [ArmoryViewController displayView];
    [[ArmoryViewController sharedArmoryViewController] loadForLevel:gs.level rarity:FullEquipProto_RarityEpic];
  } else {
    [[GameLayer sharedGameLayer] performBattleLossTutorial];
    _isForTutorial = NO;
    [self.analysisView endTutorialPhase];
  }
  [self.analysisView closeClicked:nil];
  [self.summaryView close];
  [self closeSceneFromQuestLog];
}

- (IBAction) profileButtonClicked:(id)sender {
  if (_isAnimating) {
    return;
  }
  
  if (_isBattling) {
    [self pauseClicked];
  }
  
  BOOL isMe = NO;
  if ([sender isKindOfClass:[UIButton class]]) {
    int tag = [(UIButton *)sender tag];
    if (tag == 1) {
      isMe = YES;
    }
  }
  
  // Send in attack and defense in case of fake players
  if (isMe) {
    [[ProfileViewController sharedProfileViewController] loadMyProfile];
  } else {
    [[ProfileViewController sharedProfileViewController] loadProfileForPlayer:_fup equips:self.enemyEquips attack:_fup.attack defense:_fup.defense];
  }
  [ProfileViewController displayView];
  
  [Analytics enemyProfileFromBattle];
}

- (void) closeSceneFromQuestLog {
  _cameFromClans = NO;
  _cameFromAviary = NO;
  _isBattling = NO;
  [self closeScene];
}

- (void) questLogPoppedUp {
  _cameFromClans = NO;
  _cameFromAviary = NO;
  _isBattling = NO;
}

- (void) closeScene {
  if (_isRunning) {
    self.enemyEquips = nil;
    [_fup release];
    _fup = nil;
    _isRunning = NO;
    
    [[GameLayer sharedGameLayer] startHomeMapTimersIfOkay];
    
    if (_cameFromAviary) {
      [AttackMenuController displayView];
      [[CCDirector sharedDirector] popScene];
    } else if (_cameFromClans) {
      [ClanMenuController displayView];
      [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:TRANSITION_DURATION];
    } else if (_cameFromTournament) {
      [TournamentMenuController displayView];
      [[CCDirector sharedDirector] popScene];
    } else {
      // This will cause the scene to be deallocated since there are no more references to it.
      [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:TRANSITION_DURATION];
    }
  }
}

- (void) receivedUserEquips:(RetrieveUserEquipForUserResponseProto *)proto {
  if (proto.relevantUserId == _fup.userId) {
    // Make sure it is not null
    self.enemyEquips = proto.userEquipsList ? proto.userEquipsList : [NSArray array];
    [[ProfileViewController sharedProfileViewController] updateEquips:self.enemyEquips];
  }
}

- (void) performGuaranteedWinWithUser:(FullUserProto *)fup inCity:(int)cityId {
  [self beginBattleAgainst:fup inCity:cityId];
  _guaranteeWin = YES;
}

- (void) performFirstLossTutorialWithUser:(FullUserProto *)fup inCity:(int)cityId {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  UserEquip *weap = [gs myEquipWithUserEquipId:gs.weaponEquipped];
  UserEquip *arm = [gs myEquipWithUserEquipId:gs.armorEquipped];
  UserEquip *amu = [gs myEquipWithUserEquipId:gs.amuletEquipped];
  
  FullUserProto_Builder *bldr = [FullUserProto builderWithPrototype:fup];
  
  const int arrSize = 3;
  UserEquip *ues[arrSize] = {weap, arm, amu};
  FullUserEquipProto *fueps[arrSize] = {nil, nil, nil};
  
  for (int i = 0; i < arrSize; i++) {
    UserEquip *ue = ues[i];
    FullEquipProto *oldFep = ue ? [gs equipWithId:ue.equipId] : nil;
    FullEquipProto *newFep = nil;
    int oAtt = [gl calculateAttackForEquip:ue.equipId level:ue.level enhancePercent:0];
    int oDef = [gl calculateAttackForEquip:ue.equipId level:ue.level enhancePercent:0];
    for (FullEquipProto *fep in gs.staticEquips.allValues) {
      if (fep.equipType != oldFep.equipType || (fep.equipType == FullEquipProto_EquipTypeArmor && fep.rarity < FullEquipProto_RarityRare) || fep.minLevel > fup.level) {
        continue;
      }
      
      int att = [gl calculateAttackForEquip:fep.equipId level:ue.level enhancePercent:0];
      int def = [gl calculateAttackForEquip:fep.equipId level:ue.level enhancePercent:0];
      if (oAtt+oDef < att+def) {
        int nAtt = [gl calculateAttackForEquip:newFep.equipId level:ue.level enhancePercent:0];
        int nDef = [gl calculateAttackForEquip:newFep.equipId level:ue.level enhancePercent:0];
        if (!newFep || nAtt+nDef > att+def) {
          newFep = fep;
        }
      }
    }
    FullUserEquipProto *fuep = [[[[[FullUserEquipProto builder] setEquipId:newFep.equipId] setLevel:ue.level] setEnhancementPercentage:ue.enhancementPercentage] build];
    fueps[i] = fuep;
  }
  
  bldr.weaponEquippedUserEquip = fueps[0];
  bldr.armorEquippedUserEquip = fueps[1];
  bldr.amuletEquippedUserEquip = fueps[2];
  
  [self beginBattleAgainst:bldr.build inCity:cityId];
  
  _isForTutorial = YES;
}

- (IBAction)fbClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  id<FacebookGlobalDelegate> sessionDelegate = appDelegate.facebookDelegate;
  NSString *str = [NSString stringWithFormat:@"%@ %@ %@ in Age of Chaos.", gs.name, brp.hasExpGained ? @"massacred" : @"was defeated by", _fup.name];
  [sessionDelegate postToFacebookWithString:str];
}

- (IBAction)twitterclicked:(id)sender {
  if ([TWTweetComposeViewController canSendTweet])
  {
    TWTweetComposeViewController *tweetSheet = [[[TWTweetComposeViewController alloc] init] autorelease];
    GameState *gs = [GameState sharedGameState];
    NSString *str = [NSString stringWithFormat:@"%@ %@ %@ in Age of Chaos. Click here to play now! http://bit.ly/14BpdVg #AgeOfChaos @AoCMobile", gs.name, brp.hasExpGained ? @"massacred" : @"was defeated by", _fup.name];
    [tweetSheet setInitialText:str];
    [[GameViewController sharedGameViewController] presentModalViewController:tweetSheet animated:YES];
  } else {
    [Globals popupMessage:@"Sorry, something went wrong. Make sure you have a Twitter account setup."];
  }
}

- (void) dealloc {
  self.enemyEquips = nil;
  [_fup release];
  self.brp = nil;
  [self.gainedEquipView removeFromSuperview];
  [self.gainedLockBoxView removeFromSuperview];
  [self.summaryView removeFromSuperview];
  [self.analysisView removeFromSuperview];
  self.stolenEquipView = nil;
  self.gainedEquipView = nil;
  self.gainedLockBoxView = nil;
  self.summaryView = nil;
  self.analysisView = nil;
  [_battleCalculator release];
  [super dealloc];
}

@end
