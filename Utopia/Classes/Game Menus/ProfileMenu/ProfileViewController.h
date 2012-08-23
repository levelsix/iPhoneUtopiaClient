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

typedef enum {
  kMyProfile = 1,
  kOtherPlayerProfile
} ProfileBarState;

typedef enum {
  kProfileButton = 1,
  kEquipButton = 1 << 1,
  kSkillsButton = 1 << 2,
  kSpecialButton = 1 << 3
} ProfileBarButton;

typedef enum {
  kProfileState = 1,
  kEquipState,
  kSkillsState,
  kSpecialState
} ProfileState;

typedef enum {
  kEquipScopeWeapons = 1,
  kEquipScopeArmor,
  kEquipScopeAmulets
} EquipScope;

@class MarketplacePostView;

@interface EquipView : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *equipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *bgd;
@property (nonatomic, retain) IBOutlet UIImageView *border;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *levelIcon;

@property (nonatomic, retain) UIView *darkOverlay;

@property (nonatomic, retain) UserEquip *equip;

- (void) updateForEquip:(UserEquip *)ue;

@end

@interface MarketplacePostView : UIView <UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet UIImageView *armoryPriceIcon;
@property (nonatomic, retain) IBOutlet UILabel *armoryPriceLabel;
@property (nonatomic, retain) IBOutlet UIImageView *postedPriceIcon;
@property (nonatomic, retain) IBOutlet NiceFontTextField *postedPriceTextField;

@end

@interface ProfileBar : UIView {
  ProfileBarState _state;
  
  BOOL _trackingProfile;
  BOOL _trackingEquip;
  BOOL _trackingSkills;
  BOOL _trackingSpecial;
  
  int _clickedButtons;
  
  int _profileBadgeNum;
}

@property (nonatomic, assign) ProfileBarState state;

@property (nonatomic, retain) IBOutlet UILabel *profileLabel;
@property (nonatomic, retain) IBOutlet UILabel *equipLabel;
@property (nonatomic, retain) IBOutlet UILabel *skillsLabel;
@property (nonatomic, retain) IBOutlet UILabel *specialLabel;

@property (nonatomic, retain) IBOutlet UIImageView *profileIcon;
@property (nonatomic, retain) IBOutlet UIImageView *equipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *skillsIcon;
@property (nonatomic, retain) IBOutlet UIImageView *specialIcon;

@property (nonatomic, retain) IBOutlet UIImageView *profileButton;
@property (nonatomic, retain) IBOutlet UIImageView *equipButton;
@property (nonatomic, retain) IBOutlet UIImageView *skillsButton;
@property (nonatomic, retain) IBOutlet UIImageView *specialButton;

@property (nonatomic, retain) IBOutlet UIView *profileBadgeView;
@property (nonatomic, retain) IBOutlet UILabel *profileBadgeLabel;

- (void) incrementProfileBadge;
- (void) clearProfileBadge;

@end

@interface CurrentEquipView : ServerImageView {
  BOOL _selected;
}

@property (nonatomic, retain) IBOutlet UIImageView *equipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *selectedView;
@property (nonatomic, retain) IBOutlet UIView *knownView;
@property (nonatomic, retain) IBOutlet UIView *unknownView;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *levelIcon;
@property (nonatomic, retain) IBOutlet UILabel *typeLabel;
@property (nonatomic, assign) BOOL selected;

- (void) unknownEquip;
- (void) knownEquip;

@end

@interface ProfileEquipPopup : UIView

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *classLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;
@property (nonatomic, retain) IBOutlet UILabel *typeLabel;
@property (nonatomic, retain) IBOutlet UILabel *levelLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet EquipButton *equipIcon;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *levelIcon;
@property (nonatomic, retain) IBOutlet UIView *wrongClassView;
@property (nonatomic, retain) IBOutlet UIView *tooLowLevelView;
@property (nonatomic, retain) IBOutlet UIButton *equipButton;
@property (nonatomic, retain) IBOutlet UILabel *equipLabel;
@property (nonatomic, retain) IBOutlet UIButton *sellButton;
@property (nonatomic, retain) IBOutlet UILabel *sellLabel;

@property (nonatomic, retain) IBOutlet UIView *soldView;
@property (nonatomic, retain) IBOutlet UILabel *soldItemLabel;
@property (nonatomic, retain) IBOutlet UILabel *soldSilverLabel;

@property (nonatomic, retain) IBOutlet MarketplacePostView *mktPostView;

@property (nonatomic, retain) UserEquip *userEquip;

- (void) updateForUserEquip:(UserEquip *)ue;

@end

@interface WallPostCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIButton *playerIcon;
@property (nonatomic, retain) IBOutlet UIButton *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *postLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

@property (nonatomic, retain) CAGradientLayer *gradientLayer;

@end

@interface WallTabView : UIView <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) IBOutlet NiceFontTextField *wallTextField;
@property (nonatomic, retain) IBOutlet UITableView *wallTableView;
@property (nonatomic, retain) IBOutlet WallPostCell *postCell;

@property (nonatomic, retain) NSMutableArray *wallPosts;

- (void) endEditing;
- (void) displayNewWallPost;

@end

@interface EquipTableViewDelegate : NSObject <UITableViewDelegate, UITableViewDataSource> {
  NSArray *_equips;
  NSMutableArray *_equipsForScope;
  int _weaponId;
  int _armorId;
  int _amuletId;
}

@property (nonatomic, retain) IBOutlet EquipView *nibEquipView;

@end

@interface ProfileViewController : UIViewController <UITextFieldDelegate> {
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
@property (nonatomic, retain) IBOutlet UILabel *typeLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;
@property (nonatomic, retain) IBOutlet UILabel *codeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *profilePicture;

@property (nonatomic, retain) IBOutlet CurrentEquipView *curWeaponView;
@property (nonatomic, retain) IBOutlet CurrentEquipView *curArmorView;
@property (nonatomic, retain) IBOutlet CurrentEquipView *curAmuletView;

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
@property (nonatomic, retain) IBOutlet UIView *equipTabView;
@property (nonatomic, retain) IBOutlet UIView *skillTabView;
@property (nonatomic, retain) IBOutlet UIView *specialTabView;
@property (nonatomic, retain) IBOutlet WallTabView *wallTabView;

@property (nonatomic, assign) ProfileState state;
@property (nonatomic, assign) EquipScope curScope;

@property (nonatomic, retain) IBOutlet UITableView *equipsTableView;
@property (nonatomic, retain) EquipTableViewDelegate *equipsTableDelegate;
@property (nonatomic, retain) IBOutlet UILabel *equipHeaderLabel;

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
- (void) currentEquipViewSelected:(CurrentEquipView *)cev;
- (void) loadSkills;
- (void) doEquip:(UserEquip *)equip;
- (void) doEquippingAnimation:(EquipView *)ev forType:(FullEquipProto_EquipType)type;
- (void) displayMyCurrentStats;

- (void) receivedEquips:(RetrieveUserEquipForUserResponseProto *)proto;
- (void) receivedWallPosts:(RetrievePlayerWallPostsResponseProto *)proto;
- (void) receivedFullUserProtos:(NSArray *)protos;

- (IBAction)skillButtonClicked:(id)sender;
- (IBAction)closeClicked:(id)sender;
- (IBAction)goToArmoryClicked:(id)sender;

+ (ProfileViewController *) sharedProfileViewController;
+ (void) purgeSingleton;
+ (void) displayView;
+ (void) removeView;

@end
