//
//  AttackMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/8/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "AttackMenuController.h"
#import "Globals.h"
#import "GameState.h"
#import "OutgoingEventController.h"
#import "LNSynthesizeSingleton.h"
#import "ProfileViewController.h"
#import "BattleLayer.h"

#define THRESHOLD_ENEMIES_ATTACK_LIST [[Globals sharedGlobals] sizeOfAttackList]
#define THRESHOLD_ENEMIES_IN_BOUNDS 10

#define MIN_LATITUDE 0.5f
#define MIN_LONGITUDE MIN_LATITUDE*2

@implementation AttackMenuBar

@synthesize background;

- (void) flip {
  _flipped = YES;
  self.background.transform = CGAffineTransformMakeScale(-1, 1);
}

- (void) unflip {
  _flipped = NO;
  self.background.transform = CGAffineTransformIdentity;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:self];
  
  CGRect r = self.bounds;
  r.size.width /= 2;
  if (CGRectContainsPoint(r, pt) && _flipped) {
    _trackingList = YES;
    [self unflip];
  }
  
  r = self.bounds;
  r.size.width /= 2;
  r.origin.x += r.size.width;
  if (CGRectContainsPoint(r, pt) && !_flipped) {
    _trackingLocation = YES;
    [self flip];
  }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:self];
  
  if (_trackingList) {
    CGRect r = self.bounds;
    r.size.width /= 2;
    if (CGRectContainsPoint(CGRectInset(r, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self unflip];
    } else {
      [self flip];
    }
  }
  if (_trackingLocation) {
    CGRect r = self.bounds;
    r.size.width /= 2;
    r.origin.x += r.size.width;
    if (CGRectContainsPoint(CGRectInset(r, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self flip];
    } else {
      [self unflip];
    }
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:self];
  
  if (_trackingList) {
    CGRect r = self.bounds;
    r.size.width /= 2;
    if (CGRectContainsPoint(CGRectInset(r, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self unflip];
      [[AttackMenuController sharedAttackMenuController] setState:kAttackList];
    } else {
      [self flip];
    }
  }
  if (_trackingLocation) {
    CGRect r = self.bounds;
    r.size.width /= 2;
    r.origin.x += r.size.width;
    if (CGRectContainsPoint(CGRectInset(r, -BUTTON_CLICKED_LEEWAY, -BUTTON_CLICKED_LEEWAY), pt)) {
      [self flip];
      [[AttackMenuController sharedAttackMenuController] setState:kLocationMap];
    } else {
      [self unflip];
    }
  }
  _trackingLocation = NO;
  _trackingList = NO;
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  _trackingList = NO;
  _trackingLocation = NO;
}

- (void) dealloc {
  self.background = nil;
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
  self.fup = nil;
  [super dealloc];
}

@end

@implementation AttackListCell

@synthesize userIcon, nameLabel, typeLabel;
@synthesize fup;

- (void) awakeFromNib {
  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = self.bounds;
  UIColor *topColor = [UIColor colorWithRed:35/255.f green:35/255.f blue:35/255.f alpha:0.5f];
  UIColor *botColor = [UIColor colorWithRed:12/255.f green:12/255.f blue:12/255.f alpha:0.5f];
  gradient.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[botColor CGColor], nil];
  [self.contentView.layer insertSublayer:gradient atIndex:0];
}

- (void) updateForUser:(FullUserProto *)user {
  self.fup = user;
  self.nameLabel.text = [Globals fullNameWithName:user.name clanTag:user.clan.tag];
  self.typeLabel.text = [NSString stringWithFormat:@"Level %d %@ %@", user.level, [Globals factionForUserType:user.userType], [Globals classForUserType:user.userType]];
  [userIcon setImage:[Globals squareImageForUser:user.userType] forState:UIControlStateNormal];
}

- (IBAction)attackClicked:(id)sender {
  [[AttackMenuController sharedAttackMenuController] battle:fup];
}

- (IBAction)profileClicked:(id)sender {
  [[AttackMenuController sharedAttackMenuController] viewProfile:fup];
}

- (void) dealloc {
  self.userIcon = nil;
  self.nameLabel = nil;
  self.typeLabel = nil;
  self.fup = nil;
  [super dealloc];
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

@implementation AttackMenuController

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(AttackMenuController);

@synthesize listTabView, locationTabView;
@synthesize mapView = _mapView;
@synthesize mapSpinner, listSpinner;
@synthesize state = _state;
@synthesize mainView;
@synthesize bgdView;
@synthesize listCell;
@synthesize attackTableView;

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  self.listTabView.frame = self.locationTabView.frame;
  [self.mainView insertSubview:self.listTabView belowSubview:self.locationTabView];
  
  self.state = kAttackList;
  
  self.attackTableView.tableFooterView = [[[UIView alloc] init] autorelease];
  
  [super addPullToRefreshHeader:self.attackTableView];
  [self.attackTableView addSubview:self.refreshHeaderView];
  self.refreshHeaderView.center = ccp(self.attackTableView.frame.size.width/2, -self.refreshHeaderView.frame.size.height/2);
  
  [Globals imageNamed:@"mapfilter.png" withView:self.filterImageView maskedColor:nil indicator:UIActivityIndicatorViewStyleWhiteLarge clearImageDuringDownload:YES];
}

- (void) didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  if (self.isViewLoaded && !self.view.superview) {
    self.view = nil;
    self.mapView.delegate = nil;
    self.mapView = nil;
    self.mapSpinner = nil;
    self.listSpinner = nil;
    self.listTabView = nil;
    self.locationTabView = nil;
    self.mainView = nil;
    self.bgdView = nil;
    self.listCell = nil;
    self.attackTableView = nil;
    self.refreshHeaderView = nil;
    self.refreshLabel = nil;
    self.refreshSpinner = nil;
    self.refreshArrow = nil;
    self.filterImageView = nil;
    self.topBar = nil;
  }
}

