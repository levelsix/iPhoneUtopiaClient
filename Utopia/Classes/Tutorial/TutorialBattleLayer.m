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
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  
  _leftCurrentHealth = tc.initHealth;
  _leftMaxHealth = tc.initHealth;
  _rightMaxHealth = ENEMY_HEALTH;
  _rightCurrentHealth = ENEMY_HEALTH;
  
  _rightCurHealthLabel.string = [NSString stringWithFormat:@"%d", _rightCurrentHealth];
  _rightMaxHealthLabel.string = [NSString stringWithFormat:@" / %d", _rightMaxHealth];
  _leftCurHealthLabel.string = [NSString stringWithFormat:@"%d", _leftCurrentHealth];
  _leftMaxHealthLabel.string = [NSString stringWithFormat:@" / %d", _leftMaxHealth];
  
  _leftAttack = 40;
  _leftDefense = 40;
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

- (void) pauseClicked {
  return;
}

- (void) fleeClicked {
  return;
}

- (int) calculateEnemyDamageForPercentage:(float)percent {
  return MAX([super calculateEnemyDamageForPercentage:percent], _leftCurrentHealth/2);
}

- (void) loadBattleSummary {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  GameState *gs = [GameState sharedGameState];
  
  self.summaryView.leftNameLabel.text = gs.name;
  self.summaryView.leftLevelLabel.text = @"Lvl 1";
  
  self.summaryView.rightNameLabel.text = @"Guetta";
  self.summaryView.rightLevelLabel.text = @"Lvl 1";
  
  
  FullEquipProto *fep = tc.archerInitWeapon;
  self.summaryView.leftRarityLabel1.textColor = [Globals colorForRarity:fep.rarity];
  self.summaryView.leftRarityLabel1.text = [Globals shortenedStringForRarity:fep.rarity];
  self.summaryView.leftEquipIcon1.image = [Globals imageForEquip:fep.equipId];
  
  fep = tc.archerInitWeapon;
  self.summaryView.leftRarityLabel2.textColor = [Globals colorForRarity:fep.rarity];
  self.summaryView.leftRarityLabel2.text = [Globals shortenedStringForRarity:fep.rarity];
  self.summaryView.leftEquipIcon2.image = [Globals imageForEquip:fep.equipId];
  
//  rarityLabel = leftRarityLabel3;
//  imgView = leftEquipIcon3;
//  equipId = gs.armorEquipped;
//  if (equipId > 0) {
//    FullEquipProto *fep = [gs equipWithId:equipId];
//    rarityLabel.textColor = [Globals colorForRarity:fep.rarity];
//    rarityLabel.text = [Globals shortenedStringForRarity:fep.rarity];
//    imgView.image = [Globals imageForEquip:fep.equipId];
//  } else {
//    rarityLabel.text = @"";
//    imgView.image = nil;
//  }
//  
//  if (brp.hasExpGained) {
//    // This is a win
//    winLabelsView.hidden = NO;
//    defeatLabelsView.hidden = YES;
//    coinsGainedLabel.text = [NSString stringWithFormat:@"+%@", [Globals commafyNumber:brp.coinsGained]];
//    expGainedLabel.text = [NSString stringWithFormat:@"%@ Exp.", [Globals commafyNumber:brp.expGained]];
//  } else {
//    winLabelsView.hidden = YES;
//    defeatLabelsView.hidden = NO;
//    // Coins gained is the loss amount
//    coinsLostLabel.text = [NSString stringWithFormat:@"-%@", [Globals commafyNumber:brp.coinsGained]];
//  }
}

@end
