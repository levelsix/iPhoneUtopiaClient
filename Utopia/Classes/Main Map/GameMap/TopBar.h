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

@interface TopBar : CCLayer <CCTargetedTouchDelegate> {
  CCSprite *_enstBgd;
  MaskedBar *_energyBar;
  MaskedBar *_staminaBar;
  
  CCSprite *_coinBar;
  CCLabelTTF *_silverLabel;
  CCLabelTTF *_goldLabel;
  CCSprite *_goldButton;
  
  ProfilePicture *_profilePic;
  
  // For faster comparisons of touch
  CGRect _enstBarRect;
  CGRect _coinBarRect;
  
  BOOL _trackingEnstBar;
  BOOL _trackingCoinBar;
}

@end
