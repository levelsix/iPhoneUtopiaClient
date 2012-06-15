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

@implementation TutorialProfilePicture

- (void) beginFaceDialPhase {
  _faceDialPhase = YES;
  
  _arrow = [[CCSprite spriteWithFile:@"3darrow.png"] retain];
  [self.parent addChild:_arrow z:1000];
  _arrow.position = ccpAdd(self.position, ccp(self.contentSize.width/2+_arrow.contentSize.width/2, -self.contentSize.height/2-_arrow.contentSize.height/2));
  [Globals animateCCArrow:_arrow atAngle:3*M_PI_4];
}

- (void) beginHelpPhase {
  _helpPhase = YES;
  
  CCMenuItem *help = nil;
  for (CCMenuItem *item in _menuItems) {
    if (item.tag == 3) {
      help = item;
      break;
    }
  }
  
  [help addChild:_arrow];
  _arrow.position = ccp(help.contentSize.width/2, -_arrow.contentSize.height/2);
  [Globals animateCCArrow:_arrow atAngle:M_PI_2];
}

- (void) popOutButtons {
  if (_faceDialPhase) {
    [super popOutButtons];
    _faceDialPhase = NO;
    
    [_arrow removeFromParentAndCleanup:YES];
    
    [self performSelector:@selector(popInButtons) withObject:nil afterDelay:1.5f];
    
    [[DialogMenuController sharedDialogMenuController] createUser];
  }
}

- (void) buttonClicked:(CCMenuItem *)clickedButton selector:(SEL)sel {
//  if (_helpPhase && clickedButton.tag == 3) {
//    [super buttonClicked:clickedButton selector:sel];
//    
//    _helpPhase = NO;
//    [_arrow removeFromParentAndCleanup:YES];
//  }
  return;
}

- (void) dealloc {
  [_arrow release];
  [super dealloc];
}

@end
