//
//  ProfileMenus.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/8/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "NibUtils.h"
#import "UserData.h"

typedef enum {
  kMyProfile = 1,
  kOtherPlayerProfile
} ProfileBarState;

typedef enum {
  kProfileButton1 = 1,
  kProfileButton2 = 1 << 1,
  kProfileButton3 = 1 << 2,
  kProfileButton4 = 1 << 3
} ProfileBarButton;

typedef enum {
  kProfileState = 1,
  kWallState,
  kSkillsState,
  kSpecialState
} ProfileState;

typedef enum {
  kEquipScopeWeapons = 1,
  kEquipScopeArmor,
  kEquipScopeAmulets
} EquipScope;

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
  BOOL _trackingWall;
  BOOL _trackingSkills;
  BOOL _trackingSpecial;
  
  int _clickedButtons;
  
  int _profileBadgeNum;
}

@property (nonatomic, assign) ProfileBarState state;

@property (nonatomic, retain) IBOutlet UILabel *profileLabel;
@property (nonatomic, retain) IBOutlet UILabel *wallLabel;
@property (nonatomic, retain) IBOutlet UILabel *skillsLabel;
@property (nonatomic, retain) IBOutlet UILabel *specialLabel;

@property (nonatomic, retain) IBOutlet UIImageView *profileIcon;
@property (nonatomic, retain) IBOutlet UIImageView *wallIcon;
@property (nonatomic, retain) IBOutlet UIImageView *skillsIcon;
@property (nonatomic, retain) IBOutlet UIImageView *specialIcon;

@property (nonatomic, retain) IBOutlet UIImageView *profileButton;
@property (nonatomic, retain) IBOutlet UIImageView *wallButton;
@property (nonatomic, retain) IBOutlet UIImageView *skillsButton;
@property (nonatomic, retain) IBOutlet UIImageView *specialButton;

@property (nonatomic, retain) IBOutlet UIView *profileBadgeView;
@property (nonatomic, retain) IBOutlet UILabel *profileBadgeLabel;

- (void) incrementProfileBadge;
- (void) clearProfileBadge;
- (void) setState:(ProfileBarState)state;
- (void) setProfileState:(ProfileState)s;


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
@property (nonatomic, retain) IBOutlet EnhancementLevelIcon *enhanceIcon;
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
- (IBAction)closeClicked:(id)sender;

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

@interface EquipView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *equipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *bgd;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;
@property (nonatomic, retain) IBOutlet UIImageView *border;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *levelIcon;
@property (nonatomic, retain) IBOutlet EnhancementLevelIcon *enhanceIcon;

@property (nonatomic, retain) UIView *darkOverlay;

@property (nonatomic, retain) UserEquip *equip;

- (void) updateForEquip:(UserEquip *)ue;

@end

@interface EquipTableViewDelegate : NSObject <UITableViewDelegate, UITableViewDataSource> {
  NSArray *_equips;
  NSMutableArray *_equipsForScope;
  int _weaponId;
  int _armorId;
  int _amuletId;
}

@property (nonatomic, retain) IBOutlet EquipView *nibEquipView;

- (void) loadEquips:(NSArray *)equips curWeapon:(int)weapon curArmor:(int)armor curAmulet:(int)amulet;
- (void) setCurWeapon:(int)weapon curArmor:(int)armor curAmulet:(int)amulet;
- (void) loadEquipsForScope:(EquipScope)scope;

@end

@interface EquipTabView : UIView

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;

@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;

@property (nonatomic, retain) NSArray *curEquipViews;

@end

@interface ProfileEquipContainerView : UIView

@end
