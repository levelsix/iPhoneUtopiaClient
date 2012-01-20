//
//  ProfilePicture.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/4/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "Info.pb.h"

@class MaskedHealth;

@interface ExperienceCircle : CCSprite {
@private
  CCProgressTimer *_expBar;
  CCLabelTTF *_levelLabel;
  CCSprite *_levelCircle;
  float _expPercentage;
  int _level;
}

@property (nonatomic, assign) float expPercentage;
@property (nonatomic, assign) int level;

+ (id) circle;
- (id) initCircle;
- (void) setLevel:(int)level;
- (void) setExpPercentage:(float)perc;

@end

@interface ProfilePicture : CCSprite <CCTargetedTouchDelegate> {
  BOOL _inAction;
  BOOL _menuOut;
  NSMutableArray *_menuItems;
  ExperienceCircle *_expCircle;
  MaskedHealth *_healthBar;
}

+ (id) profileWithType: (UserType) type;
- (id) initWithType: (UserType) type;
- (void) popOutButtons;
- (void) popInButtons;
- (void) buttonClicked: (CCSprite *) clickedButton;

@end
