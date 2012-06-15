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
#import "DialogMenuController.h"
#import "TutorialConstants.h"
#import "Globals.h"
#import "GameState.h"

@implementation TutorialMapViewController

- (id) init {
  return [super initWithNibName:@"MapViewController" bundle:nil];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.mapView.userInteractionEnabled = NO;
  self.missionMap.userInteractionEnabled = NO;
  
  _enemyTabPhase = YES;
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.insideAviaryText];
  [Analytics tutorialEnterAviary];
}

- (void) missionsDialog {
  // By now, we can ensure fade in is complete so unload mission map
  [[GameLayer sharedGameLayer] unloadTutorialMissionMap];
  [[TutorialHomeMap sharedHomeMap] performSelectorInBackground:@selector(backgroundRefresh) withObject:nil];
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.missionAviaryText];
}

- (void) beforeEnemiesDialog {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.beforeEnemiesAviaryText];
  
  _arrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3darrow.png"]];
  [self.view addSubview:_arrow];
  _arrow.layer.transform = CATransform3DMakeRotation(-M_PI/2, 0.0f, 0.0f, 1.0f);
  _arrow.alpha = 0.f;
  UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
  // This is confusing, basically fade in, and then do repeated animation
  [UIView animateWithDuration:0.3f animations:^{
    _arrow.alpha = 1.f;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
      _arrow.center = CGPointMake(_arrow.center.x-10, _arrow.center.y);
    } completion:nil];
  }];
}

- (void) goHomeDialog {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.beforeHomeAviaryText];
  
  UIView *homeButton = [self.view viewWithTag:23];
  _arrow.layer.transform = CATransform3DIdentity;
  _arrow.center = CGPointMake(homeButton.center.x, homeButton.frame.origin.y-_arrow.frame.size.height/2);
  UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
  // This is confusing, basically fade in, and then do repeated animation
  [UIView animateWithDuration:0.3f animations:^{
    _arrow.alpha = 1.f;
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
      _arrow.center = CGPointMake(_arrow.center.x, _arrow.center.y-40);
    } completion:nil];
  }];
}

- (void) setState:(MapState)state {
  [super setState:state];
  
  if (state == kAttackMap && _enemyTabPhase) {
    _enemyTabPhase = NO;
    _travelHomePhase = YES;
    TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
    [DialogMenuController displayViewForText:tc.enemiesAviaryText];
    
    [_arrow.layer removeAllAnimations];
    _arrow.alpha = 0.f;
    [Analytics tutorialEnemiesTab];
  }
}

- (void) determineNextDialog {
  if (_rejectedLocation) {
    [self rejectLocationDialog];
    [Analytics tutorialRejectedLocation];
  } else {
    [self goHomeDialog];
    [Analytics tutorialEnabledLocation];
  }
}

- (IBAction)closeClicked:(id)sender {
  return;
}

- (void) viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.insideHomeText];
  
  [MapViewController purgeSingleton];
}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  return;
}

- (void) rejectLocationDialog {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.rejectLocationText];
}

- (void) mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
  _rejectedLocation = YES;
}

- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
  GameState *gs = [GameState sharedGameState];
  gs.location = userLocation.location.coordinate;
}

@end
