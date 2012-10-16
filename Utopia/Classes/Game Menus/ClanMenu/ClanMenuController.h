//
//  ClanMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "LeaderboardController.h"
#import "NibUtils.h"
#import "ClanMenus.h"

// Can't reuse internal enum names..
typedef LeaderboardBarButton ClanBarButton;

typedef enum {
  kMyClan = 1,
  kBrowseClans,
  kAboutClans,
  kCreateClan
} ClanState;

@interface UIView (WakeupAndCleanup)

- (void) wakeup;
- (void) cleanup;

@end

@interface ClanTopBar : UIView {
  BOOL _trackingButton1;
  BOOL _trackingButton2;
  BOOL _trackingButton3;
  
  int _clickedButtons;
}

@property (nonatomic, retain) IBOutlet UILabel *button1Label;
@property (nonatomic, retain) IBOutlet UILabel *button2Label;
@property (nonatomic, retain) IBOutlet UILabel *button3Label;

@property (nonatomic, retain) IBOutlet UIImageView *button1;
@property (nonatomic, retain) IBOutlet UIImageView *button2;
@property (nonatomic, retain) IBOutlet UIImageView *button3;

@property (nonatomic, retain) IBOutlet UIImageView *buttonBgd1;
@property (nonatomic, retain) IBOutlet UIImageView *buttonBgd2;
@property (nonatomic, retain) IBOutlet UIImageView *buttonBgd3;

- (void) loadMyClanConfiguration;
- (void) loadBrowseClanConfiguration;
- (void) loadViewClanConfiguration;

@end

@interface ClanBar : UIView {
  BOOL _trackingButton1;
  BOOL _trackingButton2;
  BOOL _trackingButton3;
  BOOL _trackingButton4;
  
  int _clickedButtons;
}

@property (nonatomic, retain) IBOutlet UIImageView *button1Icon;
@property (nonatomic, retain) IBOutlet UIImageView *button2Icon;
@property (nonatomic, retain) IBOutlet UIImageView *button3Icon;
@property (nonatomic, retain) IBOutlet UIImageView *button4Icon;

@property (nonatomic, retain) IBOutlet UILabel *button1Label;
@property (nonatomic, retain) IBOutlet UILabel *button2Label;
@property (nonatomic, retain) IBOutlet UILabel *button3Label;
@property (nonatomic, retain) IBOutlet UILabel *button4Label;

@property (nonatomic, retain) IBOutlet UIImageView *button1;
@property (nonatomic, retain) IBOutlet UIImageView *button2;
@property (nonatomic, retain) IBOutlet UIImageView *button3;
@property (nonatomic, retain) IBOutlet UIImageView *button4;

@end

@interface ClanMenuController : UIViewController {
  int _browsingClanId;
  ClanBarButton _lastButton;
  ClanBarButton _lastBrowseButton;
  int _loadingTag;
}

@property (nonatomic, assign) ClanState state;
@property (nonatomic, retain) FullClanProtoWithClanSize *myClan;
@property (nonatomic, retain) NSMutableArray *myClanMembers;

@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet ClanBar *clanBar;
@property (nonatomic, retain) IBOutlet ClanCreateView *clanCreateView;
@property (nonatomic, retain) IBOutlet ClanMembersView *membersView;
@property (nonatomic, retain) IBOutlet ClanInfoView *clanInfoView;
@property (nonatomic, retain) IBOutlet ClanBrowseView *clanBrowseView;
@property (nonatomic, retain) IBOutlet ClanBoardView *clanBoardView;
@property (nonatomic, retain) IBOutlet UIView *clanAboutView;

@property (nonatomic, retain) IBOutlet UIView *goldView;
@property (nonatomic, retain) IBOutlet UIView *editView;
@property (nonatomic, retain) IBOutlet UIView *backView;

@property (nonatomic, retain) IBOutlet UILabel *editLabel;
@property (nonatomic, retain) IBOutlet UILabel *backLabel;
@property (nonatomic, retain) IBOutlet UILabel *goldLabel;

@property (nonatomic, retain) IBOutlet ClanTopBar *topBar;
@property (nonatomic, retain) IBOutlet ClanTopBar *secondTopBar;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

@property (nonatomic, retain) IBOutlet LoadingView *loadingView;

- (void) receivedClanCreateResponse:(CreateClanResponseProto *)proto;
- (void) receivedRetrieveClanInfoResponse:(RetrieveClanInfoResponseProto *)proto;
- (void) receivedRequestJoinClanResponse:(RequestJoinClanResponseProto *)proto;
- (void) receivedRetractRequestJoinClanResponse:(RetractRequestJoinClanResponseProto *)proto;
- (void) receivedRejectOrAcceptResponse:(ApproveOrRejectRequestToJoinClanResponseProto *)proto;
- (void) receivedTransferOwnershipResponse:(TransferClanOwnershipResponseProto *)proto;
- (void) receivedChangeDescriptionResponse:(ChangeClanDescriptionResponseProto *)proto;
- (void) receivedLeaveResponse:(LeaveClanResponseProto *)proto;
- (void) receivedBootPlayerResponse:(BootPlayerFromClanResponseProto *)proto;
- (void) receivedWallPosts:(RetrieveClanBulletinPostsResponseProto *)proto;
- (void) receivedPostOnWall:(PostOnClanBulletinResponseProto *)proto;

- (void) topBarButtonClicked:(ClanBarButton)button;

- (void) viewClan:(FullClanProtoWithClanSize *)clan;

- (void) loadTransferOwnership;
- (void) loadForClan:(MinimumClanProto *)clan;

- (void) updateGoldLabel;

- (void) beginLoading:(int)tag;
- (void) stopLoading:(int)tag;

- (void) close;

+ (BOOL) isInitialized;
+ (ClanMenuController *) sharedClanMenuController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

@end
