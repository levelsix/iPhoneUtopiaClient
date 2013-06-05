//
//  TutorialBattleLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TutorialBattleLayer.h"
#import "TutorialConstants.h"
#import "GameState.h"
#import "Globals.h"
#import "TutorialMissionMap.h"
#import "SoundEngine.h"
#import "DialogMenuController.h"

#define ENEMY_HEALTH 30
#define ENEMY_ATTACK 20
#define ENEMY_DEFENSE 5

@implementation TutorialBattleLayer

- (id) init {
  if ((self = [super init])) {
    [self beginBattle];
  }
  return self;
}

- (void) beginBattle {
  GameState *gs = [GameState sharedGameState];
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  
  _winLayer.visible = NO;
  _loseLayer.visible = NO;
  _pausedLayer.visible = NO;
  _fleeLayer.visible = NO;
  _comboBar.visible = NO;
  _flippedComboBar.visible = NO;
  _attackButton.visible = NO;
  _bottomMenu.visible = NO;
  
  Globals *gl = [Globals sharedGlobals];
  _leftMaxHealth = [gl calculateHealthForLevel:gs.level];
  _leftCurrentHealth = _leftMaxHealth;
  _rightMaxHealth = ENEMY_HEALTH;
  _rightCurrentHealth = _rightMaxHealth;
  
  _rightCurHealthLabel.string = [NSString stringWithFormat:@"%d", _rightCurrentHealth];
  _rightMaxHealthLabel.string = [NSString stringWithFormat:@" / %d", _rightMaxHealth];
  _leftCurHealthLabel.string = [NSString stringWithFormat:@"%d", _leftCurrentHealth];
  _leftMaxHealthLabel.string = [NSString stringWithFormat:@" / %d", _leftMaxHealth];
  
  _leftNameLabel.string = gs.name;
  _leftNameBg.position = ccp(_leftNameBg.contentSize.width+_leftNameLabel.contentSize.width-_leftNameLabel.position.x+15, _leftNameBg.position.y);
  _rightNameLabel.string = [[TutorialConstants sharedTutorialConstants] enemyName];
  _rightNameBg.position = ccp(_rightNameBg.parent.contentSize.width-_rightNameLabel.contentSize.width-_rightNameLabel.position.x-15, _rightNameBg.position.y);
  
  [_battleCalculator release];
  FullUserProto_Builder *builder = [[[[[[[[FullUserProto builder] setAttack:ENEMY_ATTACK]
                                       setDefense:ENEMY_DEFENSE] setLevel:1] setName:tc.enemyName] setUserType:tc.enemyType]
                                     setWeaponEquippedUserEquip:[[[[FullUserEquipProto builder] setEquipId:tc.warriorInitWeapon.equipId] setLevel:1] build]]
                                    setArmorEquippedUserEquip:[[[[FullUserEquipProto builder] setEquipId:tc.warriorInitArmor.equipId] setLevel:1] build]];
  _fup = [builder.build retain];
  _battleCalculator = [BattleCalculator
                       createWithRightStats:[UserBattleStats
                                             createWithFullUserProto:_fup]
                       andLeftStats:[UserBattleStats createFromGameState]];
  [_battleCalculator retain];
  
  _ccArrow = [[CCSprite spriteWithFile:@"3darrow.png"] retain];
  _ccArrow.visible = NO;
  
  _tapToAttack = [CCSprite spriteWithFile:@"tapanywheretoengageattack.png"];
  [self addChild:_tapToAttack z:5];
  _tapToAttack.opacity = 0.f;
  _tapToAttack.position = ccp(_tapToAttack.contentSize.width/2, _tapToAttack.contentSize.height/2);
  
  _waitForMax = [CCSprite spriteWithFile:@"waitformax.png"];
  [self addChild:_waitForMax z:5];
  _waitForMax.opacity = 0.f;
  _waitForMax.position = ccp(self.contentSize.width/2, _waitForMax.contentSize.height/2);
  
  _tryAgain = [[CCSprite spriteWithFile:@"tryagain.png"] retain];
  _tryAgain.opacity = 0.f;
  
  _uiArrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3darrow.png"]];
  _uiArrow.layer.transform = CATransform3DMakeRotation(-M_PI/2, 0.0f, 0.0f, 1.0f);
  
  _left = [CCSprite spriteWithFile:[Globals battleImageNameForUser:gs.type]];
  _right = [CCSprite spriteWithFile:[Globals battleImageNameForUser:tc.enemyType]];
  _right.flipX = YES;
  
  _left.position = ccp(-_left.contentSize.width/2, _left.contentSize.height/2);
  _right.position = ccp([[CCDirector sharedDirector] winSize].width+_left.contentSize.width/2, _right.contentSize.height/2);
  
  _enemyType = tc.enemyType;
  
  [self addChild:_left z:1];
  [self addChild:_right z:1];
  
  _firstTurn = YES;
  _firstAttack = YES;
  
  // Battle will be started when transition completes..
  [Analytics tutBattleStart];
  
  _isRunning = YES;
}

