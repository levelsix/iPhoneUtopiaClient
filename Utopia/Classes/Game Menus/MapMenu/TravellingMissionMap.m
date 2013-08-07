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

#define CITY_POPUP_OFFSET -22.f
#define CITY_POPUP_OFFSET_FLIPPED 26.f

#define NUM_CITIES 22

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
  
  self.numlabel = [[[UILabel alloc] initWithFrame:CGRectMake(7, -0.5, 23, 26)] autorelease];
  [self addSubview:self.numlabel];
  self.numlabel.font = [UIFont fontWithName:[Globals font] size:15.f];
  [Globals adjustFontSizeForSize:15.f withUIView:self.numlabel];
  self.numlabel.backgroundColor = [UIColor clearColor];
  self.numlabel.textAlignment = NSTextAlignmentCenter;
  self.numlabel.textColor = [UIColor colorWithWhite:0.f alpha:0.7f];
  self.numlabel.shadowColor = [UIColor colorWithRed:206/255.f green:188/255.f blue:32/255.f alpha:1.f];
  self.numlabel.shadowOffset = CGSizeMake(0, 1);
  
  originalRect = self.frame;
}

- (void) setIsLocked:(BOOL)i {
  isLocked = i;
  
  Globals *gl = [Globals sharedGlobals];
  NSString *base = gl.downloadableNibConstants.mapNibName;
  if (!isLocked) {
    [self setImage:[Globals imageNamed:[base stringByAppendingString:@"/opencity.png"]] forState:UIControlStateNormal] ;
    self.numlabel.text = [NSString stringWithFormat:@"%d", fcp.cityId];
    self.numlabel.hidden = NO;
  } else {
    [self setImage:[Globals imageNamed:[base stringByAppendingString:@"/lockedcity.png"]] forState:UIControlStateNormal];
    self.numlabel.hidden = YES;
  }
  
  self.frame = originalRect;
  
  self.bossButton.hidden = YES;
  self.timer = nil;
}

- (void) setTimer:(NSTimer *)t {
  if (_timer != t) {
    [_timer invalidate];
    [_timer release];
    _timer = [t retain];
  }
}

- (void) updateForBossId:(int)bossId {
  if (!self.bossButton) {
    Globals *gl = [Globals sharedGlobals];
    NSString *base = gl.downloadableNibConstants.mapNibName;
    UIImage *img = [Globals imageNamed:[base stringByAppendingString:@"/bossbutton.png"]];
    self.bossButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bossButton setImage:img forState:UIControlStateNormal];
    
    [self.superview addSubview:self.bossButton];
    [self.bossButton addTarget:self action:@selector(bossButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(4 , 0, 61, 21)] autorelease];
    [self.bossButton addSubview:self.timeLabel];
    self.timeLabel.font = [UIFont fontWithName:[Globals font] size:12.f];
    [Globals adjustFontSizeForSize:12.f withUIView:self.timeLabel];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.textColor = [UIColor colorWithWhite:1.f alpha:1.f];
    self.timeLabel.shadowColor = [UIColor colorWithWhite:0.f alpha:0.5f];
    self.timeLabel.shadowOffset = CGSizeMake(0, 1);
  }
  
  GameState *gs = [GameState sharedGameState];
  FullBossProto *fbp = [gs bossWithId:bossId];
  UIImage *img = [Globals imageNamed:fbp.mapIconImageName];
  [self setImage:img forState:UIControlStateNormal];
  
  CGRect r = self.frame;
  r.size = img.size;
  r.origin.x -= 1;
  r.origin.y -= 15;
  self.frame = r;
  
  r = self.bossButton.frame;
  r.size = [self.bossButton imageForState:UIControlStateNormal].size;
  self.bossButton.frame = r;
  
  self.bossButton.center = ccp(self.center.x, CGRectGetMaxY(self.frame));
  
  self.bossButton.hidden = NO;
  self.numlabel.hidden = YES;
  _bossId = bossId;
  
  [self updateLabel];
  self.timer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void) updateLabel {
  GameState *gs = [GameState sharedGameState];
  
  UserBoss *ub = nil;
  for (UserBoss *b in gs.myBosses) {
    if (b.bossId == _bossId) {
      ub = b;
    }
  }
  
  self.timeLabel.text = [NSString stringWithFormat:@"%@ »", [ub timeTillEndString]];
}

