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
  id _target;
  SEL _selector;
  int _progress;
  
  BOOL _isDisplayingLoadingView;
}

@property (nonatomic, retain) IBOutlet DialogMenuLoadingView *loadingView;

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIImageView *progressBar;
@property (nonatomic, retain) IBOutlet UIImageView *girlImageView;
@property (nonatomic, assign) int progress;

@property (nonatomic, retain) IBOutlet UIView *textView;
@property (nonatomic, retain) IBOutlet UIView *retryView;
@property (nonatomic, retain) IBOutlet UIView *referralView;
@property (nonatomic, retain) IBOutlet UITextField *referralTextField;

+ (void) displayViewForBeginningText:(NSString *)str callbackTarget:(id)t action:(SEL)s;
+ (void) displayViewForText:(NSString *)str callbackTarget:(id)t action:(SEL)s;
+ (void) displayViewForReferral;
+ (void) closeView;
+ (void) incrementProgress;

+ (DialogMenuController *) sharedDialogMenuController;
- (void) receivedUserCreateResponse:(UserCreateResponseProto *)ucrp;

@end