- (void) startMyTurn {
  if (!_firstAttack) {
    [_overLayer removeFromParentAndCleanup:YES];
    _overLayer = nil;
  }
  [super startMyTurn];
  
  if (_firstTurn) {
    _attackButton.visible = YES;
    _comboBar.visible = NO;
    _bottomMenu.visible = YES;
    
    _attackProgressTimer.percentage = 68;
    
    _overLayer = [CCSprite spriteWithFile:@"attackbuttonlight.png"];
    [self addChild:_overLayer z:5];
    _overLayer.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    _overLayer.visible = NO;
    
    CCSprite *instr = [CCSprite spriteWithFile:@"tapbegin.png"];
    [_overLayer addChild:instr];
    instr.position = ccp(_overLayer.contentSize.width/2, _overLayer.contentSize.height/2);	
    
    [_attackProgressTimer stopAllActions];
    [_attackProgressTimer runAction:[CCSequence actions:[CCProgressFromTo actionWithDuration:ATTACK_BUTTON_ANIMATION/10.f from:100 to:90],
                                     [CCCallBlock actionWithBlock:
                                      ^{
                                        _firstTurn = NO;
                                        _overLayer.visible = YES;
                                        _ccArrow.visible = YES;
                                      }],
                                     [CCDelayTime actionWithDuration:2],
                                     [CCProgressFromTo actionWithDuration:ATTACK_BUTTON_ANIMATION from:90 to:0],
                                     [CCCallFunc actionWithTarget:self selector:@selector(turnMissed)], nil]];
    
    [_overLayer addChild:_ccArrow];
    [_overLayer addChild:_tryAgain];
    _tryAgain.position = ccp(_overLayer.contentSize.width/2, _tryAgain.contentSize.height/2);
  } else {
    _ccArrow.visible = YES;
    
    _tapToAttack.opacity = 0.f;
    [_tapToAttack stopAllActions];
  }
  
  CGPoint pos = ccp(_ccArrow.parent.contentSize.width/2,
                    _attackButton.position.y+_attackButton.contentSize.height/2+_ccArrow.contentSize.height/2);
  _ccArrow.position = pos;
  [Globals animateCCArrow:_ccArrow atAngle:-M_PI_2];
}

- (void) turnMissed {
  if (_isAnimating) {
    return;
  }
  [self startMyTurn];
  
  _tryAgain.opacity = 255;
  [_tryAgain runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.f],
                        [CCFadeOut actionWithDuration:1.f],nil]];
}

