//
//  HomeMap.m
//  Utopia
//
//  Created by Ashwin Kamath on 2/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "HomeMap.h"
#import "Building.h"
#import "Globals.h"
#import "GameState.h"
#import "UserData.h"
#import "SynthesizeSingleton.h"
#import "OutgoingEventController.h"

#define LEFT_STAR_OFFSET 8
#define MAX_STARS 5

#define UPGRADE_VIEW_LINE_YOFFSET 28.f
#define UPGRADE_VIEW_LINE_XOFFSET 14.f

#define HOME_BUILDING_TAG_OFFSET 123456

#define PROGRESS_BAR_SPEED 2.f

@implementation UpgradeButtonOverlay

@synthesize fullStar, emptyStar;
@synthesize level;

- (id) initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    fullStar = [[UIImage imageNamed:@"fullstar.png"] retain];
    emptyStar = [[UIImage imageNamed:@"emptystar.png"] retain];
    self.level = 1;
    self.userInteractionEnabled = NO;
  }
  return self;
}

- (void) setLevel:(int)lev {
  if (level != lev) {
    level = lev;
    [self setNeedsDisplay];
  }
}

- (void) drawRect:(CGRect)rect {
  [super drawRect:rect];
  
  int y = CGRectGetMidY(self.bounds)-fullStar.size.height/2;
  int width = fullStar.size.width;
  
  int i;
  for (i = 0; i < level  && i < MAX_STARS; i++) {
    [fullStar drawAtPoint:CGPointMake(LEFT_STAR_OFFSET+i*width, y)];
  }
  for (; i < MAX_STARS; i++) {
    [emptyStar drawAtPoint:CGPointMake(LEFT_STAR_OFFSET+i*width, y)];
  }
}

- (void) dealloc {
  self.fullStar = nil;
  self.emptyStar = nil;
  [super dealloc];
}

@end

@implementation HomeBuildingInfoView

@synthesize sellView, incomeView, starView;
@synthesize upgradeButton;
@synthesize sellCostLabel, sellCoinImageView;

- (void) awakeFromNib {
  self.backgroundColor = [UIColor clearColor];
  self.incomeView.frame = self.sellView.frame;
  starView = [[UpgradeButtonOverlay alloc] initWithFrame:upgradeButton.bounds];
  [starView setBackgroundColor:[UIColor clearColor]];
  [self.upgradeButton addSubview:starView];
}

- (void) setSellCostString:(NSString *)s {
  self.sellCostLabel.text = s;
  CGSize size = [s sizeWithFont:self.sellCostLabel.font];
  CGRect rect = sellCostLabel.frame;
  rect.origin.x = CGRectGetMaxX(rect)-size.width;
  rect.size.width = size.width;
  sellCostLabel.frame = rect;
  
  rect = sellCoinImageView.frame;
  rect.origin.x = sellCostLabel.frame.origin.x - rect.size.width;
  sellCoinImageView.frame = rect;
}

- (void) drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetLineWidth(context, 1.f);
  CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
  
  CGRect f = sellView.frame;
  // Draw black lines
  CGContextMoveToPoint(context, CGRectGetMinX(f), CGRectGetMinY(f));
  CGContextAddLineToPoint(context, CGRectGetMaxX(f), CGRectGetMinY(f));
  CGContextMoveToPoint(context, CGRectGetMinX(f), CGRectGetMaxY(f));
  CGContextAddLineToPoint(context, CGRectGetMaxX(f), CGRectGetMaxY(f));
  
	CGContextStrokePath(context);
  
  CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.15);
  // Draw white lines
  float offset = 0.5;
  CGContextMoveToPoint(context, CGRectGetMinX(f), CGRectGetMinY(f)+offset);
  CGContextAddLineToPoint(context, CGRectGetMaxX(f), CGRectGetMinY(f)+offset);
  CGContextMoveToPoint(context, CGRectGetMinX(f), CGRectGetMaxY(f)+offset);
  CGContextAddLineToPoint(context, CGRectGetMaxX(f), CGRectGetMaxY(f)+offset);
  
	CGContextStrokePath(context);
}

@end

@implementation HomeBuildingUpgradeView

@synthesize costView, costLabel;

- (void) awakeFromNib {
  self.backgroundColor = [UIColor clearColor];
}

