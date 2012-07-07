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
#import "LNSynthesizeSingleton.h"
#import "OutgoingEventController.h"
#import "GameLayer.h"
#import "RefillMenuController.h"
#import "CritStructPopupController.h"
#import "BuildUpgradePopupController.h"
#import "GenericPopupController.h"

#define HOME_BUILDING_TAG_OFFSET 123456

@implementation HomeMap

@synthesize buildableData = _buildableData;
@synthesize hbMenu, collectMenu, moveMenu, upgradeMenu;
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
    CCTMXLayer *layer = [self layerNamed:@"Buildable"];
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        NSMutableArray *row = [self.buildableData objectAtIndex:i];
        // Convert their coordinates to our coordinate system
        CGPoint tileCoord = ccp(height-j-1, width-i-1);
        int tileGid = [layer tileGIDAt:tileCoord];
        if (tileGid) {
          [row replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:YES]];
        }
      }
    }
    [self removeChild:layer cleanup:YES];
    
    self.walkableData = [NSMutableArray arrayWithCapacity:[self mapSize].width];
    for (int i = 0; i < self.mapSize.width; i++) {
      NSMutableArray *row = [NSMutableArray arrayWithCapacity:self.mapSize.height];
      for (int j = 0; j < self.mapSize.height; j++) {
        [row addObject:[NSNumber numberWithBool:NO]];
      }
      [self.walkableData addObject:row];
    }
    
    layer = [self layerNamed:@"Walkable"];
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        NSMutableArray *row = [self.walkableData objectAtIndex:i];
        // Convert their coordinates to our coordinate system
        CGPoint tileCoord = ccp(height-j-1, width-i-1);
        int tileGid = [layer tileGIDAt:tileCoord];
        if (tileGid) {
          [row replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:YES]];
        }
      }
    }
    [self removeChild:layer cleanup:YES];
    
    layer = [self layerNamed:@"Expansion"];
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        NSMutableArray *brow = [self.buildableData objectAtIndex:i];
        NSMutableArray *wrow = [self.walkableData objectAtIndex:i];
        // Convert their coordinates to our coordinate system
        CGPoint tileCoord = ccp(height-j-1, width-i-1);
        int tileGid = [layer tileGIDAt:tileCoord];
        if (tileGid) {
          [brow replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:NO]];
          [wrow replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:NO]];
        }
      }
    }
    
    // Create the attack gate
    MapSprite *mid = [[MapSprite alloc] initWithFile:@"centergate.png" location:CGRectMake(47, 23, 3, 1) map:self];
    [self addChild:mid];
    [mid release];
    
    for (int i = 1; i < 9; i++) {
      MapSprite *left = [[MapSprite alloc] initWithFile:@"leftgate.png" location:CGRectMake(47-3*i, 23, 3, 1) map:self];
      [self addChild:left];
      [left release];
    }
    for (int i = 1; i < 9; i++) {
      MapSprite *right = [[MapSprite alloc] initWithFile:@"rightgate.png" location:CGRectMake(47+3*i, 23, 3, 1) map:self];
      [self addChild:right];
      [right release];
    }
    
    CGRect r = CGRectZero;
    r.origin = [self randomWalkablePosition];
    r.size = CGSizeMake(1, 1);
    _carpenter = [[Carpenter alloc] initWithLocation:r map:self];
    [self addChild:_carpenter];
    [_carpenter release];
    
    r = CGRectZero;
    r.origin = [self randomWalkablePosition];
    r.size = CGSizeMake(1, 1);
    _tutGirl = [[TutorialGirl alloc] initWithLocation:r map:self];
    [self addChild:_tutGirl];
    [_tutGirl release];
    
    [self reloadQuestGivers];
    
    [[NSBundle mainBundle] loadNibNamed:@"HomeBuildingMenu" owner:self options:nil];
    [Globals displayUIView:self.hbMenu];
    [Globals displayUIView:self.collectMenu];
    [Globals displayUIView:self.moveMenu];
    
    [[NSBundle mainBundle] loadNibNamed:@"UpgradeBuildingMenu" owner:self options:nil];
    
    [[[CCDirector sharedDirector] openGLView] setUserInteractionEnabled:YES];
    
    hbMenu.center = CGPointMake(hbMenu.frame.size.width/2+5.f, hbMenu.superview.frame.size.height-hbMenu.frame.size.height/2-2.f);
    hbMenu.alpha = 0.f;
    collectMenu.alpha = 0.f;
    moveMenu.hidden = YES;
    
    
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
  NSLog(@"ending timers");
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
  
  [self refresh];
}

- (void) beginTimers {
  NSLog(@"beginning timers");
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
  
  [arr addObject:_tutGirl];
  [arr addObject:_carpenter];
  [arr addObject:_myPlayer];
  
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
  } else {
    [self moveToCarpenter];
  }
}

