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

@interface EquipView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *equipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *border;
@property (nonatomic, retain) IBOutlet UILabel *rarityLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;

- (void) updateForEquip:(FullUserEquipProto *)fuep;

@end

@interface ProfileBar : UIImageView {
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

@interface ProfileViewController : UIViewController {
  ProfileState _state;
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

@property (nonatomic, retain) IBOutlet UILabel *equippedWeaponLabel;
@property (nonatomic, retain) IBOutlet UILabel *equippedArmorLabel;
@property (nonatomic, retain) IBOutlet UILabel *equippedAmuletLabel;

@property (nonatomic, retain) IBOutlet UIImageView *equippedWeaponIcon;
@property (nonatomic, retain) IBOutlet UIImageView *equippedArmorIcon;
@property (nonatomic, retain) IBOutlet UIImageView *equippedAmuletIcon;

@property (nonatomic, retain) IBOutlet UIView *chooseWeaponButton;
@property (nonatomic, retain) IBOutlet UIView *chooseArmorButton;
@property (nonatomic, retain) IBOutlet UIView *chooseAmuletButton;

@property (nonatomic, assign) ProfileState state;

@property (nonatomic, retain) IBOutlet UIScrollView *equipsScrollView;
@property (nonatomic, retain) NSMutableArray *equipViews;
@property (nonatomic, retain) IBOutlet EquipView *nibEquipView;

- (void) loadMyProfile;

+ (ProfileViewController *) sharedProfileViewController;
+ (void) displayView;
+ (void) removeView;

@end
