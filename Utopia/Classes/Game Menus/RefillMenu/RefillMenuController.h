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

@property (nonatomic, assign) int equipId;

- (id) initWithEquipId:(int)eq;

@end

@interface RefillMenuController : UIViewController {
  CGRect _fullRect;
  BOOL _isEnergy;
}

@property (nonatomic, retain) IBOutlet UIView *goldView;
@property (nonatomic, retain) IBOutlet UIView *silverView;
@property (nonatomic, retain) IBOutlet UIView *enstView;
@property (nonatomic, retain) IBOutlet UIView *itemsView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UILabel *needGoldLabel;
@property (nonatomic, retain) IBOutlet UILabel *curGoldLabel;

@property (nonatomic, retain) IBOutlet UIImageView *enstImageView;
@property (nonatomic, retain) IBOutlet UILabel *enstTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *enstGoldCostLabel;
@property (nonatomic, retain) IBOutlet UILabel *fillEnstLabel;
@property (nonatomic, retain) IBOutlet UILabel *enstHintLabel;

@property (nonatomic, retain) UIView *itemsContainerView;
@property (nonatomic, retain) IBOutlet UIView *itemsCostView;
@property (nonatomic, retain) IBOutlet UILabel *itemsSilverLabel;

@property (nonatomic, retain) IBOutlet UIScrollView *itemsScrollView;

- (void) displayBuyGoldView:(int)needsGold;
- (void) displayBuySilverView;
- (void) displayEnstView:(BOOL)isEnergy;
- (void) displayEquipsView:(NSArray *)equipIds;

+ (RefillMenuController *) sharedRefillMenuController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

@end
