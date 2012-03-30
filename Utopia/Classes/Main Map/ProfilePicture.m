//
//  ProfilePicture.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/4/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ProfilePicture.h"
#import "GameState.h"
#import "Globals.h"
#import "MaskedSprite.h"
#import "QuestLogController.h"
#import "ArmoryViewController.h"
#import "MarketplaceViewController.h"
#import "GoldShoppeViewController.h"
#import "VaultMenuController.h"
#import "CarpenterMenuController.h"
#import "MapViewController.h"
#import "ProfileViewController.h"
#import "ActivityFeedController.h"

#define DELAY_BETWEEN_BUTTONS 0.03
#define TOTAL_ROTATION_ANGLE 1080
#define START_ANGLE -14.f
#define TOTAL_ANGLE -87.f
#define BUTTON_DISTANCE 60.f

#define PULSATE_DURATION 1.587f

@implementation ExperienceCircle

@synthesize expPercentage = _expPercentage;
@synthesize level = _level;

+ (id) circle {
  return [[[self alloc] initCircle] autorelease];
}

- (id) initCircle {
  if ((self = [super initWithFile:@"expring.png"])) {
    _expBar = [CCProgressTimer progressWithFile:@"expringover.png"];
    _expBar.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    _expBar.type = kCCProgressTimerTypeRadialCW;
    _expBar.percentage = 1;
    [self addChild:_expBar];
    
    _levelCircle = [CCSprite spriteWithFile:@"levelnumberbg.png"];
    _levelCircle.position = ccp(21.5, 25.5);
    [self addChild:_levelCircle];
    
    _levelLabel = [CCLabelTTF labelWithString:@"" fontName:[Globals font] fontSize:12];
    _levelLabel.position = ccp(_levelCircle.contentSize.width/2, _levelCircle.contentSize.height/2);
    [_levelCircle addChild:_levelLabel];
    [Globals adjustFontSizeForCCLabelTTF:_levelLabel size:12];
    
    _notificationAlert = [CCSprite spriteWithFile:@"notificationoverlevel.png"];
    [_levelCircle addChild:_notificationAlert];
    _notificationAlert.position = ccp(_levelCircle.contentSize.width/2, _levelCircle.contentSize.height/2);
    _notificationAlert.visible = NO;
    
    self.level = 1;
    self.expPercentage = 0;
  }
  
  return self;
}

- (void) flashNotification {
  if (!_flashing) {
    _flashing = YES;
    _notificationAlert.visible = YES;
    _notificationAlert.opacity = 255;
    CCAction *action = [CCRepeatForever actionWithAction:[CCSequence actions:
                                                          [CCFadeTo actionWithDuration:PULSATE_DURATION opacity:180],
                                                          [CCFadeTo actionWithDuration:PULSATE_DURATION opacity:255], nil]];
    [_notificationAlert runAction:action];
  }
}

- (void) stopNotification {
  [_notificationAlert stopAllActions];
  [_notificationAlert runAction:[CCSequence actions:[CCFadeTo actionWithDuration:PULSATE_DURATION opacity:0], 
                                 [CCCallFunc actionWithTarget:self selector:@selector(setNotificationInvisible)], nil]];
  _flashing = NO;
}

- (void) setNotificationInvisible {
  _notificationAlert.visible = NO;
}

- (void) setRotation:(float)rotation {
  _levelCircle.rotation = -rotation;
  _expBar.rotation = -rotation;
  [super setRotation:rotation];
}

- (void) setExpPercentage:(float)perc {
  if (perc != _expPercentage) {
    perc = clampf(perc, 0.f, 1.f);
    _expBar.percentage = perc*100;
    _expPercentage = perc;
  }
}

- (void) setLevel:(int)level {
  [_levelLabel setString:[NSString stringWithFormat:@"%d", level]];
  _level = level;
}

@end

@implementation ProfileButton

@synthesize badgeNum;

- (id) initFromNormalSprite:(CCNode<CCRGBAProtocol> *)normalSprite selectedSprite:(CCNode<CCRGBAProtocol> *)selectedSprite disabledSprite:(CCNode<CCRGBAProtocol> *)disabledSprite target:(id)target selector:(SEL)selector {
  if ((self = [super initFromNormalSprite:normalSprite selectedSprite:selectedSprite disabledSprite:disabledSprite target:target selector:selector])) {
    _badge = [CCSprite spriteWithFile:@"notificationnumber.png"];
    _badge.anchorPoint = ccp(1,1);
    _badge.position = ccp(self.contentSize.width+5, self.contentSize.height+1);
    [self addChild:_badge];
    
    _badgeLabel = [CCLabelTTF labelWithString:@"" fontName:[Globals font] fontSize:12];
    _badgeLabel.position = ccp(_badge.contentSize.width/2, _badge.contentSize.height/2-2);
    [_badge addChild:_badgeLabel];
    
    badgeNum = 0;
  }
  return self;
}

