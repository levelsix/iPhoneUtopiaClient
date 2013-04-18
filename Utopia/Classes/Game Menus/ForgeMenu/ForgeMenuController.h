//
//  ForgeMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 7/17/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "NibUtils.h"
#import "ForgeMenus.h"
#import "CoinBar.h"
#import "ForgeEnhanceView.h"
#import "LeaderboardController.h"

@interface ForgeTopBar : UIView {
  BOOL _trackingButton1;
  BOOL _trackingButton2;
  
  int _clickedButtons;
}

@property (nonatomic, retain) IBOutlet UIImageView *button1;
@property (nonatomic, retain) IBOutlet UIImageView *button2;

@end

@interface ForgeMenuController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
  CGRect backOldFrame;
  CGRect frontOldFrame;
  CGRect upgrFrame;
  
  BOOL _collectingEquips;
  BOOL _shouldShake;
  
  int _forgedUserEquipId;
}

@property (nonatomic, retain) IBOutlet UIView *topBar;
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet ForgeTopBar *navBar;
@property (nonatomic, retain) IBOutlet ForgeSlotTopBar *slotBar;

@property (nonatomic, retain) IBOutlet UITableView *forgeTableView;
@property (nonatomic, retain) IBOutlet LoadingView *loadingView;

@property (nonatomic, retain) IBOutlet UIView *backOldItemView;
@property (nonatomic, retain) IBOutlet UIView *frontOldItemView;
@property (nonatomic, retain) IBOutlet UIView *upgrItemView;
@property (nonatomic, retain) IBOutlet UILabel *backOldAttackLabel;
@property (nonatomic, retain) IBOutlet UILabel *backOldDefenseLabel;
@property (nonatomic, retain) IBOutlet UIView *backOldStatsView;
@property (nonatomic, retain) IBOutlet UIView *frontOldStatsView;
@property (nonatomic, retain) IBOutlet UILabel *frontOldAttackLabel;
@property (nonatomic, retain) IBOutlet UILabel *frontOldDefenseLabel;
@property (nonatomic, retain) IBOutlet UILabel *upgrAttackLabel;
@property (nonatomic, retain) IBOutlet UILabel *upgrDefenseLabel;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *backOldLevelIcon;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *frontOldLevelIcon;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *upgrLevelIcon;
@property (nonatomic, retain) IBOutlet UIImageView *backOldEquipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *frontOldEquipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *upgrEquipIcon;
@property (nonatomic, retain) IBOutlet UILabel *chanceOfSuccessLabel;
@property (nonatomic, retain) IBOutlet UILabel *forgeTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *bottomLabel;

@property (nonatomic, retain) IBOutlet UIView *notForgingMiddleView;
@property (nonatomic, retain) IBOutlet ForgeProgressView *progressView;
@property (nonatomic, retain) IBOutlet ForgeStatusView *statusView;
@property (nonatomic, retain) IBOutlet UIView *notEnoughQuantityView;
@property (nonatomic, retain) IBOutlet UIView *backOldForgingPlacerView;
@property (nonatomic, retain) IBOutlet UIView *frontOldForgingPlacerView;
@property (nonatomic, retain) IBOutlet UIImageView *equalPlusSign;
@property (nonatomic, retain) IBOutlet UIImageView *twinkleIcon;

@property (nonatomic, retain) IBOutlet UIButton *forgeButton;
@property (nonatomic, retain) IBOutlet UIButton *finishNowButton;
@property (nonatomic, retain) IBOutlet UIButton *collectButton;
@property (nonatomic, retain) IBOutlet UIButton *okayButton;
@property (nonatomic, retain) IBOutlet UIButton *goToMarketplaceButton;
@property (nonatomic, retain) IBOutlet UIView *buyOneView;
@property (nonatomic, retain) IBOutlet UILabel *buyOneLabel;
@property (nonatomic, retain) IBOutlet UIImageView *buyOneCoinIcon;

@property (nonatomic, retain) UIImageView *backMovingView;
@property (nonatomic, retain) UIImageView *frontMovingView;

@property (nonatomic, retain) IBOutlet CoinBar *coinBar;

@property (nonatomic, retain) IBOutlet ForgeItemView *itemView;

@property (nonatomic, retain) IBOutlet UIView *forgingView;
@property (nonatomic, retain) IBOutlet ForgeEnhanceView *enhancingView;

@property (nonatomic, retain) IBOutlet UIView *forgingRightView;
@property (nonatomic, retain) IBOutlet UIView *buySlotView;
@property (nonatomic, retain) IBOutlet UILabel *buySlotDescLabel;
@property (nonatomic, retain) IBOutlet UILabel *buySlotCostLabel;

@property (nonatomic, retain) NSMutableArray *forgeItems;
@property (nonatomic, retain) ForgeItem *curItem;

@property (nonatomic, assign) int slotNumber;

+ (ForgeMenuController *) sharedForgeMenuController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

- (void) displayForgeMenu;
- (void) displayEnhanceMenu;

- (void) reloadCurrentItem;
- (IBAction) closeClicked:(id)sender;
- (IBAction) forgeButtonClicked:(id)sender;

- (void) receivedSubmitEquipResponse:(SubmitEquipsToBlacksmithResponseProto *)proto;
- (void) receivedCollectForgeEquipsResponse:(CollectForgeEquipsResponseProto *)proto;
- (void) receivedArmoryResponse:(BOOL)success;
- (void) receivedPurchaseForgeSlot;

@end
