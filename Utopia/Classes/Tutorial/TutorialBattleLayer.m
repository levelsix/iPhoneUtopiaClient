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
#import "DialogMenuController.h"

#define ENEMY_HEALTH 30
#define ENEMY_ATTACK 20
#define ENEMY_DEFENSE 20

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
  
  _leftCurrentHealth = gs.maxHealth;
  _leftMaxHealth = gs.maxHealth;
  _rightMaxHealth = ENEMY_HEALTH;
  _rightCurrentHealth = ENEMY_HEALTH;
  
  _rightCurHealthLabel.string = [NSString stringWithFormat:@"%d", _rightCurrentHealth];
  _rightMaxHealthLabel.string = [NSString stringWithFormat:@" / %d", _rightMaxHealth];
  _leftCurHealthLabel.string = [NSString stringWithFormat:@"%d", _leftCurrentHealth];
  _leftMaxHealthLabel.string = [NSString stringWithFormat:@" / %d", _leftMaxHealth];
  
  _leftNameLabel.string = gs.name;
  _leftNameBg.position = ccp(_leftNameBg.contentSize.width+_leftNameLabel.contentSize.width-_leftNameLabel.position.x+15, _leftNameBg.position.y);
  _rightNameLabel.string = [[TutorialConstants sharedTutorialConstants] enemyName];
  _rightNameBg.position = ccp(_rightNameBg.parent.contentSize.width-_rightNameLabel.contentSize.width-_rightNameLabel.position.x-15, _rightNameBg.position.y);
  
  _leftAttack = [[Globals sharedGlobals] calculateAttackForStat:gs.attack weapon:gs.weaponEquipped armor:gs.armorEquipped amulet:0];
  _leftDefense = [[Globals sharedGlobals] calculateDefenseForStat:gs.defense weapon:gs.weaponEquipped armor:gs.armorEquipped amulet:0];;
  _rightAttack = ENEMY_ATTACK;
  _rightDefense = ENEMY_DEFENSE;
  
  _ccArrow = [[CCSprite spriteWithFile:@"green.png"] retain];
  [self addChild:_ccArrow];
  _ccArrow.visible = NO;
  
  _pulsingLabel = [[CCLabelTTF alloc] initWithString:@"" fontName:[Globals font] fontSize:18];
  [self addChild:_pulsingLabel];
  _pulsingLabel.opacity = 0.f;
  _pulsingLabel.color = ccc3(255,200,0);
  
  _uiArrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"green.png"]];
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
  [self startBattle]; 
}

- (void) startMyTurn {
  if (_firstTurn) {
    _attackButton.visible = YES;
    _comboBar.visible = NO;
    _bottomMenu.visible = YES;
    
    TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
    [DialogMenuController displayViewForText:tc.beginBattleText callbackTarget:self action:@selector(startMyTurn)];
    _firstTurn = NO;
    return;
  }
  
  [super startMyTurn];
  _ccArrow.visible = YES;
  CGPoint pos = ccp(_attackButton.position.x,
                    _attackButton.position.y+_attackButton.contentSize.height/2+_ccArrow.contentSize.height/2);
  _ccArrow.position = pos;
  
  CCMoveBy *upAction = [CCMoveTo actionWithDuration:1 position:ccp(pos.x, pos.y+20)];
  CCMoveBy *downAction = [CCMoveTo actionWithDuration:1 position:pos];
  [_ccArrow stopAllActions];
  [_ccArrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, 
                                                         downAction, nil]]];
  
  _pulsingLabel.opacity = 0.f;
  [_pulsingLabel stopAllActions];
}

- (void) turnMissed {
  [self startMyTurn];
  
  _pulsingLabel.position = ccp(_ccArrow.position.x, _ccArrow.position.y+40);
  _pulsingLabel.string = @"Try Again!";
  _pulsingLabel.opacity = 255;
  [_pulsingLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.f],
                            [CCFadeOut actionWithDuration:1.f],nil]];
}

