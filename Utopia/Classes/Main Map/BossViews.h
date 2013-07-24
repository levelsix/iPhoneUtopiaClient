//
//  BossViews.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/13/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "NibUtils.h"
#import "UserData.h"

@interface BossUnlockedView : UIView

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UIImageView *tutGirlImage;
@property (nonatomic, retain) IBOutlet UIImageView *unlockedBossImage;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

@property (nonatomic, retain) FullBossProto *boss;

- (void) displayForBoss:(FullBossProto *)boss;

- (IBAction)visitClicked:(id)sender;
- (IBAction)closeClicked:(id)sender;

@end

@interface CityBossView : UIView

@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *regStamLabel;
@property (nonatomic, retain) IBOutlet UILabel *regDmgLabel;
@property (nonatomic, retain) IBOutlet UILabel *pwrStamLabel;
@property (nonatomic, retain) IBOutlet UILabel *pwrDmgLabel;

@property (nonatomic, retain) IBOutlet ProgressBar *healthBar;

@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, retain) UserBoss *boss;

- (void) updateForUserBoss:(UserBoss *)boss;

@end

@interface BossInfoView : UIView

@property (nonatomic, retain) IBOutlet UILabel *tasksLabel;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

- (void) updateForCity:(int)cityId;

@end
