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
#import "MarketplaceFilterView.h"

typedef enum {
  kEquipBuyingState = 1,
  kEquipSellingState
} MarketplaceState;

@interface MarketplaceViewController : PullRefreshTableViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
  BOOL _refreshing;
  BOOL _isDisplayingLoadingView;
  
  UIGestureRecognizer *_swipeGestureRecognizer;
}

@property (nonatomic, retain) IBOutlet UIView *navBar;
@property (nonatomic, retain) IBOutlet UIView *topBar;
@property (nonatomic, retain) IBOutlet UITableViewCell *itemView;
@property (nonatomic, retain) IBOutlet UIButton *doneButton;
@property (nonatomic, retain) IBOutlet UIButton *listAnItemButton;
@property (nonatomic, retain) IBOutlet UIView *redeemView;
@property (nonatomic, retain) IBOutlet UILabel *redeemGoldLabel;
@property (nonatomic, retain) IBOutlet UILabel *redeemSilverLabel;
@property (nonatomic, retain) IBOutlet UILabel *redeemTitleLabel;
@property (nonatomic, retain) IBOutlet UIView *ropeView;
@property (nonatomic, retain) IBOutlet UIView *leftRope;
@property (nonatomic, retain) IBOutlet UIView *rightRope;

@property (nonatomic, retain) IBOutlet UILabel *topBarLabel;

@property (nonatomic, retain) IBOutlet LoadingView *loadingView;

@property (nonatomic, retain) IBOutlet CoinBar *coinBar;

@property (nonatomic, retain) IBOutlet UIView *removeView;
@property (nonatomic, retain) IBOutlet UILabel *removeDescriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *removePriceLabel;
@property (nonatomic, retain) IBOutlet UIImageView *retractPriceIcon;

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

@property (nonatomic, retain) IBOutlet MarketplaceFilterView *filterView;
@property (nonatomic, retain) IBOutlet UIView *mainView;

+ (MarketplaceViewController *) sharedMarketplaceViewController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;
+ (BOOL) isInitialized;

- (void) disableEditing;
- (void) insertRowsFrom:(int)start;
- (void) deleteRows:(int)start;
- (void) resetAllRows;
- (NSMutableArray *) arrayForCurrentState;
- (void) displayRedeemView;
- (void) doneRefreshing;

- (IBAction) shortLicenseClicked:(id)sender;
- (IBAction) longLicenseClicked:(id)sender;
- (IBAction) backClicked:(id)sender;

- (void) searchForEquipId:(int)equipId level:(int)level;

- (void) receivedPurchaseMktLicenseResponse:(PurchaseMarketplaceLicenseResponseProto *)p;

- (void) closeFilterPage;

- (void) close;

@end
