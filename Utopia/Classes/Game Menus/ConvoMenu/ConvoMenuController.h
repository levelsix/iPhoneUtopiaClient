//
//  ConvoMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/22/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"

@interface ConvoMenuController : UIViewController {
  int curSpeechSegment;
}

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

// Holds button and "Previous" label
@property (nonatomic, retain) IBOutlet UIView *prevButton;
@property (nonatomic, retain) IBOutlet UIView *nextButton;
@property (nonatomic, retain) IBOutlet UILabel *speakerNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *speechLabel;
@property (nonatomic, retain) IBOutlet UIImageView *speakerImageView;

@property (nonatomic, retain) IBOutlet UIButton *closeButton;

@property (nonatomic, retain) FullQuestProto *quest;

- (void)displayQuestConversationForQuest:(FullQuestProto *)fqp;

+ (ConvoMenuController *)sharedConvoMenuController;
+ (void)displayView;
+ (void)removeView;
+ (void)purgeSingleton;

@end