- (void) setUpgradeCostString:(NSString *)s {
  self.costLabel.text = s;
  CGSize size = [s sizeWithFont:self.costLabel.font];
  CGRect labelRect = costLabel.frame;
  
  CGRect viewRect = costView.frame;
  viewRect.size.width -= labelRect.size.width - size.width;
  costView.frame = viewRect;
  
  labelRect.size.width = size.width;
  costLabel.frame = labelRect;
  
  costView.center = CGPointMake(CGRectGetMidX(self.frame), costView.center.y);
}

- (void) drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetLineWidth(context, 1.f);
  CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
  
  // Draw black lines
  float y = UPGRADE_VIEW_LINE_YOFFSET;
  float x = UPGRADE_VIEW_LINE_XOFFSET;
  CGContextMoveToPoint(context, x, y);
  CGContextAddLineToPoint(context, CGRectGetMaxX(self.frame)-x, y);
  
	CGContextStrokePath(context);
  
  CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.15);
  // Draw white lines
  float offset = 0.5;
  CGContextMoveToPoint(context, x, y+offset);
  CGContextAddLineToPoint(context, CGRectGetMaxX(self.frame)-x, y+offset);
  
	CGContextStrokePath(context);
}

@end

@implementation HomeBuildingMenu

@synthesize titleLabel;
@synthesize blueButton, redButton, greenButton;
@synthesize infoView, upgradeView, progressView;
@synthesize state  = _state;
@synthesize mainView, moveView;
@synthesize timer, retrievalTime;
@synthesize upgradeTime, totalUpgradeTime;
@synthesize incomeLabel, upgradeCurIncomeLabel, upgradeNewIncomeLabel, retrieveTimeLabel;
@synthesize instaFinishCostLabel, finishTimeLabel, progressBar;
@synthesize finishNowButton;

- (void) awakeFromNib {
  [super awakeFromNib];
  [self.mainView insertSubview:infoView aboveSubview:titleLabel];
  [self.mainView insertSubview:upgradeView aboveSubview:titleLabel];
  [self.mainView insertSubview:progressView aboveSubview:titleLabel];
  self.state = kNormalState;
  greenButton.text = @"Upgrade";
  [Globals adjustFontSizeForUILabel:titleLabel];
  titleLabel.text = @"Executioner Arena";
  
  [self addSubview:moveView];
  int width = moveView.frame.size.width;
  int height = moveView.frame.size.height;
  moveView.frame = CGRectMake(CGRectGetMidX(self.frame)-width/2, CGRectGetMaxY(self.frame)-height, width, height);
  
  self.hidden = YES;
}

- (void) setState:(HomeBuildingState)state {
  if (_state != state) {
    _state = state;
    switch (state) {
      case kNormalState:
        blueButton.text = @"Move";
        blueButton.enabled = YES;
        redButton.hidden = NO;
        redButton.text = @"Sell";
        redButton.enabled = YES;
        infoView.hidden = NO;
        infoView.sellView.hidden = YES;
        infoView.incomeView.hidden = NO;
        upgradeView.hidden = YES;
        progressView.hidden = YES;
        mainView.hidden = NO;
        moveView.hidden = YES;
        break;
        
      case kSellState:
        blueButton.text = @"Cancel";
        redButton.text = @"Ok, Sell";
        infoView.sellView.hidden = NO;
        infoView.incomeView.hidden = YES;
        break;
        
      case kUpgradeState:
        blueButton.text = @"Cancel";
        upgradeView.hidden = NO;
        redButton.hidden = YES;
        infoView.hidden = YES;
        break;
        
      case kProgressState:
        mainView.hidden = NO;
        moveView.hidden = YES;
        blueButton.text = @"Move";
        upgradeView.hidden = YES;
        redButton.hidden = NO;
        progressView.hidden = NO;
        redButton.enabled = NO;
        infoView.hidden = YES;
        finishNowButton.enabled = YES;
        break;
        
      case kMoveState:
        mainView.hidden = YES;
        moveView.hidden = NO;
        
      default:
        break;
    }
  }
}

- (void) updateTimes {
  if (_state == kProgressState) {
    int t = MAX([upgradeTime timeIntervalSinceNow], 0);
    self.finishTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", t/3600, t/60%60, t%60];
    
    // Adjust the progress bar appropriately
    [self setProgressBarProgress:(1-t/totalUpgradeTime)];
  } else {
    int t = MAX([retrievalTime timeIntervalSinceNow], 0);
    self.retrieveTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", t/3600, t/60%60, t%60];
  }
}

