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
#import "GameLayer.h"
#import "RefillMenuController.h"
#import "CritStructPopupController.h"
#import "BuildUpgradePopupController.h"

#define LEFT_STAR_OFFSET 8
#define MAX_STARS 5

#define UPGRADE_VIEW_LINE_YOFFSET 28.f
#define UPGRADE_VIEW_LINE_XOFFSET 14.f

#define HOME_BUILDING_TAG_OFFSET 123456

@implementation UpgradeButtonOverlay

@synthesize fullStar, emptyStar;
@synthesize level;

- (id) initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    fullStar = [[Globals imageNamed:@"fullstar.png"] retain];
    emptyStar = [[Globals imageNamed:@"emptystar.png"] retain];
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
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  int y = CGRectGetMidY(self.bounds)-fullStar.size.height/2;
  int width = fullStar.size.width;
  
  int i;
  CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 10, [UIColor yellowColor].CGColor);
  for (i = 0; i < level  && i < MAX_STARS; i++) {
    [fullStar drawAtPoint:CGPointMake(LEFT_STAR_OFFSET+i*width, y)];
  }
  //  CGContextSetShadow(context, CGSizeMake(0, 0), 0);
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
@synthesize upgradeButton, coinIcon;
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
  rect.origin.x = sellCostLabel.frame.origin.x - rect.size.width-5;
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

- (void) dealloc {
  self.sellView = nil;
  self.incomeView = nil;
  self.starView = nil;
  self.upgradeButton = nil;
  self.coinIcon = nil;
  self.sellCostLabel = nil;
  self.sellCoinImageView = nil;
  [super dealloc];
}

@end

@implementation HomeBuildingUpgradeView

@synthesize costView, costLabel, upgradeCoinIcon;

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

- (void) dealloc {
  self.costView = nil;
  self.costLabel = nil;
  self.upgradeCoinIcon = nil;
  [super dealloc];
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
    
    if (fsp.coinPrice > 0) {
      [self.infoView setSellCostString:[Globals commafyNumber:[gl calculateStructSilverSellCost:us]]];
      self.infoView.coinIcon.highlighted = NO;
      self.upgradeView.upgradeCoinIcon.highlighted = NO;
    } else {
      [self.infoView setSellCostString:[Globals commafyNumber:[gl calculateStructGoldSellCost:us]]];
      self.infoView.coinIcon.highlighted = YES;
      self.upgradeView.upgradeCoinIcon.highlighted = YES;
    }
    
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
  self.titleLabel = nil;
  self.blueButton = nil;
  self.redButton = nil;
  self.greenButton = nil;
  self.infoView = nil;
  self.upgradeView = nil;
  self.progressView = nil;
  self.mainView = nil;
  self.moveView = nil;
  self.retrievalTime = nil;
  self.upgradeTime = nil;
  self.incomeLabel = nil;
  self.upgradeCurIncomeLabel = nil;
  self.upgradeNewIncomeLabel = nil;
  self.retrieveTimeLabel = nil;
  self.instaFinishCostLabel = nil;
  self.finishTimeLabel = nil;
  self.finishNowButton = nil;
  self.progressBar = nil;
  [super dealloc];
}

@end

@implementation HomeMap

@synthesize buildableData = _buildableData;
@synthesize hbMenu;
@synthesize loading = _loading;
@synthesize redGid, greenGid;

SYNTHESIZE_SINGLETON_FOR_CLASS(HomeMap);

- (id) init {
  self = [self initWithTMXFile:@"Home.tmx"];
  return self;
}

