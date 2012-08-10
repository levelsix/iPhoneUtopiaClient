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

@implementation MapLoadingView

@synthesize darkView, actIndView, label;

- (void) awakeFromNib {
  self.darkView.layer.cornerRadius = 10.f;
}

- (void) dealloc {
  self.darkView = nil;
  self.actIndView = nil;
  self.label = nil;
  
  [super dealloc];
}

@end

@implementation MapViewController

@synthesize missionMap;
@synthesize loadingView;
@synthesize mainView;
@synthesize bgdView;
@synthesize titleLabel;
@synthesize enstBar, enstIcon;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(MapViewController);

#pragma mark - View lifecycle

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
  
  // Just in case the loading screen wasn't removed
  [self stopLoading];
  
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

- (void) didReceiveMemoryWarning {
  if (!self.loadingView.superview) {
    [super didReceiveMemoryWarning];
  }
}

- (IBAction)closeClicked:(id)sender {
  [self close];
}

- (void) startLoadingWithText:(NSString *)str {
  loadingView.label.text = str;
  [loadingView.actIndView startAnimating];
  
  [[[[CCDirector sharedDirector] openGLView] superview] addSubview:loadingView];
  _isDisplayingLoadingView = YES;
}

- (void) stopLoading {
  if (_isDisplayingLoadingView) {
    [loadingView.actIndView stopAnimating];
    [loadingView removeFromSuperview];
    _isDisplayingLoadingView = NO;
  }
}

- (void) close {
  [self stopLoading];
  if (self.view.superview) {
    [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^(void) {
      [MapViewController removeView];
    }];
  }
}

- (void) viewDidUnload {
  [super viewDidUnload];
  self.missionMap = nil;
  self.loadingView = nil;
  self.enstBar = nil;
  self.enstIcon = nil;
}

+ (void) cleanupAndPurgeSingleton {
  if (sharedMapViewController) {
    [sharedMapViewController closeClicked:nil];
    [MapViewController removeView];
    [MapViewController purgeSingleton];
  }
}

@end
