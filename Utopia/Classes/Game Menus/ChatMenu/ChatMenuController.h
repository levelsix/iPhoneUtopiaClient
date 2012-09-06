//
//  ChatMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 8/28/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

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

@property (nonatomic, retain) ChatMessage *chatMessage;

@end

@interface ChatMenuController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet ChatCell *chatCell;

@property (nonatomic, retain) IBOutlet UITableView *chatTable;
@property (nonatomic, retain) IBOutlet UILabel *numChatsLabel;

@property (nonatomic, retain) IBOutlet UIView *bottomView;
@property (nonatomic, retain) IBOutlet UITextField *postTextField;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

+ (ChatMenuController *) sharedChatMenuController;
+ (void) purgeSingleton;
+ (void) displayView;
+ (void) removeView;
+ (BOOL) isInitialized;

- (void) updateNumChatsLabel;

@end
