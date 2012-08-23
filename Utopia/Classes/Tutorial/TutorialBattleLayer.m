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
#define ENEMY_DEFENSE 10

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
  FullUserProto_Builder *builder = [[[FullUserProto builder] setAttack:ENEMY_ATTACK] 
                                    setDefense:ENEMY_ATTACK];
  _battleCalculator = [BattleCalculator 
                       createWithRightStats:[UserBattleStats 
                                             createWithFullUserProto:[builder build]] 
                       andLeftStats:[UserBattleStats createFromGameState]];
  [_battleCalculator retain];
  
  _ccArrow = [[CCSprite spriteWithFile:@"3darrow.png"] retain];
  [self addChild:_ccArrow];
  _ccArrow.visible = NO;
  
  _tapToAttack = [CCSprite spriteWithFile:@"tapanywheretoattack.png"];
  [self addChild:_tapToAttack];
  _tapToAttack.opacity = 0.f;
  _tapToAttack.position = ccp(self.contentSize.width/2, self.contentSize.height/2+100);
  
  _tryAgain = [CCSprite spriteWithFile:@"tryagain.png"];
  [self addChild:_tryAgain z:1];
  _tryAgain.opacity = 0.f;
  _tryAgain.position = ccp(self.contentSize.width/2, self.contentSize.height/2+130);
  
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
  [Analytics tutorialBattleStart];
}

- (void) startMyTurn {
  if (_firstTurn) {
    _attackButton.visible = YES;
    _comboBar.visible = NO;
    _bottomMenu.visible = YES;
    
    _attackProgressTimer.percentage = 68;
    
    _overLayer = [CCSprite spriteWithFile:@"attackbuttonlight.png"];
    [self addChild:_overLayer z:5];
    _overLayer.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Hit attack before the timer runs out!" dimensions:CGSizeMake(150, 53) alignment:UITextAlignmentLeft lineBreakMode:UILineBreakModeWordWrap fontName:@"DINCond-Black" fontSize:20.f];
    [_overLayer addChild:label];
    label.anchorPoint = ccp(0, 0.5f);
    label.position = ccp(self.contentSize.width/2+75, self.contentSize.height/2+15);
    
    CCMenuItem *okay = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"visitbutton.png"] selectedSprite:nil block:^(id sender) {
      [_overLayer removeFromParentAndCleanup:YES];
      _firstTurn = NO;
      [self startMyTurn];
    }];
    okay.anchorPoint = ccp(0, 0.5f);
    CCMenu *menu = [CCMenu menuWithItems:okay, nil];
    menu.anchorPoint = ccp(0, 0.5f);
    [_overLayer addChild:menu];
    menu.position = ccpAdd(label.position, ccp(0, -label.contentSize.height));
    
    label = [CCLabelFX labelWithString:@"OKAY" fontName:@"DINCond-Black" fontSize:16.f shadowOffset:CGSizeMake(0, -1) shadowBlur:0.3f shadowColor:ccc4(191, 54, 0, 20) fillColor:ccc4(255, 255, 255, 255)];
    [okay addChild:label];
    label.position = ccp(okay.contentSize.width/2, okay.contentSize.height/2);
  } else {
    [super startMyTurn];
    _ccArrow.visible = YES;
    CGPoint pos = ccp(_attackButton.position.x,
                      _attackButton.position.y+_attackButton.contentSize.height/2+_ccArrow.contentSize.height/2);
    _ccArrow.position = pos;
    [Globals animateCCArrow:_ccArrow atAngle:-M_PI_2];
    
    _tapToAttack.opacity = 0.f;
    [_tapToAttack stopAllActions];
  }
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
  if (_firstTurn) {
    return;
  }
  
  _ccArrow.visible = NO;
  if (_firstAttack) {
    [_attackProgressTimer stopAllActions];
    
    _bottomMenu.visible = NO;
    _attackButton.visible = NO;
    
    _comboBar.visible = YES;
    _comboBarMoving = NO;
    
    _overLayer = [CCSprite spriteWithFile:@"combowheellight.png"];
    [self addChild:_overLayer z:5];
    _overLayer.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tap anywhere on the screen to engage your attack." dimensions:CGSizeMake(200, 53) alignment:UITextAlignmentLeft lineBreakMode:UILineBreakModeWordWrap fontName:@"DINCond-Black" fontSize:20.f];
    [_overLayer addChild:label];
    label.anchorPoint = ccp(0, 1.f);
    label.position = ccp(self.contentSize.width/2, self.contentSize.height/2+15);
    
    CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"Aim for the max!" dimensions:CGSizeMake(150, 30) alignment:UITextAlignmentLeft lineBreakMode:UILineBreakModeWordWrap fontName:@"DINCond-Black" fontSize:20.f];
    label2.color = ccc3(255, 200, 0);
    [_overLayer addChild:label2];
    label2.anchorPoint = ccp(0, 1.f);
    label2.position = ccpAdd(label.position, ccp(0, -label.contentSize.height));
    
    CCMenuItem *okay = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"visitbutton.png"] selectedSprite:nil block:^(id sender) {
      [_overLayer removeFromParentAndCleanup:YES];
      _firstAttack = NO;
      [self attackStart];
    }];
    okay.anchorPoint = ccp(0, 1.f);
    CCMenu *menu = [CCMenu menuWithItems:okay, nil];
    menu.anchorPoint = ccp(0, 1.f);
    [_overLayer addChild:menu];
    menu.position = ccpAdd(label2.position, ccp(0, -label2.contentSize.height));
    
    label = [CCLabelFX labelWithString:@"OKAY" fontName:@"DINCond-Black" fontSize:16.f shadowOffset:CGSizeMake(0, -1) shadowBlur:0.3f shadowColor:ccc4(191, 54, 0, 20) fillColor:ccc4(255, 255, 255, 255)];
    [okay addChild:label];
    label.position = ccp(okay.contentSize.width/2, okay.contentSize.height/2);
  } else {
    [super attackStart];
    [_ccArrow stopAllActions];
    _tryAgain.opacity = 0;
    [_tryAgain stopAllActions];
    
    _tapToAttack.opacity = 255;
    CCScaleBy *bigger = [CCScaleBy actionWithDuration:1.f scale:1.1f];
    [_tapToAttack runAction:[CCRepeatForever actionWithAction:
                             [CCSequence actions:bigger, [bigger reverse], nil]]];
  }
}

