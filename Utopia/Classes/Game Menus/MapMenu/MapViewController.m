//
//  MapViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MapViewController.h"
#import "SynthesizeSingleton.h"
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
#import "FlurryAnalytics.h"

#define THRESHOLD_ENEMIES_IN_BOUNDS 10

@implementation MapBar

@synthesize missionLabel, enemyLabel;
@synthesize missionButtonClicked, enemyButtonClicked;

- (void) awakeFromNib {
  _clickedButtons = 0;
}

- (void) clickButton:(MapBarButton)button {
  switch (button) {
    case kMissionButton:
      missionButtonClicked.hidden = NO;
      _clickedButtons |= kMissionButton;
      missionLabel.highlighted = NO;
      break;
      
    case kEnemyButton:
      enemyButtonClicked.hidden = NO;
      _clickedButtons |= kEnemyButton;
      enemyLabel.highlighted = NO;
      break;
      
    default:
      break;
  }
}

- (void) unclickButton:(MapBarButton)button {
  switch (button) {
    case kMissionButton:
      missionButtonClicked.hidden = YES;
      _clickedButtons &= ~kMissionButton;
      missionLabel.highlighted = YES;
      break;
      
    case kEnemyButton:
      enemyButtonClicked.hidden = YES;
      _clickedButtons &= ~kEnemyButton;
      enemyLabel.highlighted = YES;
      break;
      
    default:
      break;
  }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:missionButtonClicked];
  if (!(_clickedButtons & kMissionButton) && [missionButtonClicked pointInside:pt withEvent:nil]) {
    _trackingMission = YES;
    [self clickButton:kMissionButton];
  }
  
  pt = [touch locationInView:enemyButtonClicked];
  if (!(_clickedButtons & kEnemyButton) && [enemyButtonClicked pointInside:pt withEvent:nil]) {
    _trackingEnemy = YES;
    [self clickButton:kEnemyButton];
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:missionButtonClicked];
  if (_trackingMission) {
    if (CGRectContainsPoint(CGRectInset(missionButtonClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kMissionButton];
    } else {
      [self unclickButton:kMissionButton];
    }
  }
  
  pt = [touch locationInView:enemyButtonClicked];
  if (_trackingEnemy) {
    if (CGRectContainsPoint(CGRectInset(enemyButtonClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self clickButton:kEnemyButton];
    } else {
      [self unclickButton:kEnemyButton];
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:missionButtonClicked];
  if (_trackingMission) {
    if (CGRectContainsPoint(CGRectInset(missionButtonClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [[MapViewController sharedMapViewController] setState:kMissionMap];
      [self clickButton:kMissionButton];
      [self unclickButton:kEnemyButton];
    } else {
      [self unclickButton:kMissionButton];
    }
  }
  
  pt = [touch locationInView:enemyButtonClicked];
  if (_trackingEnemy) {
    if (CGRectContainsPoint(CGRectInset(enemyButtonClicked.bounds, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [[MapViewController sharedMapViewController] setState:kAttackMap];
      [self clickButton:kEnemyButton];
      [self unclickButton:kMissionButton];
    } else {
      [self unclickButton:kEnemyButton];
    }
  }
  _trackingMission = NO;
  _trackingEnemy = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self unclickButton:kMissionButton];
  [self unclickButton:kEnemyButton];
  _trackingMission = NO;
  _trackingEnemy = NO;
}

- (void) dealloc {
  self.missionLabel = nil;
  self.enemyLabel = nil;
  self.missionButtonClicked = nil;
  self.enemyButtonClicked = nil;
  [super dealloc];
}

@end

@implementation EnemyAnnotation

@synthesize fup;

- (id) initWithPlayer:(FullUserProto *)player {
  if ((self = [super init])) {
    self.coordinate = CLLocationCoordinate2DMake(player.userLocation.latitude, player.userLocation.longitude);
    self.fup = player;
    self.title = player.name;
    self.subtitle = [NSString stringWithFormat:@"Level %d %@ %@", player.level, [Globals factionForUserType:player.userType], [Globals classForUserType:player.userType]];
  }
  return self;
}

- (void) dealloc {
  [super dealloc];
  self.fup = nil;
}

@end

@implementation PinView

@synthesize levelLabel, view, imgView;

- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
    self.canShowCallout = YES;
    
    [[NSBundle mainBundle] loadNibNamed:@"PinView" owner:self options:nil];
    [self addSubview:view];
    self.frame = view.frame;
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [Globals imageNamed:@"mapprofileicon.png"];
    [leftButton setImage:img forState:UIControlStateNormal];
    leftButton.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    leftButton.tag = 1;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    img = [Globals imageNamed:@"mapattackicon.png"];
    [rightButton setImage:img forState:UIControlStateNormal];
    rightButton.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    rightButton.tag = 2;
    
    self.leftCalloutAccessoryView = leftButton;
    self.rightCalloutAccessoryView = rightButton;
  }
  return self;
}

- (void) setAnnotation:(id<MKAnnotation>)annotation {
  [super setAnnotation:annotation];
  
  if ([annotation isKindOfClass:[EnemyAnnotation class]]) {
    FullUserProto *fup = [(EnemyAnnotation *)annotation fup];
    levelLabel.text = [NSString stringWithFormat:@"%d", fup.level];
    imgView.image = [Globals circleImageForUser:fup.userType];
  }
}

- (void) dealloc {
  self.levelLabel = nil;
  self.view = nil;
  self.imgView = nil;
  [super dealloc];
}

@end

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

@synthesize mapView = _mapView;
@synthesize missionMap;
@synthesize state = _state;
@synthesize mapBar;
@synthesize loadingView;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(MapViewController);

#pragma mark - View lifecycle

- (void)viewDidLoad
{ 
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  [_mapView addSubview:[[[UIImageView alloc] initWithImage:[Globals imageNamed:@"mapfilter.png"]] autorelease]];
  
  // Insert right under the home button
  [self.view insertSubview: missionMap atIndex:0];
  missionMap.frame = _mapView.frame;
}

- (void) viewWillAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self removeAllPins];
  [[[GameState sharedGameState] attackList] removeAllObjects];
  
  if (_loaded) {
    [self retrieveAttackListForCurrentBounds];
  }
  
  missionMap.lumoriaView.hidden = YES;
  
  self.state = kMissionMap;
  
  [self.mapBar clickButton:kMissionButton];
  [self.mapBar unclickButton:kEnemyButton];
  
  // Just in case the loading screen wasn't removed
  [self stopLoading];
  
  CGRect f = self.view.frame;
  self.view.center = CGPointMake(f.size.width/2, f.size.height*3/2);
  [UIView animateWithDuration:FULL_SCREEN_APPEAR_ANIMATION_DURATION animations:^{
    self.view.center = CGPointMake(f.size.width/2, f.size.height/2);
  } completion:^(BOOL finished) {
    // In case we got here from the marketplace or armory
    [MarketplaceViewController removeView];
    [ArmoryViewController removeView];
    [CarpenterMenuController removeView];
  }];
}

- (void) viewWillDisappear:(BOOL)animated {
  [self removeAllPins];
  [[[GameState sharedGameState] attackList] removeAllObjects];
  self.mapView.showsUserLocation = NO;
}

- (void) openEnemiesTab {
  self.state = kEnemyButton;
  
  [self.mapBar clickButton:kEnemyButton];
  [self.mapBar unclickButton:kMissionButton];
}

- (void) setState:(MapState)state {
  _state = state;
  
  switch (state) {
    case kAttackMap:
      missionMap.hidden = YES;
      _mapView.hidden = NO;
      
      if ([CLLocationManager locationServicesEnabled]) {
        _mapView.showsUserLocation = YES;
      } else {
        _mapView.showsUserLocation = NO;
      }
      break;
      
    case kMissionMap:
      missionMap.hidden = NO;
      _mapView.hidden = YES;
      _mapView.showsUserLocation = NO;
      break;
      
    default:
      break;
  }
}

- (void) retrieveAttackListForCurrentBounds {
  int curEnemies = [_mapView annotationsInMapRect:_mapView.visibleMapRect].count;
  
  if (curEnemies >= THRESHOLD_ENEMIES_IN_BOUNDS) {
    return;
  }
  
  MKCoordinateRegion region = _mapView.region;
  
  CGRect mapBounds;
  mapBounds.origin.x = region.center.longitude-region.span.longitudeDelta/2;
  mapBounds.origin.y = region.center.latitude-region.span.latitudeDelta/2;
  mapBounds.size.width = region.span.longitudeDelta;
  mapBounds.size.height = region.span.latitudeDelta;
  
  [[OutgoingEventController sharedOutgoingEventController] generateAttackList:THRESHOLD_ENEMIES_IN_BOUNDS-curEnemies bounds:mapBounds];
}

- (void) removeAllPins {
  [_mapView removeAnnotations:_mapView.annotations];
}

- (void) addNewPins {
  NSMutableArray *arr = [[GameState sharedGameState] attackList];
  int userLocEnabled = _mapView.showsUserLocation ? 1 : 0;
  int i = _mapView.annotations.count == 0 ? 0 : _mapView.annotations.count-userLocEnabled;
  for (; i < arr.count; i++) {
    EnemyAnnotation *annotation = [[EnemyAnnotation alloc] initWithPlayer:[arr objectAtIndex:i]];
    [_mapView addAnnotation:annotation];
    [annotation release];
  }
}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  _loaded = YES;
  [self retrieveAttackListForCurrentBounds];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  static NSString *reuseId = @"enemyAnnotationView";
  
  if ([annotation isKindOfClass:[EnemyAnnotation class]]) {
    MKAnnotationView *mkav = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    
    if (!mkav) {
      mkav = [[[PinView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId] autorelease];
    }
    
    return mkav;
  }
  return nil;
}

- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
  int tag = control.tag;
  FullUserProto *fup = [(EnemyAnnotation *)view.annotation fup];
  
  if (tag == 1) {
    // Left clicked
    [[ProfileViewController sharedProfileViewController] loadProfileForPlayer:fup buttonsEnabled:YES];
    [ProfileViewController displayView];
    
    [Analytics enemyProfileFromAttackMap];
  } else if (tag == 2) {
    // Right clicked
    
    // BattleLayer will fade out view
    [[BattleLayer sharedBattleLayer] beginBattleAgainst:fup];
  }
}

