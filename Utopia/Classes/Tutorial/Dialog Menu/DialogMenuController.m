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
#import "IncomingEventController.h"

#define MASKED_GIRL_TAG 35

@implementation DialogMenuController

#define ANIMATION_DURATION 0.5f
#define ANIMATION_VERTICAL_MOVEMENT 124
#define WIN_HEIGHT [[UIScreen mainScreen] applicationFrame].size.width

@synthesize nameLabel;
@synthesize girlImageView;
@synthesize loadingView;
@synthesize label;
@synthesize speechBubble;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(DialogMenuController);

- (void) viewWillAppear:(BOOL)animated {
  self.view.alpha = 0.f;
}

+ (void) displayViewForText:(NSString *)str {
  DialogMenuController *dmc = [DialogMenuController sharedDialogMenuController];
  dmc.label.text = str;
  
  GameState *gs = [GameState sharedGameState];
  dmc.nameLabel.text = [Globals userTypeIsGood:gs.type] ? @"Ruby" : @"Adriana";
  dmc.girlImageView.highlighted = [Globals userTypeIsBad:gs.type];
  
  // Make sure that it is set at the center
  dmc.view.center = ccp(dmc.view.frame.size.width/2, dmc.view.frame.size.height/2);
  
  dmc.view.transform = CGAffineTransformIdentity;
  dmc.label.transform = CGAffineTransformIdentity;
  dmc.girlImageView.transform = CGAffineTransformIdentity;
  
  [DialogMenuController displayView];
  
  // Alpha will only start at 0 if it is not already there
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

- (void) flipView {
  self.view.transform = CGAffineTransformMakeScale(-1, 1);
  self.label.transform = CGAffineTransformMakeScale(-1, 1);
  self.girlImageView.transform = CGAffineTransformMakeScale(-1, 1);
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
  GameState *gs = [GameState sharedGameState];
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  
  [self.loadingView display:self.view];
  
  if (!tc.userCreateResponse) {
    [[OutgoingEventController sharedOutgoingEventController] createUser];
    self.waitingForUserCreate = YES;
  } else {
    [self receivedUserCreateResponse:tc.userCreateResponse];
    
    if (tc.userCreateResponse.status == UserCreateResponseProto_UserCreateStatusSuccess ||
        tc.userCreateResponse.status == UserCreateResponseProto_UserCreateStatusUserWithUdidAlreadyExists) {
      if (tc.userCreateResponse.hasSender) {
        [gs updateUser:tc.userCreateResponse.sender timestamp:0];
      }
      
      self.waitingForStartup = YES;
      if (tc.startupResponse) {
        FullEvent *fe = [FullEvent new];
        fe.event = tc.startupResponse;
        [[IncomingEventController sharedIncomingEventController] handleStartupResponseProto:fe];
      } else {
        [[OutgoingEventController sharedOutgoingEventController] startup];
      }
    }
  }
}

- (void) receivedUserCreateResponse:(UserCreateResponseProto *)ucrp {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  if (ucrp.status == UserCreateResponseProto_UserCreateStatusSuccess || ucrp.status == UserCreateResponseProto_UserCreateStatusUserWithUdidAlreadyExists) {
  } else if (ucrp.status == UserCreateResponseProto_UserCreateStatusTimeIssue) {
    [DialogMenuController displayViewForText:tc.timeSyncErrorText];
    [self stopLoading:NO];
  } else {
    [DialogMenuController displayViewForText:[NSString stringWithFormat:tc.otherFailText, ucrp.status]];
    [self stopLoading:NO];
  }
}

- (void) stopLoading:(BOOL)continueTut {
  [self.loadingView stop];
  
  if (continueTut) {
    [(TutorialTopBar *)[TutorialTopBar sharedTopBar] beginQuestsPhase];
    
    [Analytics tutUserCreated];
  }
}

- (void) didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  if (self.isViewLoaded && !self.view.superview) {
    self.view = nil;
    // Release any retained subviews of the main view.
    self.label = nil;
    self.nameLabel = nil;
    self.girlImageView = nil;
    self.loadingView = nil;
    self.label = nil;
  }
}

@end
