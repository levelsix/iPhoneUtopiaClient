//
//  EquipMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/15/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"

@interface EquipMenuController : UIViewController {
  int equipId;
  BOOL _isDisplayingLoadingView;
}

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *classLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;
@property (nonatomic, retain) IBOutlet UILabel *typeLabel;
@property (nonatomic, retain) IBOutlet UILabel *levelLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *priceLabel;
@property (nonatomic, retain) IBOutlet UIImageView *equipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *priceIcon;
@property (nonatomic, retain) IBOutlet UIView *wrongClassView;
@property (nonatomic, retain) IBOutlet UIView *tooLowLevelView;
@property (nonatomic, retain) IBOutlet UIButton *buyButton;
@property (nonatomic, retain) IBOutlet UILabel *buyLabel;

@property (nonatomic, retain) IBOutlet LoadingView *loadingView;

+ (EquipMenuController *)sharedEquipMenuController;
+ (void) displayViewForEquip:(int)equipId;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

- (void) updateForEquip:(int)equipId;
- (void) receivedArmoryResponse;
- (void) displayLoadingView;
- (void) removeLoadingView;

@end
