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
#import "NibUtils.h"
#import "CoinBar.h"
#import "ArmoryCarouselView.h"

@interface ArmoryRow : UITableViewCell

@property (nonatomic, retain) IBOutlet UIButton *bgdView;
@property (nonatomic, retain) IBOutlet UIImageView *chestIcon;
@property (nonatomic, retain) IBOutlet UIImageView *middleImageView;
@property (nonatomic, retain) IBOutlet UILabel *levelsLabel;
@property (nonatomic, retain) IBOutlet UILabel *equipsLeftLabel;

@property (nonatomic, retain) BoosterPackProto *boosterPack;

@end

@interface ArmoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView *armoryTableView;
@property (nonatomic, retain) IBOutlet ArmoryRow *armoryRow;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) IBOutlet CoinBar *coinBar;

@property (nonatomic, assign) BOOL equipClicked;

@property (nonatomic, retain) IBOutlet LoadingView *loadingView;

@property (nonatomic, retain) NSArray *boosterPacks;
@property (nonatomic, retain) IBOutlet ArmoryCarouselView *carouselView;
@property (nonatomic, retain) IBOutlet ArmoryCardDisplayView *cardDisplayView;

- (void) refresh;
- (void) close;

- (IBAction)purchaseClicked:(UIView *)sender;

+ (ArmoryViewController *) sharedArmoryViewController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;
+ (BOOL) isInitialized;

@end