- (void) setTimer:(NSTimer *)t {
  [timer invalidate];
  [timer release];
  timer = [t retain];
}

- (void) startTimer {
  [self updateTimes];
  self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateTimes) userInfo:nil repeats:YES];
  [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void) setHidden:(BOOL)hidden {
  [super setHidden:hidden];
  [self.timer invalidate];
  if (!hidden) {
    [self updateTimes];
    [self startTimer];
  }
}

- (void) setProgressBarProgress:(float)val {
  // Float from 0 to 1
  int width = progressBar.image.size.width;
  CGRect r = progressBar.frame;
  r.size.width = clampf(width * val, 0, width);
  progressBar.frame = r;
}

- (float) progressBarProgress {
  int width = progressBar.image.size.width;
  return progressBar.frame.size.width/width;
}

- (void) updateLabelsForUserStruct:(UserStruct *)us {
  if (!us) {
    return;
  }
  
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  Globals *gl = [Globals sharedGlobals];
  
  self.titleLabel.text = fsp.name;
  
  UserStructState s = us.state;
  // Convert to normal state first to ensure normal transition
  if (s == kBuilding) {
    // First build phase
    self.state = kProgressState;
    int secs = fsp.minutesToBuild*60;
    self.upgradeTime = [NSDate dateWithTimeInterval:secs sinceDate:us.purchaseTime];
    self.totalUpgradeTime = secs;
    [self updateTimes];
    self.instaFinishCostLabel.text = [Globals commafyNumber:[gl calculateDiamondCostForInstaBuild:us]];
  } else if (s == kUpgrading) {
    // Upgrading..
    self.state = kProgressState;
    int secs = [gl calculateMinutesToUpgrade:us]*60;
    self.upgradeTime = [NSDate dateWithTimeInterval:secs sinceDate:us.lastUpgradeTime];
    self.totalUpgradeTime = secs;
    [self updateTimes];
    self.instaFinishCostLabel.text = [Globals commafyNumber:[gl calculateDiamondCostForInstaUpgrade:us]];
  } else {
    self.state = kNormalState;
    self.retrievalTime = [NSDate dateWithTimeInterval:fsp.minutesToGain*60 sinceDate:us.lastRetrieved];
    [self updateTimes];
    self.incomeLabel.text = [NSString stringWithFormat:@"+%@", [Globals commafyNumber:[gl calculateIncomeForUserStruct:us]]];
    self.infoView.starView.level = us.level;
    [self.infoView setSellCostString:[Globals commafyNumber:[gl calculateSellCost:us]]];
    
    self.upgradeCurIncomeLabel.text = [Globals commafyNumber:[gl calculateIncomeForUserStruct:us]];
    self.upgradeNewIncomeLabel.text = [Globals commafyNumber:[gl calculateIncomeForUserStructAfterLevelUp:us]];
    [self.upgradeView setUpgradeCostString:[Globals commafyNumber:[gl calculateUpgradeCost:us]]];
  }
}

- (void) setFrameForPoint:(CGPoint)pt {
  // place it so that the bottom middle is at pt
  // Remember, frame is relative to top left corner
  float width = self.frame.size.width;
  float height = self.frame.size.height;
  self.frame = CGRectMake(pt.x-width/2, ([[CCDirector sharedDirector] winSize].height - pt.y)-height, width, height);
}

- (void) dealloc {
  [self.timer invalidate];
  self.timer = nil;
  [super dealloc];
}

@end

@implementation HomeMap

@synthesize buildableData = _buildableData;
@synthesize hbMenu;
@synthesize loading = _loading;

SYNTHESIZE_SINGLETON_FOR_CLASS(HomeMap);

- (id) init {
  self = [self initWithTMXFile:@"iso-test2.tmx"];
  return self;
}