- (void) attackStart {
  _ccArrow.visible = NO;
  if (_firstAttack) {
    [_attackProgressTimer stopAllActions];
    
    _bottomMenu.visible = NO;
    _attackButton.visible = NO;
    
    _comboBar.visible = YES;
    _comboBarMoving = YES;
    
    TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
    [DialogMenuController displayViewForText:tc.beginAttackText callbackTarget:self action:@selector(attackStart)];
    _firstAttack = NO;
    return;
  }
  
  [super attackStart];
  [_ccArrow stopAllActions];
  
  _pulsingLabel.string = @"Tap anywhere to attack";
  _pulsingLabel.position = ccp(self.contentSize.width/2, self.contentSize.height/2+100);
  _pulsingLabel.opacity = 255;
  CCScaleBy *bigger = [CCScaleBy actionWithDuration:1.f scale:1.1f];
  [_pulsingLabel runAction:[CCRepeatForever actionWithAction:
                            [CCSequence actions:bigger, [bigger reverse], nil]]];
}

- (void) comboBarClicked {
  if (_comboBarMoving) {
    [_comboProgressTimer stopAllActions];
    _comboBarMoving = NO;
    _damageDone = [self calculateMyDamageForPercentage:_comboProgressTimer.percentage];
    
    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:0.5] two:[CCCallFunc actionWithTarget:self selector:@selector(doAttackAnimation)]]];
  }
}

- (void) startEnemyTurn {
  _pulsingLabel.opacity = 0;
  [super startEnemyTurn];
}

- (void) pauseClicked {
  return;
}

- (void) fleeClicked {
  return;
}

- (void) doneClicked {
  [_left runAction: [CCSequence actions: 
                     [CCDelayTime actionWithDuration:0.1],
                     [CCMoveBy actionWithDuration:0.2 position:ccp(-3*_right.contentSize.width/4, 0)],
                     [CCCallFunc actionWithTarget:self selector:@selector(displayStolenEquip)],
                     nil]];
}

- (void) displayStolenEquip {
  UIView *view = [[[CCDirector sharedDirector] openGLView] superview];
  [self loadStolenEquip];
  [view addSubview:self.stolenEquipView];
}

- (void) displaySummary {
  UIView *view = [[[CCDirector sharedDirector] openGLView] superview];
  [self loadBattleSummary];
  [view addSubview:self.summaryView];
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.afterBattleText callbackTarget:nil action:nil];
  [_uiArrow removeFromSuperview];
  
  [self performSelector:@selector(arrowOnClose) withObject:nil afterDelay:2.f];
}

- (int) calculateEnemyDamageForPercentage:(float)percent {
  return MIN([super calculateEnemyDamageForPercentage:percent], _leftCurrentHealth/2);
}

