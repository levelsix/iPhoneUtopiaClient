//
//  MapViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MapViewController.h"
#import "LNSynthesizeSingleton.h"
#import "OutgoingEventController.h"
#import "ProfileViewController.h"
#import "Globals.h"
#import "GameState.h"
#import "BattleLayer.h"
#import "HomeMap.h"
#import "GameLayer.h"
#import "ArmoryViewController.h"
#import "CarpenterMenuController.h"
#import "MarketplaceViewController.h"

@implementation MapViewController

@synthesize missionMap;
@synthesize mainView;
@synthesize bgdView;
@synthesize titleLabel;
@synthesize enstBar, enstIcon;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(MapViewController);

#pragma mark - View lifecycle

- (id) init {
  Globals *gl = [Globals sharedGlobals];
  if (IS_IPAD) return [self initWithNibName:@"MapViewController" bundle:nil];
  else return [self initWithNibName:@"MapViewController" bundle:[Globals bundleNamed:gl.downloadableNibConstants.mapNibName]];
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [missionMap.lumoriaView reloadCities];
  
  GameState *gs = [GameState sharedGameState];
  //  if (self.state == kAttackMap) {
  //    self.enstIcon.highlighted = NO;
  //    self.enstBar.percentage = ((float)gs.currentStamina)/gs.maxStamina;
  //    self.enstBar.highlighted = NO;
  //  } else if (self.state == kMissionMap) {
  self.enstIcon.highlighted = YES;
  self.enstBar.percentage = ((float)gs.currentEnergy)/gs.maxEnergy;
  self.enstBar.highlighted = YES;
  //  }
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

//- (void) setState:(MapState)state {
//  _state = state;
//
//  switch (state) {
//    case kAttackMap:
//      missionMap.hidden = YES;
//      _mapView.hidden = NO;
//
//      if ([CLLocationManager locationServicesEnabled]) {
//        _mapView.showsUserLocation = YES;
//      } else {
//        _mapView.showsUserLocation = NO;
//      }
//      titleLabel.text = @"Rivals";
//      break;
//
//    case kMissionMap:
//      missionMap.hidden = NO;
//      _mapView.hidden = YES;
//      _mapView.showsUserLocation = NO;
//      titleLabel.text = @"World Map";
//      break;
//
//    default:
//      break;
//  }
//}

+ (void) displayMissionMap {
  [self displayView];
}

- (IBAction)closeClicked:(id)sender {
  [self close];
}

- (void) close {
  if (self.view.superview) {
    [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^(void) {
      [MapViewController removeView];
    }];
  }
}

- (void) didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  if (self.isViewLoaded && !self.view.superview) {
    self.view = nil;
    self.missionMap = nil;
    self.enstBar = nil;
    self.enstIcon = nil;
  }
}

+ (void) cleanupAndPurgeSingleton {
  if (sharedMapViewController) {
    [sharedMapViewController closeClicked:nil];
    [MapViewController removeView];
    [MapViewController purgeSingleton];
  }
}

@end