- (id) initWithTMXFile:(NSString *)tmxFile {
  
  if ((self = [super initWithTMXFile:tmxFile])) {
    self.buildableData = [NSMutableArray arrayWithCapacity:[self mapSize].width];
    
    for (CCTMXLayer *child in [self children]) {
      if ([[child layerName] isEqualToString: @"MetaLayer"])
        // Put meta tile layer at front, 
        // when something is selected, we will make it z = 1000
        [self reorderChild:child z:1001];
      else
        [self reorderChild:child z:-1];
    }
    
    CCTMXLayer *blocked = [self layerNamed:@"Blocked"];
    
    for (int i = 0; i < self.mapSize.width; i++) {
      NSMutableArray *row = [NSMutableArray arrayWithCapacity:self.mapSize.height];
      for (int j = 0; j < self.mapSize.height; j++) {
        CGPoint tileCoord = ccp(63-j, 63-i);
        int tileGid = [blocked tileGIDAt:tileCoord];
        if (tileGid) {
          NSDictionary *properties = [self propertiesForGID:tileGid];
          if (properties) {
            NSString *collision = [properties valueForKey:@"Buildable"];
            if (collision && [collision compare:@"No"] == NSOrderedSame) {
              [row addObject:[NSNumber numberWithBool:NO]];
              continue;
            }
          }
        }
        [row addObject:[NSNumber numberWithBool:YES]];
      }
      [self.buildableData addObject:row];
    }
    
    [[NSBundle mainBundle] loadNibNamed:@"HomeBuildingMenu" owner:self options:nil];
    [[[CCDirector sharedDirector] openGLView] addSubview:self.hbMenu];
    self.hbMenu.frame = CGRectMake(100, 100, self.hbMenu.frame.size.width, self.hbMenu.frame.size.height);
    
    self.hbMenu.greenButton.label.shadowColor = [UIColor darkGrayColor];
    self.hbMenu.greenButton.label.shadowOffset = CGSizeMake(1, 1);
    
    _loading = YES;
    
    _timers = [[NSMutableArray alloc] init];
  }
  return self;
}

- (int) baseTagForStructId:(int)structId {
  return [[Globals sharedGlobals] maxRepeatedNormStructs]*structId+HOME_BUILDING_TAG_OFFSET;
}

- (void) refresh {
  _constrBuilding = nil;
  _upgrBuilding = nil;
  _loading = YES;
  
  // Invalidate all timers
  [_timers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSTimer *t = (NSTimer *)obj;
    [t invalidate];
  }];
  [_timers removeAllObjects];
  
  NSMutableArray *arr = [NSMutableArray array];
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  int i = 0;
  for (UserStruct *s in [gs myStructs]) {
    int tag = [self baseTagForStructId:s.structId];
    HomeBuilding *hb = (HomeBuilding *)[self getChildByTag:tag];
    
    int offset = 0;
    while (hb && [arr containsObject:hb]) {
      offset++;
      if (offset >= [gl maxRepeatedNormStructs]) {
        hb = nil;
        break;
      }
      // Check if we already assigned this building and it is in arr.
      hb = (HomeBuilding *)[self getChildByTag:tag+offset];
    }
    
    FullStructureProto *fsp = [gs structWithId:s.structId];
    CGRect loc = CGRectMake(s.coordinates.x, s.coordinates.y, fsp.xLength, fsp.yLength);
    if (!hb) {
      hb = [[HomeBuilding alloc] initWithFile:[Globals imageNameForStruct:s.structId] location:loc map:self];
      [self addChild:hb z:0 tag:tag+offset];
      [hb release];
      
      i++;
    } else {
      [hb liftBlock];
      hb.location = loc;
    }
    
    hb.userStruct = s;
    [_timers removeObject:hb.timer];
    
    UserStructState st = s.state;
    switch (st) {
      case kUpgrading:
        hb.retrievable = NO;
        _upgrBuilding = hb;
        break;
        
      case kBuilding:
        hb.retrievable = NO;
        _constrBuilding = hb;
        break;
        
      case kWaitingForIncome:
        hb.retrievable = NO;
        break;
        
      case kRetrieving:
        hb.retrievable = YES;
        break;
        
      default:
        break;
    }
    [self updateTimersForBuilding:hb];
    
    [arr addObject:hb];
    [hb placeBlock];
  }
  
  CCNode *c;
  CCARRAY_FOREACH(self.children, c) {
    if ([c isKindOfClass:[SelectableSprite class]] && ![arr containsObject:c]) {
      if ([c isKindOfClass:[HomeBuilding class]]) {
        [(HomeBuilding *)c liftBlock];
      }
      [self removeChild:c cleanup:YES];
    }
  }
  
  [self doReorder];
  _loading = NO;
}