- (IBAction)closeClicked:(id)sender {
  [self fadeOut];
}

- (IBAction)homeClicked:(id)sender {
  [[GameLayer sharedGameLayer] loadHomeMap];
  [self fadeOut];
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

- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
  [[OutgoingEventController sharedOutgoingEventController] changeUserLocationWithCoordinate:userLocation.location.coordinate];

  // We must send the user's location to FlurryAnalytics
  [FlurryAnalytics setLatitude:userLocation.location.coordinate.latitude 
                     longitude:userLocation.location.coordinate.longitude 
            horizontalAccuracy:userLocation.location.horizontalAccuracy
              verticalAccuracy:userLocation.location.verticalAccuracy];
}

- (void) fadeOut {
  [self stopLoading];
  if (self.view.superview) {
    CGRect f = self.view.frame;
    [UIView animateWithDuration:FULL_SCREEN_DISAPPEAR_ANIMATION_DURATION animations:^{
      self.view.center = CGPointMake(f.size.width/2, f.size.height*3/2);
    } completion:^(BOOL finished) {
      [MapViewController removeView];
    }];
  }
}

- (void) viewDidUnload {
  [super viewDidUnload];
  self.mapView = nil;
  self.missionMap = nil;
  self.mapBar = nil;
  self.loadingView = nil;
}

+ (void) cleanupAndPurgeSingleton {
  if (sharedMapViewController) {
    [sharedMapViewController closeClicked:nil];
    [MapViewController removeView];
    [MapViewController purgeSingleton];
  }
}

@end