- (id) initWithTMXFile:(NSString *)tmxFile {
  if ((self = [super initWithTMXFile:tmxFile])) {
    self.buildableData = [NSMutableArray arrayWithCapacity:[self mapSize].width];
    
    for (CCNode *child in [self children]) {
      if ([child isKindOfClass:[CCTMXLayer class]]) {
        CCTMXLayer *layer = (CCTMXLayer *)child;
        if ([[layer layerName] isEqualToString: @"MetaLayer"]) {
          // Put meta tile layer at front, 
          // when something is selected, we will make it z = 1000
          [self reorderChild:layer z:1001];
          CGPoint redGidPt = ccp(mapSize_.width-1, mapSize_.height-1);
          CGPoint greenGidPt = ccp(mapSize_.width-1, mapSize_.height-2);
          redGid = [layer tileGIDAt:redGidPt];
          greenGid = [layer tileGIDAt:greenGidPt];
          [layer removeTileAt:redGidPt];
          [layer removeTileAt:greenGidPt];
        }
        else {
          [self reorderChild:layer z:-1];
        }
      }
    }
    
    self.buildableData = [NSMutableArray arrayWithCapacity:[self mapSize].width];
    for (int i = 0; i < self.mapSize.width; i++) {
      NSMutableArray *row = [NSMutableArray arrayWithCapacity:self.mapSize.height];
      for (int j = 0; j < self.mapSize.height; j++) {
        [row addObject:[NSNumber numberWithBool:NO]];
      }
      [self.buildableData addObject:row];
    }
    
    int width = self.mapSize.width;
    int height = self.mapSize.height;
    for (CCNode *node in self.children) {
      if (![node isKindOfClass:[CCTMXLayer class]]) {
        continue;
      }
      CCTMXLayer *layer = (CCTMXLayer *)node;
      
      for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
          NSMutableArray *row = [self.buildableData objectAtIndex:i];
          NSNumber *curVal = [row objectAtIndex:j];
          if (curVal.boolValue == NO) {
            // Convert their coordinates to our coordinate system
            CGPoint tileCoord = ccp(height-j-1, width-i-1);
            int tileGid = [layer tileGIDAt:tileCoord];
            if (tileGid) {
              NSDictionary *properties = [self propertiesForGID:tileGid];
              if (properties) {
                NSString *collision = [properties valueForKey:@"Buildable"];
                if (collision && [collision isEqualToString:@"Yes"]) {
                  [row replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:YES]];
                }
              }
            }
          }
        }
      }
    }
    
    [[NSBundle mainBundle] loadNibNamed:@"HomeBuildingMenu" owner:self options:nil];
    [[[[CCDirector sharedDirector] openGLView] superview] addSubview:self.hbMenu];
    [[[CCDirector sharedDirector] openGLView] setUserInteractionEnabled:YES];
    
    self.hbMenu.greenButton.label.shadowColor = [UIColor colorWithWhite:0.f alpha:0.3f];
    self.hbMenu.greenButton.label.shadowOffset = CGSizeMake(1, 1);
    
    _loading = YES;
    
    _timers = [[NSMutableArray alloc] init];
  }
  return self;
}

- (int) baseTagForStructId:(int)structId {
  return [[Globals sharedGlobals] maxRepeatedNormStructs]*structId+HOME_BUILDING_TAG_OFFSET;
}

- (void) invalidateAllTimers {
  // Invalidate all timers
  [_timers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSTimer *t = (NSTimer *)obj;
    [t invalidate];
  }];
  [_timers removeAllObjects];
}

- (void) backgroundRefresh {
  // Need this to be able to run on background thread
  EAGLContext *k_context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1 sharegroup:[[[[CCDirector sharedDirector] openGLView] context] sharegroup]] autorelease];
  [EAGLContext setCurrentContext:k_context];
  
  @synchronized(self) {
    [self refresh];
  }
}

- (void) beginTimers {
  for (CCNode *node in children_) {
    if ([node isKindOfClass:[MoneyBuilding class]]) {
      [self updateTimersForBuilding:(MoneyBuilding *)node];
    }
  }
}

