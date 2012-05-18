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
#import "SynthesizeSingleton.h"
#import "GameLayer.h"
#import "OutgoingEventController.h"
#import "ProfileViewController.h"
#import "RefillMenuController.h"
#import "MapViewController.h"
#import "SimpleAudioEngine.h"
#import "MissionMap.h"
#import "MarketplaceViewController.h"
#import "Downloader.h"

#define FAKE_PLAYER_RAND 6
#define NAME_LABEL_FONT_SIZE 11.f

#define TRANSITION_DURATION 1.5f

#define NUM_BACKGROUND_IMAGES 8

@implementation BattleSummaryView

@synthesize leftNameLabel, leftLevelLabel, leftPlayerIcon;
@synthesize rightNameLabel, rightLevelLabel, rightPlayerIcon;
@synthesize leftRarityLabel1, leftRarityLabel2, leftRarityLabel3;
@synthesize leftEquipIcon1, leftEquipIcon2, leftEquipIcon3;
@synthesize rightRarityLabel1, rightRarityLabel2, rightRarityLabel3;
@synthesize rightEquipIcon1, rightEquipIcon2, rightEquipIcon3;
@synthesize coinsGainedLabel, coinsLostLabel, expGainedLabel;
@synthesize winLabelsView, defeatLabelsView;
@synthesize mainView, bgdView;

- (void) loadBattleSummaryForBattleResponse:(BattleResponseProto *)brp enemy:(FullUserProto *)fup {
  GameState *gs = [GameState sharedGameState];
  
  leftNameLabel.text = gs.name;
  leftLevelLabel.text = [NSString stringWithFormat:@"Lvl %d", gs.level];
  leftPlayerIcon.image = [Globals squareImageForUser:gs.type];
  
  rightNameLabel.text = fup.name;
  rightLevelLabel.text = [NSString stringWithFormat:@"Lvl %d", fup.level];
  rightPlayerIcon.image = [Globals squareImageForUser:fup.userType];
  
  UILabel *rarityLabel = leftRarityLabel1;
  UIImageView *imgView = leftEquipIcon1;
  int equipId = gs.weaponEquipped;
  if (equipId > 0) {
    FullEquipProto *fep = [gs equipWithId:equipId];
    rarityLabel.textColor = [Globals colorForRarity:fep.rarity];
    rarityLabel.text = [Globals shortenedStringForRarity:fep.rarity];
    imgView.image = [Globals imageForEquip:fep.equipId];
  } else {
    rarityLabel.text = @"";
    imgView.image = nil;
  }
  
  rarityLabel = leftRarityLabel2;
  imgView = leftEquipIcon2;
  equipId = gs.armorEquipped;
  if (equipId > 0) {
    FullEquipProto *fep = [gs equipWithId:equipId];
    rarityLabel.textColor = [Globals colorForRarity:fep.rarity];
    rarityLabel.text = [Globals shortenedStringForRarity:fep.rarity];
    imgView.image = [Globals imageForEquip:fep.equipId];
  } else {
    rarityLabel.text = @"";
    imgView.image = nil;
  }
  
  rarityLabel = leftRarityLabel3;
  imgView = leftEquipIcon3;
  equipId = gs.amuletEquipped;
  if (equipId > 0) {
    FullEquipProto *fep = [gs equipWithId:equipId];
    rarityLabel.textColor = [Globals colorForRarity:fep.rarity];
    rarityLabel.text = [Globals shortenedStringForRarity:fep.rarity];
    imgView.image = [Globals imageForEquip:fep.equipId];
  } else {
    rarityLabel.text = @"";
    imgView.image = nil;
  }
  
  rarityLabel = rightRarityLabel1;
  imgView = rightEquipIcon1;
  equipId = fup.weaponEquipped;
  if (equipId > 0) {
    FullEquipProto *fep = [gs equipWithId:equipId];
    rarityLabel.textColor = [Globals colorForRarity:fep.rarity];
    rarityLabel.text = [Globals shortenedStringForRarity:fep.rarity];
    imgView.image = [Globals imageForEquip:fep.equipId];
  } else {
    rarityLabel.text = @"";
    imgView.image = nil;
  }
  
  rarityLabel = rightRarityLabel2;
  imgView = rightEquipIcon2;
  equipId = fup.armorEquipped;
  if (equipId > 0) {
    FullEquipProto *fep = [gs equipWithId:equipId];
    rarityLabel.textColor = [Globals colorForRarity:fep.rarity];
    rarityLabel.text = [Globals shortenedStringForRarity:fep.rarity];
    imgView.image = [Globals imageForEquip:fep.equipId];
  } else {
    rarityLabel.text = @"";
    imgView.image = nil;
  }
  
  rarityLabel = rightRarityLabel3;
  imgView = rightEquipIcon3;
  equipId = fup.amuletEquipped;
  if (equipId > 0) {
    FullEquipProto *fep = [gs equipWithId:equipId];
    rarityLabel.textColor = [Globals colorForRarity:fep.rarity];
    rarityLabel.text = [Globals shortenedStringForRarity:fep.rarity];
    imgView.image = [Globals imageForEquip:fep.equipId];
  } else {
    rarityLabel.text = @"";
    imgView.image = nil;
  }
  
  if (brp.hasExpGained) {
    // This is a win
    winLabelsView.hidden = NO;
    defeatLabelsView.hidden = YES;
    coinsGainedLabel.text = [NSString stringWithFormat:@"+%@", [Globals commafyNumber:brp.coinsGained]];
    expGainedLabel.text = [NSString stringWithFormat:@"%@ Exp.", [Globals commafyNumber:brp.expGained]];
  } else {
    winLabelsView.hidden = YES;
    defeatLabelsView.hidden = NO;
    // Coins gained is the loss amount
    coinsLostLabel.text = [NSString stringWithFormat:@"-%@", [Globals commafyNumber:brp.coinsGained]];
  }
}

