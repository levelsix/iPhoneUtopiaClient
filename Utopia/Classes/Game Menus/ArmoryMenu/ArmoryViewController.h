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
#import "LeaderboardController.h"

@interface ArmoryTopBar : UIView {
  BOOL _trackingButton1;
  BOOL _trackingButton2;
  
  int _clickedButtons;
}

@property (nonatomic, retain) IBOutlet UIImageView *button1;
@property (nonatomic, retain) IBOutlet UIImageView *button2;

@end

@interface ArmoryRow : UITableViewCell

@property (nonatomic, retain) IBOutlet UIButton *bgdView;
@property (nonatomic, retain) IBOutlet UIImageView *chestIcon;
@property (nonatomic, retain) IBOutlet UIImageView *middleImageView;
@property (nonatomic, retain) IBOutlet UILabel *levelsLabel;
@property (nonatomic, retain) IBOutlet UILabel *equipsLeftLabel;

@property (nonatomic, retain) BoosterPackProto *boosterPack;

@end

@interface ArmoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
  int _level;
  BOOL _shouldCostCoins;
}

@property (nonatomic, retain) IBOutlet UITableView *armoryTableView;
@property (nonatomic, retain) IBOutlet ArmoryRow *armoryRow;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) IBOutlet CoinBar *coinBar;

@property (nonatomic, assign) BOOL equipClicked;

@property (nonatomic, retain) IBOutlet LoadingView *loadingView;

@property (nonatomic, retain) NSArray *boosterPacks;
@property (nonatomic, retain) IBOutlet ArmoryCarouselView *carouselView;
@property (nonatomic, retain) IBOutlet ArmoryCardDisplayView *cardDisplayView;

@property (nonatomic, retain) IBOutlet UIView *backView;

@property (nonatomic, retain) IBOutlet ArmoryTopBar *topBar;

@property (nonatomic, retain) IBOutlet UIScrollView *infoScrollView;
@property (nonatomic, retain) IBOutlet UIImageView *infoImageView;

- (void) refresh;
- (void) close;

- (void) displayBuyChests;
- (void) displayInfo;

- (void) loadForLevel:(int)level rarity:(FullEquipProto_Rarity)rarity;

- (IBAction)purchaseClicked:(UIView *)sender;
- (IBAction)resetClicked:(id)sender;

- (void) receivedPurchaseBoosterPackResponse:(PurchaseBoosterPackResponseProto *)proto;
- (void) resetBoosterPackResponse:(ResetBoosterPackResponseProto *)proto;

+ (ArmoryViewController *) sharedArmoryViewController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;
+ (BOOL) isInitialized;

@end
