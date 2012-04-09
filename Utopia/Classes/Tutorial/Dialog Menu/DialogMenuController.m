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
#import "GameState.h"
#import "Globals.h"
#import "TutorialHomeMap.h"

@implementation DialogMenuLoadingView

@synthesize darkView, actIndView;

- (void) awakeFromNib {
  self.darkView.layer.cornerRadius = 10.f;
}

- (void) dealloc {
  self.darkView = nil;
  self.actIndView = nil;
  
  [super dealloc];
}

@end

@implementation DialogMenuController

#define ANIMATION_DURATION 0.5f
#define ANIMATION_VERTICAL_MOVEMENT 124
#define WIN_HEIGHT [[UIScreen mainScreen] applicationFrame].size.width

@synthesize nameLabel;
@synthesize girlImageView;
@synthesize loadingView;
@synthesize label, progressBar;
@synthesize target = _target;
@synthesize selector = _selector;
@synthesize progress = _progress;
@synthesize textView, referralView;
@synthesize referralTextField;
@synthesize retryView;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(DialogMenuController);

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  [self.view addSubview:self.referralView];
  self.referralView.frame = self.textView.frame;
  
  CGRect r = loadingView.frame;
  r.origin.y = self.view.frame.size.height - r.size.height;
  loadingView.frame = r;
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
  dmc.retryView.hidden = YES;
  dmc.girlImageView.hidden = NO;
  
  GameState *gs = [GameState sharedGameState];
  dmc.nameLabel.text = gs.type < 3 ? @"Ruby" : @"Adriana";
  
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

+ (void) displayViewForBeginningText:(NSString *)str callbackTarget:(id)t action:(SEL)s {
  [self displayViewForText:str callbackTarget:t action:s];
  DialogMenuController *dmc = [DialogMenuController sharedDialogMenuController];
  dmc.nameLabel.text = @"???";
  dmc.girlImageView.hidden = YES;
  UIImageView *masked = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"maskedgirl.png"]];
  masked.tag = 35;
  [dmc.view addSubview:masked];
  masked.center = CGPointMake(dmc.girlImageView.center.x, CGRectGetMaxY(dmc.girlImageView.frame)-masked.frame.size.height/2);
  [masked release];
}

- (void) displayViewForReferral {
  self.textView.hidden = YES;
  self.referralView.hidden = NO;
  self.retryView.hidden = YES;
  self.girlImageView.hidden = NO;
  
  GameState *gs = [GameState sharedGameState];
  self.nameLabel.text = gs.type < 3 ? @"Ruby" : @"Adriana";
  
  CGRect r = self.progressBar.frame;
  r.size.width = 10+43*self.progress;
  self.progressBar.frame = r;
  
  if (!self.view.superview) {
    r = self.view.frame;
    r.origin.y = WIN_HEIGHT-r.size.height+ANIMATION_VERTICAL_MOVEMENT;
    self.view.frame = r;
    
    [DialogMenuController displayView];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
      CGRect r = self.view.frame;
      r.origin.y = WIN_HEIGHT-r.size.height;
      self.view.frame = r;
    }];
  }
}

+ (void) displayViewForReferral {
  DialogMenuController *dmc = [DialogMenuController sharedDialogMenuController];
  [dmc displayViewForReferral];
}

+ (void) closeView {
  DialogMenuController *dmc = [DialogMenuController sharedDialogMenuController];
  
  [UIView animateWithDuration:ANIMATION_DURATION animations:^{
    CGRect r = dmc.view.frame;
    r.origin.y = WIN_HEIGHT-r.size.height+ANIMATION_VERTICAL_MOVEMENT;
    dmc.view.frame = r;
  } completion:^(BOOL finished) {
    [[dmc.view viewWithTag:35] removeFromSuperview];
    [dmc.view removeFromSuperview];
    [dmc performCallback];
  }];
}

+ (void) incrementProgress {
  [self sharedDialogMenuController].progress++;
}

- (void) startLoading {
  [loadingView.actIndView startAnimating];
  
  [self.view addSubview:loadingView];
  _isDisplayingLoadingView = YES;
}

- (void) stopLoading {
  if (_isDisplayingLoadingView) {
    [loadingView.actIndView stopAnimating];
    [loadingView removeFromSuperview];
    _isDisplayingLoadingView = NO;
  }
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
  [referralTextField resignFirstResponder];
  
  [self startLoading];
  
  [Analytics tutorialEnterredReferral];
}

- (IBAction)skipClicked:(id)sender {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  tc.referralCode = nil;
  
  [[OutgoingEventController sharedOutgoingEventController] createUser];
  [referralTextField resignFirstResponder];
  
  [self startLoading];
  
  [Analytics tutorialSkippedReferral];
}

- (IBAction)retryClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] createUser];
  [referralTextField resignFirstResponder];
  
  [self startLoading];
}

- (void) receivedUserCreateResponse:(UserCreateResponseProto *)ucrp {
  if (ucrp.status == UserCreateResponseProto_UserCreateStatusSuccess) {
    [self registerCallback:self action:@selector(displayUserCreateSuccessDialog)];
  } else if (ucrp.status == UserCreateResponseProto_UserCreateStatusTimeIssue) {
    [self registerCallback:self action:@selector(displayTimeSyncDialog)];
  } else if (ucrp.status == UserCreateResponseProto_UserCreateStatusInvalidReferCode) {
    [self registerCallback:self action:@selector(displayReferralCodeFailDialog)];
  } else {
    [self registerCallback:self action:@selector(displayOtherFailDialog)];
  }
  [DialogMenuController closeView];
  [self stopLoading];
}

- (void) displayUserCreateSuccessDialog {
  self.progress++;
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  GameState *gs = [GameState sharedGameState];
  NSString *string = [NSString stringWithFormat:tc.createSuccessText, gs.name, [Globals factionForUserType:gs.type]];
  [DialogMenuController displayViewForText:string callbackTarget:nil action:nil];
  
  [(TutorialHomeMap *)[TutorialHomeMap sharedHomeMap] startGoToAviaryPhase];
  
  [Analytics tutorialUserCreated];
}

- (void) displayTimeSyncDialog {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.otherFailText callbackTarget:nil action:nil];
  
//  // Display retry button
//  DialogMenuController *dmc = [DialogMenuController sharedDialogMenuController];
//  dmc.retryView.hidden = NO;
  
  [Analytics tutorialTimeSync];
}

- (void) displayReferralCodeFailDialog {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.invalidReferCodeText callbackTarget:self action:@selector(displayViewForReferral)];
  
  [Analytics tutorialInvalidReferral];
}

- (void) displayOtherFailDialog {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.otherFailText callbackTarget:nil action:nil];
  
  [Analytics tutorialOtherFail];
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
