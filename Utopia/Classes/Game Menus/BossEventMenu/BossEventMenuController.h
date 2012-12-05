//
//  BossEventMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/30/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "NibUtils.h"
#import "LeaderboardController.h"

typedef LeaderboardBarButton ChatBarButton;

@interface BossEventTopBar : UIView {
  BOOL _trackingButton1;
  BOOL _trackingButton2;
  
  int _clickedButtons;
}

@property (nonatomic, retain) IBOutlet UIImageView *button1;
@property (nonatomic, retain) IBOutlet UIImageView *button2;

@end

@interface BossEventCard : UIView

@property (nonatomic, retain) IBOutlet UIImageView *tagIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet EquipButton *equipIcon;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;

@end

typedef enum {
  kEventState = 1,
  kInfoState = 2
} BossEventState;

@interface BossEventMenuController : UIViewController

@property (nonatomic, retain) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *headerImageView;

@property (nonatomic, retain) IBOutlet BossEventCard *leftCard;
@property (nonatomic, retain) IBOutlet BossEventCard *middleCard;
@property (nonatomic, retain) IBOutlet BossEventCard *rightCard;

@property (nonatomic, retain) IBOutlet UILabel *infoLabel;

@property (nonatomic, retain) IBOutlet UIView *eventView;
@property (nonatomic, retain) IBOutlet UIView *infoView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, assign) BossEventState state;

- (void) loadForCurrentEvent;
- (void) updateLabels;

- (IBAction)closeClicked:(id)sender;

+ (BossEventMenuController *) sharedBossEventMenuController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

@end
