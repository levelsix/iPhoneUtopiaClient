//
//  DiamondShopViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/11/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <StoreKit/StoreKit.h>
#import "InAppPurchaseData.h"
#import "NibUtils.h"

typedef enum {
  kPackagesState = 1,
  kEarnFreeState
} GoldShoppeState;

typedef enum {
  kGoldCoinsButton = 1,
  kEarnFreeButton = 1 << 1
} GoldShoppeButton;

@interface PriceLabel : UIView

@property (nonatomic, retain) NSString *price;
@property (nonatomic, retain) IBOutlet UILabel *bigLabel;
@property (nonatomic, retain) IBOutlet UILabel *littleLabel;

@end

@interface GoldPackageView : UITableViewCell {
    id<InAppPurchaseData> productData;
}

@property (nonatomic, retain) id<InAppPurchaseData> productData;

@property (nonatomic, retain) IBOutlet UILabel     *pkgNameLabel;
@property (nonatomic, retain) IBOutlet UILabel     *pkgGoldLabel;
@property (nonatomic, retain) IBOutlet PriceLabel  *priceLabel;
@property (nonatomic, retain) IBOutlet UIImageView *pkgIcon;
@property (nonatomic, retain) IBOutlet UIView      *selectedView;

- (void) updateForPurchaseData:(id<InAppPurchaseData>)product;
@end

@interface GoldShoppeBar : UIView {
  BOOL _trackingGoldCoins;
  BOOL _trackingEarnFree;
  
  int _clickedButtons;
}

@property (nonatomic, retain) IBOutlet UILabel *goldCoinsLabel;
@property (nonatomic, retain) IBOutlet UILabel *earnFreeLabel;

@property (nonatomic, retain) IBOutlet UIImageView *goldCoinsClicked;
@property (nonatomic, retain) IBOutlet UIImageView *earnFreeClicked;

@end

@interface GoldShoppeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
  UIScrollView    *_scrollView;
  GoldPackageView *_itemView;
  BOOL            _isDisplayingLoadingView;
  GoldShoppeState _state;
  NSArray         *_sponsoredOffers;
}

@property (nonatomic, retain) IBOutlet LoadingView *loadingView;
@property (nonatomic, retain) IBOutlet UITableView *pkgTableView;
@property (nonatomic, retain) IBOutlet GoldPackageView *itemView;
@property (nonatomic, retain) IBOutlet UILabel *curGoldLabel;
@property (nonatomic, retain) IBOutlet GoldShoppeBar *topBar;

@property (nonatomic, assign) GoldShoppeState state;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

+ (GoldShoppeViewController *)sharedGoldShoppeViewController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

- (IBAction)closeButtonClicked:(id)sender;
- (void) stopLoading;

@end
