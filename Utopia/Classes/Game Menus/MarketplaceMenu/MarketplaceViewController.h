//
//  MarketplaceViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/21/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "PullRefreshTableViewController.h"
#import "UserData.h"
#import "NibUtils.h"
#import "CoinBar.h"
#import "MarketplaceMenus.h"

typedef enum {
  kEquipBuyingState = 1,
  kEquipSellingState
} MarketplaceState;

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
  kAmuletFilter,
  kNoneFilterSelected
} Filters;

@interface MarketplaceViewController : PullRefreshTableViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
  BOOL _refreshing;
  BOOL _isDisplayingLoadingView;
  BOOL _trackingAll;
  BOOL _trackingWeapon;
  BOOL _trackingArmor;
  BOOL _trackingAmulet;
  int _clickedButtons;
  Filters currentFilter;
}

@property (nonatomic, retain) IBOutlet UIView *navBar;
@property (nonatomic, retain) IBOutlet UIView *topBar;
@property (nonatomic, retain) IBOutlet UITableViewCell *itemView;
@property (nonatomic, retain) IBOutlet UIView *removeView;
@property (nonatomic, retain) IBOutlet UILabel *removePriceLabel;
@property (nonatomic, retain) IBOutlet UIButton *doneButton;
@property (nonatomic, retain) IBOutlet UIButton *listAnItemButton;
@property (nonatomic, retain) IBOutlet UIView *redeemView;
@property (nonatomic, retain) IBOutlet UILabel *redeemGoldLabel;
@property (nonatomic, retain) IBOutlet UILabel *redeemSilverLabel;
@property (nonatomic, retain) IBOutlet UILabel *redeemTitleLabel;
@property (nonatomic, retain) IBOutlet UIView *ropeView;
@property (nonatomic, retain) IBOutlet UIView *leftRope;
@property (nonatomic, retain) IBOutlet UIView *rightRope;
@property (nonatomic, retain) IBOutlet UIView *purchLicenseView;

@property (nonatomic, retain) IBOutlet UILabel *topBarLabel;

@property (nonatomic, retain) IBOutlet LoadingView *loadingView;

@property (nonatomic, retain) IBOutlet CoinBar *coinBar;

@property (nonatomic, retain) IBOutlet UIImageView *retractPriceIcon;

@property (nonatomic, retain) IBOutlet UIView *licenseMainView;
@property (nonatomic, retain) IBOutlet UIView *licenseBgdView;
@property (nonatomic, retain) IBOutlet UILabel *shortLicenseCost;
@property (nonatomic, retain) IBOutlet UILabel *longLicenseCost;
@property (nonatomic, retain) IBOutlet UILabel *shortLicenseLength;
@property (nonatomic, retain) IBOutlet UILabel *longLicenseLength;

@property (nonatomic, retain) IBOutlet MarketPurchaseView *purchView;
@property (nonatomic, retain) IBOutlet MarketplaceBottomBar *bottomBar;

@property (nonatomic, retain) IBOutlet UIView *armoryPriceView;
@property (nonatomic, retain) IBOutlet UIView *armoryPriceBottomSubview;
@property (nonatomic, retain) IBOutlet UILabel *armoryPriceLabel;
@property (nonatomic, retain) IBOutlet UIImageView *armoryPriceIcon;

@property (nonatomic, assign) BOOL listing;

@property (nonatomic, retain) UITableView *postsTableView;
@property (nonatomic, retain) ItemPostView *selectedCell;
@property (nonatomic, retain) UITextField *curField;
@property (nonatomic, assign) BOOL shouldReload;
@property (nonatomic, assign) MarketplaceState state;
@property (nonatomic, retain) UIView *leftRopeFirstRow;
@property (nonatomic, retain) UIView *rightRopeFirstRow;

@property (nonatomic, retain) IBOutlet UILabel *allButton;
@property (nonatomic, retain) IBOutlet UIImageView *weapIcon;
@property (nonatomic, retain) IBOutlet UIImageView *armIcon;
@property (nonatomic, retain) IBOutlet UIImageView *amuIcon;

@property (nonatomic, retain) IBOutlet UIImageView *weapButtonClicked;
@property (nonatomic, retain) IBOutlet UIImageView *armButtonClicked;
@property (nonatomic, retain) IBOutlet UIImageView *amuButtonClicked;
@property (nonatomic, retain) IBOutlet UIImageView *allButtonClicked;

@property (nonatomic, retain) NSMutableArray *filtered;

+ (MarketplaceViewController *) sharedMarketplaceViewController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;
+ (BOOL) isInitialized;

- (void) disableEditing;
- (void) insertRowsFrom:(int)start;
- (void) deleteRows:(int)start;
- (void) resetAllRows;
- (NSMutableArray *) getCurrentFilterState;
- (void) displayRedeemView;
- (void) doneRefreshing;

- (IBAction)closePurchLicenseView:(id)sender;
- (IBAction)shortLicenseClicked:(id)sender;
- (IBAction)longLicenseClicked:(id)sender;
- (IBAction)backClicked:(id)sender;

- (void) close;

@end