- (void) attackStart {
  if (_firstTurn && !_overLayer.visible) {
    return;
  }
  
  _ccArrow.visible = NO;
  [_ccArrow removeFromParentAndCleanup:YES];
  [self addChild:_ccArrow];
  [_tryAgain removeFromParentAndCleanup:YES];
  [self addChild:_tryAgain z:1];
  _tryAgain.position = ccp(self.contentSize.width/2, _tryAgain.contentSize.height/2);
  _tryAgain.opacity = 0;
  [_overLayer removeFromParentAndCleanup:YES];
  
  _attackMoving = NO;
  [_attackProgressTimer stopAllActions];
  
  _bottomMenu.visible = NO;
  _attackButton.visible = NO;
  _isAnimating = YES;
  
  _comboBar.visible = YES;
  _comboBarMoving = YES;
  
  // Increase by 1 second
  float duration = [self rand]*(MAX_COMBO_BAR_DURATION-MIN_COMBO_BAR_DURATION)+MIN_COMBO_BAR_DURATION+1;
  _triangle.rotation = START_TRIANGLE_ROTATION;
  
  float firstStop = 1.f/12;
  float firstRot = START_TRIANGLE_ROTATION+firstStop*(END_TRIANGLE_ROTATION-START_TRIANGLE_ROTATION);
  
  if (_firstAttack) {
    
    _overLayer = [CCSprite spriteWithFile:@"combowheellight.png"];
    [self addChild:_overLayer z:5];
    _overLayer.position = ccp(_overLayer.contentSize.width/2, self.contentSize.height/2);
    
    CCSprite *whenArrow = [CCSprite spriteWithFile:@"arrow1.png"];
    CCSprite *whenthis = [CCSprite spriteWithFile:@"whenthis.png"];
    whenArrow.anchorPoint = ccp(0,0);
    whenthis.anchorPoint = ccp(0,0);
    whenArrow.opacity = 0;
    whenthis.opacity = 0;
    [whenthis addChild:whenArrow];
    [_overLayer addChild:whenthis];
    
    CCSprite *reachesArrow = [CCSprite spriteWithFile:@"arrow2.png"];
    CCSprite *reachesthis = [CCSprite spriteWithFile:@"reachesthis.png"];
    reachesArrow.anchorPoint = ccp(0,0);
    reachesthis.anchorPoint = ccp(0,0);
    reachesArrow.opacity = 0;
    reachesthis.opacity = 0;
    [reachesthis addChild:reachesArrow];
    [_overLayer addChild:reachesthis];
    
    CCSprite *tapPerfect = [CCSprite spriteWithFile:@"tapforaperfectattack.png"];
    tapPerfect.anchorPoint = ccp(0,0);
    tapPerfect.opacity = 0;
    [_overLayer addChild:tapPerfect];
    
    CCSprite *okay = [CCSprite spriteWithFile:@"tutokay.png"];
    CCMenuItemSprite *item = [CCMenuItemSprite itemFromNormalSprite:okay selectedSprite:nil target:self selector:@selector(okayClickedMyTurn:)];
    CCMenu *menu = [CCMenu menuWithItems:item, nil];
    // Need to left align it
    item.position = ccp(-menu.contentSize.width/2+375, 0);
    item.opacity = 0;
    [_overLayer addChild:menu];
    
    float baseSecs = 1.5f;
    
    [self runAction:[CCSequence actions:
                     [CCCallBlock actionWithBlock:
                      ^{
                        [_triangle runAction:[CCRotateBy actionWithDuration:duration*firstStop angle:firstRot-_triangle.rotation]];
                      }],
                     [CCDelayTime actionWithDuration:duration*firstStop],
                     [CCCallBlock actionWithBlock:
                      ^{
                        [whenthis runAction:[CCSequence actions:[RecursiveFadeTo actionWithDuration:0.2f opacity:255], [CCDelayTime actionWithDuration:baseSecs-0.3f], [RecursiveFadeTo actionWithDuration:0.1f opacity:100], nil]];
                        [reachesthis runAction:[CCSequence actions:[CCDelayTime actionWithDuration:baseSecs], [RecursiveFadeTo actionWithDuration:0.2f opacity:255],
                                                [CCDelayTime actionWithDuration:baseSecs-0.3f], [RecursiveFadeTo actionWithDuration:0.1f opacity:100], nil]];
                        [tapPerfect runAction:[CCSequence actions:[CCDelayTime actionWithDuration:baseSecs*2], [CCFadeIn actionWithDuration:0.2f], nil]];
                        [item runAction:[CCSequence actions:[CCDelayTime actionWithDuration:baseSecs*2.5f], [CCFadeIn actionWithDuration:0.2f], nil]];
                      }],
                     nil]];
    
    [Analytics tutClickedBegin];
  } else {
    _allowAttackingForFirstAttack = NO;
    [self runAction:[CCSequence actions:
                     [CCCallBlock actionWithBlock:
                      ^{
                        [_triangle runAction:[CCRotateBy actionWithDuration:duration*firstStop angle:firstRot-_triangle.rotation]];
                      }],
                     [CCDelayTime actionWithDuration:duration*firstStop],
                     [CCCallBlock actionWithBlock:
                      ^{
                        // Send in an object with 255 opacity
                        [self okayClickedMyTurn:_ccArrow];
                      }], nil]];
  }
}

