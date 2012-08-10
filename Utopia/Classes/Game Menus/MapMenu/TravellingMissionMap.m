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
#import "OutgoingEventController.h"
#import "MapViewController.h"

#define SHAKE_DURATION 0.2f
#define SHAKE_OFFSET 3.f

#define CITY_POPUP_OFFSET 34.f

@implementation ContinentView

@synthesize lock;

- (void) dealloc {
  self.lock = nil;
  [super dealloc];
}

@end

@implementation CityView

@synthesize isLocked, fcp;

- (void) awakeFromNib {
  isLocked = YES;
}

- (void) setIsLocked:(BOOL)i {
  isLocked = i;
  
  if (!isLocked) {
    [self setImage:[Globals imageNamed:@"opencity.png"] forState:UIControlStateNormal] ;
  } else {
    [self setImage:[Globals imageNamed:@"lockedcity.png"] forState:UIControlStateNormal];
  }
}

- (void) dealloc {
  self.fcp = nil;
  [super dealloc];
}

@end

@implementation CloseUpContinentView

@synthesize cityPopup, cityNameLabel, cityRankLabel, progressLabel, progressBar;

- (void) awakeFromNib {
  [self addSubview:cityPopup];
}

- (void) reloadCities {
  GameState *gs = [GameState sharedGameState];
  for (int i = 1; i <= gs.maxCity; i++) {
    FullCityProto *fcp = [gs cityWithId:i];
    UserCity *city = [gs myCityWithId:i];
    
    CityView *cv = (CityView *)[self viewWithTag:i];
    cv.fcp = fcp;
    cv.isLocked = (city == nil);
  }
  cityPopup.hidden = YES;
}

- (void) updatePopupForCity:(CityView *)cv {
  _fcp = cv.fcp;
  UserCity *uc = [[GameState sharedGameState] myCityWithId:_fcp.cityId];
  Globals *gl = [Globals sharedGlobals];
  
  cityNameLabel.text = _fcp.name;
  cityRankLabel.text = [NSString stringWithFormat:@"Rank: %d", uc.curRank];
  progressLabel.text = uc.curRank < gl.maxCityRank ? [NSString stringWithFormat:@"%d/%d", uc.numTasksComplete, _fcp.taskIdsList.count] : @"Max";
  cityPopup.center = CGPointMake(cv.center.x+CITY_POPUP_OFFSET, cv.frame.origin.y-cityPopup.frame.size.height/2);
  
  float fullWidth = progressBar.image.size.width;
  CGRect r = progressBar.frame;
  r.size.width = fullWidth * uc.numTasksComplete / _fcp.taskIdsList.count;
  progressBar.frame = r;
}

- (IBAction)cityClicked:(CityView *)cv {
  if (!cv.isLocked) {
    [self updatePopupForCity:cv];
    cityPopup.hidden = NO;
  } else {
    FullCityProto *fcp = cv.fcp;
    [Globals popupMessage:[NSString stringWithFormat:@"%@ is unlocked at Level %d", fcp.name, fcp.minLevel]];
    [Globals shakeView:cv duration:SHAKE_DURATION offset:SHAKE_OFFSET];
  }
}

- (IBAction)goClicked:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] loadNeutralCity:_fcp.cityId];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (!cityPopup.hidden) {
    if (![cityPopup pointInside:[[touches anyObject] locationInView:cityPopup] withEvent:event]) {
      cityPopup.hidden = YES;
      _fcp = nil;
    }
  }
}

- (void) dealloc {
  self.cityPopup = nil;
  self.cityNameLabel = nil;
  self.cityRankLabel = nil;
  self.progressLabel = nil;
  self.progressBar = nil;
  [super dealloc];
}

@end

@implementation TravellingMissionMap

@synthesize lumoriaView;

- (void) awakeFromNib {
  [self addSubview:lumoriaView];
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
    [lumoriaView reloadCities];
  }
}

- (IBAction)globeClicked:(id)sender {
  [UIView animateWithDuration:1.f animations:^{
    lumoriaView.alpha = 0.f;
  } completion:^(BOOL finished) {
    lumoriaView.hidden = YES;
  }];
}

- (void) dealloc {
  self.lumoriaView = nil;
  [super dealloc];
}

@end
