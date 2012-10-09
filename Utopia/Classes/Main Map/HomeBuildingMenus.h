//
//  HomeBuildingMenus.h
//  Utopia
//
//  Created by Ashwin Kamath on 5/24/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "NibUtils.h"
#import "UserData.h"

#define PROGRESS_BAR_SPEED 2.f

@interface HomeBuildingMenu : UIView

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *incomeLabel;
@property (nonatomic, retain) IBOutlet UILabel *rankLabel;

- (void) updateForUserStruct:(UserStruct *)us;

@end

@interface HomeBuildingCollectMenu : UIView

@property (nonatomic, retain) IBOutlet UILabel *coinsLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet ProgressBar *progressBar;

@property (nonatomic, retain) UserStruct *userStruct;
@property (nonatomic, retain) NSTimer *timer;

- (void) updateForUserStruct:(UserStruct *)us;

@end

@interface UpgradeBuildingMenu : UIView

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *currentIncomeLabel;
@property (nonatomic, retain) IBOutlet UILabel *upgradedIncomeLabel;
@property (nonatomic, retain) IBOutlet UILabel *upgradeTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *upgradePriceLabel;
@property (nonatomic, retain) IBOutlet UIImageView *structIcon;
@property (nonatomic, retain) IBOutlet UIImageView *coinIcon;

@property (nonatomic, retain) IBOutlet UILabel *timeLeftLabel;
@property (nonatomic, retain) IBOutlet ProgressBar *progressBar;

@property (nonatomic, retain) IBOutlet UIView *hazardSign;
@property (nonatomic, retain) IBOutlet UIView *upgradingMiddleView;
@property (nonatomic, retain) IBOutlet UIView *upgradingBottomView;
@property (nonatomic, retain) IBOutlet UIView *notUpgradingMiddleView;
@property (nonatomic, retain) IBOutlet UIView *notUpgradingBottomView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) UserStruct *userStruct;
@property (nonatomic, retain) NSTimer *timer;

- (void) displayForUserStruct:(UserStruct *)us;
- (void) finishNow:(void(^)(void))completed;

- (IBAction)closeClicked:(id)sender;

@end

@interface ExpansionView : UIView {
  ExpansionDirection _direction;
}

@property (nonatomic, retain) IBOutlet UIImageView *farLeftArrow;
@property (nonatomic, retain) IBOutlet UIImageView *farRightArrow;
@property (nonatomic, retain) IBOutlet UIImageView *nearLeftArrow;
@property (nonatomic, retain) IBOutlet UIImageView *nearRightArrow;
@property (nonatomic, retain) IBOutlet UIImageView *expandingSign;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *buttonLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLeftLabel;
@property (nonatomic, retain) IBOutlet UILabel *totalTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel *costLabel;

@property (nonatomic, retain) IBOutlet ProgressBar *progressBar;

@property (nonatomic, retain) IBOutlet UIView *expandingView;
@property (nonatomic, retain) IBOutlet UIView *cantExpandView;
@property (nonatomic, retain) IBOutlet UIView *expandNowView;

@property (nonatomic, retain) IBOutlet UIView *bgdView;
@property (nonatomic, retain) IBOutlet UIView *mainView;

@property (nonatomic, retain) NSTimer *timer;

- (void) displayForDirection:(ExpansionDirection)direction;

@end