- (void) okayClickedMyTurn:(CCSprite *)sender {
  if (sender.opacity < 255) {
    return;
  }
  
  CCSprite *maxLayer = [CCSprite spriteWithFile:@"combowheelmaxedbg.png"];
  maxLayer.position = ccp(maxLayer.contentSize.width/2, self.contentSize.height/2);
  CCSprite *maxArrow = [CCSprite spriteWithFile:@"arrow3.png"];
  CCSprite *barmaxed = [CCSprite spriteWithFile:@"barismaxed.png"];
  CCSprite *tapanywhere = [CCSprite spriteWithFile:@"tapanywheretoengageattack.png"];
  maxLayer.opacity = 0;
  tapanywhere.opacity = 0;
  maxArrow.anchorPoint = ccp(0,0);
  barmaxed.anchorPoint = ccp(0,0);
  tapanywhere.anchorPoint = ccp(0,0);
  [barmaxed addChild:maxArrow];
  [barmaxed addChild:tapanywhere];
  [maxLayer addChild:barmaxed];
  
  float duration = [self rand]*(MAX_COMBO_BAR_DURATION-MIN_COMBO_BAR_DURATION)+MIN_COMBO_BAR_DURATION+1;
  float secondStop = 5.f/6;
  float secondRot = START_TRIANGLE_ROTATION+secondStop*(END_TRIANGLE_ROTATION-START_TRIANGLE_ROTATION);
  [self runAction:[CCSequence actions:
                   [CCCallBlock actionWithBlock:
                    ^{
                      [_overLayer removeFromParentAndCleanup:YES];
                      _overLayer = nil;
                      [_triangle runAction:[CCRotateBy actionWithDuration:duration*secondStop angle:secondRot-_triangle.rotation]];
                    }],
                   [CCDelayTime actionWithDuration:duration*secondStop+0.05f],
                   [CCCallBlock actionWithBlock:
                    ^{
                      _overLayer = maxLayer;
                      [_overLayer runAction:[CCFadeIn actionWithDuration:0.2f]];
                      [self addChild:_overLayer z:5];
                    }],
                   [CCDelayTime actionWithDuration:0.5f],
                   [CCCallBlock actionWithBlock:
                    ^{
                      [tapanywhere runAction:[CCFadeIn actionWithDuration:0.2f]];
                      _allowAttackingForFirstAttack = YES;
                    }],
                   nil]];
  
  [Analytics tutClickedOkay1];
}

