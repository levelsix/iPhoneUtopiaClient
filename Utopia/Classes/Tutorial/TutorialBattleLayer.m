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

#define ENEMY_HEALTH 30
#define ENEMY_ATTACK 10
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
  
  _leftCurrentHealth = gs.maxHealth;
  _leftMaxHealth = gs.maxHealth;
  _rightMaxHealth = ENEMY_HEALTH;
  _rightCurrentHealth = ENEMY_HEALTH;
  
  _rightCurHealthLabel.string = [NSString stringWithFormat:@"%d", _rightCurrentHealth];
  _rightMaxHealthLabel.string = [NSString stringWithFormat:@" / %d", _rightMaxHealth];
  _leftCurHealthLabel.string = [NSString stringWithFormat:@"%d", _leftCurrentHealth];
  _leftMaxHealthLabel.string = [NSString stringWithFormat:@" / %d", _leftMaxHealth];
  
  _leftAttack = [[Globals sharedGlobals] calculateAttackForStat:gs.attack weapon:gs.weaponEquipped armor:gs.armorEquipped amulet:0];
  _leftDefense = [[Globals sharedGlobals] calculateDefenseForStat:gs.defense weapon:gs.weaponEquipped armor:gs.armorEquipped amulet:0];;
  _rightAttack = ENEMY_ATTACK;
  _rightDefense = ENEMY_DEFENSE;
  
  [self startBattle];
  
  _arrow = [CCSprite spriteWithFile:@"green.png"];
  [self addChild:_arrow];
  _arrow.visible = NO;
}

- (void) startMyTurn {
  [super startMyTurn];
  _arrow.visible = YES;
  CGPoint pos = ccp(_attackButton.position.x,
                    _attackButton.position.y+_attackButton.contentSize.height/2+_arrow.contentSize.height/2);
  _arrow.position = pos;
  
  CCMoveBy *upAction = [CCMoveTo actionWithDuration:1 position:ccp(pos.x, pos.y+20)];
  CCMoveBy *downAction = [CCMoveTo actionWithDuration:1 position:pos];
  [_arrow stopAllActions];
  [_arrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:upAction, 
                                                       downAction, nil]]];
}

- (void) turnMissed {
  [self startMyTurn];
}

- (void) attackStart {
  [super attackStart];
  _arrow.visible = NO;
  [_arrow stopAllActions]; 
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
  float perc = [self calculateEnemyPercentage];
  _damageDone = [self calculateEnemyDamageForPercentage:perc];
  
  _bottomMenu.visible = NO;
  _attackButton.visible = NO;
  _flippedComboBar.visible = YES;
  
  float duration = [self rand]*(MAX_COMBO_BAR_DURATION-MIN_COMBO_BAR_DURATION)+MIN_COMBO_BAR_DURATION;
  [_flippedComboProgressTimer runAction:[CCSequence actions:[CCEaseIn actionWithAction:[CCProgressFromTo actionWithDuration:perc*duration/100 from:0 to:perc] rate:2.5],
                                         [CCDelayTime actionWithDuration:0.5],
                                         [CCCallFunc actionWithTarget:self selector:@selector(doEnemyAttackAnimation)],
                                         nil]];
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
}

- (void) loadBattleSummary {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  GameState *gs = [GameState sharedGameState];
  
  self.summaryView.leftNameLabel.text = gs.name;
  self.summaryView.leftLevelLabel.text = @"Lvl 1";
  
  self.summaryView.rightNameLabel.text = tc.enemyName;
  self.summaryView.rightLevelLabel.text = @"Lvl 1";
  
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

- (void) myWin {
  [_right runAction:[CCSpawn actions:
                     [CCScaleBy actionWithDuration:0.1 scale:1.2],
                     [CCFadeOut actionWithDuration:0.1],
                     nil]];
  
  _winLayer.visible = YES;
  _winButton.visible = YES;
  
  GameState *gs = [GameState sharedGameState];
  StartupResponseProto_TutorialConstants_FullTutorialQuestProto *tutQuest = [[TutorialConstants sharedTutorialConstants] tutorialQuest];
  gs.experience += tutQuest.firstDefeatTypeJobBattleExpGain;
  gs.currentStamina -= 1;
  gs.silver += tutQuest.firstDefeatTypeJobBattleCoinGain;
  
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

@end
