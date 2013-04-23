//
//  TutorialProfilePicture.m
//  Utopia
//
//  Created by Ashwin Kamath on 6/13/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TutorialProfilePicture.h"
#import "Globals.h"
#import "DialogMenuController.h"
#import "TutorialConstants.h"
#import "ProfileViewController.h"
#import "GameState.h"

@implementation TutorialProfilePicture

- (void) beginFaceDialPhase {
  _faceDialPhase = YES;
  
  _arrow = [[CCSprite spriteWithFile:@"3darrow.png"] retain];
  [self.parent addChild:_arrow z:1000];
  _arrow.position = ccpAdd(self.position, ccp(self.contentSize.width/2+_arrow.contentSize.width/2, -self.contentSize.height/2-_arrow.contentSize.height/2));
  [Globals animateCCArrow:_arrow atAngle:3*M_PI_4];
  
  [self incrementProfileBadge];
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.beforeFaceDialText];
  
  DialogMenuController *dmc = [DialogMenuController sharedDialogMenuController];
  [dmc flipView];
}

- (void) beginWallPhase {
  _wallPhase = YES;
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.beforeWallText];
  
  DialogMenuController *dmc = [DialogMenuController sharedDialogMenuController];
  [dmc flipView];
  
  [_arrow removeFromParentAndCleanup:YES];
  
  [self performSelector:@selector(showArrowOnProfileButton) withObject:nil afterDelay:0.5f];
}

- (void) showArrowOnProfileButton {
  CCMenuItem *profile = [_menuItems objectAtIndex:1];
  [profile addChild:_arrow];
  _arrow.position = ccp(profile.contentSize.width+5, -5);
  [Globals animateCCArrow:_arrow atAngle:3*M_PI_4];
}

- (void) popInButtons {
  return;
}

- (void) popOutButtons {
  if (_faceDialPhase) {
    [super popOutButtons];
    _faceDialPhase = NO;
    
    [self beginWallPhase];
    
    [Analytics tutPathMenu];
  }
}

- (void) buttonClicked:(CCMenuItem *)clickedButton selector:(SEL)sel {
  if (_wallPhase && clickedButton.tag == 2) {
    [super buttonClicked:clickedButton selector:sel];
    
    _wallPhase = NO;
    [_arrow removeFromParentAndCleanup:YES];
    
    [DialogMenuController closeView];
  }
  return;
}

- (void) openProfile {
  [super openProfile];
  
  GameState *gs = [GameState sharedGameState];
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  RetrievePlayerWallPostsResponseProto_Builder *b = [RetrievePlayerWallPostsResponseProto builder];
  b.relevantUserId = gs.userId;
  [b addPlayerWallPosts:tc.firstWallPost];
  
  [[ProfileViewController sharedProfileViewController] receivedWallPosts:b.build];
  [[ProfileViewController sharedProfileViewController] setState:kProfileState];
  
  [Analytics tutProfileButton];
}

- (void) dealloc {
  [_arrow release];
  [super dealloc];
}

@end
