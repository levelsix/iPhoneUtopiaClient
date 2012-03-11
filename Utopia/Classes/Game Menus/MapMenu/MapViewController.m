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

#define THRESHOLD_ENEMIES_IN_BOUNDS 5

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

static UIButton *leftButton = nil;
static UIButton *rightButton = nil;

- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
  if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
    self.canShowCallout = YES;
    
    [[NSBundle mainBundle] loadNibNamed:@"PinView" owner:self options:nil];
    [self addSubview:view];
    self.frame = view.frame;
    
    if (!leftButton) {
      leftButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
      UIImage *img = [Globals imageNamed:@"mapprofileicon.png"];
      [leftButton setImage:img forState:UIControlStateNormal];
      leftButton.frame = CGRectMake(0, 0, img.size.width, img.size.height);
      leftButton.tag = 1;
    }
    
    if (!rightButton) {
      rightButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
      UIImage *img = [Globals imageNamed:@"mapattackicon.png"];
      [rightButton setImage:img forState:UIControlStateNormal];
      rightButton.frame = CGRectMake(0, 0, img.size.width, img.size.height);
      rightButton.tag = 2;
    }
    
    self.leftCalloutAccessoryView = leftButton;
    self.rightCalloutAccessoryView = rightButton;
  }
  return self;
}

- (void) setAnnotation:(id<MKAnnotation>)annotation {
  [super setAnnotation:annotation];
  
  if ([annotation isKindOfClass:[EnemyAnnotation class]]) {
    levelLabel.text = [NSString stringWithFormat:@"%d", [[(EnemyAnnotation *)annotation fup] level]];
  }
}

- (void) dealloc {
  self.levelLabel = nil;
  self.view = nil;
  self.imgView = nil;
  [super dealloc];
}

@end

@implementation MapViewController

@synthesize mapView = _mapView;
@synthesize missionMap;
@synthesize state = _state;

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

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self removeAllPins];
  [[[GameState sharedGameState] attackList] removeAllObjects];
  
  if (_loaded) {
    [self retrieveAttackListForCurrentBounds];
  }
  
  if ([CLLocationManager locationServicesEnabled]) {
    _mapView.showsUserLocation = YES;
  } else {
    _mapView.showsUserLocation = NO;
  }
  
  missionMap.lumoriaView.hidden = YES;
  
  self.state = kMissionMap;
}

- (void) setState:(MapState)state {
  _state = state;
  
  switch (state) {
    case kAttackMap:
      missionMap.hidden = YES;
      _mapView.hidden = NO;
      break;
      
    case kMissionMap:
      missionMap.hidden = NO;
      _mapView.hidden = YES;
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
  } else if (tag == 2) {
    // Right clicked
    [[BattleLayer sharedBattleLayer] beginBattleAgainst:fup];
    [MapViewController removeView];
  }
}

- (IBAction)closeClicked:(id)sender {
  [MapViewController removeView];
}

- (IBAction)homeClicked:(id)sender {
  [[HomeMap sharedHomeMap] refresh];
  [[GameLayer sharedGameLayer] loadHomeMap];
  [MapViewController removeView];
}

- (void) viewDidUnload {
  [super viewDidUnload];
  self.mapView = nil;
  self.missionMap = nil;
  [sharedMapViewController release];
  sharedMapViewController = nil;
}

@end
