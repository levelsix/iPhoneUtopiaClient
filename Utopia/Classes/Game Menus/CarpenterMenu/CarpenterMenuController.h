//
//  CarpenterMenuControllerViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/21/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
  kAvailable = 1,
  kLocked,
  kDisappear
} ListingState;

@interface CarpenterListing : UIView {
  ListingState _state;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *incomeLabel;
@property (nonatomic, retain) IBOutlet UILabel *priceLabel;
@property (nonatomic, retain) IBOutlet UIView *priceView;

@property (nonatomic, retain) IBOutlet UILabel *lockedPriceLabel;
@property (nonatomic, retain) IBOutlet UILabel *lockedIncomeLabel;
@property (nonatomic, retain) IBOutlet UILabel *lockedCollectsLabel;

@property (nonatomic, retain) IBOutlet UIImageView *buildingIcon;
@property (nonatomic, retain) IBOutlet UIImageView *lockIcon;

@property (nonatomic, retain) UIImageView *darkOverlay;

@property (nonatomic, assign) ListingState state;

@end

@interface CarpenterListingContainer : UIView

@property (nonatomic, retain) IBOutlet CarpenterListing *carpListing;

@end

@interface CarpenterRow : UITableViewCell

@end

@interface CarpenterMenuController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet CarpenterRow *carpRow;
@property (nonatomic, retain) IBOutlet UITableView *carpTable;

+ (CarpenterMenuController *) sharedCarpenterMenuController;
+ (void) displayView;
+ (void) removeView;

@end
