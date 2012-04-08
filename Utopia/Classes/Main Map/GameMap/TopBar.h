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
}

@property (nonatomic, retain) ProfilePicture *profilePic;

- (void) setUpEnergyTimer;
- (void) setUpStaminaTimer;
- (void) update;
- (void) setEnergyBarPercentage:(float)perc;
- (void) setStaminaBarPercentage:(float)perc;
- (void) start;

- (void) invalidateTimers;

+ (TopBar *) sharedTopBar;
+ (void) purgeSingleton;

@end
