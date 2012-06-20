//
//  TutorialProfilePicture.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/13/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ProfilePicture.h"

@interface TutorialProfilePicture : ProfilePicture {
  BOOL _faceDialPhase;
  BOOL _wallPhase;
  
  CCSprite *_arrow;
}

- (void) beginFaceDialPhase;
- (void) beginWallPhase;

@end