- (void) viewWillAppear:(BOOL)animated {
  [self removeAllPins];
  [[[GameState sharedGameState] attackList] removeAllObjects];
  [[[GameState sharedGameState] attackMapList] removeAllObjects];
  
  [self.attackTableView reloadData];
  
  [[OutgoingEventController sharedOutgoingEventController] generateAttackList:THRESHOLD_ENEMIES_ATTACK_LIST];
  if (_loaded) {
    [self retrieveAttackListForCurrentBounds];
  }
  [self.mapSpinner startAnimating];
  self.mapSpinner.hidden = NO;
  
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
}

- (void) viewWillDisappear:(BOOL)animated {
  [self removeAllPins];
  [[[GameState sharedGameState] attackList] removeAllObjects];
  [[[GameState sharedGameState] attackMapList] removeAllObjects];
  self.mapView.showsUserLocation = NO;
}

- (void) setState:(AttackListState)state {
  _state = state;
  
  switch (state) {
    case kLocationMap:
      listTabView.hidden = YES;
      locationTabView.hidden = NO;
      
      if ([CLLocationManager locationServicesEnabled]) {
        _mapView.showsUserLocation = YES;
      } else {
        _mapView.showsUserLocation = NO;
      }
      break;
      
    case kAttackList:
      listTabView.hidden = NO;
      locationTabView.hidden = YES;
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
  NSMutableArray *arr = [[GameState sharedGameState] attackMapList];
  int userLocEnabled = _mapView.showsUserLocation ? 1 : 0;
  int i = _mapView.annotations.count == 0 ? 0 : _mapView.annotations.count-userLocEnabled;
  for (; i < arr.count; i++) {
    EnemyAnnotation *annotation = [[EnemyAnnotation alloc] initWithPlayer:[arr objectAtIndex:i]];
    [_mapView addAnnotation:annotation];
    [annotation release];
  }
  
  if (arr.count > 0) {
    [self.mapSpinner stopAnimating];
    self.mapSpinner.hidden = YES;
  }
}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  _loaded = YES;
  
  // Make sure it doesnt become too zoomed in for privacy purposes
  MKCoordinateRegion rect = mapView.region;
  BOOL change = NO;
  if (rect.span.latitudeDelta < MIN_LATITUDE) {
    rect.span.latitudeDelta = MIN_LATITUDE;
    change = YES;
  }
  if (rect.span.longitudeDelta < MIN_LONGITUDE) {
    rect.span.longitudeDelta = MIN_LONGITUDE;
    change = YES;
  }
  
  if (change) {
    [mapView setRegion:rect animated:YES];
  }
  
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
    [self viewProfile:fup];
    [Analytics enemyProfileFromAttackMap];
  } else if (tag == 2) {
    // Right clicked
    [self battle:fup];
  }
}

- (void) viewProfile:(FullUserProto *)fup {
  [[ProfileViewController sharedProfileViewController] loadProfileForPlayer:fup buttonsEnabled:YES];
  [ProfileViewController displayView];
}

- (void) battle:(FullUserProto *)fup {
  // BattleLayer will fade out view
  [[BattleLayer sharedBattleLayer] beginBattleAgainst:fup inCity:0];
}

- (void) mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
  [[OutgoingEventController sharedOutgoingEventController] changeUserLocationWithCoordinate:userLocation.location.coordinate];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  GameState *gs = [GameState sharedGameState];
  int ct = gs.attackList.count;
  
  if (ct > 0) {
    [self.listSpinner stopAnimating];
    self.listSpinner.hidden = YES;
  } else {
    [self.listSpinner startAnimating];
    self.listSpinner.hidden = NO;
  }
  
  return ct;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  AttackListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttackListCell"];
  
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed:@"AttackListCell" owner:self options:nil];
    cell = self.listCell;
  }
  
  GameState *gs = [GameState sharedGameState];
  [cell updateForUser:[gs.attackList objectAtIndex:indexPath.row]];
  
  return cell;
}

- (IBAction)closeClicked:(id)sender {
  [self close];
}

- (void) refresh {
  [[OutgoingEventController sharedOutgoingEventController] generateAttackList:THRESHOLD_ENEMIES_ATTACK_LIST];
  [[[GameState sharedGameState] attackList] removeAllObjects];
  [self.attackTableView reloadData];
  [self stopLoading];
}

- (void) close {
  if (self.view.superview) {
    [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^(void) {
      [AttackMenuController removeView];
    }];
  }
}

@end