- (void) startEnemyTurn {
  if (_firstAttack) {
    _overLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 100)];
    [self addChild:_overLayer z:5];
    
    CCSprite *oppAttack = [CCSprite spriteWithFile:@"opponentsattack.png"];
    oppAttack.position = ccp(_overLayer.contentSize.width/2, _overLayer.contentSize.height/2);
    [_overLayer addChild:oppAttack];
    
    CCSprite *okay = [CCSprite spriteWithFile:@"tutokay.png"];
    CCMenuItemSprite *item = [CCMenuItemSprite itemFromNormalSprite:okay selectedSprite:nil target:self selector:@selector(startEnemyTurn)];
    CCMenu *menu = [CCMenu menuWithItems:item, nil];
    item.position = ccp(0, -48);
    [_overLayer addChild:menu];
    
    _firstAttack = NO;
  } else {
    if (_overLayer) {
      [_overLayer removeFromParentAndCleanup:YES];
      _overLayer = nil;
      
      [Analytics tutClickedOkay2];
    }
    [super startEnemyTurn];
  }
}

- (void) comboBarClicked {
  if (!_allowAttackingForFirstAttack) {
    if (!_overLayer.parent) {
      [_waitForMax stopAllActions];
      [_waitForMax runAction:[CCSequence actions:[CCFadeIn actionWithDuration:0.1f], [CCDelayTime actionWithDuration:0.5f], [CCFadeOut actionWithDuration:0.1f], nil]];
    }
    return;
  }
  
  if (_comboBarMoving) {
    [_waitForMax stopAllActions];
    _waitForMax.opacity = 0.f;
    [_triangle stopAllActions];
    _comboBarMoving = NO;
    [_overLayer removeFromParentAndCleanup:YES];
    _overLayer = nil;	
    
    float percentage = (_triangle.rotation-START_TRIANGLE_ROTATION)/(END_TRIANGLE_ROTATION-START_TRIANGLE_ROTATION)*100;
    _damageDone = [self calculateMyDamageForPercentage:percentage];
    
    _tapToAttack.opacity = 0;
    
    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:0.5] two:[CCCallFunc actionWithTarget:self selector:@selector(doAttackAnimation)]]];
    
    [self showBattleWordForPercentage:percentage];
  }
}

- (void) pauseClicked {
  return;
}

- (void) fleeClicked {
  return;
}

- (void) doneClicked {
  if (_clickedDone) {
    return;
  }
  _clickedDone = YES;
  
  [_left runAction: [CCSequence actions:
                     [CCDelayTime actionWithDuration:0.1],
                     [CCMoveBy actionWithDuration:0.2 position:ccp(-3*_right.contentSize.width/4, 0)],
                     [CCCallFunc actionWithTarget:self selector:@selector(displayStolenEquip)],
                     nil]];
  
  [_ccArrow removeFromParentAndCleanup:YES];
  
  [Analytics tutClickedDone];
}

- (void) displayStolenEquip {
  GameState *gs = [GameState sharedGameState];
  
  UserEquip *ue = [[UserEquip alloc] init];
  ue.equipId = [gs myEquipWithUserEquipId:gs.weaponEquipped].equipId;
  ue.userId = gs.userId;
  ue.level = 1;
  ue.userEquipId = 4;
  [gs.myEquips addObject:ue];
  [ue release];
  
  [self.gainedEquipView loadForEquip:(FullUserEquipProto *)ue];
  
  // Move arrow to close button (tag 20)
  [self.gainedEquipView.mainView addSubview:_uiArrow];
  UIView *okayButton = [self.gainedEquipView viewWithTag:20];
  _uiArrow.center = CGPointMake(CGRectGetMinX(okayButton.frame)-_uiArrow.frame.size.width/2-2, okayButton.center.y);
  [Globals animateUIArrow:_uiArrow atAngle:0];
  
  self.gainedEquipView.equipIcon.userInteractionEnabled = NO;
  [Globals displayUIView:self.gainedEquipView];
  [Globals bounceView:self.gainedEquipView.mainView fadeInBgdView:self.gainedEquipView.bgdView];
}

