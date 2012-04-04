//
//  DialogMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialogMenuController : UIViewController <UITextFieldDelegate> {
  id _target;
  SEL _selector;
  int _progress;
}

@property (nonatomic, retain) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIImageView *progressBar;
@property (nonatomic, assign) int progress;

@property (nonatomic, retain) IBOutlet UIView *textView;
@property (nonatomic, retain) IBOutlet UIView *referralView;
@property (nonatomic, retain) IBOutlet UITextField *referralTextField;

+ (void) displayViewForText:(NSString *)str callbackTarget:(id)t action:(SEL)s;
+ (void) displayViewForReferral;
+ (void) closeView;
+ (void) incrementProgress;

@end
