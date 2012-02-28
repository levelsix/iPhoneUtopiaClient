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
#import "LabelButton.h"

@interface ArmoryListing : UIView

@property (nonatomic, retain) IBOutlet UIImageView *bgdView;
@property (nonatomic, retain) IBOutlet UIImageView *equipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *coinIcon;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;
@property (nonatomic, retain) IBOutlet UILabel *priceLabel;

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

@interface ArmoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView *armoryTableView;
@property (nonatomic, retain) IBOutlet ArmoryRow *armoryRow;

@property (nonatomic, retain) IBOutlet UIView *buySellView;
@property (nonatomic, retain) IBOutlet LabelButton *buyButton;
@property (nonatomic, retain) IBOutlet LabelButton *sellButton;
@property (nonatomic, retain) IBOutlet UILabel *cantEquipLabel;
@property (nonatomic, retain) IBOutlet UILabel *numOwnedLabel;
@property (nonatomic, retain) IBOutlet UILabel *equipDescriptionLabel;

@property (nonatomic, retain) NSArray *equipsList;

+ (ArmoryViewController *) sharedArmoryViewController;
+ (void) displayView;
+ (void) removeView;

@end
