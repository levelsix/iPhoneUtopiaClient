//
//  MarketplaceFilterView.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/29/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"
#import "Protocols.pb.h"

#define FILTER_BAR_USER_DEFAULTS_KEY @"FilterBarButtonMarketplace"
#define RARITY_BAR_USER_DEFAULTS_KEY @"RarityBarButtonMarketplace"
#define SWITCH_BUTTON_USER_DEFAULTS_KEY @"SwitchButtonMarketplace"
#define EQUIP_LEVEL_MIN_USER_DEFAULTS_KEY @"EquipLevelMinMarketplace"
#define EQUIP_LEVEL_MAX_USER_DEFAULTS_KEY @"EquipLevelMaxMarketplace"
#define FORGE_LEVEL_MIN_USER_DEFAULTS_KEY @"ForgeLevelMinMarketplace"
#define FORGE_LEVEL_MAX_USER_DEFAULTS_KEY @"ForgeLevelMaxMarketplace"
#define SORT_ORDER_USER_DEFAULTS_KEY @"SortOrderMarketplace"

@class SliderPin;

typedef enum {
  kWeapButton = 1,
  kArmButton = 1 << 1,
  kAmuButton = 1 << 2,
  kAllButton = 1 << 3
} MarketPlaceFilterButton;

typedef enum {
  kAllFilter = 20,
  kWeaponFilter,
  kArmorFilter,
  kAmuletFilter
} Filters;

@interface FilterBar : UIView {
  BOOL _trackingAll;
  BOOL _trackingWeapon;
  BOOL _trackingArmor;
  BOOL _trackingAmulet;
  int _clickedButtons;
}

@property (nonatomic, retain) IBOutlet UILabel *allButton;
@property (nonatomic, retain) IBOutlet UIImageView *weapIcon;
@property (nonatomic, retain) IBOutlet UIImageView *armIcon;
@property (nonatomic, retain) IBOutlet UIImageView *amuIcon;

@property (nonatomic, retain) IBOutlet UIImageView *weapButtonClicked;
@property (nonatomic, retain) IBOutlet UIImageView *armButtonClicked;
@property (nonatomic, retain) IBOutlet UIImageView *amuButtonClicked;
@property (nonatomic, retain) IBOutlet UIImageView *allButtonClicked;

@end

@interface RarityTab : UIView

@property (nonatomic, retain) IBOutlet UIImageView *check;

@end

@interface RarityBar : UIView

@property (nonatomic, retain) IBOutlet RarityTab *comTab;
@property (nonatomic, retain) IBOutlet RarityTab *uncTab;
@property (nonatomic, retain) IBOutlet RarityTab *rareTab;
@property (nonatomic, retain) IBOutlet RarityTab *epicTab;
@property (nonatomic, retain) IBOutlet RarityTab *legTab;

@end

@interface SwitchButton : UIView {
  CGPoint _initialTouch;
}

@property (nonatomic, assign) BOOL isOn;

@property (nonatomic, retain) IBOutlet UIImageView *handle;
@property (nonatomic, retain) UIImageView *darkHandle;

@end

@interface SliderBar : UIView

@property (nonatomic, assign) int numNotches;

@property (nonatomic, retain) IBOutlet SliderPin *leftPin;
@property (nonatomic, retain) IBOutlet SliderPin *rightPin;
@property (nonatomic, retain) IBOutlet UIImageView *bar;

@end

@interface SliderPin : UIView {
  int _curVal;
  CGPoint _initialTouch;
  float _originalX;
}

@property (nonatomic, assign) BOOL isLeft;

@property (nonatomic, retain) UIImageView *darkOverlay;

- (void) clicked;
- (void) unclicked;
- (void) movedToNotch:(int)notch;
- (int) currentValue;

@end

@interface ForgeLevelPin : SliderPin

@property (nonatomic, retain) IBOutlet EquipLevelIcon *levelIcon;

@end

@interface EquipLevelPin : SliderPin

@property (nonatomic, retain) IBOutlet UIImageView *backgroundImg;
@property (nonatomic, retain) IBOutlet UILabel *levelLabel;

@end

@interface MarketplacePickerView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, assign) RetrieveCurrentMarketplacePostsRequestProto_RetrieveCurrentMarketplacePostsSortingOrder sortOrder;

@property (nonatomic, retain) IBOutlet UILabel *sortOrderLabel;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;

@property (nonatomic, retain) NSArray *sortOrderStrings;

@end

@interface MarketplaceSearchCell : UITableViewCell

@property (nonatomic, retain) MarketplaceSearchEquipProto *searchEquip;

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

@end

@interface MarketplaceLiveSearchView : UIView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet NSArray *searchEquips;

@property (nonatomic, retain) IBOutlet UITableView *searchTable;
@property (nonatomic, retain) IBOutlet UITextField *textField;

@property (nonatomic, retain) IBOutlet MarketplaceSearchCell *searchCell;

@property (nonatomic, assign) int searchEquipId;

@end

@interface MarketplaceFilterView : UIView

@property (nonatomic, retain) IBOutlet FilterBar *filterBar;
@property (nonatomic, retain) IBOutlet RarityBar *rarityBar;
@property (nonatomic, retain) IBOutlet SwitchButton *switchButton;
@property (nonatomic, retain) IBOutlet SliderBar *equipLevelBar;
@property (nonatomic, retain) IBOutlet SliderBar *forgeLevelBar;
@property (nonatomic, retain) IBOutlet MarketplacePickerView *pickerView;
@property (nonatomic, retain) IBOutlet MarketplaceLiveSearchView *searchView;

- (void) loadFilterSettings;
- (void) saveFilterSettings;

@end

@interface MarketplaceDragView : UIView {
  float _initialX;
  BOOL _passedThreshold;
}

@end