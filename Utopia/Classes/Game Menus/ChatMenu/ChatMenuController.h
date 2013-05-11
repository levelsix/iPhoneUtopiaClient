//
//  ChatMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/28/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"
#import "LeaderboardController.h"
#import "Protocols.pb.h"

typedef enum {
  kChatStateGlobal = 1,
  kChatStateClan,
  kChatStatePrivate
} ChatState;

@interface ChatTopBar : UIView {
  BOOL _trackingButton1;
  BOOL _trackingButton2;
  BOOL _trackingButton3;
  
  int _clickedButtons;
}

@property (nonatomic, retain) IBOutlet UIImageView *button1;
@property (nonatomic, retain) IBOutlet UIImageView *button2;
@property (nonatomic, retain) IBOutlet UIImageView *button3;

@property (nonatomic, retain) IBOutlet UILabel *button1Label;
@property (nonatomic, retain) IBOutlet UILabel *button2Label;
@property (nonatomic, retain) IBOutlet UILabel *button3Label;

@property (nonatomic, retain) IBOutlet UIView *clanBadgeView;
@property (nonatomic, retain) IBOutlet UILabel *clanBadgeLabel;
@property (nonatomic, retain) IBOutlet UIView *privateBadgeView;
@property (nonatomic, retain) IBOutlet UILabel *privateBadgeLabel;

@end

@interface PrivateChatCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *textLabel2;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *typeImage;
@property (nonatomic, retain) IBOutlet UIImageView *blueCircle;

@property (nonatomic, retain) PrivateChatPostProto *privateChat;

@end

@interface PrivateChatView : UIView <UITableViewDataSource>

@property (nonatomic, retain) IBOutlet PrivateChatCell *chatCell;
@property (nonatomic, retain) IBOutlet UITableView *privateChatTable;

@end

@interface ChatCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *bubbleBotLeft;
@property (nonatomic, retain) IBOutlet UIImageView *bubbleBotMid;
@property (nonatomic, retain) IBOutlet UIImageView *bubbleBotRight;
@property (nonatomic, retain) IBOutlet UIImageView *bubbleMidLeft;
@property (nonatomic, retain) IBOutlet UIImageView *bubbleMidMid;
@property (nonatomic, retain) IBOutlet UIImageView *bubbleMidRight;
@property (nonatomic, retain) IBOutlet UIImageView *bubbleTopLeft;
@property (nonatomic, retain) IBOutlet UIImageView *bubbleTopMid;
@property (nonatomic, retain) IBOutlet UIImageView *bubbleTopRight;
@property (nonatomic, retain) IBOutlet UIView *bubbleView;

@property (nonatomic, retain) IBOutlet UIImageView *chatLine;
@property (nonatomic, retain) IBOutlet UIButton *nameButton;
@property (nonatomic, retain) IBOutlet UILabel *textLabel;
@property (nonatomic, retain) IBOutlet UIImageView *typeCircle;
@property (nonatomic, retain) IBOutlet UIButton *typeIcon;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

@property (nonatomic, retain) ChatMessage *chatMessage;

@end

@interface ChatMenuController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
  int _otherUserId;
  BOOL _loading;
}

@property (nonatomic, assign) ChatState state;

@property (nonatomic, retain) IBOutlet ChatCell *chatCell;

@property (nonatomic, retain) IBOutlet UITableView *chatTable;
@property (nonatomic, retain) IBOutlet UILabel *numChatsLabel;

@property (nonatomic, retain) IBOutlet UIView *bottomView;
@property (nonatomic, retain) IBOutlet UITextField *postTextField;

@property (nonatomic, retain) IBOutlet ChatTopBar *topBar;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet PrivateChatView *privateChatView;
@property (nonatomic, retain) IBOutlet UIView *chatTableView;
@property (nonatomic, retain) IBOutlet UIView *backView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, retain) NSMutableArray *privateChatMsgs;

@property (nonatomic, retain) MinimumUserProto *clickedMinUser;
@property (nonatomic, retain) IBOutlet UIView *chatPopup;

+ (ChatMenuController *) sharedChatMenuController;
+ (void) purgeSingleton;
+ (void) displayView;
+ (void) removeView;
+ (BOOL) isInitialized;

- (void) receivedRetrievePrivateChats:(RetrievePrivateChatPostsResponseProto *)proto;
- (void) receivedPrivateChatPost:(PrivateChatPostResponseProto *)proto;

- (void) loadPrivateChatsForUserId:(int)userId animated:(BOOL)animated;

- (void) updateNumChatsLabel;

- (void) close;

@end