- (void) refresh {
  _constrBuilding = nil;
  _upgrBuilding = nil;
  _loading = YES;
  
  [self invalidateAllTimers];
  
  NSMutableArray *arr = [NSMutableArray array];
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  for (UserStruct *s in [gs myStructs]) {
    int tag = [self baseTagForStructId:s.structId];
    MoneyBuilding *moneyBuilding = (MoneyBuilding *)[self getChildByTag:tag];
    
    int offset = 0;
    while (moneyBuilding && [arr containsObject:moneyBuilding]) {
      offset++;
      if (offset >= [gl maxRepeatedNormStructs]) {
        moneyBuilding = nil;
        break;
      }
      // Check if we already assigned this building and it is in arr.
      moneyBuilding = (MoneyBuilding *)[self getChildByTag:tag+offset];
    }
    
    FullStructureProto *fsp = [gs structWithId:s.structId];
    CGRect loc = CGRectMake(s.coordinates.x, s.coordinates.y, fsp.xLength, fsp.yLength);
    if (!moneyBuilding) {
      NSString *imgName = [Globals imageNameForStruct:s.structId];
      moneyBuilding = [[MoneyBuilding alloc] initWithFile:imgName location:loc map:self];
      [self addChild:moneyBuilding z:0 tag:tag+offset];
      [moneyBuilding release];
    } else {
      [moneyBuilding liftBlock];
      moneyBuilding.location = loc;
    }
    
    moneyBuilding.orientation = s.orientation;
    moneyBuilding.userStruct = s;
    
    UserStructState st = s.state;
    switch (st) {
      case kUpgrading:
        moneyBuilding.retrievable = NO;
        _upgrBuilding = moneyBuilding;
        break;
        
      case kBuilding:
        moneyBuilding.retrievable = NO;
        _constrBuilding = moneyBuilding;
        moneyBuilding.isConstructing = YES;
        break;
        
      case kWaitingForIncome:
        moneyBuilding.retrievable = NO;
        break;
        
      case kRetrieving:
        moneyBuilding.retrievable = YES;
        break;
        
      default:
        break;
    }
    
    [arr addObject:moneyBuilding];
    [moneyBuilding placeBlock];
  }
  
//  for (UserCritStruct *cs in gs.myCritStructs) {
//    if (cs.type != CritStructTypeAviary) {
//      CritStructBuilding *csb = [[CritStructBuilding alloc] initWithFile:[cs.name stringByAppendingString:@".png"] location:cs.location map:self];
//      [self addChild:csb];
//      [csb release];
//      
//      csb.orientation = cs.orientation;
//      csb.critStruct = cs;
//      [arr addObject:csb];
//      [csb placeBlock];
//    } else {
//      Aviary *av = [[Aviary alloc] initWithFile:[cs.name stringByAppendingString:@".png"] location:cs.location map:self];
//      [self addChild:av];
//      [av release];
//      
//      av.orientation = cs.orientation;
//      [arr addObject:av];
//      [self changeTiles:av.location toBuildable:NO];
//    }
//  }
  
  CCNode *c;
  CCARRAY_FOREACH(self.children, c) {
    if ([c isKindOfClass:[SelectableSprite class]] && ![arr containsObject:c]) {
      if ([c isKindOfClass:[HomeBuilding class]]) {
        [(HomeBuilding *)c liftBlock];
      }
      [self removeChild:c cleanup:YES];
    }
  }
  
  for (CCNode *node in arr) {
    if ([node isKindOfClass:[HomeBuilding class]]) {
      [(HomeBuilding *)node placeBlock];
    }
  }
  
  [self doReorder];
  _loading = NO;
}

- (void) moveToStruct:(int)structId {
  int baseTag = [self baseTagForStructId:structId];
  MoneyBuilding *mb = nil;
  for (int tag = baseTag; tag < baseTag+[[Globals sharedGlobals] maxRepeatedNormStructs]; tag++) {
    MoneyBuilding *check;
    if ((check = (MoneyBuilding *)[self getChildByTag:tag])) {
      if (!mb || check.userStruct.level > mb.userStruct.level) {
        mb = check;
      }
    } else {
      break;
    }
  }
  
  if (mb) {
    [self moveToSprite:mb];
  }
}

- (void) doReorder {
  [super doReorder];
  
  if (_isMoving || ([_selected isKindOfClass:[HomeBuilding class]] && !((HomeBuilding *)_selected).isSetDown)) {
    [self reorderChild:_selected z:1000];
  }
}

- (void) setPosition:(CGPoint)position {
  CGPoint oldPos = position_;
  [super setPosition:position];
  if (!hbMenu.hidden) {
    CGPoint diff = ccpSub(oldPos, position_);
    diff.x *= -1;
    CGRect curRect = hbMenu.frame;
    curRect.origin = ccpAdd(curRect.origin, diff);
    hbMenu.frame = curRect;
  }
}

