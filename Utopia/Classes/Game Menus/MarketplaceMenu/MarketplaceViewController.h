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

// My selling is when you have the item on the mktplace.
// Listing is when you own the item but its not on the mktplace.

typedef enum {
  kSellingState = 1,
  kListState,
  kMySellingState,
  kSubmitState
} MarketCellState;

@interface ItemPostView : UITableViewCell {
  MarketCellState _state;
}

@property (nonatomic, retain) IBOutlet UILabel *postTitle;

@property (nonatomic, retain) IBOutlet UIImageView *itemImageView;
@property (nonatomic, retain) IBOutlet UIView *statsView;
@property (nonatomic, retain) IBOutlet UIView *submitView;
@property (nonatomic, retain) IBOutlet UIView *submitButton;
@property (nonatomic, retain) IBOutlet UIView *listButton;
@property (nonatomic, retain) IBOutlet UIView *removeButton;
@property (nonatomic, retain) IBOutlet UIView *buyButton;
@property (nonatomic, retain) IBOutlet NiceFontTextField *priceField;
@property (nonatomic, retain) IBOutlet UIImageView *priceIcon;
@property (nonatomic, retain) IBOutlet UIImageView *submitPriceIcon;
@property (nonatomic, retain) IBOutlet UILabel *priceLabel;
@property (nonatomic, retain) IBOutlet UILabel *attStatLabel;
@property (nonatomic, retain) IBOutlet UILabel *defStatLabel;
@property (nonatomic, retain) IBOutlet UIImageView *quanityBackground;
@property (nonatomic, retain) IBOutlet UILabel *quantityLabel;

@property (nonatomic, assign) MarketCellState state;
@property (nonatomic, retain) FullMarketplacePostProto *mktProto;
@property (nonatomic, retain) UserEquip *equip;

- (void) showEquipPost: (FullMarketplacePostProto *)proto;
- (void) showEquipListing: (FullUserEquipProto *)proto;

@end

@interface MarketplaceLoadingView : UIView

@property (nonatomic, retain) IBOutlet UIView *darkView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *actIndView;

@end

typedef enum {
  kEquipBuyingState = 1,
  kEquipSellingState
} MarketplaceState;

@interface MarketplaceViewController : PullRefreshTableViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
  BOOL _refreshing;
  BOOL _isDisplayingLoadingView;
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

@property (nonatomic, retain) IBOutlet MarketplaceLoadingView *loadingView;

@property (nonatomic, retain) IBOutlet CoinBar *coinBar;

@property (nonatomic, retain) IBOutlet UIImageView *retractPriceIcon;

@property (nonatomic, retain) IBOutlet UILabel *shortLicenseCost;
@property (nonatomic, retain) IBOutlet UILabel *longLicenseCost;
@property (nonatomic, retain) IBOutlet UILabel *shortLicenseLength;
@property (nonatomic, retain) IBOutlet UILabel *longLicenseLength;

@property (nonatomic, assign) BOOL listing;

@property (nonatomic, retain) UITableView *postsTableView;
@property (nonatomic, retain) ItemPostView *selectedCell;
@property (nonatomic, retain) UITextField *curField;
@property (nonatomic, assign) BOOL shouldReload;
@property (nonatomic, assign) MarketplaceState state;
@property (nonatomic, retain) UIView *leftRopeFirstRow;
@property (nonatomic, retain) UIView *rightRopeFirstRow;

+ (MarketplaceViewController *) sharedMarketplaceViewController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

- (void) disableEditing;
- (void) insertRowsFrom:(int)start;
- (void) deleteRows:(int)start;
- (void) resetAllRows;
- (NSMutableArray *) postsForState;
- (void) displayRedeemView;
- (void) doneRefreshing;

- (void) displayLoadingView;
- (void) removeLoadingView;

- (IBAction)closePurchLicenseView:(id)sender;
- (IBAction)shortLicenseClicked:(id)sender;
- (IBAction)longLicenseClicked:(id)sender;

@end
