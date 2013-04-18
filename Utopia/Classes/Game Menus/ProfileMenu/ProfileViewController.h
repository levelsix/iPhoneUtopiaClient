//
//  ProfileViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/26/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "Protocols.pb.h"
#import "NibUtils.h"
#import "UserData.h"
#import "ProfileMenus.h"

@class MarketplacePostView;

@interface ProfileViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, EquipViewDelegate> {
  ProfileState _state;
  EquipScope _curScope;
  FullUserProto *_fup;
  
  NSArray *_queuedEquips;
  BOOL _waitingForEquips;
  
  BOOL _displayKiipOnClose;
}

@property (nonatomic, retain) IBOutlet UILabel *userNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *winsLabel;
@property (nonatomic, retain) IBOutlet UILabel *lossesLabel;
@property (nonatomic, retain) IBOutlet UILabel *fleesLabel;
@property (nonatomic, retain) IBOutlet UILabel *levelLabel;
@property (nonatomic, retain) IBOutlet UIButton *clanButton;
@property (nonatomic, retain) IBOutlet UILabel *typeLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;
@property (nonatomic, retain) IBOutlet UILabel *codeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *profilePicture;

@property (nonatomic, retain) IBOutlet UIView *clanView;

@property (nonatomic, retain) IBOutlet UILabel *attackStatLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseStatLabel;
@property (nonatomic, retain) IBOutlet UILabel *energyStatLabel;
@property (nonatomic, retain) IBOutlet UILabel *staminaStatLabel;
@property (nonatomic, retain) IBOutlet UILabel *staminaCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *skillPointsLabel;

@property (nonatomic, retain) IBOutlet UIButton *attackStatButton;
@property (nonatomic, retain) IBOutlet UIButton *defenseStatButton;
@property (nonatomic, retain) IBOutlet UIButton *energyStatButton;
@property (nonatomic, retain) IBOutlet UIButton *staminaStatButton;

@property (nonatomic, retain) IBOutlet ProfileBar *profileBar;

@property (nonatomic, retain) IBOutlet UIView *profileTabView;
@property (nonatomic, retain) IBOutlet UIView *skillTabView;
@property (nonatomic, retain) IBOutlet UIView *specialTabView;
@property (nonatomic, retain) IBOutlet WallTabView *wallTabView;
@property (nonatomic, retain) IBOutlet EquipTabView *equipTabView;

@property (nonatomic, assign) ProfileState state;

@property (nonatomic, retain) IBOutlet UILabel *enemyAttackLabel;
@property (nonatomic, retain) IBOutlet UIView *enemyMiddleView;

@property (nonatomic, retain) IBOutlet UIView *noEquipMiddleView;
@property (nonatomic, retain) IBOutlet UILabel *noEquipLabel;
@property (nonatomic, retain) IBOutlet UIView *noEquipButtonView;

@property (nonatomic, retain) IBOutlet UIView *enemyLeftView;
@property (nonatomic, retain) IBOutlet UIView *selfLeftView;
@property (nonatomic, retain) IBOutlet UIView *friendLeftView;

@property (nonatomic, retain) IBOutlet UIButton *visitButton;
@property (nonatomic, retain) IBOutlet UIButton *smallAttackButton;
@property (nonatomic, retain) IBOutlet UIButton *bigAttackButton;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) IBOutlet LoadingView *loadingView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet ProfileEquipPopup *equipPopup;
@property (nonatomic, retain) IBOutlet ProfileEquipBrowseView *equipBrowseView;

@property (nonatomic, retain) UIImageView *equippingView;

@property (nonatomic, retain) IBOutlet UITextField *nameChangeTextField;
@property (nonatomic, retain) IBOutlet UIView *nameChangeView;


// UserId will usually be equal to fup.userId unless we are loading current
// player's profile or we are waiting for the fup from server
@property (nonatomic, retain) FullUserProto *fup;
@property (nonatomic, assign) int userId;

- (void) refreshSkillPointsButtons;
- (void) loadMyProfileWithLevelUp;
- (void) loadMyProfile;
- (void) loadProfileForPlayer:(FullUserProto *)fup buttonsEnabled:(BOOL)enabled;
- (void) loadProfileForPlayer:(FullUserProto *)fup equips:(NSArray *)equips attack:(int)attack defense:(int)defense;
- (void) loadProfileForMinimumUser:(MinimumUserProto *)user withState:(ProfileState)pState;
- (void) updateEquips:(NSArray *)equips;
- (void) openSkillsMenu;
- (void) equipViewSelected:(EquipView *)ev;
- (void) loadSkills;
- (void) doEquip:(UserEquip *)equip;
- (void) displayMyCurrentStats;

- (void) receivedEquips:(RetrieveUserEquipForUserResponseProto *)proto;
- (void) receivedWallPosts:(RetrievePlayerWallPostsResponseProto *)proto;
- (void) receivedFullUserProtos:(NSArray *)protos;

- (IBAction)skillButtonClicked:(id)sender;
- (IBAction)closeClicked:(id)sender;
- (IBAction)goToArmoryClicked:(id)sender;
- (IBAction)resetSkillsClicked:(id)sender;

+ (ProfileViewController *) sharedProfileViewController;
+ (void) purgeSingleton;
+ (void) displayView;
+ (void) removeView;
+ (BOOL) isInitialized;

@end
