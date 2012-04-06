//
//  DialogMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "DialogMenuController.h"
#import "SynthesizeSingleton.h"
#import "cocos2d.h"
#import "NibUtils.h"
#import "OutgoingEventController.h"
#import "TutorialConstants.h"

@implementation DialogMenuController

#define ANIMATION_DURATION 0.5f
#define ANIMATION_VERTICAL_MOVEMENT 124
#define WIN_HEIGHT [[UIScreen mainScreen] applicationFrame].size.width

@synthesize label, progressBar;
@synthesize target = _target;
@synthesize selector = _selector;
@synthesize progress = _progress;
@synthesize textView, referralView;
@synthesize referralTextField;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(DialogMenuController);

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  [self.view addSubview:self.referralView];
  self.referralView.frame = self.textView.frame;
}

- (void) registerCallback:(id)t action:(SEL)s {
  self.target = t;
  self.selector = s;
}

- (void) performCallback {
  // release before performing selector to ensure that if selector sets this,
  // we don't lose information about the new target
  id target = [_target retain];
  SEL selector = _selector;
  self.target = nil;
  self.selector = nil;
  
  [target performSelector:selector];
  
  [target release];
}

+ (void) displayViewForText:(NSString *)str callbackTarget:(id)t action:(SEL)s {
  DialogMenuController *dmc = [DialogMenuController sharedDialogMenuController];
  dmc.label.text = str;
  
  dmc.textView.hidden = NO;
  dmc.referralView.hidden = YES;
  
  [dmc registerCallback:t action:s];
  
  CGRect r = dmc.progressBar.frame;
  r.size.width = 10+43*dmc.progress;
  dmc.progressBar.frame = r;
  
  if (!dmc.view.superview) {
    r = dmc.view.frame;
    r.origin.y = WIN_HEIGHT-r.size.height+ANIMATION_VERTICAL_MOVEMENT;
    dmc.view.frame = r;
    
    [DialogMenuController displayView];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
      CGRect r = dmc.view.frame;
      r.origin.y = WIN_HEIGHT-r.size.height;
      dmc.view.frame = r;
    }];
  }
}

+ (void) displayViewForReferral {
  DialogMenuController *dmc = [DialogMenuController sharedDialogMenuController];
  
  dmc.textView.hidden = YES;
  dmc.referralView.hidden = NO;
  
  CGRect r = dmc.progressBar.frame;
  r.size.width = 10+43*dmc.progress;
  dmc.progressBar.frame = r;
  
  if (!dmc.view.superview) {
    r = dmc.view.frame;
    r.origin.y = WIN_HEIGHT-r.size.height+ANIMATION_VERTICAL_MOVEMENT;
    dmc.view.frame = r;
    
    [DialogMenuController displayView];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
      CGRect r = dmc.view.frame;
      r.origin.y = WIN_HEIGHT-r.size.height;
      dmc.view.frame = r;
    }];
  }
}

+ (void) closeView {
  DialogMenuController *dmc = [DialogMenuController sharedDialogMenuController];
  
  [UIView animateWithDuration:ANIMATION_DURATION animations:^{
    CGRect r = dmc.view.frame;
    r.origin.y = WIN_HEIGHT-r.size.height+ANIMATION_VERTICAL_MOVEMENT;
    dmc.view.frame = r;
  } completion:^(BOOL finished) {
    [dmc.view removeFromSuperview];
    [dmc performCallback];
  }];
}

+ (void) incrementProgress {
  [self sharedDialogMenuController].progress++;
}

- (void) didReceiveMemoryWarning {
  return;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (!textView.hidden) {
    [DialogMenuController closeView];
  } else {
    [referralTextField resignFirstResponder];
  }
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
  [UIView animateWithDuration:0.3f animations:^{
    self.view.center = CGPointMake(self.view.center.x, self.view.center.y-WIN_HEIGHT/2);
  }];
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
  [UIView animateWithDuration:0.3f animations:^{
    self.view.center = CGPointMake(self.view.center.x, self.view.center.y+WIN_HEIGHT/2);
  }];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
  [[(NiceFontTextField *)textField label] setText:str];
  return YES;
}

- (IBAction)enterClicked:(id)sender {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  tc.referralCode = referralTextField.text;
  
  [[OutgoingEventController sharedOutgoingEventController] createUser];
}

- (IBAction)skipClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] createUser];
}

- (void) viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  self.target = nil;
  self.selector = nil;
  self.label = nil;
  self.progressBar = nil;
}

@end