- (void) moveToTutorialGirl {
  [self moveToSprite:_tutGirl];
}

- (void) moveToCarpenter {
  [self moveToSprite:_carpenter];
}

- (void) doReorder {
  [super doReorder];
  
  if ((_isMoving && _selected) || ([_selected isKindOfClass:[HomeBuilding class]] && !((HomeBuilding *)_selected).isSetDown)) {
    [self reorderChild:_selected z:1000];
  }
}

- (void) moveToCenter {
  // When this is called we want to move the player's sprite to the center too.
  // Also, center of home map should show gate
  _myPlayer.location = CGRectMake(48, 28, 1, 1);
  [self moveToSprite:_myPlayer];
}

- (void) preparePurchaseOfStruct:(int)structId {
  if (_purchasing || _constrBuilding) {
    [Globals popupMessage:[NSString stringWithFormat:@"Already %@ a building.", _purchasing ? @"purchasing" : @"constructing"]];
    return;
  }
  
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:structId];
  CGRect loc = CGRectMake(47, 28, fsp.xLength, fsp.yLength);
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
  _canMove = YES;
  _purchasing = YES;
  _purchStructId = structId;
  
  [self doReorder];
  
  [self moveToSprite:_purchBuilding];
  [self openMoveMenuOnSelected];
}

- (void) setViewForSelected:(UIView *)view {
  // Used to set collect menu and move menu
  
  CGPoint pt = [_selected convertToWorldSpace:ccp(_selected.contentSize.width/2, _selected.contentSize.height-OVER_HOME_BUILDING_MENU_OFFSET)];
  [Globals setFrameForView:view forPoint:pt];
}

- (void) setSelected:(SelectableSprite *)selected {
  if (_selected != selected) {
    [super setSelected:selected];
    if ([selected isKindOfClass: [MoneyBuilding class]]) {
      UserStruct *us = ((MoneyBuilding *) selected).userStruct;
      if (us.state == kUpgrading || us.state == kBuilding) {
        [self.upgradeMenu displayForUserStruct:us];
      } else if (us.state == kRetrieving) {
        // Retrieve the cash!
        [self retrieveFromBuilding:((MoneyBuilding *) selected)];
        self.selected = nil;
      } else {
        [self.hbMenu updateForUserStruct:us];
        [self.collectMenu updateForUserStruct:us];
        
        [self setViewForSelected:self.collectMenu];
        
        [self doMenuAnimations];
      }
    } else {
      [self closeMenus];
      [self.upgradeMenu closeClicked:nil];
      self.moveMenu.hidden = YES;
      _canMove = NO;
      if (_purchasing) {
        _purchasing = NO;
        [self removeChild:_purchBuilding cleanup:YES];
      }
    }
  }
}

- (void) doMenuAnimations {
  hbMenu.alpha = 0.f;
  
  // Do 0.01f because timer gets deallocated when alpha is 0.f
  collectMenu.alpha = 0.01f;
  
  [UIView animateWithDuration:0.3f animations:^{
    hbMenu.alpha = 1.f;
    collectMenu.alpha = 1.f;
  }];
}

- (void) openMoveMenuOnSelected {
  [self closeMenus];
  
  [self setViewForSelected:self.moveMenu];
  
  self.moveMenu.hidden = NO;
}

- (void) closeMenus {
  collectMenu.alpha = 0.f;
  moveMenu.hidden = YES;
  [UIView animateWithDuration:0.3f animations:^{
    hbMenu.alpha = 0.f;
  }];
}

- (void) drag:(UIGestureRecognizer*)recognizer node:(CCNode*)node
{
  // First check if a sprite was clicked
  CGPoint pt = [recognizer locationInView:recognizer.view];
  pt = [[CCDirector sharedDirector] convertToGL:pt];
  pt = [self convertToNodeSpace:pt];
  
  // During drag, take out menus
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
          [self openMoveMenuOnSelected];
          return;
        }
      } else if (_isMoving && [recognizer state] == UIGestureRecognizerStateChanged) {
        [self scrollScreenForTouch:pt];
        [homeBuilding clearMeta];
        [homeBuilding locationAfterTouch:pt];
        [homeBuilding updateMeta];
        [self openMoveMenuOnSelected];
        return;
      } else if (_isMoving && [recognizer state] == UIGestureRecognizerStateEnded) {
        [homeBuilding clearMeta];
        [homeBuilding placeBlock];
        _isMoving = NO;
        [self doReorder];
        [self openMoveMenuOnSelected];
        return;
      }
    }
  } else {
    self.selected = nil;
  }
  
  [super drag:recognizer node:node];
}

- (void) tap:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  // Reimplement for retrievals and moving buildings
  if (!_canMove) {
    [super tap:recognizer node:node];
    [self doReorder];
  }
}

