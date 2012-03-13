//
//  BattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/23/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "Protocols.pb.h"

@interface BattleSummaryView : UIView

@property (nonatomic, retain) IBOutlet UILabel *leftNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *leftLevelLabel;
@property (nonatomic, retain) IBOutlet UIImageView *leftPlayerIcon;
@property (nonatomic, retain) IBOutlet UILabel *rightNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *rightLevelLabel;
@property (nonatomic, retain) IBOutlet UIImageView *rightPlayerIcon;

@property (nonatomic, retain) IBOutlet UILabel *leftRarityLabel1;
@property (nonatomic, retain) IBOutlet UIImageView *leftEquipIcon1;
@property (nonatomic, retain) IBOutlet UILabel *leftRarityLabel2;
@property (nonatomic, retain) IBOutlet UIImageView *leftEquipIcon2;
@property (nonatomic, retain) IBOutlet UILabel *leftRarityLabel3;
@property (nonatomic, retain) IBOutlet UIImageView *leftEquipIcon3;
@property (nonatomic, retain) IBOutlet UILabel *rightRarityLabel1;
@property (nonatomic, retain) IBOutlet UIImageView *rightEquipIcon1;
@property (nonatomic, retain) IBOutlet UILabel *rightRarityLabel2;
@property (nonatomic, retain) IBOutlet UIImageView *rightEquipIcon2;
@property (nonatomic, retain) IBOutlet UILabel *rightRarityLabel3;
@property (nonatomic, retain) IBOutlet UIImageView *rightEquipIcon3;

@property (nonatomic, retain) IBOutlet UILabel *coinsGainedLabel;
@property (nonatomic, retain) IBOutlet UILabel *coinsLostLabel;
@property (nonatomic, retain) IBOutlet UILabel *expGainedLabel;
@property (nonatomic, retain) IBOutlet UIView *winLabelsView;
@property (nonatomic, retain) IBOutlet UIView *defeatLabelsView;

@end

@interface StolenEquipView : UIView

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *equipIcon;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;

@end

@interface BattleLayer : CCLayer {
  CCSprite *_left;
  CCSprite *_right;
  
  CCSprite *_leftHealthBar;
  CCSprite *_rightHealthBar;
  
  CCSprite *_attackButton;
  CCProgressTimer *_attackProgressTimer;
  
  CCSprite *_comboBar;
  CCProgressTimer *_comboProgressTimer;
  CCSprite *_flippedComboBar;
  CCProgressTimer *_flippedComboProgressTimer;
  
  CCLabelTTF *_leftMaxHealthLabel;
  CCLabelTTF *_leftCurHealthLabel;
  CCLabelTTF *_rightMaxHealthLabel;
  CCLabelTTF *_rightCurHealthLabel;
  
  CCMenu *_bottomMenu;
  
  BOOL _comboBarMoving;
  
  int _leftMaxHealth;
  int _leftCurrentHealth;
  int _rightMaxHealth;
  int _rightCurrentHealth;
  
  int _leftAttack;
  int _leftDefense;
  int _rightAttack;
  int _rightDefense;
  
  float _damageDone;
  
  CCLayer *_pausedLayer;
  CCLayer *_fleeLayer;
  CCMenuItemSprite *_fleeButton;
  CCLayer *_winLayer;
  CCMenuItemSprite *_winButton;
  CCLayer *_loseLayer;
  CCMenuItemSprite *_loseButton;
  
  FullUserProto *_fup;
}

@property (nonatomic, retain) IBOutlet StolenEquipView *stolenEquipView;
@property (nonatomic, retain) IBOutlet BattleSummaryView *summaryView;

@property (nonatomic, retain) BattleResponseProto *brp;

+ (CCScene *) scene;
+ (BattleLayer *) sharedBattleLayer;
- (void) beginBattleAgainst:(FullUserProto *)user;
- (void) doAttackAnimation;

- (IBAction)stolenEquipOkayClicked:(id)sender;
- (IBAction)closeClicked:(id)sender;
- (IBAction)attackAgainClicked:(id)sender;
- (IBAction)profileButtonClicked:(id)sender;

- (void) startBattle;
- (void) startMyTurn;
- (void) attackStart;
- (void) turnMissed;
- (void) comboBarClicked;
- (void) attackAnimationDone;
- (void) startEnemyTurn;
- (void) enemyAttackDone;
- (void) doneWithLeftHealthBar;
- (void) myWin;
- (void) myLoss;
- (void) checkLoseBrp;
- (void) fleeClicked;
- (void) checkFleeBrp;
- (void) pauseClicked;
- (void) resumeClicked;
- (void) doneClicked;
- (void) displaySummary;
- (void) closeScene;
- (int) calculateEnemyDamageForPercentage:(float)percent;

@end