- (void) doReorder {
  [super doReorder];
  
  if (_isMoving || ([_selected isKindOfClass:[HomeBuilding class]] && !((HomeBuilding *)_selected).isSetDown)) {
    [self reorderChild:_selected z:1000];
  }
}

- (void) setPosition:(CGPoint)position {
  [super setPosition:position];
  [self updateHomeBuildingMenu];
}

- (void) updateHomeBuildingMenu {
  if (_selected && [_selected class] == [HomeBuilding class]) {
    CGPoint pt = [_selected convertToWorldSpace:ccp(_selected.contentSize.width/2, _selected.contentSize.height-OVER_HOME_BUILDING_MENU_OFFSET)];
    [hbMenu setFrameForPoint:pt];
    hbMenu.hidden = NO;
  } else {
    hbMenu.hidden = YES;
  }
}

- (void) preparePurchaseOfStruct:(int)structId {
  if (_purchasing || _constrBuilding) {
    [Globals popupMessage:[NSString stringWithFormat:@"Already %@ a building.", _purchasing ? @"purchasing" : @"constructing"]];
    return;
  }
  
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:structId];
  CGRect loc = CGRectMake(0, 0, fsp.xLength, fsp.yLength);
  _purchBuilding = [[HomeBuilding alloc] initWithFile:[Globals imageNameForStruct:structId] location:loc map:self];
  int baseTag = [self baseTagForStructId:structId];
  int tag;
  for (tag = baseTag; tag < baseTag+[[Globals sharedGlobals] maxRepeatedNormStructs]; tag++) {
    if (![self getChildByTag:tag]) {
      break;
    }
  }
  [self addChild:_purchBuilding z:0 tag:tag];
  [_purchBuilding release];
  
  self.selected = _purchBuilding;
  self.hbMenu.state = kMoveState;
  _canMove = YES;
  _purchasing = YES;
  _purchStructId = structId;
  
  [self doReorder];
}

- (void) setSelected:(SelectableSprite *)selected {
  if (_selected != selected) {
    if ([selected class] == [HomeBuilding class]) {
      [super setSelected:nil];
      [self.hbMenu updateLabelsForUserStruct:((HomeBuilding *) selected).userStruct];
      [self updateHomeBuildingMenu];
    }
    [super setSelected:selected];
    [self updateHomeBuildingMenu];
  }
}

- (void) drag:(UIGestureRecognizer*)recognizer node:(CCNode*)node
{
  // First check if a sprite was clicked
  CGPoint pt = [recognizer locationInView:recognizer.view];
  pt = [[CCDirector sharedDirector] convertToGL:pt];
  pt = [self convertToNodeSpace:pt];
  
  if (_canMove) {
    if ([_selected class] == [HomeBuilding class]) {
      HomeBuilding *homeBuilding = (HomeBuilding *)_selected;
      if([recognizer state] == UIGestureRecognizerStateBegan ) {
        // This fat statement just checks that the drag touch is somewhere closeby the selected sprite
        if (CGRectContainsPoint(CGRectMake(_selected.position.x-_selected.contentSize.width/2*_selected.scale-20, _selected.position.y-20, _selected.contentSize.width*_selected.scale+40, _selected.contentSize.height*_selected.scale+40), pt)) {
          [homeBuilding setStartTouchLocation: pt];
          [homeBuilding liftBlock];
          
          [homeBuilding updateMeta];
          _isMoving = YES;
          [self updateHomeBuildingMenu];
          return;
        }
      } else if (_isMoving && [recognizer state] == UIGestureRecognizerStateChanged) {
        [self scrollScreenForTouch:pt];
        [homeBuilding clearMeta];
        [homeBuilding locationAfterTouch:pt];
        [homeBuilding updateMeta];
        [self updateHomeBuildingMenu];
        return;
      } else if (_isMoving && [recognizer state] == UIGestureRecognizerStateEnded) {
        [homeBuilding clearMeta];
        [homeBuilding placeBlock];
        _isMoving = NO;
        [self doReorder];
        return;
      }
    }
  }
  
  [super drag:recognizer node:node];
}

