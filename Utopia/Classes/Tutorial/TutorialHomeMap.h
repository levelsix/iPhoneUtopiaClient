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
  BOOL _visitCarpPhase;
  BOOL _waitingForBuildPhase;
  BOOL _goToArmory;
  CCSprite *_ccArrow;
  CritStructBuilding *_csb;
  Aviary *_av;
  UIImageView *_uiArrow;
  BOOL _arrowDir;
}

@property (nonatomic, retain) CoordinateProto *tutCoords;

@end
