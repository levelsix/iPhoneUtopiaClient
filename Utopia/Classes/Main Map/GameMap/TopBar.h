//
//  TopBar.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/20/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "MaskedSprite.h"
#import "ProfilePicture.h"
#import "InGameNotification.h"
#import "ChatBottomView.h"
#import "DailyBonusMenuController.h"

#define ENST_BAR_TAG 165
#define COIN_BAR_TAG 166

#define BUTTON_OPACITY 70

#define LAST_GOLD_SALE_POPUP_TIME_KEY @"Last Gold Sale Popup Time"
#define LAST_LOCK_BOX_POPUP_TIME_KEY @"Lock Box Popup Time"
#define LAST_BOSS_EVENT_POPUP_TIME_KEY @"Boss Event Popup Time"
#define LAST_TOURNAMENT_POPUP_TIME_KEY @"Tournament Popup Time"
#define LAST_DAILY_BONUS_TIME_KEY @"Last Daily Bonus Time"

typedef enum {
  kNotShowing = 1,
  kEnergy,
  kStamina
} ToolTipState;

@interface ToolTip : CCSprite

@end

@interface TopBar : CCLayer <CCTargetedTouchDelegate> {
  CCSprite *_enstBgd;
  MaskedBar *_energyBar;
  MaskedBar *_staminaBar;
  CCSprite *_curEnergyBar;
  CCSprite *_curStaminaBar;
  
  CCSprite *_coinBar;
  CCLabelTTF *_silverLabel;
  CCLabelTTF *_goldLabel;
  CCSprite *_goldButton;
  
  ToolTipState _bigToolTipState;
  ToolTipState _littleToolTipState;
  NSDate *_toolTipTimerDate;
  
  CCSprite *_bigToolTip;
  CCLabelTTF *_bigCurValLabel;
  CCLabelTTF *_bigTimerLabel;
  CCLabelTTF *_bigGoldCostLabel;
  CCLabelTTF *_bigGoldCostLabelShadow;
  
  CCSprite *_littleToolTip;
  CCLabelTTF *_littleCurValLabel;
  
  ProfilePicture *_profilePic;
  
  CCMenuItemSprite *_questButton;
  CCMenuItemSprite *_attackButton;
  CCMenuItemSprite *_lockBoxButton;
  CCMenuItemSprite *_bossEventButton;
  CCMenuItemSprite *_tournamentButton;
  CCMenuItemSprite *_bazaarButton;
  CCMenuItemSprite *_homeButton;
  CCMenuItemSprite *_towerButton;
  CCMenuItemSprite *_mapButton;
  CCMenu *_bottomButtons;
  
  CCSprite *_questNewArrow;
  CCSprite *_questProgArrow;
  CCSprite *_questNewBadge;
  CCLabelTTF *_questNewLabel;
  int _questNewBadgeNum;
  
  CCSprite *_lockBoxBadge;
  
  CCSprite *_goldSaleBanner;
  
  // For faster comparisons of touch
  CGRect _enstBarRect;
  CGRect _coinBarRect;
  
  BOOL _trackingEnstBar;
  BOOL _trackingCoinBar;
  
  NSTimer *_energyTimer;
  NSTimer *_staminaTimer;
  
  int _curGold;
  int _curSilver;
  int _curEnergy;
  int _curStamina;
  int _curExp;
  
  NSMutableArray *_notificationsToDisplay;
  
  CCSprite *_arrow;
  BOOL _isForBattleLossTutorial;
}

@property (nonatomic, retain) IBOutlet InGameNotification *inGameNotification;

@property (nonatomic, retain) IBOutlet ChatBottomView *chatBottomView;

@property (nonatomic, retain) ProfilePicture *profilePic;

@property (nonatomic, retain) NSTimer *energyTimer;
@property (nonatomic, retain) NSTimer *staminaTimer;

@property (nonatomic, assign) BOOL isStarted;

// If it is first day bonus
@property (nonatomic, retain) StartupResponseProto_DailyBonusInfo *dbi;

- (void) setUpEnergyTimer;
- (void) setUpStaminaTimer;
- (void) update;
- (void) setEnergyBarPercentage:(float)perc;
- (void) setStaminaBarPercentage:(float)perc;
- (void) start;

- (void) lowerAllOpacities;
- (void) resetAllOpacities;
- (void) goToBazaarForFirstLossTutorial;
- (void) endBazaarFirstLossTutorial;

- (void) addNotificationToDisplayQueue:(UserNotification *)un;

- (void) questButtonClicked;
- (void) mapClicked;
- (void) homeClicked;

- (void) fadeInBigToolTip:(BOOL)isEnergy;
- (void) fadeInLittleToolTip:(BOOL)isEnergy;
- (void) fadeOutToolTip:(BOOL)big;

- (void) loadHomeConfiguration;
- (void) loadBazaarConfiguration;
- (void) loadNormalConfiguration;

- (void) invalidateTimers;

- (void) displayNewQuestArrow;
- (void) displayProgressQuestArrow;
- (void) stopProgressArrow;
- (void) stopQuestArrow;
- (void) setQuestBadgeAnimated:(BOOL)animated;

- (void) displayGoldSaleBadge;

- (void) fadeInMenuOverChatView:(UIView *)view;
- (void) fadeOutMenuOverChatView:(UIView *)view;

- (void) shouldDisplayLockBoxButton:(BOOL)button andBadge:(BOOL)badge;
- (void) shouldDisplayBossEventButton:(BOOL)button;
- (void) shouldDisplayTournamentButton:(BOOL)button;
- (void) shouldDisplayTowerButton:(BOOL)button;

+ (TopBar *) sharedTopBar;
+ (void) purgeSingleton;
+ (BOOL) isInitialized;

@end
