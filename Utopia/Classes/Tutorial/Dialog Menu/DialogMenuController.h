//
//  DialogMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"

@interface DialogMenuLoadingView : UIView

@property (nonatomic, retain) IBOutlet UIView *darkView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *actIndView;

@end

@interface DialogMenuController : UIViewController <UITextFieldDelegate> {
  BOOL _isDisplayingLoadingView;
}

@property (nonatomic, retain) IBOutlet DialogMenuLoadingView *loadingView;

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIView *speechBubble;
@property (nonatomic, retain) IBOutlet UIImageView *girlImageView;

+ (void) displayViewForText:(NSString *)str;
+ (void) closeView;
- (void) stopLoading;
- (void) createUser;

+ (DialogMenuController *) sharedDialogMenuController;
- (void) receivedUserCreateResponse:(UserCreateResponseProto *)ucrp;

@end