- (void) bossButtonClicked {
  // Simulate self being clicked
  id target = [[self allTargets] anyObject];
  SEL selector = NSSelectorFromString([[self actionsForTarget:target forControlEvent:UIControlEventTouchUpInside] lastObject]);
  [target performSelector:selector withObject:self];
}

- (void) dealloc {
  self.fcp = nil;
  self.bossButton = nil;
  self.numlabel = nil;
  self.timeLabel = nil;
  self.timer = nil;
  [super dealloc];
}

@end

@implementation CloseUpContinentView

@synthesize cityPopup, cityNameLabel, cityRankLabel, progressLabel, progressBar;

- (void) reloadCities {
  GameState *gs = [GameState sharedGameState];
  for (int i = 1; i <= NUM_CITIES; i++) {
    FullCityProto *fcp = [gs cityWithId:i];
    UserCity *city = [gs myCityWithId:i];
    
    CityView *cv = (CityView *)[self viewWithTag:i];
    cv.fcp = fcp;
    cv.isLocked = (city == nil);
  }
  cityPopup.hidden = YES;
  
  for (UserBoss *b in gs.myBosses) {
    if ([b isAlive]) {
      FullBossProto *fbp = [gs bossWithId:b.bossId];
      CityView *cv = (CityView *)[self viewWithTag:fbp.cityId];
      [cv updateForBossId:b.bossId];
    }
  }
}

- (void) updatePopupForCity:(CityView *)cv {
  _fcp = cv.fcp;
  UserCity *uc = [[GameState sharedGameState] myCityWithId:_fcp.cityId];
  
  if (!cityPopup.superview) {
    [self.superview addSubview:cityPopup];
  }
  
  cityNameLabel.text = _fcp.name;
  cityRankLabel.text = [NSString stringWithFormat:@"Rank: %d", uc.curRank];
  progressLabel.text = [NSString stringWithFormat:@"%d/%d", uc.numTasksComplete, _fcp.taskIdsList.count];
  
  int offset = 0;
  if (cv.center.x < self.frame.size.width/2) {
    offset = CITY_POPUP_OFFSET_FLIPPED;
    self.cityBgdView.transform = CGAffineTransformMakeScale(-1, 1);
  } else {
    offset = CITY_POPUP_OFFSET;
    self.cityBgdView.transform = CGAffineTransformIdentity;
  }
  
  CGPoint pt = CGPointMake(cv.center.x+offset, cv.frame.origin.y-cityPopup.frame.size.height/2);
  cityPopup.center = [self convertPoint:pt toView:self.superview];
  
  float fullWidth = progressBar.image.size.width;
  CGRect r = progressBar.frame;
  int total = _fcp.taskIdsList.count > 0 ? _fcp.taskIdsList.count : 1;
  r.size.width = fullWidth * uc.numTasksComplete / total;
  progressBar.frame = r;
}

- (IBAction)cityClicked:(CityView *)cv {
  if (!cv.isLocked) {
    [self updatePopupForCity:cv];
    cityPopup.hidden = NO;
  } else {
    FullCityProto *fcp = cv.fcp;
    [Globals popupMessage:[NSString stringWithFormat:@"%@ is unlocked at Level %d.", fcp.name, fcp.minLevel]];
    [Globals shakeView:cv duration:SHAKE_DURATION offset:SHAKE_OFFSET];
  }
}

- (IBAction)goClicked:(id)sender {
  if (_fcp) {
    [[OutgoingEventController sharedOutgoingEventController] loadNeutralCity:_fcp.cityId];
  }
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
//  lumoriaView.frame = self.frame;
  [self.scrollView addSubview:lumoriaView];
  self.scrollView.contentSize = lumoriaView.frame.size;
//  [self.superview addSubview:self.lumoriaView];
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
  self.scrollView = nil;
  [super dealloc];
}

@end