- (void) dealloc {
  self.leftNameLabel = nil;
  self.leftLevelLabel = nil;
  self.leftPlayerIcon = nil;
  self.rightNameLabel = nil;
  self.rightLevelLabel = nil;
  self.rightPlayerIcon = nil;
  self.leftRarityLabel1 = nil;
  self.leftRarityLabel2 = nil;
  self.leftRarityLabel3 = nil;
  self.leftEquipIcon1 = nil;
  self.leftEquipIcon2 = nil;
  self.leftEquipIcon3 = nil;
  self.rightRarityLabel1 = nil;
  self.rightRarityLabel2 = nil;
  self.rightRarityLabel3 = nil;
  self.rightEquipIcon1 = nil;
  self.rightEquipIcon2 = nil;
  self.rightEquipIcon3 = nil;
  self.coinsGainedLabel = nil;
  self.coinsLostLabel = nil;
  self.expGainedLabel = nil;
  self.winLabelsView = nil;
  self.defeatLabelsView = nil;
  self.mainView = nil;
  self.bgdView = nil;
  [super dealloc];
}

@end

@implementation StolenEquipView

@synthesize nameLabel, equipIcon, attackLabel, defenseLabel;
@synthesize mainView, bgdView;

- (void) loadForEquip:(FullEquipProto *)fep {
  nameLabel.text = fep.name;
  nameLabel.textColor = [Globals colorForRarity:fep.rarity];
  equipIcon.image = [Globals imageForEquip:fep.equipId];
  attackLabel.text = [NSString stringWithFormat:@"%d", fep.attackBoost];
  defenseLabel.text = [NSString stringWithFormat:@"%d", fep.defenseBoost];
}

- (void) dealloc {
  self.nameLabel = nil;
  self.equipIcon = nil;
  self.attackLabel = nil;
  self.defenseLabel = nil;
  self.mainView = nil;
  self.bgdView = nil;
  [super dealloc];
}

@end

@implementation BattleLayer

@synthesize summaryView, stolenEquipView, brp, enemyEquips;

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
        [[Downloader sharedDownloader] downloadImage:fullpath.lastPathComponent completion:nil];
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

