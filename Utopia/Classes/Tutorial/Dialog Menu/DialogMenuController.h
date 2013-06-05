//
//  DialogMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "NibUtils.h"

#define SPEECH_BUBBLE_SCALE 0.7f
#define SPEECH_BUBBLE_ANIMATION_DURATION 0.2f

@interface DialogMenuController : UIViewController <UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet LoadingView *loadingView;

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIView *speechBubble;
@property (nonatomic, retain) IBOutlet UIImageView *girlImageView;

@property (nonatomic, assign) BOOL waitingForUserCreate;
@property (nonatomic, assign) BOOL waitingForStartup;

+ (void) displayViewForText:(NSString *)str;
+ (void) closeView;
- (void) stopLoading:(BOOL)continueTut;
- (void) createUser;
- (void) flipView;

+ (DialogMenuController *) sharedDialogMenuController;
- (void) receivedUserCreateResponse:(UserCreateResponseProto *)ucrp;

@end
