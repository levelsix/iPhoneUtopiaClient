//
//  BattleLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/23/11.
//  Copyright (c) 2011 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "Protocols.pb.h"
#import "NibUtils.h"
#import "BattleCalculator.h"

#define HEALTH_BAR_VELOCITY 100.f

#define ATTACK_BUTTON_ANIMATION 4.f

#define MIN_COMBO_BAR_DURATION 1.8f
#define MAX_COMBO_BAR_DURATION 3.3f

#define BIG_HEALTH_FONT 14.f
#define SMALL_HEALTH_FONT 10.f

#define COMBO_BAR_X_POSITION 110
#define DELAY_BEFORE_COMBO_BAR_WINDUP_SOUND 0.7f

#define START_TRIANGLE_ROTATION -45.f
#define END_TRIANGLE_ROTATION 225.f

@interface BattleSummaryView : UIView

@property (nonatomic, retain) IBOutlet UILabel *leftNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *leftLevelLabel;
@property (nonatomic, retain) IBOutlet UIImageView *leftPlayerIcon;
@property (nonatomic, retain) IBOutlet UILabel *rightNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *rightLevelLabel;
@property (nonatomic, retain) IBOutlet UIImageView *rightPlayerIcon;

@property (nonatomic, retain) IBOutlet UILabel *leftRarityLabel1;
@property (nonatomic, retain) IBOutlet EquipButton *leftEquipIcon1;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *leftEquipLevelIcon1;
@property (nonatomic, retain) IBOutlet UILabel *leftRarityLabel2;
@property (nonatomic, retain) IBOutlet EquipButton *leftEquipIcon2;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *leftEquipLevelIcon2;
@property (nonatomic, retain) IBOutlet UILabel *leftRarityLabel3;
@property (nonatomic, retain) IBOutlet EquipButton *leftEquipIcon3;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *leftEquipLevelIcon3;
@property (nonatomic, retain) IBOutlet UILabel *rightRarityLabel1;
@property (nonatomic, retain) IBOutlet EquipButton *rightEquipIcon1;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *rightEquipLevelIcon1;
@property (nonatomic, retain) IBOutlet UILabel *rightRarityLabel2;
@property (nonatomic, retain) IBOutlet EquipButton *rightEquipIcon2;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *rightEquipLevelIcon2;
@property (nonatomic, retain) IBOutlet UILabel *rightRarityLabel3;
@property (nonatomic, retain) IBOutlet EquipButton *rightEquipIcon3;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *rightEquipLevelIcon3;

@property (nonatomic, retain) IBOutlet UILabel *coinsGainedLabel;
@property (nonatomic, retain) IBOutlet UILabel *coinsLostLabel;
@property (nonatomic, retain) IBOutlet UILabel *expGainedLabel;
@property (nonatomic, retain) IBOutlet UIView *winLabelsView;
@property (nonatomic, retain) IBOutlet UIView *defeatLabelsView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@end

@interface StolenEquipView : UIView

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet EquipButton *equipIcon;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *levelIcon;

@property (nonatomic, retain) IBOutlet UIView *statsView;
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

- (void) loadForEquip:(FullUserEquipProto *)fuep;
- (void) loadForLockBox:(int)eventId;

@end

@interface BattleLayer : CCLayer {
  BOOL _isRunning;
  BOOL _isBattling;
  BOOL _isAnimating;
  
  CCSprite *_left;
  CCSprite *_right;
  
  CCSprite *_leftHealthBar;
  CCSprite *_rightHealthBar;
  
  CCSprite *_leftNameBg;
  CCSprite *_rightNameBg;
  CCLabelTTF *_leftNameLabel;
  CCLabelTTF *_rightNameLabel;
  
  CCSprite *_attackButton;
  CCProgressTimer *_attackProgressTimer;
  
  CCSprite *_comboBar;
  CCSprite *_triangle;
//  CCProgressTimer *_comboProgressTimer;
  CCSprite *_flippedComboBar;
  CCSprite *_flippedTriangle;
//  CCProgressTimer *_flippedComboProgressTimer;
  
  CCLabelTTF *_leftMaxHealthLabel;
  CCLabelTTF *_leftCurHealthLabel;
  CCLabelTTF *_rightMaxHealthLabel;
  CCLabelTTF *_rightCurHealthLabel;
  
  CCMenu *_bottomMenu;
  
  BOOL _comboBarMoving;
  BOOL _attackMoving;
  
  int _leftMaxHealth;
  int _leftCurrentHealth;
  int _rightMaxHealth;
  int _rightCurrentHealth;
  
  float _damageDone;
  
  UserType _enemyType;
  
  CCLayer *_pausedLayer;
  CCLayer *_fleeLayer;
  CCMenuItemSprite *_fleeButton;
  CCLayer *_winLayer;
  CCMenuItemSprite *_winButton;
  CCLayer *_loseLayer;
  CCMenuItemSprite *_loseButton;
  
  FullUserProto *_fup;
  
  int _cityId;
  
  BOOL _cameFromAviary;
  BOOL _cameFromClans;
  
  BOOL _clickedDone;
  id<BattleCalculator> _battleCalculator;
}

// Since we can only one IBOutlet, the gainedEquipView displays for stolen equips
// and the gained lock box view shows for acquiring a lock box
@property (nonatomic, retain) IBOutlet StolenEquipView *stolenEquipView;
@property (nonatomic, retain) StolenEquipView *gainedEquipView;
@property (nonatomic, retain) StolenEquipView *gainedLockBoxView;
@property (nonatomic, retain) IBOutlet BattleSummaryView *summaryView;

@property (nonatomic, retain) BattleResponseProto *brp;
@property (retain) NSArray *enemyEquips;

+ (CCScene *) scene;
+ (BattleLayer *) sharedBattleLayer;
+ (BOOL) isInitialized;
+ (void) purgeSingleton;
- (BOOL) beginBattleAgainst:(FullUserProto *)user;
- (BOOL) beginBattleAgainst:(FullUserProto *)user inCity:(int) cityId;
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
- (void) showBattleWordForPercentage:(float)percent;
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
- (int) calculateMyDamageForPercentage:(float)percent;
- (int) calculateEnemyDamageForPercentage:(float)percent;
- (float) calculateEnemyPercentage;
- (float) rand;

- (void) closeSceneFromQuestLog;

- (void)receivedUserEquips:(RetrieveUserEquipForUserResponseProto *)proto;

@end