- (void) comboBarClicked {
  if (_comboBarMoving) {
    [_triangle stopAllActions];
    _comboBarMoving = NO;
    
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
}

- (void) displayStolenEquip {
  [self loadStolenEquip];
  [Globals displayUIView:self.stolenEquipView];
  [Globals bounceView:self.stolenEquipView.mainView fadeInBgdView:self.stolenEquipView.bgdView];
}

- (void) displaySummary {
  [self loadBattleSummary];
  [Globals displayUIView:self.summaryView];
  [Globals bounceView:self.summaryView.mainView fadeInBgdView:self.summaryView.bgdView];
  
  [self performSelector:@selector(arrowOnClose) withObject:nil afterDelay:1.f];
}

- (int) calculateEnemyDamageForPercentage:(float)percent {
  return MIN([super calculateEnemyDamageForPercentage:percent], _leftCurrentHealth/2);
}

- (void) loadStolenEquip {
  GameState *gs = [GameState sharedGameState];
  StartupResponseProto_TutorialConstants_FullTutorialQuestProto *tutQuest = [[TutorialConstants sharedTutorialConstants] tutorialQuest];
  
  UserEquip *ue = [[UserEquip alloc] init];
  ue.equipId = tutQuest.firstDefeatTypeJobBattleLootAmulet.equipId;
  ue.userId = gs.userId;
  ue.level = 1;
  ue.userEquipId = 3;
  [gs.myEquips addObject:ue];
  [ue release];
  
  [self.stolenEquipView loadForEquip:(FullUserEquipProto *)ue];
  
  // Move arrow to close button (tag 20)
  [self.stolenEquipView.mainView addSubview:_uiArrow];
  UIView *okayButton = [self.stolenEquipView viewWithTag:20];
  _uiArrow.center = CGPointMake(CGRectGetMinX(okayButton.frame)-_uiArrow.frame.size.width/2-2, okayButton.center.y);
  [Globals animateUIArrow:_uiArrow atAngle:0];
}

- (void) loadBattleSummary {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  GameState *gs = [GameState sharedGameState];
  
  self.summaryView.leftNameLabel.text = gs.name;
  self.summaryView.leftLevelLabel.text = @"Lvl 1";
  self.summaryView.leftPlayerIcon.image = [Globals squareImageForUser:gs.type];
  
  self.summaryView.rightNameLabel.text = tc.enemyName;
  self.summaryView.rightLevelLabel.text = @"Lvl 1";
  self.summaryView.rightPlayerIcon.image = [Globals squareImageForUser:tc.enemyType];
  
  FullEquipProto *fep = [gs equipWithId:gs.weaponEquippedId];
  self.summaryView.leftRarityLabel1.textColor = [Globals colorForRarity:fep.rarity];
  self.summaryView.leftRarityLabel1.text = [Globals shortenedStringForRarity:fep.rarity];
  self.summaryView.leftEquipIcon1.image = [Globals imageForEquip:fep.equipId];
  self.summaryView.leftEquipLevelIcon1.level = 1;
  
  fep = [gs equipWithId:gs.armorEquippedId];
  self.summaryView.leftRarityLabel2.textColor = [Globals colorForRarity:fep.rarity];
  self.summaryView.leftRarityLabel2.text = [Globals shortenedStringForRarity:fep.rarity];
  self.summaryView.leftEquipIcon2.image = [Globals imageForEquip:fep.equipId];
  self.summaryView.leftEquipLevelIcon2.level = 1;
  
  self.summaryView.leftRarityLabel3.text = @"";
  self.summaryView.leftEquipIcon3.image = nil;
  
  fep = tc.warriorInitWeapon;
  self.summaryView.rightRarityLabel1.textColor = [Globals colorForRarity:fep.rarity];
  self.summaryView.rightRarityLabel1.text = [Globals shortenedStringForRarity:fep.rarity];
  self.summaryView.rightEquipIcon1.image = [Globals imageForEquip:fep.equipId];
  self.summaryView.rightEquipLevelIcon1.level = 1;
  
  fep = tc.warriorInitArmor;
  self.summaryView.rightRarityLabel2.textColor = [Globals colorForRarity:fep.rarity];
  self.summaryView.rightRarityLabel2.text = [Globals shortenedStringForRarity:fep.rarity];
  self.summaryView.rightEquipIcon2.image = [Globals imageForEquip:fep.equipId];
  self.summaryView.rightEquipLevelIcon2.level = 1;
  
  self.summaryView.rightRarityLabel3.text = @"";
  self.summaryView.rightEquipIcon3.image = nil;
  
  self.summaryView.winLabelsView.hidden = NO;
  self.summaryView.defeatLabelsView.hidden = YES;
  self.summaryView.coinsGainedLabel.text = [NSString stringWithFormat:@"+%@", [Globals commafyNumber:tc.tutorialQuest.firstDefeatTypeJobBattleCoinGain]];
  self.summaryView.expGainedLabel.text = [NSString stringWithFormat:@"%@ Exp.", [Globals commafyNumber:tc.tutorialQuest.firstDefeatTypeJobBattleExpGain]];
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
  StartupResponseProto_TutorialConstants_FullTutorialQuestProto *tutQuest = [[TutorialConstants sharedTutorialConstants] tutorialQuest];
  gs.experience += tutQuest.firstDefeatTypeJobBattleExpGain;
  gs.currentStamina -= 1;
  gs.silver += tutQuest.firstDefeatTypeJobBattleCoinGain;
  gs.battlesWon = 1;
  
  [Analytics tutorialBattleComplete];
}

- (IBAction)profileButtonClicked:(id)sender {
  return;
}

- (IBAction)attackAgainClicked:(id)sender {
  return;
}

- (void) dealloc {
  [_uiArrow release];
  [_ccArrow release];
  [super dealloc];
}

@end
