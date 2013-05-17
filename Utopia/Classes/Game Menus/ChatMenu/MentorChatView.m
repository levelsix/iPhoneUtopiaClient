//
//  MentorChatView.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/13/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "MentorChatView.h"
#import "GameState.h"
#import "Globals.h"
#import "ChatMenuController.h"

@implementation MentorChatView

- (void) displayForMentor:(MinimumUserProto *)mup {
  GameState *gs = [GameState sharedGameState];
  self.badgeLabel.text = @"(1)";
  self.titleLabel.text = [NSString stringWithFormat:@"Chat with %@", mup.name];
  [Globals adjustViewForCentering:self.titleView withLabel:self.titleLabel];
  
  self.firstTextLabel.text = [NSString stringWithFormat:@"Hi %@, I’m a mentor in age of chaos! I help new players learn the ropes", gs.name];
  [self.firstTypeIcon setImage:[Globals imageNamed:[Globals headshotImageNameForUser:mup.userType]] forState:UIControlStateNormal];
  [self.firstNameButton setTitle:mup.name forState:UIControlStateNormal];
  [self.scrollView addSubview:self.firstChatView];
  
  [Globals displayUIView:self];
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [UIView animateWithDuration:1.f delay:0.f options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
    self.firstGlow.alpha = 0.5f;
  } completion:nil];
  
  _mentorUserId = mup.userId;
  
  [self performSelector:@selector(showSecondChat:) withObject:mup afterDelay:3.f];
}

- (void) showSecondChat:(MinimumUserProto *)mup {
  self.badgeLabel.text = @"(2)";
  
  self.secondTextLabel.text = @"how's it going?";
  [self.secondTypeIcon setImage:[Globals imageNamed:[Globals headshotImageNameForUser:mup.userType]] forState:UIControlStateNormal];
  [self.secondNameButton setTitle:mup.name forState:UIControlStateNormal];
  [self.scrollView addSubview:self.secondChatView];
  
  [UIView animateWithDuration:1.f delay:0.f options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
    self.secondGlow.alpha = 0.5f;
  } completion:nil];
  
  CGRect r = self.secondChatView.frame;
  r.origin.y = CGRectGetMaxY(self.firstChatView.frame);
  self.secondChatView.frame = r;
  
  self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(self.secondChatView.frame));
  [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height-self.scrollView.frame.size.height) animated:YES];
}

- (IBAction)talkToMentorClicked:(id)sender {
  [ChatMenuController displayView];
  [[ChatMenuController sharedChatMenuController] loadPrivateChatsForUserId:_mentorUserId animated:NO];
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [self removeFromSuperview];
  }];
}

- (void) dealloc {
  self.badgeLabel = nil;
  self.titleLabel = nil;
  self.titleView = nil;
  self.firstChatView = nil;
  self.firstNameButton = nil;
  self.firstTextLabel = nil;
  self.firstTypeIcon = nil;
  self.secondChatView = nil;
  self.secondNameButton = nil;
  self.secondTextLabel = nil;
  self.secondTypeIcon = nil;
  self.scrollView = nil;
  self.mainView = nil;
  self.bgdView = nil;
  [super dealloc];
}

@end
