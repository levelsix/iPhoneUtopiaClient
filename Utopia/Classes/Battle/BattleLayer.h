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
#import "BattleMenus.h"

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
  BOOL _cameFromTournament;
  
  BOOL _clickedDone;
  id<BattleCalculator> _battleCalculator;
  
  BOOL _isForTutorial;
  BOOL _guaranteeWin;
}

// Since we can only one IBOutlet, the gainedEquipView displays for stolen equips
// and the gained lock box view shows for acquiring a lock box
@property (nonatomic, retain) IBOutlet StolenEquipView *stolenEquipView;
@property (nonatomic, retain) StolenEquipView *gainedEquipView;
@property (nonatomic, retain) StolenEquipView *gainedLockBoxView;
@property (nonatomic, retain) IBOutlet BattleSummaryView *summaryView;
@property (nonatomic, retain) IBOutlet BattleAnalysisView *analysisView;
@property (nonatomic, retain) IBOutlet BattleTutorialView *tutorialView;

@property (nonatomic, retain) BattleResponseProto *brp;
@property (retain) NSArray *enemyEquips;

+ (CCScene *) scene;
+ (BattleLayer *) sharedBattleLayer;
+ (BOOL) isInitialized;
+ (void) purgeSingleton;
- (BOOL) beginBattleAgainst:(FullUserProto *)user;
- (BOOL) beginBattleAgainst:(FullUserProto *)user inCity:(int) cityId;
- (void) doAttackAnimation;
- (void) performGuaranteedWinWithUser:(FullUserProto *)fup inCity:(int)cityId;
- (void) performFirstLossTutorialWithUser:(FullUserProto *)fup inCity:(int)cityId;

- (IBAction)stolenEquipOkayClicked:(id)sender;
- (IBAction)closeClicked:(id)sender;
- (IBAction)attackAgainClicked:(id)sender;
- (IBAction)profileButtonClicked:(id)sender;
- (IBAction)viewChestInArmoryClicked:(id)sender;
- (IBAction)fbClicked:(id)sender;
- (IBAction)twitterclicked:(id)sender;

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
- (void) questLogPoppedUp;

- (void) closeSceneFromQuestLog;

- (void)receivedUserEquips:(RetrieveUserEquipForUserResponseProto *)proto;

- (IBAction)analysisClicked:(id)sender;

@end
