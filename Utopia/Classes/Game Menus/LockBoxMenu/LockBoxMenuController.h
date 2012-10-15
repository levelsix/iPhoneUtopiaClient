//
//  LockBoxMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/30/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LockBoxMenus.h"

@interface LockBoxMenuController : UIViewController {
  NSArray *itemViews;
}

@property (nonatomic, retain) IBOutlet UILabel *goldLabel;
@property (nonatomic, retain) IBOutlet UILabel *silverLabel;
@property (nonatomic, retain) IBOutlet UILabel *eventTimeLabel;

@property (nonatomic, retain) IBOutlet UILabel *topPickLabel;
@property (nonatomic, retain) IBOutlet UILabel *bottomPickLabel;

@property (nonatomic, retain) IBOutlet UIImageView *chestIcon;
@property (nonatomic, retain) IBOutlet UILabel *numBoxesLabel;

@property (nonatomic, retain) IBOutlet LockBoxItemView *itemView1;
@property (nonatomic, retain) IBOutlet LockBoxItemView *itemView2;
@property (nonatomic, retain) IBOutlet LockBoxItemView *itemView3;
@property (nonatomic, retain) IBOutlet LockBoxItemView *itemView4;
@property (nonatomic, retain) IBOutlet LockBoxItemView *itemView5;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet LockBoxPickView *pickView;
@property (nonatomic, retain) IBOutlet LockBoxPrizeView *prizeView;

@property (nonatomic, retain) IBOutlet LockBoxInfoView *lockBoxInfoView;

@property (nonatomic, retain) NSTimer *timer;

- (void) loadForCurrentEvent;
- (void) updateLabels;
- (void) flyItemToBottom:(LockBoxItemProto *)item prizeEquip:(FullUserEquipProto *)prizeEquip;

- (IBAction)infoClicked:(id)sender;

+ (LockBoxMenuController *) sharedLockBoxMenuController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

@end
