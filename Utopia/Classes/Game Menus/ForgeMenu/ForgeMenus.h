//
//  ForgeMenus.h
//  Utopia
//
//  Created by Ashwin Kamath on 7/18/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "GameState.h"
#import "Globals.h"
#import "LeaderboardController.h"

@interface ForgeSlotTopBar : UIView {
  BOOL _trackingButton1;
  BOOL _trackingButton2;
  BOOL _trackingButton3;
  
  int _clickedButtons;
}

@property (nonatomic, retain) IBOutlet UIImageView *button1;
@property (nonatomic, retain) IBOutlet UIImageView *button2;
@property (nonatomic, retain) IBOutlet UIImageView *button3;

- (void) updateForSlotNum:(int)slotNum;

@end

@interface ForgeItem : NSObject

@property (nonatomic, assign) int equipId;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int quantity;
@property (nonatomic, assign) int isForging;

@end

@interface ForgeItemView : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;
@property (nonatomic, retain) IBOutlet UILabel *quantityLabel;
@property (nonatomic, retain) IBOutlet UIImageView *equipIcon;
@property (nonatomic, retain) IBOutlet UIImageView *bgdImage;
@property (nonatomic, retain) IBOutlet UIImageView *forgingTag;
@property (nonatomic, retain) IBOutlet EquipLevelIcon *levelIcon;

@property (nonatomic, retain) IBOutlet ProgressBar *topProgressBar;
@property (nonatomic, retain) IBOutlet ProgressBar *bottomProgressBar;
@property (nonatomic, retain) IBOutlet EnhancementLevelIcon *enhanceLevelIcon;

@property (nonatomic, retain) IBOutlet UIView *forgeView;
@property (nonatomic, retain) IBOutlet UIView *enhanceView;

@property (nonatomic, retain) ForgeItem *forgeItem;
@property (nonatomic, retain) UserEquip *userEquip;

- (void) loadForUserEquip:(UserEquip *)ue;
- (void) loadForForgeItem:(ForgeItem *)fi;

@end

@interface ForgeProgressView : UIView

@property (nonatomic, retain) IBOutlet UILabel *timeLeftLabel;
@property (nonatomic, retain) IBOutlet ProgressBar *progressBar;

@property (nonatomic, retain) NSTimer *timer;

- (void) beginAnimatingForSlot:(int)slot;
- (void) stopAnimating;

@end

@interface ForgeStatusView : UIView

@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UIImageView *checkIcon;
@property (nonatomic, retain) IBOutlet UIImageView *xIcon;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

- (void) displayAttemptComplete;
- (void) displayForgeSuccess;
- (void) displayForgeFailed;
- (void) displayCheckingForge;

@end