- (void) tap:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  // Reimplement for retrievals and moving buildings
  if (!_canMove) {
    CGPoint pt = [recognizer locationInView:recognizer.view];
    pt = [[CCDirector sharedDirector] convertToGL:pt];
    
    if (_selected && ![_selected isPointInArea:pt]) {
      self.selected = nil;
      [self doReorder];
    }
    SelectableSprite *sel = [self selectableForPt:pt];
    
    if ([sel isKindOfClass:[HomeBuilding class]]) {
      HomeBuilding *hb = (HomeBuilding *)sel;
      if (hb.retrievable) {
        // Retrieve the cash!
        [self retrieveFromBuilding:hb];
        return;
      }
    }
    self.selected = sel;
  }
}

- (void) scale:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  [super scale:recognizer node:node];
}

- (void) scrollScreenForTouch:(CGPoint)pt {
//  CGPoint relPt = [self convertToNodeSpace:pt];
  // TODO: Implement this
  // As you get closer to edge, it scrolls faster
}

- (void) updateTimersForBuilding:(HomeBuilding *)hb {
  [_timers removeObject:hb.timer];
  [hb createTimerForCurrentState];
  
  if (hb.timer) {
    [[NSRunLoop mainRunLoop] addTimer:hb.timer forMode:NSRunLoopCommonModes];
    [_timers addObject:hb.timer];
  }
}

- (void) retrieveFromBuilding:(HomeBuilding *)hb {
  [[OutgoingEventController sharedOutgoingEventController] retrieveFromNormStructure:hb.userStruct];
  if (hb.userStruct.state == kWaitingForIncome) {
    hb.retrievable = NO;
    [self updateTimersForBuilding:hb];
  }
}

- (void) upgradeComplete:(NSTimer *)timer {
  HomeBuilding *hb = [timer userInfo];
  [Globals popupMessage:@"Upgrade Completed"];
  [[OutgoingEventController sharedOutgoingEventController] normStructWaitComplete:hb.userStruct];
  [self updateTimersForBuilding:hb];
}

- (void) buildComplete:(NSTimer *)timer {
  HomeBuilding *hb = [timer userInfo];
  [Globals popupMessage:@"Build Completed"];
  [[OutgoingEventController sharedOutgoingEventController] normStructWaitComplete:hb.userStruct];
  [self updateTimersForBuilding:hb];
}

- (void) waitForIncomeComplete:(NSTimer *)timer {
  HomeBuilding *hb = [timer userInfo];
  hb.retrievable = YES;
  
  if (hb == _selected) {
    self.selected = nil;
  }
}

- (IBAction)leftButtonClicked:(id)sender {
  if (hbMenu.state == kSellState || hbMenu.state == kUpgradeState) {
    // Cancel Clicked
    hbMenu.state = kNormalState;
  } else {
    // Move Clicked
    _canMove = YES;
    hbMenu.state = kMoveState;
  }
}

- (IBAction)moveCheckClicked:(id)sender {
  HomeBuilding *homeBuilding = (HomeBuilding *)_selected;
  _canMove = NO;
  self.selected = nil;
  [self doReorder];
  if (_purchasing) {
    _purchasing = NO;
    // Use return value as an indicator that purchase is accepted by client
    UserStruct *us = [[OutgoingEventController sharedOutgoingEventController] purchaseNormStruct:_purchStructId atX:homeBuilding.location.origin.x atY:homeBuilding.location.origin.y];
    if (us) {
      homeBuilding.userStruct = us;
      _constrBuilding = homeBuilding;
    } else {
      [homeBuilding liftBlock];
      [self removeChild:homeBuilding cleanup:YES];
    }
    [self refresh];
  } else {
    [[OutgoingEventController sharedOutgoingEventController] moveNormStruct:homeBuilding.userStruct atX:homeBuilding.location.origin.x atY:homeBuilding.location.origin.y];
  }
}

- (IBAction)rotateClicked:(id)sender {
  [_selected setFlipX:!_selected.flipX];
}

- (IBAction)cancelMoveClicked:(id)sender {
  if (_purchasing) {
    self.selected = nil;
    [_purchBuilding liftBlock];
    [self removeChild:_purchBuilding cleanup:YES];
    _canMove = NO;
    _purchasing = NO;
  } else {
    HomeBuilding *hb = (HomeBuilding *)_selected;
    [hb cancelMove];
    _canMove = NO;
    self.selected = nil;
    [self doReorder];
  }
}

