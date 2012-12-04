//
//  BossEventMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/30/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "NibUtils.h"

@interface BossEventCard : UIView

@property (nonatomic, retain) IBOutlet UIImageView *tagIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet EquipButton *equipIcon;
@property (nonatomic, retain) IBOutlet UILabel *attackLabel;
@property (nonatomic, retain) IBOutlet UILabel *defenseLabel;

@end

@interface BossEventMenuController : UIViewController

@property (nonatomic, retain) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *headerImageView;

@property (nonatomic, retain) IBOutlet BossEventCard *leftCard;
@property (nonatomic, retain) IBOutlet BossEventCard *middleCard;
@property (nonatomic, retain) IBOutlet BossEventCard *rightCard;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) NSTimer *timer;

- (void) loadForCurrentEvent;
- (void) updateLabels;

- (IBAction)visitBossClicked:(id)sender;

+ (BossEventMenuController *) sharedBossEventMenuController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

@end
