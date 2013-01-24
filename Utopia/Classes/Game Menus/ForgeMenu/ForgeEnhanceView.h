//
//  ForgeEnhanceView.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/14/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "ForgeMenus.h"
#import "NibUtils.h"

@interface ForgeEnhanceItemView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *equipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *borderIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;
@property (nonatomic, retain) IBOutlet EnhancementLevelIcon *enhanceLevelIcon;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet ProgressBar *topProgressBar;
@property (nonatomic, retain) IBOutlet ProgressBar *bottomProgressBar;

@property (nonatomic, retain) IBOutlet UIView *checkmarkBox;
@property (nonatomic, retain) IBOutlet UIView *checkmark;

@property (nonatomic, retain) IBOutlet UIView *itemChosenView;
@property (nonatomic, retain) IBOutlet UIView *itemNotChosenView;

@property (nonatomic, retain) UserEquip *userEquip;

@end

@interface ForgeEnhanceView : UIView <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *enhanceTableView;
@property (nonatomic, retain) IBOutlet ForgeItemView *itemView;

@property (nonatomic, retain) IBOutlet ForgeEnhanceItemView *enhancingView;
@property (nonatomic, retain) IBOutletCollection(ForgeEnhanceItemView) NSArray *feederViews;
@property (nonatomic, retain) IBOutlet ForgeEnhanceItemView *movingView;

@property (nonatomic, retain) IBOutlet UIView *feederContainerView;

@property (nonatomic, retain) IBOutlet ForgeEnhanceItemView *animatedItemView;

@property (nonatomic, retain) IBOutlet UILabel *buttonLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

@property (nonatomic, retain) NSArray *userEquips;

@property (nonatomic, retain) NSTimer *timer;

- (void) reload;

- (void) receivedSubmitEquipEnhancementResponse:(SubmitEquipEnhancementResponseProto *)proto;
- (void) receivedCollectEquipEnhancementResponse:(CollectEquipEnhancementResponseProto *)proto;

@end