- (IBAction)redButtonClicked:(id)sender {
  if (hbMenu.state == kNormalState) {
    hbMenu.state = kSellState;
  } else if (hbMenu.state == kSellState) {
    // Do real sell
    UserStruct *us = ((HomeBuilding *)_selected).userStruct;
    int structId = us.structId;
    [[OutgoingEventController sharedOutgoingEventController] sellNormStruct:us];
    if (![[[GameState sharedGameState] myStructs] containsObject:us]) {
      HomeBuilding *spr = (HomeBuilding *)self.selected;
      self.selected = nil;
      [spr liftBlock];
      [_timers removeObject:spr.timer];
      spr.timer = nil;
      [self removeChild:spr cleanup:YES];
      
      // Fix tag fragmentation
      int tag = [self baseTagForStructId:structId];
      int renameTag = tag;
      for (int i = tag; i < tag+[[Globals sharedGlobals] maxRepeatedNormStructs]; i++) {
        CCNode *c = [self getChildByTag:i];
        if (c) {
          [c setTag:renameTag];
          renameTag++;
        }
      }
    }
  }
}

- (IBAction)bigUpgradeClicked:(id)sender {
  hbMenu.state = kUpgradeState;
}

- (IBAction)littleUpgradeClicked:(id)sender {
  UserStruct *us = ((HomeBuilding *)_selected).userStruct;
  [[OutgoingEventController sharedOutgoingEventController] upgradeNormStruct:us];
  [self updateTimersForBuilding:(HomeBuilding *)_selected];
  [self.hbMenu updateLabelsForUserStruct:us];
}

- (IBAction)finishNowClicked:(id)sender {
  HomeBuilding *hb = (HomeBuilding *)_selected;
  UserStructState state = hb.userStruct.state;
  self.hbMenu.finishNowButton.enabled = NO;
  self.hbMenu.blueButton.enabled = NO;
  if (state == kUpgrading) {
    [[OutgoingEventController sharedOutgoingEventController] instaUpgrade:((HomeBuilding *)_selected).userStruct];
  } else if (state == kBuilding) {
    [[OutgoingEventController sharedOutgoingEventController] instaBuild:((HomeBuilding *)_selected).userStruct];
  }
  if (hb.userStruct.state == kWaitingForIncome) {
    if (_selected == _constrBuilding) {
      _constrBuilding = nil;
    } else if (_selected == _upgrBuilding) {
      _upgrBuilding = nil;
    } else {
      [Globals popupMessage:@"This should never come up.. Inconsistent state in HomeMap->finishNowClicked"];
    }
    
    [[[CCDirector sharedDirector] openGLView] setUserInteractionEnabled:NO];
    // animate bar to top
    [self.hbMenu.timer invalidate];
    float secs = PROGRESS_BAR_SPEED*(1-[self.hbMenu progressBarProgress]);
    [UIView animateWithDuration:secs animations:^{
      [self.hbMenu setProgressBarProgress:1.f];
    } completion:^(BOOL finished) {
      [self.hbMenu updateLabelsForUserStruct:hb.userStruct];
      [self.hbMenu startTimer];
      self.hbMenu.finishNowButton.enabled = YES;
      self.hbMenu.blueButton.enabled = YES;
      [[[CCDirector sharedDirector] openGLView] setUserInteractionEnabled:YES];
    }];
    [self updateTimersForBuilding:hb];
  } else {
    self.hbMenu.finishNowButton.enabled = YES;
    self.hbMenu.blueButton.enabled = YES;
  }
}

-(void) changeTiles: (CGRect) buildBlock toBuildable:(BOOL)canBuild {
  for (int i = buildBlock.origin.x; i < buildBlock.size.width+buildBlock.origin.x; i++) {
    for (int j = buildBlock.origin.y; j < buildBlock.size.height+buildBlock.origin.y; j++) {
      [[self.buildableData objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:canBuild]];
    }
  }
}

-(BOOL) isBlockBuildable: (CGRect) buildBlock {
  for (int i = buildBlock.origin.x; i < buildBlock.size.width+buildBlock.origin.x; i++) {
    for (int j = buildBlock.origin.y; j < buildBlock.size.height+buildBlock.origin.y; j++) {
      if (![[[self.buildableData objectAtIndex:i] objectAtIndex:j] boolValue]) {
        return NO;
      }
    }
  }
  return YES;
}

@end
