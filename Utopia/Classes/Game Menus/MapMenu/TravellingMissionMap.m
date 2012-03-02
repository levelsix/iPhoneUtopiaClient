//
//  TravellingMissionMap.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/1/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TravellingMissionMap.h"
#import "Globals.h"
#import "GameState.h"

#define SHAKE_DURATION 0.2f
#define SHAKE_OFFSET 3.f

@implementation ContinentView

@synthesize lock;

@end

@implementation CityView

@synthesize isLocked, fcp;

- (void) awakeFromNib {
  isLocked = YES;
}

- (void) setIsLocked:(BOOL)i {
  if (isLocked != i) {
    isLocked = i;
    
    if (!isLocked) {
      [self setImage:[UIImage imageNamed:@"opencity.png"] forState:UIControlStateNormal] ;
    } else {
      [self setImage:[UIImage imageNamed:@"lockedcity.png"] forState:UIControlStateNormal];
    }
  }
}

@end

@implementation TravellingMissionMap

@synthesize lumoriaView;

- (void) awakeFromNib {
  [self addSubview:lumoriaView];
  lumoriaView.hidden = YES;
}

- (void) reloadCities {
  GameState *gs = [GameState sharedGameState];
  for (int i = 1; i <= gs.maxCityAccessible; i++) {
    FullCityProto *fcp = [gs cityWithId:i];
    
    CityView *cv = (CityView *)[self viewWithTag:i];
    cv.fcp = fcp;
    cv.isLocked = NO;
  }
}

- (IBAction)continentClicked:(ContinentView *)cv {
  // Just check if lock exists for now, only lumoria doesnt have lock
  if (cv.lock) {
    [Globals shakeView:cv.lock duration:SHAKE_DURATION offset:SHAKE_OFFSET];
  } else {
    lumoriaView.alpha = 0.f;
    lumoriaView.hidden = NO;
    [UIView animateWithDuration:1.f animations:^{
      lumoriaView.alpha = 1.f;
    }];
    [self reloadCities];
  }
}

- (IBAction)cityClicked:(CityView *)cv {
  if (!cv.isLocked) {
    
  } else {
    [Globals shakeView:cv duration:SHAKE_DURATION offset:SHAKE_OFFSET];
  }
}

@end
