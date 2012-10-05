//
//  TutorialHomeMap.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/13/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "HomeMap.h"

@interface TutorialHomeMap : HomeMap {
  BOOL _carpenterPhase;
  BOOL _waitingForBuildPhase;
  BOOL _goToAviary;
  CCSprite *_ccArrow;
  UIImageView *_uiArrow;
  BOOL _canUnclick;
  
  BOOL _refreshed;
}

@property (nonatomic, retain) CoordinateProto *tutCoords;

- (void) startCarpPhase;
- (void) startGoToAviaryPhase;

@end
