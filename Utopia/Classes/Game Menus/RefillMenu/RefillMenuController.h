//
//  RefillMenuControler.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/4/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "NibUtils.h"

@interface RequiresEquipView : UIImageView

@property (nonatomic, retain) IBOutlet EquipLevelIcon *levelIcon;
@property (nonatomic, retain) IBOutlet EquipButton *equipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *checkIcon;

- (void) loadWithEquipId:(int)eq level:(int)lvl owned:(BOOL)owned;

@end

@interface RefillMenuController : UIViewController {
  CGRect _fullRect;
  BOOL _isEnergy;
  
  int _numArmoryResponsesExpected;
  
  int _silverNeeded;
}

@property (nonatomic, retain) IBOutlet UIView *goldView;
@property (nonatomic, retain) IBOutlet UIView *silverView;
@property (nonatomic, retain) IBOutlet UIView *enstView;
@property (nonatomic, retain) IBOutlet UIView *itemsView;
@property (nonatomic, retain) IBOutlet UIView *spkrView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UILabel *needGoldLabel;
@property (nonatomic, retain) IBOutlet UILabel *curGoldLabel;

@property (nonatomic, retain) IBOutlet UILabel *silverDescLabel;

@property (nonatomic, retain) IBOutlet UIImageView *enstImageView;
@property (nonatomic, retain) IBOutlet UILabel *enstTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *enstGoldCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *fillEnstLabel;
@property (nonatomic, retain) IBOutlet UILabel *enstHintLabel;

@property (nonatomic, retain) IBOutlet UILabel *spkrDescLabel;
@property (nonatomic, retain) IBOutlet UILabel *spkrGoldCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *spkrPkgLabel;

@property (nonatomic, retain) UIView *itemsContainerView;
@property (nonatomic, retain) IBOutlet UIView *itemsCostView;
@property (nonatomic, retain) IBOutlet UILabel *itemsSilverLabel;
@property (nonatomic, retain) IBOutlet UIScrollView *itemsScrollView;

@property (nonatomic, retain) IBOutlet LoadingView *loadingView;

@property (nonatomic, retain) IBOutlet RequiresEquipView *rev;

- (void) displayBuyGoldView:(int)needsGold;
- (void) displayBuySilverView:(int)needsSilver;
- (void) displayEnstView:(BOOL)isEnergy;
- (void) displayEquipsView:(NSArray *)equipIds;
- (void) displayBuySpeakersView;

- (void) receivedArmoryResponse:(BOOL)success equip:(int)equipId;

+ (RefillMenuController *) sharedRefillMenuController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

@end