- (void) setBadgeNum:(int)b {
  if (badgeNum != b) {
    badgeNum = b;
    _badgeLabel.string = [NSString stringWithFormat:@"%d", badgeNum];
  }
}

- (void) hideBadge {
  _badge.visible = NO;
}

- (void) fadeInBadge {
  _badge.visible = YES;
  [_badge runAction:[CCFadeIn actionWithDuration:0.2f]];
  [_badgeLabel runAction:[CCFadeIn actionWithDuration:0.2f]];
}

- (void) fadeOutBadge {
  if (self.visible) {
    [_badge runAction:[CCSequence actions:
                       [CCFadeOut actionWithDuration:0.2f],
                       [CCCallFunc actionWithTarget:self selector:@selector(hideBadge)], nil]];
    [_badgeLabel runAction:[CCFadeOut actionWithDuration:0.2f]];
  }
}

@end

@implementation ProfilePicture 

+ (id) profileWithType: (UserType) type {
  return [[[self alloc] initWithType: type] autorelease];
}

- (id) initWithType:(UserType)type {
  if ((self = [super initWithFile:[Globals headshotImageNameForUser:type]])) {
    _inAction = NO;
    _menuOut = NO;
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    
    _expCircle = [ExperienceCircle circle];
    [self addChild:_expCircle z:2];
    _expCircle.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    
    _menuItems = [[[NSMutableArray alloc] init] retain];
    
    ProfileButton *button1 = [ProfileButton itemFromNormalImage:@"pathnotifications.png" selectedImage:nil target:self selector:@selector(button1Clicked:)];
    button1.visible = NO;
    [_menuItems addObject:button1];
    
    ProfileButton *button2 = [ProfileButton itemFromNormalImage:@"pathquests.png" selectedImage:nil target:self selector:@selector(button2Clicked:)];
    button2.visible = NO;
    [_menuItems addObject:button2];
    
    ProfileButton *button3 = [ProfileButton itemFromNormalImage:@"pathprofile.png" selectedImage:nil target:self selector:@selector(button3Clicked:)];
    button3.visible = NO;
    [_menuItems addObject:button3];
    
    ProfileButton *button4 = [ProfileButton itemFromNormalImage:@"pathsettings.png" selectedImage:nil target:self selector:@selector(button4Clicked:)];
    button4.visible = NO;
    [_menuItems addObject:button4];
    
    CCMenu *menu = [CCMenu menuWithItems:button1, button2, button3, button4, nil];
    menu.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
    
    [self addChild:menu z:-1];
  }
  return self;
}

- (void) setExpPercentage:(float)perc {
  [_expCircle setExpPercentage:perc];
}

- (void) setLevel:(int)level {
  [_expCircle setLevel:level];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint pt = [_expCircle convertTouchToNodeSpace:touch];
  if (!CGRectContainsPoint(CGRectMake(0, 0, _expCircle.contentSize.width, _expCircle.contentSize.height), pt)) {
    if (!_inAction && _menuOut) {
      [self popInButtons];
    }
    return NO;
  }
  
  return YES;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint pt = [_expCircle convertTouchToNodeSpace:touch];
  
  if (_inAction)
    return;
  
  if (!CGRectContainsPoint(CGRectMake(0, 0, _expCircle.contentSize.width, _expCircle.contentSize.height), pt)) {
    if (_menuOut) {
      [self popInButtons];
    }
    return;
  }
  
  if (_menuOut) {
    [self popInButtons];
  } else {
    [self popOutButtons];
  }
}

- (void) popOutButtons {
  _inAction = YES;
  _menuOut = YES;
  
  [_expCircle runAction: [CCRotateBy actionWithDuration:0.2 angle:90]];
  
  // Move out right to bottom 
  float step = TOTAL_ANGLE/([_menuItems count]-1);
  float dist = self.contentSize.height/2 + BUTTON_DISTANCE;
  
  // Save the duration of the last action
  float dur = 0;
  
  // Use this so that we can have buttons relative to center point
  for (int i = 0; i < [_menuItems count]; i++) {
    float degree = CC_DEGREES_TO_RADIANS(START_ANGLE + i * step);
    ProfileButton *button = [_menuItems objectAtIndex:i];
    [button stopAllActions];
    [button hideBadge];
    CGPoint pt = ccp(dist*cosf(degree), dist*sinf(degree));
    
    button.scale = 1;
    button.position = ccp(0,0);
    button.opacity = 255;
    
    CCFiniteTimeAction *action = [CCCallFunc actionWithTarget:button selector:@selector(fadeInBadge)];
    
    CCFiniteTimeAction *bounceAction = [CCSequence actions:[CCDelayTime actionWithDuration:i*DELAY_BETWEEN_BUTTONS], [CCEaseBackOut actionWithAction:[CCMoveBy actionWithDuration:0.2 position:pt]], button.badgeNum > 0 ? action : nil, nil];
    CCFiniteTimeAction *fullAction = [CCSpawn actions:bounceAction, 
                                      [CCRotateTo actionWithDuration:[bounceAction duration]/1.5 angle:TOTAL_ROTATION_ANGLE],
                                      nil];
    [button runAction:fullAction];
    
    dur = [fullAction duration];
    
    button.visible = YES;
  }
  
  [self runAction:
   [CCSequence actions:
    [CCDelayTime actionWithDuration:dur], 
    [CCCallFunc actionWithTarget:self selector:@selector(enableButton)], nil]];
  
  // Stop the notification alert
  [_expCircle stopNotification];
}

