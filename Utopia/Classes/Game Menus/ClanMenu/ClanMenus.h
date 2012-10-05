//
//  ClanMenus.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/11/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "Protocols.pb.h"
#import "NibUtils.h"

@interface ClanCreateView : UIView <UITextFieldDelegate> {
  BOOL _goToMyClan;
}

@property (nonatomic, retain) IBOutlet UITextField *nameField;
@property (nonatomic, retain) IBOutlet UITextField *tagField;

@property (nonatomic, retain) IBOutlet UILabel *createClanGoldLabel;
@property (nonatomic, retain) IBOutlet UILabel *maxTagLengthLabel;

@property (nonatomic, retain) IBOutlet UILabel *headerLabel;
@property (nonatomic, retain) IBOutlet UILabel *subheaderLabel;
@property (nonatomic, retain) IBOutlet UILabel *buttonLabel;

// These two views get substituted in and out
@property (nonatomic, retain) IBOutlet UIView *clanCreationView;
@property (nonatomic, retain) IBOutlet UIView *notificationView;

- (void) loadClanCreationView;
- (void) loadAfterClanCreationView:(NSString *)clanName;
- (void) loadAlreadyInClanView;
- (void) loadNotInClanView;

@end

@interface ClanMemberCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIButton *userIcon;
@property (nonatomic, retain) IBOutlet UIButton *nameButton;
@property (nonatomic, retain) IBOutlet UILabel *typeLabel;
@property (nonatomic, retain) IBOutlet UILabel *battleRecordLabel;
@property (nonatomic, retain) IBOutlet UIView *editMemberView;
@property (nonatomic, retain) IBOutlet UIView *respondInviteView;

@property (nonatomic, retain) MinimumUserProtoForClans *user;

@end

@interface ClanMembersView : UIView <UITableViewDelegate, UITableViewDataSource> {
  int leaderId;
  BOOL myClan;
}

@property (nonatomic, assign) BOOL editModeOn;
@property (nonatomic, assign) int clanId;
@property (nonatomic, retain) NSArray *members;
@property (nonatomic, retain) NSArray *requesters;
@property (nonatomic, retain) MinimumUserProtoForClans *leader;
@property (nonatomic, retain) IBOutlet UITableView *membersTable;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) IBOutlet UIView *leaderHeader;
@property (nonatomic, retain) IBOutlet UIView *requestersHeader;
@property (nonatomic, retain) IBOutlet UIView *membersHeader;

@property (nonatomic, retain) IBOutlet ClanMemberCell *memberCell;

- (void) preloadMembersForClan:(int)ci leader:(int)leaderId;
- (void) loadForMembers:(NSArray *)m isMyClan:(BOOL)isMyClan;

- (void) turnOnEditing;
- (void) turnOffEditing;

@end

typedef enum {
  kBrowseLegion,
  kBrowseAlliance,
  kBrowseSearch
} ClanBrowseState;

@interface BrowseClanCell : UITableViewCell

@property (nonatomic, retain) FullClanProtoWithClanSize *clan;
@property (nonatomic, retain) IBOutlet UILabel *topLabel;
@property (nonatomic, retain) IBOutlet UILabel *botLabel;

@end

@interface ClanBrowseView : UIView <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
  BOOL isSearching;
  BOOL _reachedEnd;
}

@property (nonatomic, assign) ClanBrowseState state;
@property (nonatomic, retain) NSMutableArray *legionClans;
@property (nonatomic, retain) NSMutableArray *allianceClans;
@property (nonatomic, retain) NSMutableArray *searchClans;
@property (nonatomic, retain) IBOutlet UITableView *browseClansTable;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) IBOutlet BrowseClanCell *clanCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *searchCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *loadingCell;

@property (nonatomic, retain) NSString *searchString;

@property (nonatomic, assign) BOOL shouldReload;

- (void) loadClans:(NSArray *)clans isForSearch:(BOOL)search;

@end

@interface ClanInfoView : UIView <UITextViewDelegate>

@property (nonatomic, assign) BOOL canEdit;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UILabel *membersLabel;
@property (nonatomic, retain) IBOutlet UIButton *typeIcon;
@property (nonatomic, retain) IBOutlet UIButton *leaderButton;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *foundedLabel;
@property (nonatomic, retain) IBOutlet UILabel *bottomButtonLabel;
@property (nonatomic, retain) IBOutlet UIView *bottomButtonView;

@property (nonatomic, retain) FullClanProtoWithClanSize *clan;

- (void) loadForClan:(FullClanProtoWithClanSize *)c;

@end

@interface ClanBoardCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIButton *playerIcon;
@property (nonatomic, retain) IBOutlet UIButton *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *postLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

@property (nonatomic, retain) CAGradientLayer *gradientLayer;

@end

@interface ClanBoardView : UIView <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) IBOutlet NiceFontTextField *boardTextField;
@property (nonatomic, retain) IBOutlet UITableView *boardTableView;
@property (nonatomic, retain) IBOutlet ClanBoardCell *boardCell;

@property (nonatomic, retain) NSMutableArray *boardPosts;

- (void) endEditing;
- (void) displayNewBoardPost;

@end

@interface BrowseSearchCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UITextField *textField;

@end