+(CCScene *) scene
{
  // 'scene' is an autorelease object.
  CCScene *scene = [CCScene node];
  
  // When this scene is removed, it will be deallocated so the background will change..
  CCSprite *sprite = [CCSprite spriteWithFile:[self getAvailableBackground]];
  sprite.anchorPoint = ccp(0,0);
  [scene addChild:sprite];
  
  // 'layer' is a singleton object.
  BattleLayer *layer = [self sharedBattleLayer];
  
  // add layer as a child to scene
  [scene addChild: layer];
	
	// return the scene
	return scene;
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
    
    _comboBar = [CCSprite spriteWithFile:@"attackcirclebg.png"];
    _comboBar.position = ccp(COMBO_BAR_X_POSITION, self.contentSize.height/2);
    [self addChild:_comboBar];
    
    _comboProgressTimer = [CCProgressTimer progressWithFile:@"attackchecks.png"];
    _comboProgressTimer.position = ccp(_comboBar.contentSize.width/2-2, _comboBar.contentSize.height/2);
    _comboProgressTimer.type = kCCProgressTimerTypeRadialCW;
    _comboProgressTimer.percentage = 75;
    _comboProgressTimer.rotation = 180;
    [_comboProgressTimer.sprite.texture setAntiAliasTexParameters];
    [_comboBar addChild:_comboProgressTimer];
    
    CCSprite *max = [CCSprite spriteWithFile:@"max.png"];
    max.position = ccp(_comboBar.contentSize.width+max.contentSize.width/2, _comboBar.contentSize.height/2);
    [_comboBar addChild:max];
    
    _flippedComboBar = [CCSprite spriteWithFile:@"attackcirclebg.png"];
    _flippedComboBar.flipX = YES;
    _flippedComboBar.position = ccp(self.contentSize.width-COMBO_BAR_X_POSITION, self.contentSize.height/2);
    [self addChild:_flippedComboBar];
    
    _flippedComboProgressTimer = [CCProgressTimer progressWithFile:@"attackchecksflipped.png"];
    _flippedComboProgressTimer.position = ccp(_flippedComboBar.contentSize.width/2+2, _flippedComboBar.contentSize.height/2);
    _flippedComboProgressTimer.type = kCCProgressTimerTypeRadialCCW;
    _flippedComboProgressTimer.percentage = 75;
    _flippedComboProgressTimer.rotation = 180;
    [_flippedComboBar addChild:_flippedComboProgressTimer];
    
    CCSprite *flippedMax = [CCSprite spriteWithFile:@"max.png"];
    flippedMax.position = ccp(-max.contentSize.width/2, _flippedComboBar.contentSize.height/2);
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

- (void) beginBattleAgainst:(FullUserProto *)user {
  GameState *gs = [GameState sharedGameState];
  Globals *gl = [Globals sharedGlobals];
  
  if (_isBattling) {
    return;
  }
  
  if (gs.currentStamina <= 0) {
    [[RefillMenuController sharedRefillMenuController] displayEnstView:NO];
    [Analytics notEnoughStaminaForBattle];
    return;
  }
  
  if (ABS(gs.level-user.level) > gl.maxLevelDiffForBattle) {
    [Globals popupMessage:@"The level difference is too much to start battle."];
    return;
  }
  
  self.enemyEquips = nil;
  [[OutgoingEventController sharedOutgoingEventController] retrieveEquipsForUser:user.userId];
  
  [self removeChild:_left cleanup:YES];
  [self removeChild:_right cleanup:YES];
  
  _left = [CCSprite spriteWithFile:[Globals battleImageNameForUser:gs.type]];
  _right = [CCSprite spriteWithFile:[Globals battleImageNameForUser:user.userType]];
  _right.flipX = YES;
  
  _left.position = ccp(-_left.contentSize.width/2, _left.contentSize.height/2);
  _right.position = ccp([[CCDirector sharedDirector] winSize].width+_left.contentSize.width/2, _right.contentSize.height/2);
  
  [self addChild:_left z:1];
  [self addChild:_right z:1];
  
  _leftCurrentHealth = gs.maxHealth;
  _leftMaxHealth = gs.maxHealth;
  _rightMaxHealth = user.healthMax;
  _rightCurrentHealth = user.healthMax;
  
  _leftNameLabel.string = gs.name;
  _leftNameBg.position = ccp(_leftNameBg.contentSize.width+_leftNameLabel.contentSize.width-_leftNameLabel.position.x+15, _leftNameBg.position.y);
  _rightNameLabel.string = user.name;
  _rightNameBg.position = ccp(_rightNameBg.parent.contentSize.width-_rightNameLabel.contentSize.width-_rightNameLabel.position.x-15, _rightNameBg.position.y);
  
  _rightCurHealthLabel.string = [NSString stringWithFormat:@"%d", _rightCurrentHealth];
  _rightMaxHealthLabel.string = [NSString stringWithFormat:@" / %d", _rightMaxHealth];
  _leftCurHealthLabel.string = [NSString stringWithFormat:@"%d", _leftCurrentHealth];
  _leftMaxHealthLabel.string = [NSString stringWithFormat:@" / %d", _leftMaxHealth];
  
  _leftAttack = [gl calculateAttackForStat:gs.attack weapon:gs.weaponEquipped armor:gs.armorEquipped amulet:gs.amuletEquipped];
  _leftDefense = [gl calculateDefenseForStat:gs.defense weapon:gs.weaponEquipped armor:gs.armorEquipped amulet:gs.amuletEquipped];
  
  if (user.isFake) {
    int randAtt = arc4random() % 6;
    int randDef = arc4random() % 6;
    if (user.level > gs.level) {
      _rightAttack = _leftAttack + randAtt;
      _rightDefense = _leftDefense + randDef;
    } else {
      _rightAttack = _leftAttack - randAtt;
      _rightDefense = _leftDefense - randDef;
    }
  } else {
    _rightAttack = [gl calculateAttackForStat:user.attack weapon:user.weaponEquipped armor:user.armorEquipped amulet:user.amuletEquipped];
    _rightDefense = [gl calculateAttackForStat:user.defense weapon:user.weaponEquipped armor:user.armorEquipped amulet:user.amuletEquipped];
  }
  
  _enemyType = user.userType;
  
  CCDirector *dir = [CCDirector sharedDirector];
  if (!_isRunning) {
    _isRunning = YES;
    CCScene *scene = [BattleLayer scene];
    [dir pushScene:[CCTransitionFade transitionWithDuration:TRANSITION_DURATION scene:scene]];
    
    // Remove mapviewcontroller in case we were called from there
    // but record whether we came from there or not
    MapViewController *mvc = [MapViewController sharedMapViewController];
    if (mvc.view.superview) {
      [[MapViewController sharedMapViewController] fadeOut];
      _cameFromAviary = YES;
    } else {
      _cameFromAviary = NO;
    }
    
    [[MarketplaceViewController sharedMarketplaceViewController] backClicked:nil];
  } else {
    [self startBattle];
  }
  
  self.brp = nil;
  
  if (_fup != user) {
    [_fup release];
    _fup = [user retain];
  }
  
  [summaryView removeFromSuperview];
  [stolenEquipView removeFromSuperview];
  
  // Close the menus
  [[GameLayer sharedGameLayer] closeMenus];
  
  _cityId = 0;
  
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
}

- (void) onEnterTransitionDidFinish {
  [super onEnterTransitionDidFinish];
  [self startBattle];
}

- (void) beginBattleAgainst:(FullUserProto *)user inCity:(int) cityId {
  [self beginBattleAgainst:user];
  _cityId = cityId;
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
  
  [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Battle_Music.m4a"];
  
  [_left runAction: [CCMoveBy actionWithDuration:0.6 position:ccp(3*_left.contentSize.width/4,0)]];
  
  [_right runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:0.6],
                     [CCMoveBy actionWithDuration:0.5 position:ccp(-3*_right.contentSize.width/4,0)],
                     [CCCallFunc actionWithTarget:self selector:@selector(startMyTurn)],
                     nil]];
}

