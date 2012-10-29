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

@interface DialogMenuController : UIViewController <UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet LoadingView *loadingView;

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIView *speechBubble;
@property (nonatomic, retain) IBOutlet UIImageView *girlImageView;

+ (void) displayViewForText:(NSString *)str;
+ (void) closeView;
- (void) stopLoading:(BOOL)continueTut;
- (void) createUser;

+ (DialogMenuController *) sharedDialogMenuController;
- (void) receivedUserCreateResponse:(UserCreateResponseProto *)ucrp;

@end
