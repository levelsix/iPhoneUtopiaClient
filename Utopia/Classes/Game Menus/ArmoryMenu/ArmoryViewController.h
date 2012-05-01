//
//  ArmoryViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/25/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "Protocols.pb.h"
#import "NibUtils.h"
#import "CoinBar.h"

typedef enum {
  kWeaponButton = 1,
  kArmorButton = 1 << 1,
  kAmuletButton = 1 << 2
} ArmoryBarButton;

typedef enum {
  kWeaponState = 1,
  kArmorState,
  kAmuletState
} ArmoryState;

@interface ArmoryBar : UIView {
  BOOL _trackingWeapon;
  BOOL _trackingArmor;
  BOOL _trackingAmulet;
  
  int _clickedButtons;
}

@property (nonatomic, retain) IBOutlet UIImageView *weaponIcon;
@property (nonatomic, retain) IBOutlet UIImageView *armorIcon;
@property (nonatomic, retain) IBOutlet UIImageView *amuletIcon;

@property (nonatomic, retain) IBOutlet UIImageView *weaponButtonClicked;
@property (nonatomic, retain) IBOutlet UIImageView *armorButtonClicked;
@property (nonatomic, retain) IBOutlet UIImageView *amuletButtonClicked;

@end

@interface ArmoryListing : UIView

@property (nonatomic, retain) IBOutlet UIImageView *bgdView;
@property (nonatomic, retain) IBOutlet UIImageView *equipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *maskedEquipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *coinIcon;
@property (nonatomic, retain) IBOutlet UIImageView *equippedTag;

@property (nonatomic, retain) IBOutlet UIView *priceView;
@property (nonatomic, retain) IBOutlet UILabel *naLabel;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;
@property (nonatomic, retain) IBOutlet UILabel *priceLabel;

@property (nonatomic, retain) UIView *darkOverlay;

@property (nonatomic, retain) FullEquipProto *fep;

@end

@interface ArmoryListingContainer : UIView

@property (nonatomic, retain) IBOutlet ArmoryListing *armoryListing;

@end

@interface ArmoryRow : UITableViewCell

@property (nonatomic, retain) IBOutlet ArmoryListingContainer *listing1;
@property (nonatomic, retain) IBOutlet ArmoryListingContainer *listing2;
@property (nonatomic, retain) IBOutlet ArmoryListingContainer *listing3;

@end

@interface ArmoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
  ArmoryListing *_clickedAl;
  CGRect _oldClickedRect;
  CGSize _originalBuySellSize;
  
  ArmoryState _state;
}

@property (nonatomic, retain) IBOutlet UITableView *armoryTableView;
@property (nonatomic, retain) IBOutlet ArmoryRow *armoryRow;

@property (nonatomic, retain) IBOutlet UIView *buySellView;
@property (nonatomic, retain) IBOutlet LabelButton *buyButton;
@property (nonatomic, retain) IBOutlet LabelButton *sellButton;
@property (nonatomic, retain) IBOutlet UILabel *cantBuyLabel;
@property (nonatomic, retain) IBOutlet UILabel *cantEquipLabel;
@property (nonatomic, retain) IBOutlet UIView *cantEquipView;
@property (nonatomic, retain) IBOutlet UILabel *numOwnedLabel;
@property (nonatomic, retain) IBOutlet UILabel *equipDescriptionLabel;

@property (nonatomic, retain) IBOutlet CoinBar *coinBar;

@property (nonatomic, retain) IBOutlet ArmoryBar *armoryBar;

@property (nonatomic, assign) BOOL equipClicked;

@property (nonatomic, assign) ArmoryState state;

- (void) armoryListingClicked:(ArmoryListing *)al;
- (void) refresh;

+ (ArmoryViewController *) sharedArmoryViewController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

@end