- (void) startMyTurn {
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
  [_comboProgressTimer runAction:[CCSequence actionOne:[CCEaseIn actionWithAction:[CCProgressFromTo actionWithDuration:duration from:0 to:100] rate:2.5]
                                                   two:[CCCallFunc actionWithTarget:self selector:@selector(comboBarClicked)]]];
  
  [self runAction:[CCSequence actions:
                   [CCDelayTime actionWithDuration:DELAY_BEFORE_COMBO_BAR_WINDUP_SOUND],
                   [CCCallBlock actionWithBlock:
                    ^{
                      if (_comboBarMoving) {
                        _comboBarWindupSound = [[SimpleAudioEngine sharedEngine] playEffect:[Globals comboBarChargeupSound:[GameState sharedGameState].type]];
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
  [[SimpleAudioEngine sharedEngine] stopEffect:_comboBarWindupSound];
  [self startEnemyTurn];
}

- (void) comboBarClicked {
  if (_comboBarMoving) {
    [_comboProgressTimer stopAllActions];
    _comboBarMoving = NO;
    [self stopAllActions];
    
    [[SimpleAudioEngine sharedEngine] stopEffect:_comboBarWindupSound];
    
    _damageDone = [self calculateMyDamageForPercentage:_comboProgressTimer.percentage];
    
    if (_rightCurrentHealth - _damageDone <= 0) {
      [[OutgoingEventController sharedOutgoingEventController] battle:_fup result:BattleResultAttackerWin city:_cityId equips:enemyEquips];
      
      if (_cityId > 0 && [[GameLayer sharedGameLayer] currentCity] == _cityId) {
        [[[GameLayer sharedGameLayer] missionMap] killEnemy:_fup.userId];
      }
    }
    
    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:0.5] two:[CCCallFunc actionWithTarget:self selector:@selector(doAttackAnimation)]]];
  }
}

- (int) calculateMyDamageForPercentage:(float)percent {
  Globals *gl = [Globals sharedGlobals];
  int multiplerWeightForSecondHalf = gl.locationBarMax / (100-gl.locationBarMax);
  double amountWorseThanMax = (percent <= gl.locationBarMax) ? (gl.locationBarMax-percent)*gl.maxAttackMultiplier/gl.locationBarMax : (percent-gl.locationBarMax)*multiplerWeightForSecondHalf*gl.maxAttackMultiplier/gl.locationBarMax;
  
  
  //assumes linearity from 0-BAR_MAX and BAR_MAX-100 (diff slope magnitudes for each) to calculate attack value
  double attackMultiplier = gl.maxAttackMultiplier - amountWorseThanMax;
  
  double attackStat = _leftAttack * attackMultiplier;
  double defenseStat = _rightDefense;
  
  int minDamage = (int) (_rightMaxHealth * gl.minPercentOfEnemyHealth);
  int maxDamage = (int) (_rightMaxHealth * gl.maxPercentOfEnemyHealth);
  
  return (int)MIN(maxDamage, MAX(minDamage, attackStat-defenseStat));
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
      return ccp(430, 55);
      
    case UserTypeBadMage:
    case UserTypeGoodMage:
      return ccp(211,105);
      
    default:
      break;
  }
  return ccp(0,0);
}

- (void) leftClassSpecificAnimation {
  [[SimpleAudioEngine sharedEngine] playEffect:[Globals battleAttackSound:[GameState sharedGameState].type]];
  
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
  
  CCLabelTTF *damageLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", (int)_damageDone] fontName:@"DINCond-Black" fontSize:35];
  [self addChild:damageLabel z:3];
  damageLabel.position = ccp(430, 180);
  damageLabel.color = ccc3(255, 0, 0);
  [damageLabel runAction:[CCSequence actions:
                          [CCSpawn actions:
                           [CCFadeOut actionWithDuration:1.f], 
                           [CCMoveBy actionWithDuration:1.f position:ccp(0,40)],nil],
                          [CCCallBlock actionWithBlock:^{[damageLabel removeFromParentAndCleanup:YES];}], nil]];
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
  [_rightHealthBar runAction:[CCSequence actions:[CCMoveTo actionWithDuration:dist/HEALTH_BAR_VELOCITY position:finalPt],
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
    [[OutgoingEventController sharedOutgoingEventController] battle:_fup result:BattleResultDefenderWin city:0 equips:nil];
  }
  
  _bottomMenu.visible = NO;
  _attackButton.visible = NO;
  _flippedComboBar.visible = YES;
  
  float duration = [self rand]*(MAX_COMBO_BAR_DURATION-MIN_COMBO_BAR_DURATION)+MIN_COMBO_BAR_DURATION;
  [_flippedComboProgressTimer runAction:[CCSequence actions:[CCEaseIn actionWithAction:[CCProgressFromTo actionWithDuration:perc*duration/100 from:0 to:perc] rate:2.5],
                                         [CCDelayTime actionWithDuration:0.5],
                                         [CCCallFunc actionWithTarget:self selector:@selector(doEnemyAttackAnimation)],
                                         nil]];
  
  [self runAction:[CCSequence actions:
                   [CCDelayTime actionWithDuration:DELAY_BEFORE_COMBO_BAR_WINDUP_SOUND],
                   [CCCallBlock actionWithBlock:^{
    _comboBarWindupSound = [[SimpleAudioEngine sharedEngine] playEffect:[Globals comboBarChargeupSound:_enemyType]];
  }], nil]];
}

- (void) doEnemyAttackAnimation {
  [[SimpleAudioEngine sharedEngine] stopEffect:_comboBarWindupSound];
  
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
  [[SimpleAudioEngine sharedEngine] playEffect:[Globals battleAttackSound:_enemyType]];
  
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
  
  CCLabelTTF *damageLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", (int)_damageDone] fontName:@"DINCond-Black" fontSize:35];
  [self addChild:damageLabel z:3];
  damageLabel.position = ccp(50, 180);
  damageLabel.color = ccc3(255, 0, 0);
  [damageLabel runAction:[CCSequence actions:
                          [CCSpawn actions:
                           [CCFadeOut actionWithDuration:1.f], 
                           [CCMoveBy actionWithDuration:1.f position:ccp(0,40)],nil],
                          [CCCallBlock actionWithBlock:^{[damageLabel removeFromParentAndCleanup:YES];}], nil]];
}

- (float) calculateEnemyPercentage {
  int locationOnBar = 0;
  float r = [self rand];
  
  if (r < .40) {                 //give 45-72 75% of the time
    locationOnBar = 45 + [self rand] * 27;
  } else if (r >= .40 && r < .70) {      //give 78-100 20% of the time
    locationOnBar = 78 + [self rand] * 22;
  } else if (r >= .70) {     //give 72-78 5% of the time
    locationOnBar = 72 + [self rand] * 6;
  }
  return locationOnBar;
}

- (int) calculateEnemyDamageForPercentage:(float)percent {
  Globals *gl = [Globals sharedGlobals];
  int multiplerWeightForSecondHalf = gl.locationBarMax / (100-gl.locationBarMax);
  double amountWorseThanMax = (percent <= gl.locationBarMax) ? (gl.locationBarMax-percent)*gl.maxAttackMultiplier/gl.locationBarMax : (percent-gl.locationBarMax)*multiplerWeightForSecondHalf*gl.maxAttackMultiplier/gl.locationBarMax;
  
  //assumes linearity from 0-BAR_MAX and BAR_MAX-100 (diff slope magnitudes for each) to calculate attack value
  double attackMultiplier = gl.maxAttackMultiplier - amountWorseThanMax;
  
  double attackStat = _rightAttack * attackMultiplier;
  double defenseStat = _leftDefense;
  
  int minDamage = (int) (_leftMaxHealth * gl.minPercentOfEnemyHealth);
  int maxDamage = (int) (_leftMaxHealth * gl.maxPercentOfEnemyHealth);
  
  int statDamage = attackStat-defenseStat;
  return (int)MIN(maxDamage, MAX(minDamage, gl.battleDifferenceMultiplier*statDamage+gl.battleDifferenceTuner));
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
  [_leftHealthBar runAction:[CCSequence actions:[CCMoveTo actionWithDuration:dist/HEALTH_BAR_VELOCITY position:finalPt],
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
  [self addChild:ps z:3];
  
  _winLayer.visible = YES;
  _winLayer.scale = 1.5f;
  [_winLayer runAction:[CCScaleTo actionWithDuration:0.2f scale:1.f]];
  
  [[SimpleAudioEngine sharedEngine] stopBackgroundMusic]; 
  [[SimpleAudioEngine sharedEngine] playEffect:@"Battle_Success.m4a"];
  
  // Set the city id to 0 if win, only want it to count as 1 win
  _cityId = 0;
  
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
  
  [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
  [[SimpleAudioEngine sharedEngine] playEffect:@"Battle_Loss.m4a"];
  
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
  [[OutgoingEventController sharedOutgoingEventController] battle:_fup result:BattleResultAttackerFlee city:0 equips:nil];
  [_attackProgressTimer stopAllActions];
  _attackButton.visible = NO;
  _pausedLayer.visible = NO;
  _fleeLayer.visible = YES;
  
  [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
  [[SimpleAudioEngine sharedEngine] playEffect:@"Battle_Loss.m4a"];
  
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
  _pausedLayer.visible = NO;
  _attackButton.visible = YES;
  [_attackProgressTimer resumeSchedulerAndActions];
}

- (void) setBrp:(BattleResponseProto *)b {
  if (brp != b) {
    _clickedDone = NO;
    [brp release];
    brp = [b retain];
  }
}

- (void) doneClicked {
  if (_clickedDone) {
    return;
  }
  _clickedDone = YES;
  
  _isBattling = NO;
  if (_left.opacity > 0) {
    SEL completeAction = nil;
    if (brp.hasEquipGained) {
      completeAction = @selector(displayStolenEquip);
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
  UIView *view = [[[CCDirector sharedDirector] openGLView] superview];
  [stolenEquipView loadForEquip:brp.equipGained];
  [view addSubview:stolenEquipView];
  [Globals bounceView:stolenEquipView.mainView fadeInBgdView:stolenEquipView.bgdView];
}

- (float) rand {
  return ((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX);
}

- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (_comboBarMoving) {
    [self comboBarClicked];
  }
}

- (IBAction)stolenEquipOkayClicked:(id)sender {
  [Globals popOutView:stolenEquipView.mainView fadeOutBgdView:stolenEquipView.bgdView completion:^{
    [stolenEquipView removeFromSuperview];
  }];
  [self displaySummary];
}

- (void) displaySummary {
  UIView *view = [[[CCDirector sharedDirector] openGLView] superview];
  [summaryView loadBattleSummaryForBattleResponse:brp enemy:_fup];
  [view addSubview:summaryView];
  [Globals bounceView:summaryView.mainView fadeInBgdView:summaryView.bgdView];
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:stolenEquipView.mainView fadeOutBgdView:stolenEquipView.bgdView completion:^{
    [summaryView removeFromSuperview];
  }];
  [self closeScene];
}

- (IBAction)attackAgainClicked:(id)sender {
  [self beginBattleAgainst:_fup inCity:_cityId];
  
  [Analytics attackAgain];
}

- (IBAction)profileButtonClicked:(id)sender {
  if (_isAnimating) {
    return;
  }
  
  if (_isBattling) {
    [self pauseClicked];
  }
  
  // Send in attack and defense in case of fake players
  [[ProfileViewController sharedProfileViewController] loadProfileForPlayer:_fup equips:self.enemyEquips attack:_rightAttack defense:_rightDefense];
  [ProfileViewController displayView];
  
  [Analytics enemyProfileFromBattle];
}

- (void) closeScene {
  self.enemyEquips = nil;
  [_fup release];
  _fup = nil;
  _isRunning = NO;
  
  [[GameLayer sharedGameLayer] startHomeMapTimersIfOkay];
  
  if (_cameFromAviary) {
    [MapViewController displayView];
    [[MapViewController sharedMapViewController] openEnemiesTab];
    [[CCDirector sharedDirector] popScene];
  } else {
    // This will cause the scene to be deallocated since there are no more references to it.
    [[CCDirector sharedDirector] popSceneWithTransition:[CCTransitionFade class] duration:TRANSITION_DURATION];
  }
}

- (void) receivedUserEquips:(RetrieveUserEquipForUserResponseProto *)proto {
  if (proto.relevantUserId == _fup.userId) {
    // Make sure it is not null
    NSArray *empty = [NSArray array];
    self.enemyEquips = proto.userEquipsList ? proto.userEquipsList : empty;
    [[ProfileViewController sharedProfileViewController] updateEquips:self.enemyEquips];
  }
}

- (void) dealloc {
  self.enemyEquips = nil;
  [_fup release];
  self.brp = nil;
  [self.stolenEquipView removeFromSuperview];
  [self.summaryView removeFromSuperview];
  self.stolenEquipView = nil;
  self.summaryView = nil;
  [super dealloc];
}

@end
