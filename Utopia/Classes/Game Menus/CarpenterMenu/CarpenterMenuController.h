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

@class FullStructureProto;

@interface CarpenterTicker : UIView {
  UIImage *_tickerImage;
  UIFont *_font;
}

@property (nonatomic, retain) NSString *string;

@end

@interface CarpenterListing : UIView {
  ListingState _state;
  UIColor *_lockedBuildingColor;
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

@property (nonatomic, retain) IBOutlet UIImageView *buildingIcon;
@property (nonatomic, retain) IBOutlet UIImageView *lockIcon;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImg;

@property (nonatomic, retain) IBOutlet UIImageView *darkOverlay;

@property (nonatomic, assign) ListingState state;

@property (nonatomic, retain) FullStructureProto *fsp;

@end

@interface CarpenterListingContainer : UIView

@property (nonatomic, retain) IBOutlet CarpenterListing *carpListing;

@end

@interface CarpenterRow : UITableViewCell

@property (nonatomic, retain) IBOutlet CarpenterListingContainer *listing1;
@property (nonatomic, retain) IBOutlet CarpenterListingContainer *listing2;
@property (nonatomic, retain) IBOutlet CarpenterListingContainer *listing3;

@end

@interface CarpenterMenuController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet CarpenterRow *carpRow;
@property (nonatomic, retain) IBOutlet UITableView *carpTable;

@property (nonatomic, retain) NSMutableArray *structsList;

- (IBAction)closeClicked:(id)sender;
+ (CarpenterMenuController *) sharedCarpenterMenuController;
+ (void) displayView;
+ (void) removeView;

@end