- (void) popInButtons {
  _inAction = YES;
  _menuOut = NO;
  
  float dur = 0; 
  
  [_expCircle runAction: [CCRotateBy actionWithDuration:0.2 angle:-90]];
  
  // Use this so that we can have buttons relative to center point
  for (int i = 0; i < [_menuItems count]; i++) {
    ProfileButton *button = [_menuItems objectAtIndex:[_menuItems count]-i-1];
    [button stopAllActions];
    [button hideBadge];
    
    CCFiniteTimeAction *bounceAction = [CCSequence actions:[CCDelayTime actionWithDuration:i*DELAY_BETWEEN_BUTTONS], [CCEaseBackIn actionWithAction:[CCMoveTo actionWithDuration:0.2 position:ccp(0,0)]], nil];
    
    CCFiniteTimeAction *fullAction = [CCSequence actions:
                                      [CCSpawn actions:bounceAction, 
                                       [CCRotateBy actionWithDuration:[bounceAction duration] angle:-TOTAL_ROTATION_ANGLE],
                                       nil],
                                      [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)], nil];
    
    [button runAction:fullAction];
    
    dur = [fullAction duration];
  }
  
  [self runAction: [CCSequence actions:
                    [CCDelayTime actionWithDuration:dur], 
                    [CCCallFunc actionWithTarget:self selector:@selector(enableButton)], nil]];
}

- (void) buttonClicked:(ProfileButton *)clickedButton selector:(SEL)sel {
  if (_inAction || !_menuOut) {
    return;
  }
  
  clickedButton.badgeNum = 0;
  
  [_expCircle runAction: [CCRotateBy actionWithDuration:0.2 angle:-90]];
  
  _inAction = YES;
  _menuOut = NO;
  
  [clickedButton runAction:[CCSequence actions:
                            [CCSpawn actions:
                             [CCFadeTo actionWithDuration:0.3 opacity:0],
                             [CCScaleTo actionWithDuration:0.3 scale:2]
                             , nil],
                            [CCCallFunc actionWithTarget:self selector:@selector(enableButton)],
                            [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                            [CCCallFunc actionWithTarget:self selector:sel],
                            nil]];
  
  for (ProfileButton *button in _menuItems) {
    [button hideBadge];
    if (button != clickedButton) {
      [button runAction:[CCSequence actions:
                         [CCSpawn actions:
                          [CCFadeTo actionWithDuration:0.3 opacity:0],
                          [CCScaleTo actionWithDuration:0.3 scale:0.4]
                          , nil],
                         [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                         nil]];
    }
  }
}

- (void) button1Clicked:(id)sender {
  [self buttonClicked:sender selector:@selector(openNotifications)];
}

- (void) button2Clicked:(id)sender {
  [self buttonClicked:sender selector:@selector(openQuests)];
}

- (void) button3Clicked:(id)sender {
  [self buttonClicked:sender selector:@selector(openProfile)];
}

- (void) button4Clicked:(id)sender {
  [self buttonClicked:sender selector:@selector(openSettings)];
}

- (void) openNotifications {
  [ActivityFeedController displayView];
}

- (void) openQuests {
  [QuestLogController displayView];
}

- (void) openProfile {
  [[ProfileViewController sharedProfileViewController] loadMyProfile];
  [ProfileViewController displayView];
}

- (void) openSettings {
  [QuestLogController displayView];
}

- (void) enableButton {
  _inAction = NO;
}

- (void) setInvisible: (CCMenuItem *) sender {
  sender.visible = NO;
}

- (void) incrementNotificationBadge {
  ProfileButton *pb = [_menuItems objectAtIndex:0];
  pb.badgeNum++;
  [_expCircle flashNotification];
}

- (void) incrementProfileBadge {
  ProfileButton *pb = [_menuItems objectAtIndex:2];
  pb.badgeNum++;
  [_expCircle flashNotification];
}

- (void) dealloc {
  [_menuItems release];
  [super dealloc];
}

@end
