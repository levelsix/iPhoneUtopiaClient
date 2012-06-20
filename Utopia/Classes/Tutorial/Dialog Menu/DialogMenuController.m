//
//  DialogMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "DialogMenuController.h"
#import "LNSynthesizeSingleton.h"
#import "cocos2d.h"
#import "NibUtils.h"
#import "OutgoingEventController.h"
#import "TutorialConstants.h"
#import "GameState.h"
#import "Globals.h"
#import "TutorialHomeMap.h"
#import "TutorialTopBar.h"

#define MASKED_GIRL_TAG 35

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
#define SPEECH_BUBBLE_SCALE 0.7f
#define SPEECH_BUBBLE_ANIMATION_DURATION 0.2f

@synthesize nameLabel;
@synthesize girlImageView;
@synthesize loadingView;
@synthesize label;
@synthesize speechBubble;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(DialogMenuController);

+ (void) displayViewForText:(NSString *)str {
  DialogMenuController *dmc = [DialogMenuController sharedDialogMenuController];
  dmc.label.text = str;
  
  GameState *gs = [GameState sharedGameState];
  dmc.nameLabel.text = [Globals userTypeIsGood:gs.type] ? @"Ruby" : @"Adriana";
  dmc.girlImageView.highlighted = [Globals userTypeIsBad:gs.type];
  
  // Make sure that it is set at the center
  dmc.view.center = ccp(dmc.view.frame.size.width/2, dmc.view.frame.size.height/2);
  
  [DialogMenuController displayView];
  dmc.view.alpha = 0.f;
  
  CGPoint oldCenter = dmc.speechBubble.center;
  dmc.speechBubble.center = CGPointMake(oldCenter.x-30, oldCenter.y);
  dmc.speechBubble.transform = CGAffineTransformMakeScale(SPEECH_BUBBLE_SCALE, SPEECH_BUBBLE_SCALE);
  [UIView animateWithDuration:SPEECH_BUBBLE_ANIMATION_DURATION animations:^{
    dmc.view.alpha = 1.f;
    dmc.speechBubble.center = oldCenter;
    dmc.speechBubble.transform = CGAffineTransformIdentity;
  }];
}

+ (void) closeView {
  DialogMenuController *dmc = [DialogMenuController sharedDialogMenuController];
  
  if (dmc.view.superview) {
    [UIView animateWithDuration:SPEECH_BUBBLE_ANIMATION_DURATION animations:^{
      dmc.speechBubble.center = CGPointMake(dmc.speechBubble.center.x-30, dmc.speechBubble.center.y);
      dmc.view.alpha = 0.f;
      dmc.speechBubble.transform = CGAffineTransformMakeScale(SPEECH_BUBBLE_SCALE, SPEECH_BUBBLE_SCALE);
    } completion:^(BOOL finished) {
      if (finished) {
        [dmc.view removeFromSuperview];
      }
      
      // Move center back to where it originally was
      dmc.speechBubble.center = CGPointMake(dmc.speechBubble.center.x+30, dmc.speechBubble.center.y);
    }];
  }
}

- (void) startLoading {
  [loadingView.actIndView startAnimating];
  
  [[[[CCDirector sharedDirector] openGLView] superview] addSubview:loadingView];
  _isDisplayingLoadingView = YES;
}

- (void) stopLoading {
  if (_isDisplayingLoadingView) {
    [loadingView.actIndView stopAnimating];
    [loadingView removeFromSuperview];
    _isDisplayingLoadingView = NO;
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

- (void) createUser {
  [[OutgoingEventController sharedOutgoingEventController] createUser];
  
  [self startLoading];
}

- (void) receivedUserCreateResponse:(UserCreateResponseProto *)ucrp {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  if (ucrp.status == UserCreateResponseProto_UserCreateStatusSuccess) {
    [(TutorialTopBar *)[TutorialTopBar sharedTopBar] beginQuestsPhase];
    [Analytics tutorialUserCreated];
  } else if (ucrp.status == UserCreateResponseProto_UserCreateStatusTimeIssue) {
    [DialogMenuController displayViewForText:tc.timeSyncErrorText];
    [Analytics tutorialTimeSync];
  } else {
    [DialogMenuController displayViewForText:tc.otherFailText];
    [Analytics tutorialOtherFail];
  }
   
  [self stopLoading];
}

- (void) viewDidUnload
{
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  self.label = nil;
  self.nameLabel = nil;
  self.girlImageView = nil;
  self.loadingView = nil;
  self.label = nil;
}

@end
