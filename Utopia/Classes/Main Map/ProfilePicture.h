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
  BOOL _flashing;
  
  CCSprite *_notificationAlert;
}

@property (nonatomic, assign) float expPercentage;
@property (nonatomic, assign) int level;

+ (id) circle;
- (id) initCircle;
- (void) setLevel:(int)level;

@end

@interface ProfileButton : CCMenuItemImage {
  CCSprite *_badge;
  CCLabelTTF *_badgeLabel;
}

@property (nonatomic, assign) int badgeNum;

@end

@interface ProfilePicture : CCSprite <CCTargetedTouchDelegate> {
  BOOL _inAction;
  BOOL _menuOut;
  NSMutableArray *_menuItems;
  ExperienceCircle *_expCircle;
}

+ (id) profileWithType: (UserType) type;
- (id) initWithType: (UserType) type;
- (void) popOutButtons;
- (void) popInButtons;
- (void) buttonClicked:(CCMenuItem *)clickedButton selector:(SEL)sel;
- (void) setExpPercentage:(float)perc;
- (void) setLevel:(int)level;
- (void) popOutButtons;
- (void) popInButtons;
- (void) buttonClicked:(CCMenuItem *)clickedButton selector:(SEL)sel;
- (void) button1Clicked:(id)sender;
- (void) button2Clicked:(id)sender;
- (void) button3Clicked:(id)sender;
- (void) button4Clicked:(id)sender;
- (void) incrementNotificationBadge;
- (void) incrementProfileBadge;

@end