- (void) scale:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  [super scale:recognizer node:node];
  
  if (self.collectMenu.alpha > 0.f) {
    [self setViewForSelected:self.collectMenu];
  } else if (self.moveMenu.alpha > 0.f) {
    [self setViewForSelected:self.moveMenu];
  }
}

- (void) setPosition:(CGPoint)position {
  [super setPosition:position];
  if (_canMove) {
    [self openMoveMenuOnSelected];
  }
  
  if (self.collectMenu.alpha > 0.f) {
    [self setViewForSelected:self.collectMenu];
  }
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
  if (mb == _selected && _canMove) {
    [mb cancelMove];
    _canMove = NO;
    self.selected = nil;
  }
  _constrBuilding = nil;
}

- (void) upgradeComplete:(NSTimer *)timer {
  MoneyBuilding *mb = [timer userInfo];
  [[OutgoingEventController sharedOutgoingEventController] normStructWaitComplete:mb.userStruct];
  [self updateTimersForBuilding:mb];
  [self displayUpgradeBuildPopupForUserStruct:mb.userStruct];
  _upgrBuilding = nil;
}

- (void) waitForIncomeComplete:(NSTimer *)timer {
  MoneyBuilding *mb = [timer userInfo];
  mb.retrievable = YES;
  
  if (mb == _selected) {
    if (_canMove) {
      [mb cancelMove];
      _canMove = NO;
    }
    self.selected = nil;
  }
}

- (void) upgradeMenuClosed {
  if (!_canMove) {
    self.selected = nil;
  }
}

- (IBAction)beginMoveClicked:(id)sender {
  [self openMoveMenuOnSelected];
  _canMove = YES;
  
  // Make sure canMove is set to YES so selected isnt set to nil
  [self.upgradeMenu closeClicked:nil];
}

- (IBAction)moveCheckClicked:(id)sender {
  OutgoingEventController *oec = [OutgoingEventController sharedOutgoingEventController];
  HomeBuilding *homeBuilding = (HomeBuilding *)_selected;
  
  if (homeBuilding.isSetDown) {
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
    _canMove = NO;
    self.selected = nil;
    [self doReorder];
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

- (IBAction)sellClicked:(id)sender {
  GameState *gs = [GameState sharedGameState];
  UserStruct *us = ((MoneyBuilding *)_selected).userStruct;
  Globals *gl = [Globals sharedGlobals];
  FullStructureProto *fsp = [gs structWithId:us.structId];
  int silver = [gl calculateStructSilverSellCost:us];
  int gold = [gl calculateStructGoldSellCost:us];
  
  NSString *desc = [NSString stringWithFormat:@"Are you sure you would like to sell your %@ for %@?", fsp.name, silver > 0 ? [NSString stringWithFormat:@"%d silver", silver] : [NSString stringWithFormat:@"%d gold", gold]];
  [GenericPopupController displayConfirmationWithDescription:desc title:@"Sell Building?" okayButton:@"Sell" cancelButton:@"Cancel" target:self selector:@selector(sellSelected)];
}

- (void) sellSelected {
  UserStruct *us = ((MoneyBuilding *)_selected).userStruct;
  int structId = us.structId;
  [[OutgoingEventController sharedOutgoingEventController] sellNormStruct:us];
  [self closeMenus];
  if (![[[GameState sharedGameState] myStructs] containsObject:us]) {
    MoneyBuilding *spr = (MoneyBuilding *)self.selected;
    self.selected = nil;
    [_timers removeObject:spr.timer];
    spr.timer = nil;
    
    [spr runAction:[CCSequence actions:[CCFadeOut actionWithDuration:1.f],
                    [CCCallBlock actionWithBlock:
                     ^{
                       [spr liftBlock];
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
                     }], nil]];
    
    if (_constrBuilding == spr) {
      _constrBuilding = nil;
    }
    if (_upgrBuilding == spr) {
      _upgrBuilding = nil;
    }
  }
}

- (IBAction)littleUpgradeClicked:(id)sender {
  UserStruct *us = ((MoneyBuilding *)_selected).userStruct;
  Globals *gl = [Globals sharedGlobals];
  if (us.level < gl.maxLevelForStruct) {
    [self.upgradeMenu displayForUserStruct:us];
    [self closeMenus];
  } else {
    [Globals popupMessage:[NSString stringWithFormat:@"The maximum level for buildings is level %d.", gl.maxLevelForStruct]];
  }
}

- (IBAction)bigUpgradeClicked:(id)sender {
  UserStruct *us = ((MoneyBuilding *)_selected).userStruct;
  Globals *gl = [Globals sharedGlobals];
  GameState *gs = [GameState sharedGameState];
  FullStructureProto *fsp = [gs structWithId:us.structId];
  
  if (_upgrBuilding) {
    [Globals popupMessage:@"The carpenter is already upgrading a building!"];
  } else if (us.level < gl.maxLevelForStruct) {
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
        [self.upgradeMenu displayForUserStruct:us];
        [self closeMenus];
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
        [self.upgradeMenu displayForUserStruct:us];
        [self closeMenus];
      }
    }
  } else {
    [Globals popupMessage:@"This building is at the maximum level."];
  }
}

