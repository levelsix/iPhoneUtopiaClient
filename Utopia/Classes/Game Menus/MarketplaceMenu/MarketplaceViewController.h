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

typedef enum {
  kSellingEquipState = 1,
  kSellingCurrencyState,
  kListState,
  kMySellingEquipState,
  kMySellingCurrencyState,
  kSubmitState
} MarketCellState;

@interface ItemPostView : UITableViewCell {
  MarketCellState _state;
}

@property (nonatomic, retain) IBOutlet UILabel *postTitle;

@property (nonatomic, retain) IBOutlet UIImageView *itemImageView;
@property (nonatomic, retain) IBOutlet UIView *statsView;
@property (nonatomic, retain) IBOutlet UIView *priceView;
@property (nonatomic, retain) IBOutlet UIView *submitView;
@property (nonatomic, retain) IBOutlet UIView *itemView;
@property (nonatomic, retain) IBOutlet UIButton *listButton;
@property (nonatomic, retain) IBOutlet UIButton *removeButton;
@property (nonatomic, retain) IBOutlet UITextField *goldField;
@property (nonatomic, retain) IBOutlet UITextField *silverField;
@property (nonatomic, retain) IBOutlet UILabel *goldLabel;
@property (nonatomic, retain) IBOutlet UILabel *silverLabel;
@property (nonatomic, retain) IBOutlet UILabel *attStatLabel;
@property (nonatomic, retain) IBOutlet UILabel *defStatLabel;

@property (nonatomic, assign) MarketCellState state;
@property (nonatomic, retain) FullMarketplacePostProto *mktProto;
@property (nonatomic, retain) UserEquip *equip;

- (void) showEquipPost: (FullMarketplacePostProto *)proto;
- (void) showEquipListing: (FullUserEquipProto *)proto;
- (NSString *) truncateInt:(int)num;

@end

typedef enum {
  kEquipBuyingState = 1,
  kEquipSellingState
} MarketplaceState;

@interface MarketplaceViewController : PullRefreshTableViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UIView *navBar;
@property (nonatomic, retain) IBOutlet UIView *topBar;
@property (nonatomic, retain) IBOutlet UITableViewCell *itemView;
@property (nonatomic, retain) IBOutlet UIView *buyButtonView;
@property (nonatomic, retain) IBOutlet UIView *removeView;
@property (nonatomic, retain) IBOutlet UILabel *removeGoldLabel;
@property (nonatomic, retain) IBOutlet UILabel *removeSilverLabel;
@property (nonatomic, retain) IBOutlet UIButton *doneButton;
@property (nonatomic, retain) IBOutlet UIButton *listAnItemButton;
@property (nonatomic, retain) IBOutlet UIView *redeemView;
@property (nonatomic, retain) IBOutlet UILabel *redeemGoldLabel;
@property (nonatomic, retain) IBOutlet UILabel *redeemSilverLabel;
@property (nonatomic, retain) IBOutlet UILabel *redeemTitleLabel;
@property (nonatomic, retain) IBOutlet UIView *ropeView;
@property (nonatomic, retain) IBOutlet UIView *leftRope;
@property (nonatomic, retain) IBOutlet UIView *rightRope;

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
- (void) disableEditing;
- (NSString *) truncateString:(NSString *)num;
- (NSString *) truncateInt:(int)num;
- (int) untruncateString:(NSString *)trunc;
- (void) insertRowsFrom:(int)start;
- (void) deleteRows:(int)start;
- (void) resetAllRows;
- (NSMutableArray *) postsForState;
- (void) displayRedeemView;

@end
