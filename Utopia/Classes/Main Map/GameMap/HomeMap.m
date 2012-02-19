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

#define HOME_BUILDING_TAG_OFFSET 50

@implementation UpgradeButtonOverlay

@synthesize fullStar, emptyStar;
@synthesize level;

- (id) initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    fullStar = [UIImage imageNamed:@"fullstar.png"];
    emptyStar = [UIImage imageNamed:@"emptystar.png"];
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
  for (i = 0; i < level; i++) {
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
@synthesize blueButton, redButton, greenButton, blackButton;
@synthesize infoView, upgradeView, progressView;
@synthesize state  = _state;
@synthesize mainView, moveView;
@synthesize timer, retrievalTime;
@synthesize upgradeTime, totalUpgradeTime;
@synthesize incomeLabel, upgradeCurIncomeLabel, upgradeNewIncomeLabel, retrieveTimeLabel;
@synthesize instaFinishCostLabel, finishTimeLabel, progressBar;

- (void) awakeFromNib {
  [super awakeFromNib];
  [self.mainView insertSubview:infoView aboveSubview:titleLabel];
  [self.mainView insertSubview:upgradeView aboveSubview:titleLabel];
  [self.mainView insertSubview:progressView aboveSubview:titleLabel];
  self.state = kNormalState;
  greenButton.text = @"Upgrade";
  blackButton.text = @"Move";
  blackButton.text = @"Move";
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
        blueButton.hidden = NO;
        blueButton.text = @"Move";
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
        progressView.hidden = NO;
        blueButton.hidden = YES;
        redButton.enabled = NO;
        infoView.hidden = YES;
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
  NSLog(@"%@, %@", [NSDate date], upgradeTime);
  if (_state == kProgressState) {
    int t = MAX([upgradeTime timeIntervalSinceNow], 0);
    self.finishTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", t/3600, t/60%60, t%60];
    
    // Adjust the progress bar appropriately
    int width = progressBar.image.size.width;
    CGRect r = progressBar.frame;
    r.size.width = clampf(width * (1-t/totalUpgradeTime), 0, width);
    progressBar.frame = r;
  } else {
    int t = MAX([retrievalTime timeIntervalSinceNow], 0);
    self.retrieveTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d", t/3600, t/60%60, t%60];
  }
}

- (void) setHidden:(BOOL)hidden {
  [super setHidden:hidden];
  [self.timer invalidate];
  if (!hidden) {
    [self updateTimes];
    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateTimes) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
  }
}

- (void) updateLabelsForUserStruct:(UserStruct *)us {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:us.structId];
  Globals *gl = [Globals sharedGlobals];
  
  self.titleLabel.text = fsp.name;
  self.incomeLabel.text = [NSString stringWithFormat:@"+%@", [Globals commafyNumber:[gl calculateIncomeForUserStruct:us]]];
  self.infoView.starView.level = us.level;
  [self.infoView setSellCostString:[Globals commafyNumber:[gl calculateSellCost:us]]];
  
  self.upgradeCurIncomeLabel.text = [Globals commafyNumber:[gl calculateIncomeForUserStruct:us]];
  self.upgradeNewIncomeLabel.text = [Globals commafyNumber:[gl calculateIncomeForUserStructAfterLevelUp:us]];
  [self.upgradeView setUpgradeCostString:[Globals commafyNumber:[gl calculateUpgradeCost:us]]];
  
  
  if (us.purchaseTime) {
    if (!us.lastRetrieved) {
      // First build phase
      self.state = kProgressState;
      int secs = fsp.minutesToBuild*60;
      self.upgradeTime = [NSDate dateWithTimeInterval:secs sinceDate:us.purchaseTime];
      self.totalUpgradeTime = secs;
      self.instaFinishCostLabel.text = [Globals commafyNumber:[gl calculateDiamondCostForInstaBuild:us]];
    } else if (us.lastUpgradeTime) {
      // Upgrading..
      self.state = kProgressState;
      int secs = [gl calculateMinutesToUpgrade:us]*60;
      self.upgradeTime = [NSDate dateWithTimeInterval:secs sinceDate:us.purchaseTime];
      self.totalUpgradeTime = secs;
      self.instaFinishCostLabel.text = [Globals commafyNumber:[gl calculateDiamondCostForInstaUpgrade:us]];
    } else {
      self.retrievalTime = [NSDate dateWithTimeInterval:fsp.minutesToGain*60 sinceDate:us.lastRetrieved];
    }
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
  }
  return self;
}

- (void) refresh {
  NSMutableArray *arr = [NSMutableArray array];
  for (UserStruct *s in [[GameState sharedGameState] myStructs]) {
    HomeBuilding *hb = (HomeBuilding *)[self getChildByTag:s.structId+HOME_BUILDING_TAG_OFFSET];
    if (!hb) {
      hb = [HomeBuilding buildingWithFile:@"acad.png" location:CGRectZero map:self];
      [self addChild:hb z:0 tag:hb.userStruct.structId+HOME_BUILDING_TAG_OFFSET];
    }
    hb.userStruct = s;
    [arr addObject:hb];
    [hb placeBlock];
  }
  
  CCNode *c;
  CCARRAY_FOREACH(self.children, c) {
    if ([c isKindOfClass:[SelectableSprite class]] && ![arr containsObject:c]) {
      [self removeChild:c cleanup:YES];
    }
  }
  
  [self doReorder];
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
  if (_selected) {
    CGPoint pt = [_selected convertToWorldSpace:ccp(_selected.contentSize.width/2, _selected.contentSize.height-5)];
    [hbMenu setFrameForPoint:pt];
    hbMenu.hidden = NO;
  } else {
    hbMenu.hidden = YES;
  }
}

- (void) setSelected:(SelectableSprite *)selected {
  if (_selected != selected) {
    [super setSelected:selected];
    if ([_selected class] == [HomeBuilding class]) {
      self.hbMenu.state = kNormalState;
      [self.hbMenu updateLabelsForUserStruct:((HomeBuilding *) _selected).userStruct];
    }
  }
  [self updateHomeBuildingMenu];
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
          
          if ([homeBuilding isSetDown]) {
            homeBuilding.opacity = 150;
            [self changeTiles:homeBuilding.location toBuildable:YES];
          }
          homeBuilding.isSetDown = NO;
          [homeBuilding updateMeta];
          _isMoving = YES;
          [self updateHomeBuildingMenu];
          return;
        }
      } else if (_isMoving && [recognizer state] == UIGestureRecognizerStateChanged) {
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
  if (!_canMove) {
    [super tap:recognizer node:node];
    [self updateHomeBuildingMenu];
  }
}

- (void) scale:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  [super scale:recognizer node:node];
  [self updateHomeBuildingMenu];
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
  [[OutgoingEventController sharedOutgoingEventController] moveNormStruct:homeBuilding.userStruct.userStructId atX:_selected.location.origin.x atY:_selected.location.origin.y];
  
  _canMove = NO;
  homeBuilding.isSelected = NO;
  self.selected = nil;
  [self doReorder];
}

- (IBAction)rotateClicked:(id)sender {
  [_selected setFlipX:!_selected.flipX];
}

- (IBAction)redButtonClicked:(id)sender {
  hbMenu.state = kSellState;
}

- (IBAction)upgradeClicked:(id)sender {
  hbMenu.state = kUpgradeState;
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