- (IBAction)finishNowClicked:(id)sender {MoneyBuilding *mb = (MoneyBuilding *)_selected;
  UserStructState state = mb.userStruct.state;
  Globals *gl = [Globals sharedGlobals];
  int goldCost = 0;
  
  if (state == kUpgrading) {
    UserStruct *us = _upgrBuilding.userStruct;
    goldCost = [gl calculateDiamondCostForInstaUpgrade:us];
  } else if (state == kBuilding) {
    goldCost = [gl calculateDiamondCostForInstaBuild:_constrBuilding.userStruct];
  }
  NSString *desc = [NSString stringWithFormat:@"Finish instantly for %d gold?", goldCost];
  [GenericPopupController displayConfirmationWithDescription:desc title:@"Speed Up!" okayButton:@"Yes" cancelButton:@"No" target:self selector:@selector(speedUpBuilding)];
}

- (void) speedUpBuilding {
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
      [[OutgoingEventController sharedOutgoingEventController] instaUpgrade:mb.userStruct];
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
  
  if (mb.userStruct.state == kWaitingForIncome) {
    if (_selected == _constrBuilding) {
      _constrBuilding = nil;
    } else if (_selected == _upgrBuilding) {
      _upgrBuilding = nil;
    } else {
      [Globals popupMessage:@"This should never come up.. Inconsistent state in HomeMap->finishNowClicked"];
    }
    
    [self updateTimersForBuilding:mb];
    
    [self.upgradeMenu finishNow:^{
      mb.isConstructing = NO;
    }];
  }
}

-(void) changeTiles: (CGRect) buildBlock toBuildable:(BOOL)canBuild {
  for (float i = floorf(buildBlock.origin.x); i < ceilf(buildBlock.size.width+buildBlock.origin.x); i++) {
    for (float j = floorf(buildBlock.origin.y); j < ceilf(buildBlock.size.height+buildBlock.origin.y); j++) {
      [[self.buildableData objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:canBuild]];
      [[self.walkableData objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:canBuild]];
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

- (void) reloadQuestGivers {
  GameState *gs = [GameState sharedGameState];
  for (FullQuestProto *fqp in [gs.inProgressCompleteQuests allValues]) {
    if (fqp.cityId == 0 && fqp.assetNumWithinCity == 1) {
      QuestGiver *qg = _tutGirl;
      qg.quest = fqp;
      qg.questGiverState = kCompleted;
      qg.visible = YES;
      return;
    }
  }
  for (FullQuestProto *fqp in [gs.inProgressIncompleteQuests allValues]) {
    if (fqp.cityId == 0 && fqp.assetNumWithinCity == 1) {
      QuestGiver *qg = _tutGirl;
      qg.quest = fqp;
      qg.questGiverState = kInProgress;
      return;
    }
  }
  for (FullQuestProto *fqp in [gs.availableQuests allValues]) {
    if (fqp.cityId == 0 && fqp.assetNumWithinCity == 1) {
      QuestGiver *qg = _tutGirl;
      qg.quest = fqp;
      qg.questGiverState = kAvailable;
      return;
    }
  }
  
  // No quest was found for this guy
  _tutGirl.quest = nil;
  _tutGirl.questGiverState = kNoQuest;
}

- (void) questAccepted:(FullQuestProto *)fqp {
  if (fqp.cityId == 0 && fqp.assetNumWithinCity == 1) {
    QuestGiver *qg = _tutGirl;
    qg.quest = fqp;
    qg.questGiverState = kInProgress;
  }
}

- (void) questRedeemed:(FullQuestProto *)fqp {
  if (fqp.cityId == 0 && fqp.assetNumWithinCity == 1) {
    QuestGiver *qg = _tutGirl;
    qg.quest = nil;
    qg.questGiverState = kNoQuest;
  }
}

- (void) onExit {
  [super onExit];
  [self invalidateAllTimers];
}

- (void) dealloc {
  [self.hbMenu removeFromSuperview];
  self.hbMenu = nil;
  [self.collectMenu removeFromSuperview];
  self.collectMenu = nil;
  [self.moveMenu removeFromSuperview];
  self.collectMenu = nil;
  [self.upgradeMenu removeFromSuperview];
  self.upgradeMenu = nil;
  self.buildableData = nil;
  
  [self invalidateAllTimers];
  [_timers release];
  
  [super dealloc];
}

@end
