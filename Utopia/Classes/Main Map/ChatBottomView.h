//
//  ChatBottomView.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/5/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@interface ChatLineView : UIView

@property (nonatomic, retain) IBOutlet UILabel *factionLabel;
@property (nonatomic, retain) IBOutlet UILabel *textLabel;

@property (nonatomic, assign) BOOL hasBeenUsed;

@end

@interface ChatBottomView : UIView

@property (nonatomic, retain) IBOutlet UIView *mainView;

@property (nonatomic, retain) IBOutlet ChatLineView *chatView1;
@property (nonatomic, retain) IBOutlet ChatLineView *chatView2;
@property (nonatomic, retain) IBOutlet ChatLineView *chatView3;

@property (nonatomic, retain) IBOutlet UIImageView *globalIcon;
@property (nonatomic, retain) IBOutlet UIImageView *clanIcon;

// Determines if we are on global or clan chat
@property (nonatomic, assign) BOOL isGlobal;

- (void) addChat:(ChatMessage *)chat;

@end
