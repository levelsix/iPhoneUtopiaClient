//
//  MentorMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "LeaderboardController.h"
#import "NibUtils.h"
#import "MentorMenus.h"
#import "MentorTowerTab.h"
#import "MentorTowerScoresTab.h"

typedef enum {
  kNewPlayers = 1,
  kMentees,
  kMentors,
  kApplicants,
  kAbout
} MentorState;

@interface MentorBar : UIView {
  BOOL _trackingButton1;
  BOOL _trackingButton2;
  BOOL _trackingButton3;
  BOOL _trackingButton4;
  BOOL _trackingButton5;
  
  int _clickedButtons;
}

@property (nonatomic, retain) IBOutlet UIImageView *button1Icon;
@property (nonatomic, retain) IBOutlet UIImageView *button2Icon;
@property (nonatomic, retain) IBOutlet UIImageView *button3Icon;
@property (nonatomic, retain) IBOutlet UIImageView *button4Icon;
@property (nonatomic, retain) IBOutlet UIImageView *button5Icon;

@property (nonatomic, retain) IBOutlet UILabel *button1Label;
@property (nonatomic, retain) IBOutlet UILabel *button2Label;
@property (nonatomic, retain) IBOutlet UILabel *button3Label;
@property (nonatomic, retain) IBOutlet UILabel *button4Label;
@property (nonatomic, retain) IBOutlet UILabel *button5Label;

@property (nonatomic, retain) IBOutlet UIImageView *button1;
@property (nonatomic, retain) IBOutlet UIImageView *button2;
@property (nonatomic, retain) IBOutlet UIImageView *button3;
@property (nonatomic, retain) IBOutlet UIImageView *button4;
@property (nonatomic, retain) IBOutlet UIImageView *button5;

@end

@interface MentorMenuController : UIViewController {
  int _browsingMentorId;
  MentorBarButton _lastButton;
  MentorBarButton _lastBrowseButton;
  int _loadingTag;
}

@property (nonatomic, assign) MentorState state;

@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet MentorBar *mentorBar;

@property (nonatomic, retain) IBOutlet UIView *backView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

@property (nonatomic, retain) IBOutlet LoadingView *loadingView;

- (void) close;

+ (BOOL) isInitialized;
+ (MentorMenuController *) sharedMentorMenuController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

@end
