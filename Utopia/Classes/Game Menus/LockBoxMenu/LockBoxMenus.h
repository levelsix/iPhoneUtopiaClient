//
//  LockBoxMenus.h
//  Utopia
//
//  Created by Ashwin Kamath on 10/1/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.pb.h"
#import "BattleLayer.h"

@interface LockBoxItemView : UIView {
  int _itemId;
}

@property (nonatomic, assign) int itemId;
@property (nonatomic, assign) int quantity;

@property (nonatomic, retain) IBOutlet UIImageView *itemIcon;
@property (nonatomic, retain) IBOutlet UILabel *quantityLabel;

@property (nonatomic, retain) UIImageView *maskedItemIcon;

- (void) loadForImage:(NSString *)img quantity:(int)quantity itemId:(int)itemId;

@end

@interface LockBoxStatusView : UIView

@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UIImageView *checkIcon;
@property (nonatomic, retain) IBOutlet UIImageView *xIcon;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

- (void) displayLockBoxSuccess;
- (void) displayLockBoxFailed;
- (void) displayCheckingLockBox;

@end

@interface LockBoxPickView : UIView {
  BOOL _resetPickTimer;
  BOOL _pickingLock;
  BOOL _shouldShake;
  CGRect _oldChestFrame;
  CGRect _middleChestFrame;
  
  LockBoxItemProto *_toFlyDown;
  FullUserEquipProto *_prizeEquip;
}

@property (nonatomic, retain) IBOutlet UIImageView *chestIcon;

@property (nonatomic, retain) IBOutlet UILabel *freeChanceLabel;
@property (nonatomic, retain) IBOutlet UILabel *freePriceLabel;
@property (nonatomic, retain) IBOutlet UILabel *silverChanceLabel;
@property (nonatomic, retain) IBOutlet UILabel *silverPriceLabel;
@property (nonatomic, retain) IBOutlet UILabel *goldChanceLabel;
@property (nonatomic, retain) IBOutlet UILabel *goldPriceLabel;

@property (nonatomic, retain) IBOutlet LockBoxStatusView *statusView;
@property (nonatomic, retain) IBOutlet UIView *pickOptionsView;
@property (nonatomic, retain) IBOutlet UIView *middleChestView;
@property (nonatomic, retain) IBOutlet UIView *okayView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

- (void) loadForView:(UIView *)view chestImage:(NSString *)chestImage reset:(BOOL)reset;

- (void) pickFailed;
- (void) pickSucceeded:(LockBoxItemProto *)proto;
- (void) receivedPickLockResponse:(PickLockBoxResponseProto *)proto;

@end

@interface LockBoxPrizeView : UIView {
  NSArray *oldRects;
}

@property (nonatomic, retain) IBOutlet UIImageView *imgView1;
@property (nonatomic, retain) IBOutlet UIImageView *imgView2;
@property (nonatomic, retain) IBOutlet UIImageView *imgView3;
@property (nonatomic, retain) IBOutlet UIImageView *imgView4;
@property (nonatomic, retain) IBOutlet UIImageView *imgView5;

@property (nonatomic, retain) IBOutlet UIImageView *whiteCircle;
@property (nonatomic, retain) IBOutlet UIImageView *equipIcon;

@property (nonatomic, retain) IBOutlet StolenEquipView *stolenEquipView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

- (void) beginPrizeAnimationForImageView:(NSArray *)startImgViews prize:(FullUserEquipProto *)fuep;

@end

@interface LockBoxUnusedItemsView : UIView

@property (nonatomic, retain) IBOutletCollection(LockBoxItemView) NSArray *leftItemViews;
@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray *leftLabels;
@property (nonatomic, retain) IBOutletCollection(LockBoxItemView) NSArray *rightItemViews;

@property (nonatomic, retain) IBOutlet UILabel *silverChestsLabel;
@property (nonatomic, retain) IBOutlet UILabel *goldChestsLabel;
@property (nonatomic, retain) IBOutlet UILabel *cantBuyLabel;
@property (nonatomic, retain) IBOutlet UIView *buttonView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet LoadingView *loadingView;

- (IBAction)openChestsClicked:(id)sender;

- (void) displayForCurrentLockBoxEvent;

@end

@interface LockBoxInfoView : UIView

@property (nonatomic, retain) IBOutlet UILabel *topLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *equipNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;

@property (nonatomic, retain) IBOutlet UIImageView *item1Icon;
@property (nonatomic, retain) IBOutlet UIImageView *item2Icon;
@property (nonatomic, retain) IBOutlet UIImageView *item3Icon;
@property (nonatomic, retain) IBOutlet UIImageView *item4Icon;
@property (nonatomic, retain) IBOutlet UIImageView *item5Icon;
@property (nonatomic, retain) IBOutlet EquipButton *prizeEquipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *descriptionImage;
@property (nonatomic, retain) IBOutlet UIImageView *tagIcon;

@property (nonatomic, retain) IBOutlet LockBoxUnusedItemsView *unusedItemsView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

- (void) displayForCurrentLockBoxEvent;

- (IBAction)closeClicked:(id)sender;

@end