- (void) displayStolenLockBox {
  [self displaySummary];
}

- (void) displaySummary {
  [Analytics tutClosedBattleSummary];
  
  [self loadBattleSummary];
  [Globals displayUIView:self.summaryView];
  [Globals bounceView:self.summaryView.mainView fadeInBgdView:self.summaryView.bgdView];
  
  [self performSelector:@selector(arrowOnClose) withObject:nil afterDelay:1.f];
}

- (int) calculateMyDamageForPercentage:(float)percent {
  return MIN([super calculateMyDamageForPercentage:percent], _rightMaxHealth/2);
}

- (int) calculateEnemyDamageForPercentage:(float)percent {
  return MIN([super calculateEnemyDamageForPercentage:percent], _leftCurrentHealth/2);
}

- (void) loadBattleSummary {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  
  BattleResponseProto *brp = [[[[BattleResponseProto builder] setExpGained:tc.firstBattleExpGain] setCoinsGained:tc.firstBattleCoinGain] build];
  
  [self.summaryView loadBattleSummaryForBattleResponse:brp enemy:_fup];
  
  self.summaryView.leftScrollView.userInteractionEnabled = NO;
  self.summaryView.rightScrollView.userInteractionEnabled = NO;
}

- (void) arrowOnClose {
  // Move arrow to close button (tag 20)
  [self.summaryView.mainView addSubview:_uiArrow];
  UIView *close = [self.summaryView viewWithTag:20];
  _uiArrow.center = CGPointMake(CGRectGetMinX(close.frame)-_uiArrow.frame.size.width/2+20, close.center.y);
  [Globals animateUIArrow:_uiArrow atAngle:0];
}

- (void) myWin {
  [_right runAction:[CCSpawn actions:
                     [CCScaleBy actionWithDuration:0.3 scale:1.2],
                     [CCFadeOut actionWithDuration:0.3],
                     nil]];
  
  CCParticleSystemQuad *ps = [CCParticleSystemQuad particleWithFile:@"death.plist"];
  [self addChild:ps z:3];
  
  [[SoundEngine sharedSoundEngine] stopBackgroundMusic];
  [[SoundEngine sharedSoundEngine] battleVictory];
  
  [_tapToAttack stopAllActions];
  _tapToAttack.visible = NO;
  [_tryAgain stopAllActions];
  _tryAgain.visible = NO;
  _winLayer.visible = YES;
  _winButton.visible = YES;
  
  [_ccArrow removeFromParentAndCleanup:YES];
  [_winLayer addChild:_ccArrow];
  _ccArrow.visible = YES;
  CCNode *buttonMenu = _winButton.parent;
  CGPoint pos = ccp(buttonMenu.position.x-_winButton.contentSize.width/2-_ccArrow.contentSize.width/2,
                    buttonMenu.position.y);
  _ccArrow.position = pos;
  [Globals animateCCArrow:_ccArrow atAngle:0];
  
  GameState *gs = [GameState sharedGameState];
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  gs.experience += tc.firstBattleExpGain;
  gs.currentStamina -= 1;
  gs.silver += tc.firstBattleCoinGain;
  gs.battlesWon = 1;
  gs.battlesLost = 0;
  gs.flees = 0;
  
//  [Analytics tutorialBattleComplete];
}

- (IBAction)profileButtonClicked:(id)sender {
  return;
}

- (IBAction)attackAgainClicked:(id)sender {
  return;
}

- (void) fbClicked:(id)sender {
  return;
}

- (void) analysisClicked:(id)sender {
  return;
}

- (void) twitterclicked:(id)sender {
  return;
}

- (void) closeClicked:(id)sender {
  [super closeClicked:sender];
  [Analytics tutClosedBattleSummary];
}

- (void) dealloc {
  [_uiArrow release];
  [_ccArrow release];
  [_tryAgain release];
  [_fup release];
  [super dealloc];
}

@end
