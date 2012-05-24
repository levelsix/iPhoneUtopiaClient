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
  kEquipButton = 1,
  kSkillsButton = 1 << 1,
  kWallButton = 1 << 2
} ProfileBarButton;

typedef enum {
  kEquipState = 1,
  kSkillsState,
  kWallState
} ProfileState;

typedef enum {
  kEquipScopeAll = 1,
  kEquipScopeWeapons,
  kEquipScopeArmor,
  kEquipScopeAmulets
} EquipScope;

@class MarketplacePostView;

@interface EquipView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *equipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *maskedEquipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *border;
@property (nonatomic, retain) IBOutlet UIImageView *bgd;
@property (nonatomic, retain) IBOutlet UILabel *rarityLabel;
@property (nonatomic, retain) IBOutlet UILabel *quantityLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;

@property (nonatomic, retain) UIView *darkOverlay;

@property (nonatomic, retain) FullUserEquipProto *equip;

- (void) updateForEquip:(FullUserEquipProto *)fuep;

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
  
  UIImageView *_curEquipSelectedImage;
  UIImageView *_curSkillsSelectedImage;
  UIImageView *_curWallSelectedImage;
  
  BOOL _trackingEquip;
  BOOL _trackingSkills;
  BOOL _trackingWall;
  
  int _clickedButtons;
}

@property (nonatomic, assign) ProfileBarState state;

@property (nonatomic, retain) IBOutlet UILabel *equipLabel;
@property (nonatomic, retain) IBOutlet UILabel *skillsLabel;
@property (nonatomic, retain) IBOutlet UILabel *wallLabel;

@property (nonatomic, retain) IBOutlet UIImageView *equipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *skillsIcon;
@property (nonatomic, retain) IBOutlet UIImageView *wallIcon;

@property (nonatomic, retain) IBOutlet UIImageView *equipSelectedSmallImage;
@property (nonatomic, retain) IBOutlet UIImageView *skillsSelectedSmallImage;
@property (nonatomic, retain) IBOutlet UIImageView *wallSelectedSmallImage;

@property (nonatomic, retain) IBOutlet UIImageView *equipSelectedLargeImage;
@property (nonatomic, retain) IBOutlet UIImageView *wallSelectedLargeImage;

@property (nonatomic, retain) IBOutlet UIImageView *glowIcon;

@end

@interface CurrentEquipView : ServerImageView {
  BOOL _selected;
}

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UILabel *unknownLabel;
@property (nonatomic, retain) IBOutlet UIImageView *equipIcon;
@property (nonatomic, retain) IBOutlet UIView *chooseEquipButton;
@property (nonatomic, retain) IBOutlet UIView *border;

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

@end

@interface ProfileViewController : UIViewController {
  ProfileState _state;
  EquipScope _curScope;
  EquipView *_weaponEquipView;
  EquipView *_armorEquipView;
  EquipView *_amuletEquipView;
  FullUserProto *_fup;
  
  NSArray *_queuedEquips;
  BOOL _waitingForEquips;
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
@property (nonatomic, retain) IBOutlet UILabel *hpStatLabel;
@property (nonatomic, retain) IBOutlet UILabel *staminaCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *hpCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *skillPointsLabel;

@property (nonatomic, retain) IBOutlet UIButton *attackStatButton;
@property (nonatomic, retain) IBOutlet UIButton *defenseStatButton;
@property (nonatomic, retain) IBOutlet UIButton *energyStatButton;
@property (nonatomic, retain) IBOutlet UIButton *staminaStatButton;
@property (nonatomic, retain) IBOutlet UIButton *hpStatButton;

@property (nonatomic, retain) IBOutlet ProfileBar *profileBar;

@property (nonatomic, retain) IBOutlet UIView *equipTabView;
@property (nonatomic, retain) IBOutlet UIView *skillTabView;
@property (nonatomic, retain) IBOutlet WallTabView *wallTabView;

@property (nonatomic, assign) ProfileState state;
@property (nonatomic, assign) EquipScope curScope;

@property (nonatomic, retain) IBOutlet UIScrollView *equipsScrollView;
@property (nonatomic, retain) NSMutableArray *equipViews;
@property (nonatomic, retain) IBOutlet EquipView *nibEquipView;
@property (nonatomic, retain) IBOutlet UIView *unequippableView;
@property (nonatomic, retain) IBOutlet UILabel *unequippableLabel;

@property (nonatomic, retain) IBOutlet UILabel *enemyAttackLabel;
@property (nonatomic, retain) IBOutlet UIView *enemyMiddleView;

@property (nonatomic, retain) IBOutlet UIView *enemyLeftView;
@property (nonatomic, retain) IBOutlet UIView *selfLeftView;
@property (nonatomic, retain) IBOutlet UIView *friendLeftView;

@property (nonatomic, retain) IBOutlet UIButton *visitButton;
@property (nonatomic, retain) IBOutlet UIButton *smallAttackButton;
@property (nonatomic, retain) IBOutlet UIButton *bigAttackButton;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet ProfileEquipPopup *equipPopup;

@property (nonatomic, retain) UIImageView *equippingView;


// UserId will usually be equal to fup.userId unless we are loading current
// player's profile or we are waiting for the fup from server
@property (nonatomic, retain) FullUserProto *fup;
@property (nonatomic, assign) int userId;

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

- (void) receivedEquips:(RetrieveUserEquipForUserResponseProto *)proto;
- (void) receivedWallPosts:(RetrievePlayerWallPostsResponseProto *)proto;
- (void) receivedFullUserProtos:(NSArray *)protos;

- (IBAction)skillButtonClicked:(id)sender;
- (IBAction)closeClicked:(id)sender;

+ (ProfileViewController *) sharedProfileViewController;
+ (void) purgeSingleton;
+ (void) displayView;
+ (void) removeView;

@end