- (void) updateHomeBuildingMenu {
  if (_selected && [_selected isKindOfClass:[MoneyBuilding class]]) {
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
  CGRect loc = CGRectMake((int)mapSize_.width/2, (int)mapSize_.height/2, fsp.xLength, fsp.yLength);
  _purchBuilding = [[MoneyBuilding alloc] initWithFile:[Globals imageNameForStruct:structId] location:loc map:self];
  _purchBuilding.verticalOffset = fsp.imgVerticalPixelOffset;
  
  int baseTag = [self baseTagForStructId:structId];
  int tag;
  for (tag = baseTag; tag < baseTag+[[Globals sharedGlobals] maxRepeatedNormStructs]; tag++) {
    if (![self getChildByTag:tag]) {
      break;
    }
  }
  if (tag == baseTag+[[Globals sharedGlobals] maxRepeatedNormStructs]) {
    [Globals popupMessage:@"Already have max of this building."];
    return;
  }
  
  [self addChild:_purchBuilding z:0 tag:tag];
  // Only keep a weak ref
  [_purchBuilding release];
  
  self.selected = _purchBuilding;
  self.hbMenu.state = kMoveState;
  _canMove = YES;
  _purchasing = YES;
  _purchStructId = structId;
  
  [self doReorder];
  
  [self moveToSprite:_purchBuilding];
}

- (void) setSelected:(SelectableSprite *)selected {
  if (_selected != selected) {
    if ([selected isKindOfClass: [MoneyBuilding class]]) {
      [super setSelected:nil];
      [self.hbMenu updateLabelsForUserStruct:((MoneyBuilding *) selected).userStruct];
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
  
  // During drag, take out menus
  if([recognizer state] == UIGestureRecognizerStateBegan ) {
    self.hbMenu.hidden = YES;
  } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
    [self updateHomeBuildingMenu];
  }
  
  if (_canMove) {
    if ([_selected isKindOfClass:[HomeBuilding class]]) {
      HomeBuilding *homeBuilding = (HomeBuilding *)_selected;
      if([recognizer state] == UIGestureRecognizerStateBegan ) {
        // This fat statement just checks that the drag touch is somewhere closeby the selected sprite
        if (CGRectContainsPoint(CGRectMake(_selected.position.x-_selected.contentSize.width/2*_selected.scale-20, _selected.position.y-20, _selected.contentSize.width*_selected.scale+40, _selected.contentSize.height*_selected.scale+40), pt)) {
          [homeBuilding setStartTouchLocation: pt];
          [homeBuilding liftBlock];
          
          [homeBuilding updateMeta];
          _isMoving = YES;
          return;
        }
      } else if (_isMoving && [recognizer state] == UIGestureRecognizerStateChanged) {
        [self scrollScreenForTouch:pt];
        [homeBuilding clearMeta];
        [homeBuilding locationAfterTouch:pt];
        [homeBuilding updateMeta];
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
    
    if ([sel isKindOfClass:[MoneyBuilding class]]) {
      MoneyBuilding *mb = (MoneyBuilding *)sel;
      if (mb.retrievable) {
        // Retrieve the cash!
        [self retrieveFromBuilding:mb];
        return;
      }
    }
    self.selected = sel;
  }
}

- (void) scale:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  [super scale:recognizer node:node];
  [self updateHomeBuildingMenu];
  
}

- (void) scrollScreenForTouch:(CGPoint)pt {
  // CGPoint relPt = [self convertToNodeSpace:pt];
  // TODO: Implement this
  // As you get closer to edge, it scrolls faster
}

- (void) updateTimersForBuilding:(MoneyBuilding *)mb {
  [_timers removeObject:mb.timer];
  [mb createTimerForCurrentState];
  
  if (mb.timer) {
    [_timers addObject:mb.timer];
    [[NSRunLoop mainRunLoop] addTimer:mb.timer forMode:NSRunLoopCommonModes];
  }
}

- (void) retrieveFromBuilding:(MoneyBuilding *)mb {
  [[OutgoingEventController sharedOutgoingEventController] retrieveFromNormStructure:mb.userStruct];
  if (mb.userStruct.state == kWaitingForIncome) {
    mb.retrievable = NO;
    [self updateTimersForBuilding:mb];
    [self addSilverDrop:[[Globals sharedGlobals] calculateIncomeForUserStruct:mb.userStruct] fromSprite:mb];
  }
}

- (void) buildComplete:(NSTimer *)timer {
  MoneyBuilding *mb = [timer userInfo];
  [[OutgoingEventController sharedOutgoingEventController] normStructWaitComplete:mb.userStruct];
  [self updateTimersForBuilding:mb];
  mb.isConstructing = NO;
  [self displayUpgradeBuildPopupForUserStruct:mb.userStruct];
  if (mb == _selected && hbMenu.state != kMoveState) {
    //    [self.hbMenu updateLabelsForUserStruct:mb.userStruct];
    self.selected = nil;
  }
  [self updateHomeBuildingMenu];
  _constrBuilding = nil;
}

- (void) upgradeComplete:(NSTimer *)timer {
  MoneyBuilding *mb = [timer userInfo];
  [[OutgoingEventController sharedOutgoingEventController] normStructWaitComplete:mb.userStruct];
  [self updateTimersForBuilding:mb];
  [self displayUpgradeBuildPopupForUserStruct:mb.userStruct];
  if (mb == _selected && hbMenu.state != kMoveState) {
    //    [self.hbMenu updateLabelsForUserStruct:mb.userStruct];
    self.selected = nil;
  }
  _upgrBuilding = nil;
}

- (void) waitForIncomeComplete:(NSTimer *)timer {
  MoneyBuilding *mb = [timer userInfo];
  mb.retrievable = YES;
  
  if (mb == _selected) {
    if (self.hbMenu.state == kMoveState) {
      [mb cancelMove];
      _canMove = NO;
    }
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
  OutgoingEventController *oec = [OutgoingEventController sharedOutgoingEventController];
  HomeBuilding *homeBuilding = (HomeBuilding *)_selected;
  
  if (homeBuilding.isSetDown) {
    _canMove = NO;
    self.selected = nil;
    [self doReorder];
    if (_purchasing) {
      _purchasing = NO;
      if ([homeBuilding isKindOfClass:[MoneyBuilding class]]) {
        MoneyBuilding *moneyBuilding = (MoneyBuilding *)homeBuilding;
        
        // Use return value as an indicator that purchase is accepted by client
        UserStruct *us = [[OutgoingEventController sharedOutgoingEventController] purchaseNormStruct:_purchStructId atX:moneyBuilding.location.origin.x atY:moneyBuilding.location.origin.y];
        if (us) {
          moneyBuilding.userStruct = us;
          _constrBuilding = moneyBuilding;
          [self updateTimersForBuilding:_constrBuilding];
          moneyBuilding.isConstructing = YES;
        } else {
          [moneyBuilding liftBlock];
          [self removeChild:moneyBuilding cleanup:YES];
        }
      }
    } else {
      if ([homeBuilding isKindOfClass:[MoneyBuilding class]]) {
        MoneyBuilding *moneyBuilding = (MoneyBuilding *)homeBuilding;
        [oec moveNormStruct:moneyBuilding.userStruct atX:moneyBuilding.location.origin.x atY:moneyBuilding.location.origin.y];
        [oec rotateNormStruct:moneyBuilding.userStruct to:moneyBuilding.orientation];
      }
    }
  }
}

- (IBAction)rotateClicked:(id)sender {
  if ([_selected isKindOfClass:[Building class]] && !_purchasing) {
    Building *building = (Building *)_selected;
    [building setOrientation:building.orientation+1];
  }
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
    UserStruct *us = ((MoneyBuilding *)_selected).userStruct;
    int structId = us.structId;
    [[OutgoingEventController sharedOutgoingEventController] sellNormStruct:us];
    if (![[[GameState sharedGameState] myStructs] containsObject:us]) {
      MoneyBuilding *spr = (MoneyBuilding *)self.selected;
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
  UserStruct *us = ((MoneyBuilding *)_selected).userStruct;
  Globals *gl = [Globals sharedGlobals];
  
  if (us.level < gl.maxLevelForStruct) {
    hbMenu.state = kUpgradeState;
  }
}

- (IBAction)littleUpgradeClicked:(id)sender {
  UserStruct *us = ((MoneyBuilding *)_selected).userStruct;
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  FullStructureProto *fsp = [gs structWithId:us.structId];
  if (us.level < gl.maxLevelForStruct) {
    int cost = [gl calculateUpgradeCost:us];
    BOOL isGoldBuilding = fsp.diamondPrice > 0;
    if (!isGoldBuilding) {
      if (cost > gs.silver) {
        [[RefillMenuController sharedRefillMenuController] displayBuySilverView];
        [Analytics notEnoughSilverForUpgrade:us.structId cost:cost];
        self.selected = nil;
      } else {
        [[OutgoingEventController sharedOutgoingEventController] upgradeNormStruct:us];
        _upgrBuilding = (MoneyBuilding *)_selected;
        [self updateTimersForBuilding:_upgrBuilding];
        [self.hbMenu updateLabelsForUserStruct:us];
      }
    } else {
      if (cost > gs.gold) {
        [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:cost];
        [Analytics notEnoughGoldForUpgrade:us.structId cost:cost];
        self.selected = nil;
      } else {
        [[OutgoingEventController sharedOutgoingEventController] upgradeNormStruct:us];
        _upgrBuilding = (MoneyBuilding *)_selected;
        [self updateTimersForBuilding:_upgrBuilding];
        [self.hbMenu updateLabelsForUserStruct:us];
      }
    }
  }
}

- (IBAction)finishNowClicked:(id)sender {
  MoneyBuilding *mb = (MoneyBuilding *)_selected;
  UserStructState state = mb.userStruct.state;
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  
  if (state == kUpgrading) {
    UserStruct *us = _upgrBuilding.userStruct;
    int goldCost = [gl calculateDiamondCostForInstaUpgrade:us];
    if (gs.gold < goldCost) {
      [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:goldCost];
      [Analytics notEnoughGoldForInstaUpgrade:us.structId level:us.level cost:goldCost];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] instaUpgrade:_upgrBuilding.userStruct];
    }
  } else if (state == kBuilding) {
    int goldCost = [gl calculateDiamondCostForInstaBuild:_constrBuilding.userStruct];
    if (gs.gold < goldCost) {
      [[RefillMenuController sharedRefillMenuController] displayBuyGoldView:goldCost];
    } else {
      [[OutgoingEventController sharedOutgoingEventController] instaBuild:_constrBuilding.userStruct];
      [Analytics notEnoughGoldForInstaBuild:_constrBuilding.userStruct.structId];
    }
  }
  
  self.hbMenu.finishNowButton.enabled = NO;
  self.hbMenu.blueButton.enabled = NO;
  
  if (mb.userStruct.state == kWaitingForIncome) {
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
      [self displayUpgradeBuildPopupForUserStruct:mb.userStruct];
      [[[CCDirector sharedDirector] openGLView] setUserInteractionEnabled:YES];
      self.hbMenu.finishNowButton.enabled = YES;
      self.hbMenu.blueButton.enabled = YES;
      [self.hbMenu startTimer];
      mb.isConstructing = NO;
      self.selected = nil;
      //      [self.hbMenu updateLabelsForUserStruct:mb.userStruct];
      //      [self updateHomeBuildingMenu];
    }];
    [self updateTimersForBuilding:mb];
  } else {
    self.hbMenu.finishNowButton.enabled = YES;
    self.hbMenu.blueButton.enabled = YES;
  }
}

-(void) changeTiles: (CGRect) buildBlock toBuildable:(BOOL)canBuild {
  for (float i = floorf(buildBlock.origin.x); i < ceilf(buildBlock.size.width+buildBlock.origin.x); i++) {
    for (float j = floorf(buildBlock.origin.y); j < ceilf(buildBlock.size.height+buildBlock.origin.y); j++) {
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

- (void) displayUpgradeBuildPopupForUserStruct:(UserStruct *)us {
  // This will be released after the level up controller closes
  BuildUpgradePopupController *vc = [[BuildUpgradePopupController alloc] initWithUserStruct:us];
  [[[[CCDirector sharedDirector] openGLView] superview] addSubview:vc.view];
}

- (void) onExit {
  [super onExit];
  [self invalidateAllTimers];
}

- (void) dealloc {
  [self.hbMenu removeFromSuperview];
  self.hbMenu = nil;
  self.buildableData = nil;
  
  [self invalidateAllTimers];
  [_timers release];
  
  [super dealloc];
}

@end
