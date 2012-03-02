//
//  ProfileViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/26/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "Protocols.pb.h"

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
- (void) doShake;

@end

@interface ProfileBar : UIView {
  ProfileBarState _state;
  
  UIImageView *_curEquipSelectedImage;
  UIImageView *_curSkillsSelectedImage;
  UIImageView *_curWallSelectedImage;
  
  BOOL _trackingEquip;
  BOOL _trackingSkills;
  BOOL _trackingWall;
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

@property (nonatomic, assign) int clickedButtons;

@end

@interface CurrentEquipView : UIImageView {
  BOOL _selected;
}

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIImageView *equipIcon;
@property (nonatomic, retain) IBOutlet UIView *chooseEquipButton;
@property (nonatomic, retain) IBOutlet UIView *border;

@property (nonatomic, assign) BOOL selected;

@end

@interface ProfileViewController : UIViewController {
  ProfileState _state;
  EquipScope _curScope;
  EquipView *_weaponEquipView;
  EquipView *_armorEquipView;
  EquipView *_amuletEquipView;
}

@property (nonatomic, retain) IBOutlet UILabel *userNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *winsLabel;
@property (nonatomic, retain) IBOutlet UILabel *lossesLabel;
@property (nonatomic, retain) IBOutlet UILabel *fleesLabel;
@property (nonatomic, retain) IBOutlet UILabel *levelLabel;
@property (nonatomic, retain) IBOutlet UILabel *factionLabel;
@property (nonatomic, retain) IBOutlet UILabel *classLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;
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

@property (nonatomic, assign) ProfileState state;
@property (nonatomic, assign) EquipScope curScope;

@property (nonatomic, retain) IBOutlet UIScrollView *equipsScrollView;
@property (nonatomic, retain) NSMutableArray *equipViews;
@property (nonatomic, retain) IBOutlet EquipView *nibEquipView;
@property (nonatomic, retain) IBOutlet UIView *unequippableView;
@property (nonatomic, retain) IBOutlet UILabel *unequippableLabel;

@property (nonatomic, retain) UIImageView *equippingView;

- (void) loadMyProfile;
- (void) loadProfileForPlayer:(FullUserProto *)fup;
- (void) equipViewSelected:(EquipView *)ev;
- (void) currentEquipViewSelected:(CurrentEquipView *)cev;

+ (ProfileViewController *) sharedProfileViewController;
+ (void) displayView;
+ (void) removeView;

@end