- (void) loadStolenEquip {
  FullEquipProto *fep = [[[TutorialConstants sharedTutorialConstants] tutorialQuest] firstDefeatTypeJobBattleLootAmulet];
  
  self.stolenEquipView.nameLabel.text = fep.name;
  self.stolenEquipView.equipIcon.image = [Globals imageForEquip:fep.equipId];
  self.stolenEquipView.attackLabel.text = [NSString stringWithFormat:@"%d", fep.attackBoost];
  self.stolenEquipView.defenseLabel.text = [NSString stringWithFormat:@"%d", fep.defenseBoost];
  
  // Move arrow to close button (tag 20)
  [self.stolenEquipView addSubview:_uiArrow];
  UIView *okayButton = [self.stolenEquipView viewWithTag:20];
  _uiArrow.center = CGPointMake(CGRectGetMinX(okayButton.frame)-_uiArrow.frame.size.width/2-2, okayButton.center.y);
  
  UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
  [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
    _uiArrow.center = CGPointMake(_uiArrow.center.x-10, _uiArrow.center.y);
  } completion:nil];
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
  
  FullEquipProto *fep = tc.archerInitWeapon;
  self.summaryView.leftRarityLabel1.textColor = [Globals colorForRarity:fep.rarity];
  self.summaryView.leftRarityLabel1.text = [Globals shortenedStringForRarity:fep.rarity];
  self.summaryView.leftEquipIcon1.image = [Globals imageForEquip:fep.equipId];
  
  fep = tc.archerInitWeapon;
  self.summaryView.leftRarityLabel2.textColor = [Globals colorForRarity:fep.rarity];
  self.summaryView.leftRarityLabel2.text = [Globals shortenedStringForRarity:fep.rarity];
  self.summaryView.leftEquipIcon2.image = [Globals imageForEquip:fep.equipId];
  
  self.summaryView.leftRarityLabel3.text = @"";
  self.summaryView.leftEquipIcon3.image = nil;
  
  self.summaryView.rightRarityLabel1.text = @"";
  self.summaryView.rightEquipIcon1.image = nil;
  
  self.summaryView.rightRarityLabel2.text = @"";
  self.summaryView.rightEquipIcon2.image = nil;
  
  self.summaryView.rightRarityLabel3.text = @"";
  self.summaryView.rightEquipIcon3.image = nil;
  
  self.summaryView.winLabelsView.hidden = NO;
  self.summaryView.defeatLabelsView.hidden = YES;
  self.summaryView.coinsGainedLabel.text = [NSString stringWithFormat:@"+%@", [Globals commafyNumber:tc.tutorialQuest.firstDefeatTypeJobBattleCoinGain]];
  self.summaryView.expGainedLabel.text = [NSString stringWithFormat:@"%@ Exp.", [Globals commafyNumber:tc.tutorialQuest.firstDefeatTypeJobBattleExpGain]];
}

- (void) arrowOnClose {
  // Move arrow to close button (tag 20)
  [self.summaryView addSubview:_uiArrow];
  UIView *close = [self.summaryView viewWithTag:20];
  _uiArrow.center = CGPointMake(CGRectGetMinX(close.frame)-_uiArrow.frame.size.width/2-2, close.center.y);
  
  _uiArrow.alpha = 0.f;
  UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
  // This is confusing, basically fade in, and then do repeated animation
  [UIView animateWithDuration:0.3f animations:^{
    _uiArrow.alpha = 1.f;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
      _uiArrow.center = CGPointMake(_uiArrow.center.x+10, _uiArrow.center.y);
    } completion:nil];
  }];
}

- (void) myWin {
  [_right runAction:[CCSpawn actions:
                     [CCScaleBy actionWithDuration:0.1 scale:1.2],
                     [CCFadeOut actionWithDuration:0.1],
                     nil]];
  
  [_pulsingLabel stopAllActions];
  _pulsingLabel.visible = NO;
  _winLayer.visible = YES;
  _winButton.visible = YES;
  
  GameState *gs = [GameState sharedGameState];
  StartupResponseProto_TutorialConstants_FullTutorialQuestProto *tutQuest = [[TutorialConstants sharedTutorialConstants] tutorialQuest];
  gs.experience += tutQuest.firstDefeatTypeJobBattleExpGain;
  gs.currentStamina -= 1;
  gs.silver += tutQuest.firstDefeatTypeJobBattleCoinGain;
  gs.battlesWon = 1;
  
  UserEquip *ue = [[UserEquip alloc] init];
  ue.equipId = tutQuest.firstDefeatTypeJobBattleLootAmulet.equipId;
  ue.quantity = 1;
  ue.userId = gs.userId;
  [[gs myEquips] addObject:ue];
  [ue release];
  
  [[TutorialMissionMap sharedTutorialMissionMap] battleDone];
}

- (IBAction)profileButtonClicked:(id)sender {
  return;
}

- (IBAction)attackAgainClicked:(id)sender {
  return;
}

- (IBAction)closeClicked:(id)sender {
  [super closeClicked:sender];
  [[TutorialMissionMap sharedTutorialMissionMap] battleClosed];
}

- (void) dealloc {
  [_uiArrow release];
  [_pulsingLabel release];
  [_ccArrow release];
  [super dealloc];
}

@end
