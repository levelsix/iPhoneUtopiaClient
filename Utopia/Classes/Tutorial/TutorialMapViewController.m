//
//  TutorialMapViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/16/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TutorialMapViewController.h"
#import "TutorialHomeMap.h"
#import "TutorialMissionMap.h"
#import "GameLayer.h"

@implementation TutorialMapViewController

- (id) init {
  return [super initWithNibName:@"MapViewController" bundle:nil];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  _travelHomePhase = YES;
  [[GameLayer sharedGameLayer] unloadTutorialMissionMap];
  
  self.mapView.userInteractionEnabled = NO;
  self.missionMap.userInteractionEnabled = NO;
}

- (IBAction)closeClicked:(id)sender {
  return;
}

- (IBAction)homeClicked:(id)sender {
  if (_travelHomePhase) {
    [super homeClicked:sender];
  }
}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  return;
}

@end
