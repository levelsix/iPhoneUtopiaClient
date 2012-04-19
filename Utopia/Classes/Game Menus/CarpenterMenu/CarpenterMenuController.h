//
//  CarpenterMenuControllerViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/21/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"
#import "CoinBar.h"

@class FullStructureProto;

typedef enum {
  kIncomeAvailable = 1,
  kIncomeLocked,
  kFunctionalAvailable,
  kFunctionalLocked,
  kDisappear
} ListingState;

typedef enum {
  kIncomeButton = 1,
  kFunctionalButton = 1 << 1
} CarpBarButton;

typedef enum {
  kIncomeCarp = 1,
  kFunctionalCarp
} CarpState;

@interface CarpBar : UIView {
  BOOL _trackingIncome;
  BOOL _trackingFunctional;
  
  int _clickedButtons;
}

@property (nonatomic, retain) IBOutlet UILabel *incomeLabel;
@property (nonatomic, retain) IBOutlet UILabel *functionalLabel;

@property (nonatomic, retain) IBOutlet UIImageView *incomeButtonClicked;
@property (nonatomic, retain) IBOutlet UIImageView *functionalButtonClicked;

- (void) clickButton:(CarpBarButton)button;
- (void) unclickButton:(CarpBarButton)button;

@end

@interface CarpenterTicker : UIView {
  UIImage *_tickerImage;
  UIFont *_font;
}

@property (nonatomic, retain) NSString *string;

@end

@interface CarpenterListing : UIView {
  ListingState _state;
  int _structId;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *incomeLabel;
@property (nonatomic, retain) IBOutlet UILabel *priceLabel;
@property (nonatomic, retain) IBOutlet UIView *priceView;
@property (nonatomic, retain) IBOutlet UIImageView *priceIcon;
@property (nonatomic, retain) IBOutlet CarpenterTicker *tickerView;

@property (nonatomic, retain) IBOutlet UILabel *lockedPriceLabel;
@property (nonatomic, retain) IBOutlet UILabel *lockedIncomeLabel;
@property (nonatomic, retain) IBOutlet UILabel *lockedCollectsLabel;

@property (nonatomic, retain) IBOutlet UILabel *availableLabel;

@property (nonatomic, retain) IBOutlet UIImageView *buildingIcon;
@property (nonatomic, retain) IBOutlet UIImageView *lockIcon;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImg;

@property (nonatomic, retain) IBOutlet UIImageView *darkOverlay;

@property (nonatomic, assign) ListingState state;

@property (nonatomic, retain) FullStructureProto *fsp;
@property (nonatomic, retain) CritStruct *critStruct;

@end

@interface CarpenterListingContainer : UIView

@property (nonatomic, retain) IBOutlet CarpenterListing *carpListing;

@end

@interface CarpenterRow : UITableViewCell

@property (nonatomic, retain) IBOutlet CarpenterListingContainer *listing1;
@property (nonatomic, retain) IBOutlet CarpenterListingContainer *listing2;
@property (nonatomic, retain) IBOutlet CarpenterListingContainer *listing3;

@end

@interface CarpenterMenuController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
  BOOL _critStructAvail;
}

@property (nonatomic, retain) IBOutlet CarpenterRow *carpRow;
@property (nonatomic, retain) IBOutlet UITableView *carpTable;

@property (nonatomic, retain) NSMutableArray *structsList;
@property (nonatomic, retain) NSMutableArray *critStructsList;

@property (nonatomic, assign) CarpState state;

@property (nonatomic, retain) IBOutlet CarpBar *carpBar;
@property (nonatomic, retain) IBOutlet CoinBar *coinBar;

- (void) reloadCarpenterStructs;

- (IBAction)closeClicked:(id)sender;
+ (CarpenterMenuController *) sharedCarpenterMenuController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;
- (void) carpListingClicked:(CarpenterListing *)carp;

@end
