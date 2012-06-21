//
//  GameMap.m
//  IsoMap
//
//  Created by Ashwin Kamath on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GameMap.h"
#import "Building.h"
#import "Globals.h"
#import "NibUtils.h"
#import "MapViewController.h"
#import "BattleLayer.h"
#import "GameLayer.h"
#import "ProfileViewController.h"
#import "SoundEngine.h"
#import "TopBar.h"
#import "GameState.h"
#import "CCLabelFX.h"

#define REORDER_START_Z 150

#define SILVER_STACK_BOUNCE_DURATION 1.f
#define DROP_LABEL_DURATION 3.f

//CCMoveByCustom
@interface CCMoveByCustom : CCMoveBy

-(void) update: (ccTime) t;

@end

@implementation CCMoveByCustom
- (void) update: (ccTime) t {	
	//Here we neglect to change something with a zero delta.
	if (delta_.x == 0) {
		[target_ setPosition: ccp( [(CCNode*)target_ position].x, (startPosition_.y + delta_.y * t ) )];
	} else if (delta_.y == 0) {
		[target_ setPosition: ccp( (startPosition_.x + delta_.x * t ), [(CCNode*)target_ position].y )];
	} else {
		[target_ setPosition: ccp( (startPosition_.x + delta_.x * t ), (startPosition_.y + delta_.y * t ) )];
	}
}
@end

//CClCustom
@interface CCMoveToCustom : CCMoveTo

- (void) update: (ccTime) t;

@end

@implementation CCMoveToCustom
- (void) update: (ccTime) t {
	//Here we neglect to change something with a zero delta.
	if (delta_.x == 0) {
		[target_ setPosition: ccp( [(CCNode*)target_ position].x, (startPosition_.y + delta_.y * t ) )];
	} else if (delta_.y == 0) {
		[target_ setPosition: ccp( (startPosition_.x + delta_.x * t ), [(CCNode*)target_ position].y )];
	} else{
		[target_ setPosition: ccp( (startPosition_.x + delta_.x * t ), (startPosition_.y + delta_.y * t ) )];
	}
}
@end

@implementation EnemyPopupView

@synthesize nameLabel, levelLabel, imageIcon;

- (void) dealloc {
  self.nameLabel = nil;
  self.levelLabel = nil;
  self.imageIcon = nil;
  [super dealloc];
}

@end

@implementation GameMap

@synthesize selected = _selected;
@synthesize tileSizeInPoints;
@synthesize enemyMenu;
@synthesize mapSprites = _mapSprites;
@synthesize silverOnMap;
@synthesize decLayer;
@synthesize walkableData = _walkableData;

+(id) tiledMapWithTMXFile:(NSString*)tmxFile
{
	return [[[self alloc] initWithTMXFile:tmxFile] autorelease];
}

-(void) addChild:(CCNode *)node z:(NSInteger)z tag:(NSInteger)tag {
  if ([[node class] isSubclassOfClass:[MapSprite class]]) {
    [_mapSprites addObject:node];
  }
  [super addChild:node z:z tag:tag];
}

- (void) removeChild:(CCNode *)node cleanup:(BOOL)cleanup {
  if ([_mapSprites containsObject:node]) {
    [_mapSprites removeObject:node];
  }
  [super removeChild:node cleanup:cleanup];
}

-(id) initWithTMXFile:(NSString *)tmxFile {
  if ((self = [super initWithTMXFile:tmxFile])) {
    _mapSprites = [[NSMutableArray array] retain];
    
    int width = self.mapSize.width;
    int height = self.mapSize.height;
    bottomLeftCorner = ccp(width, height);
    CCTMXLayer * layer = [self layerNamed:@"Border of Doom"];
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        // Convert their coordinates to our coordinate system
        CGPoint tileCoord = ccp(height-j-1, width-i-1);
        int tileGid = [layer tileGIDAt:tileCoord];
        if (tileGid) {
          if (tileCoord.x < bottomLeftCorner.x) {
            bottomLeftCorner = tileCoord;
          }
          if (tileCoord.x > topRightCorner.x) {
            topRightCorner = tileCoord;
          }
        }
      }
    }
    [self removeChild:layer cleanup:YES];
    
    // add UIPanGestureRecognizer
    UIPanGestureRecognizer *uig = [[[UIPanGestureRecognizer alloc ]init] autorelease];
    uig.maximumNumberOfTouches = 1;
    CCGestureRecognizer *recognizer = [CCGestureRecognizer CCRecognizerWithRecognizerTargetAction: uig target:self action:@selector(drag:node:)];
    [self addGestureRecognizer:recognizer];
    
    // add UIPinchGestureRecognizer
    recognizer = [CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[[UIPinchGestureRecognizer alloc ]init] autorelease] target:self action:@selector(scale:node:)];
    [self addGestureRecognizer:recognizer];
    
    self.isTouchEnabled = YES;
    
    // add UITapGestureRecognizer
    recognizer = [CCGestureRecognizer CCRecognizerWithRecognizerTargetAction:[[[UITapGestureRecognizer alloc ]init] autorelease] target:self action:@selector(tap:node:)];
    [self addGestureRecognizer:recognizer];
    
    if (CC_CONTENT_SCALE_FACTOR() == 2) {
      tileSizeInPoints = CGSizeMake(self.tileSize.width/2, self.tileSize.height/2);
    } else {
      tileSizeInPoints = tileSize_;
    }
    
    [self createMyPlayer];
    
    // Add the decoration layer for clouds
    decLayer = [[DecorationLayer alloc] initWithSize:self.contentSize];
    [self addChild:self.decLayer z:2000];
    [decLayer release];
    
    [[NSBundle mainBundle] loadNibNamed:@"EnemyPopupView" owner:self options:nil];
    [[[[CCDirector sharedDirector] openGLView] superview] addSubview:self.enemyMenu];
    [[[CCDirector sharedDirector] openGLView] setUserInteractionEnabled:YES];
    
    enemyMenu.hidden = YES;
    
    self.scale = DEFAULT_ZOOM;
  }
  return self;
}

- (void) createMyPlayer {
  // Do this so that tutorial classes can override
  _myPlayer = [[MyPlayer alloc] initWithLocation:CGRectMake(mapSize_.width/2, mapSize_.height/2, 1, 1) map:self];
  [self addChild:_myPlayer];
  [_myPlayer release];
}

- (void) setVisible:(BOOL)visible {
  [super setVisible:visible];
  self.selected = nil;
}

- (void) addSilverDrop:(int)amount fromSprite:(MapSprite *)sprite {
  silverOnMap += amount;
  
  SilverStack *ss = [[SilverStack alloc] initWithAmount:amount];
  [self addChild:ss z:1004];
  [ss release];
  ss.position = ccpAdd(sprite.position, ccp(0,sprite.contentSize.height/2));
  ss.scale = 0.01;
  ss.opacity = 5;
  
  // Need to fade in, scale to 1, bounce in y dir, move normal in x dir
  float xPos = ((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX)*120-60;
  float yPos = ((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX)*20-10;
  [ss runAction:[CCSpawn actions:
                 [CCFadeIn actionWithDuration:0.1],
                 [CCScaleTo actionWithDuration:0.1 scale:1],
                 [CCSequence actions:
                  [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.2 position:ccp(0,40)],
                  [CCEaseBounceOut actionWithAction:
                   [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.8 position:ccp(0,-85+yPos)]],
                  nil],
                 [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION position:ccp(xPos, 0)],
                 nil]];
  
  [[SoundEngine sharedSoundEngine] coinDrop];
}

- (void) pickUpSilverDrop:(SilverStack *)ss {
  silverOnMap -= ss.amount;
  
  [ss stopAllActions];
  
  CCLabelTTF *coinLabel = [CCLabelFX labelWithString:[NSString stringWithFormat:@"+%d Silver", ss.amount] fontName:@"DINCond-Black" fontSize:25 shadowOffset:CGSizeMake(0, -1) shadowBlur:1.f];
  [self addChild:coinLabel z:1005];
  coinLabel.position = ss.position;
  coinLabel.color = ccc3(174, 237, 0);
  [coinLabel runAction:[CCSequence actions:
                        [CCSpawn actions:
                         [CCFadeOut actionWithDuration:DROP_LABEL_DURATION], 
                         [CCMoveBy actionWithDuration:DROP_LABEL_DURATION position:ccp(0,40)],nil],
                        [CCCallBlock actionWithBlock:^{[coinLabel removeFromParentAndCleanup:YES];}], nil]];
  
  TopBar *tb = [TopBar sharedTopBar];
  CGPoint world = [ss.parent convertToWorldSpace:ss.position];
  CGPoint pos = [tb convertToNodeSpace:world];
  [ss removeFromParentAndCleanup:NO];
  ss.position = pos;
  ss.scale *= self.scale;
  [tb addChild:ss z:-1];
  
  [ss runAction:[CCSequence actions:
                 [CCSpawn actions:
                  [CCEaseSineIn actionWithAction:
                   [CCMoveToCustom actionWithDuration:0.5 position:ccp(ss.position.x,292)]],
                  [CCEaseSineOut actionWithAction:
                   [CCMoveToCustom actionWithDuration:0.5 position:ccp(352,ss.position.y)]],
                  [CCScaleTo actionWithDuration:0.5 scale:0.5],
                  nil],
                 [CCCallBlock actionWithBlock:^{[ss removeFromParentAndCleanup:YES];}],
                 nil]];
  
  [[SoundEngine sharedSoundEngine] coinPickup];
}

- (void) addEquipDrop:(int)equipId fromSprite:(MapSprite *)sprite {
  EquipDrop *ed = [[EquipDrop alloc] initWithEquipId:equipId];
  [self addChild:ed z:1004];
  [ed release];
  ed.position = ccpAdd(sprite.position, ccp(0,sprite.contentSize.height/2));
  ed.scale = 0.01;
  ed.opacity = 5;
  
  // Need to fade in, scale to 1, bounce in y dir, move normal in x dir
  float xPos = ((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX)*120-60;
  float yPos = ((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX)*20-10;
  [ed runAction:[CCSpawn actions:
                 [CCFadeIn actionWithDuration:0.1],
                 [CCScaleTo actionWithDuration:0.1 scale:0.65],
                 [CCSequence actions:
                  [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.2 position:ccp(0,40)],
                  [CCEaseBounceOut actionWithAction:
                   [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION*0.8 position:ccp(0,-85+yPos)]],
                  nil],
                 [CCMoveByCustom actionWithDuration:SILVER_STACK_BOUNCE_DURATION position:ccp(xPos, 0)],
                 nil]];
}

- (void) pickUpEquipDrop:(EquipDrop *)ed {
  [ed stopAllActions];
  
  FullEquipProto *fep = [[GameState sharedGameState] equipWithId:ed.equipId];
  CCLabelFX *nameLabel = [CCLabelFX labelWithString:fep.name fontName:@"DINCond-Black" fontSize:25 shadowOffset:CGSizeMake(0, -1) shadowBlur:1.f];
  [self addChild:nameLabel z:1005];
  nameLabel.position = ed.position;
  UIColor *col = [Globals colorForRarity:fep.rarity];
  CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
  [col getRed:&red green:&green blue:&blue alpha:&alpha];
  nameLabel.color = ccc3((int)(red*255), (int)(green*255), (int)(blue*255));
  [nameLabel runAction:[CCSequence actions:
                        [CCSpawn actions:
                         [CCFadeOut actionWithDuration:DROP_LABEL_DURATION], 
                         [CCMoveBy actionWithDuration:DROP_LABEL_DURATION position:ccp(0,40)],nil],
                        [CCCallBlock actionWithBlock:^{[nameLabel removeFromParentAndCleanup:YES];}], nil]];
  
  TopBar *tb = [TopBar sharedTopBar];
  CGPoint world = [ed.parent convertToWorldSpace:ed.position];
  CGPoint pos = [tb convertToNodeSpace:world];
  [ed removeFromParentAndCleanup:NO];
  ed.position = pos;
  ed.scale *= self.scale;
  [tb addChild:ed z:-1];
  
  [ed runAction:[CCSequence actions:
                 [CCSpawn actions:
                  [CCEaseSineIn actionWithAction:
                   [CCMoveToCustom actionWithDuration:0.5 position:ccp(ed.position.x,tb.profilePic.position.y)]],
                  [CCEaseSineOut actionWithAction:
                   [CCMoveToCustom actionWithDuration:0.5 position:ccp(tb.profilePic.position.x,ed.position.y)]],
                  [CCScaleTo actionWithDuration:0.5 scale:0.5],
                  nil],
                 [CCCallBlock actionWithBlock:^{[ed removeFromParentAndCleanup:YES];}],
                 nil]];
}

- (BOOL) mapSprite:(MapSprite *)front isInFrontOfMapSprite: (MapSprite *)back {
  if (front == back) {
    return YES;
  }
  
  CGRect frontLoc = front.location;
  CGRect backLoc = back.location;
  
  if ((frontLoc.origin.x < backLoc.origin.x && frontLoc.origin.x+frontLoc.size.width-1 < backLoc.origin.x) || (frontLoc.origin.x > backLoc.origin.x+backLoc.size.width-1 && frontLoc.origin.x+frontLoc.size.width-1 > backLoc.origin.x+backLoc.size.width-1)) {
    return frontLoc.origin.x <= backLoc.origin.x;
  }
  return frontLoc.origin.y <= backLoc.origin.y;
}

- (void) updateEnemyMenu {
  if (_selected && [_selected isKindOfClass:[Enemy class]]) {
    CGPoint pt = [_selected convertToWorldSpace:ccp(_selected.contentSize.width/2, _selected.contentSize.height-OVER_HOME_BUILDING_MENU_OFFSET+5)];
    
    float width = enemyMenu.frame.size.width;
    float height = enemyMenu.frame.size.height;
    enemyMenu.frame = CGRectMake(pt.x-width/2, ([[CCDirector sharedDirector] winSize].height-pt.y)-height, width, height);
    
    enemyMenu.hidden = NO;
  } else {
    enemyMenu.hidden = YES;
  }
}

- (void) setSelected:(SelectableSprite *)selected {
  if (_selected != selected) {
    _selected.isSelected = NO;
    _selected = selected;
    if ([selected isKindOfClass: [Enemy class]]) {
      FullUserProto *fup = [(Enemy *)selected user];
      [[self.enemyMenu nameLabel] setText:fup.name];
      [[self.enemyMenu levelLabel] setText:[NSString stringWithFormat:@"Lvl %d", fup.level]];
      [[self.enemyMenu imageIcon] setImage:[Globals squareImageForUser:fup.userType]];
    }
    _selected.isSelected = YES;
    [self updateEnemyMenu];
  }
}

- (void) doReorder {
  for (int i = 1; i < [_mapSprites count]; i++) {
    MapSprite *toSort = [_mapSprites objectAtIndex:i];
    MapSprite *sorted = [_mapSprites objectAtIndex:i-1];
    if (![self mapSprite:toSort isInFrontOfMapSprite:sorted]) {
      int j;
      for (j = i-2; j >= 0; j--) {
        sorted = [_mapSprites objectAtIndex:j];
        if ([self mapSprite:toSort isInFrontOfMapSprite:sorted]) {
          break;
        }
      }
      
      [_mapSprites removeObjectAtIndex:i];
      [_mapSprites insertObject:toSort atIndex:j+1];
    }
  }
  
  for (int i = 0; i < [_mapSprites count]; i++) {
    MapSprite *child = [_mapSprites objectAtIndex:i];
    [self reorderChild:child z:i+REORDER_START_Z];
  }
}

- (SelectableSprite *) selectableForPt:(CGPoint)pt {
  // Find sprite that has center closest to pt
  SelectableSprite *toRet = nil;
  float distToCenter = 320.f;
  for(MapSprite *spr in _mapSprites) {
    if (![spr isKindOfClass:[SelectableSprite class]]) {
      continue;
    }
    SelectableSprite *child = (SelectableSprite *)spr;
    if ([child isPointInArea:pt] && child.visible && child.opacity > 0.f) {
      CGPoint center = ccp(child.contentSize.width/2, child.contentSize.height/2);
      float thisDistToCenter = ccpDistance(center, [child convertToNodeSpace:pt]);
      
      if (thisDistToCenter < distToCenter) {
        distToCenter = thisDistToCenter;
        toRet = child;
      }
    }
  }
  return toRet;
}

- (void) tap:(UIGestureRecognizer*)recognizer node:(CCNode*)node
{
  CGPoint pt = [recognizer locationInView:recognizer.view];
  pt = [[CCDirector sharedDirector] convertToGL:pt];
  
  if (_selected && ![_selected isPointInArea:pt]) {
    self.selected = nil;
  }
  
  self.selected = [self selectableForPt:pt];
  
  if (_selected == nil) {
    pt = [self convertToNodeSpace:pt];
    pt = [self convertCCPointToTilePoint:pt];
    CGRect loc = CGRectMake(pt.x, pt.y, 1, 1);
    
    [_myPlayer moveToLocation:loc];
  }
}

- (void) drag:(UIGestureRecognizer*)recognizer node:(CCNode*)node
{
  // Now do drag motion
  UIPanGestureRecognizer* pan = (UIPanGestureRecognizer*)recognizer;
  
  if([recognizer state] == UIGestureRecognizerStateBegan ||
     [recognizer state] == UIGestureRecognizerStateChanged )
  {
    [node stopActionByTag:190];
    CGPoint translation = [pan translationInView:pan.view.superview];
    
    CGPoint delta = [self convertVectorToGL: translation];
    [node setPosition:ccpAdd(node.position, delta)];
    [pan setTranslation:CGPointZero inView:pan.view.superview];
    self.enemyMenu.hidden = YES;
  } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
    [self updateEnemyMenu];
    CGPoint vel = [pan velocityInView:pan.view.superview];
    vel = [self convertVectorToGL: vel];
    
    float dist = ccpDistance(ccp(0,0), vel);
    if (dist < 500) {
      return;
    }
    
    vel.x /= 3;
    vel.y /= 3;
    id actionID = [CCMoveBy actionWithDuration:dist/1500 position:vel];
    CCEaseOut *action = [CCEaseSineOut actionWithAction:actionID];
    action.tag = 190;
    [node runAction:action];
  }
}

- (void) scale:(UIGestureRecognizer*)recognizer node:(CCNode*)node
{
  UIPinchGestureRecognizer* pinch = (UIPinchGestureRecognizer*)recognizer;
  
  // See if zoom should even be allowed
  float newScale = node.scale * pinch.scale;
  pinch.scale = 1.0f; // we just reset the scaling so we only wory about the delta
  if (newScale > MAX_ZOOM || newScale < MIN_ZOOM) {
    return;
  }
  
  CCDirector* director = [CCDirector sharedDirector];
  CGPoint pt = [recognizer locationInView:recognizer.view.superview];
  pt = [director convertToGL:pt];
  CGPoint beforeScale = [node convertToNodeSpace:pt];
  
  node.scale = newScale;
  CGPoint afterScale = [node convertToNodeSpace:pt];
  CGPoint diff = ccpSub(afterScale, beforeScale);
  
  node.position = ccpAdd(node.position, ccpMult(diff, node.scale));
  
  [self updateEnemyMenu];
  [self.decLayer updateAllCloudOpacities];
}

-(void) setPosition:(CGPoint)position {
  CGSize ms = self.mapSize;
  CGSize ts = self.tileSizeInPoints;
  // For y, make sure to account for anchor point being at bottom middle.
  float minX = ms.width * ts.width/2.f + ts.width * (bottomLeftCorner.x-bottomLeftCorner.y)/2.f;
  float minY = ts.height * (bottomLeftCorner.y+bottomLeftCorner.x)/2.f+ts.height/2;
  float maxX = ms.width * ts.width/2.f + ts.width * (topRightCorner.x-topRightCorner.y)/2.f;
  float maxY = ts.height * (topRightCorner.y+topRightCorner.x)/2.f+ts.height/2;
  
  float x = MAX(MIN(-minX*self.scaleX, position.x), -maxX*self.scaleX + [[CCDirector sharedDirector] winSize].width);
  float y = MAX(MIN(-minY*self.scaleY, position.y), -maxY*self.scaleY + [[CCDirector sharedDirector] winSize].height);
  
  CGPoint oldPos = position_;
  [super setPosition:ccp(x,y)];
  if (!enemyMenu.hidden) {
    CGPoint diff = ccpSub(oldPos, position_);
    diff.x *= -1;
    CGRect curRect = enemyMenu.frame;
    curRect.origin = ccpAdd(curRect.origin, diff);
    enemyMenu.frame = curRect;
  }
}

- (BOOL) isPointInArea:(CGPoint)pt {
  // Whole screen is in area
  return YES;
}

- (IBAction)attackClicked:(id)sender {
  if ([_selected isKindOfClass:[Enemy class]]) {
    Enemy *enemy = (Enemy *)_selected;
    FullUserProto *fup = enemy.user;
    if (fup) {
      int city = [[GameLayer sharedGameLayer] currentCity];
      
      if (city > 0) {
        [[BattleLayer sharedBattleLayer] beginBattleAgainst:fup inCity:city];
      } else {
        [[BattleLayer sharedBattleLayer] beginBattleAgainst:fup];
      }
    }
  }
}

- (IBAction)profileClicked:(id)sender {
  if ([_selected isKindOfClass:[Enemy class]]) {
    Enemy *enemy = (Enemy *)_selected;
    [[ProfileViewController sharedProfileViewController] loadProfileForPlayer:enemy.user buttonsEnabled:YES];
    [ProfileViewController displayView];
    
    [Analytics enemyProfileFromSprite];
  }
}

- (void) layerWillDisappear {
  self.selected = nil;
}

-(CGPoint)convertVectorToGL:(CGPoint)uiPoint
{
  float newY = - uiPoint.y;
  float newX = - uiPoint.x;
  
  CGPoint ret = CGPointZero;
  switch ([[CCDirector sharedDirector] deviceOrientation]) {
    case CCDeviceOrientationPortrait:
      ret = ccp( uiPoint.x, newY );
      break;
    case CCDeviceOrientationPortraitUpsideDown:
      ret = ccp(newX, uiPoint.y);
      break;
    case CCDeviceOrientationLandscapeLeft:
      ret.x = uiPoint.y;
      ret.y = uiPoint.x;
      break;
    case CCDeviceOrientationLandscapeRight:
      ret.x = newY;
      ret.y = newX;
      break;
  }
  return ret;
}

- (CGPoint) randomWalkablePosition {
  while (true) {
    int x = arc4random() % (int)self.mapSize.width;
    int y = arc4random() % (int)self.mapSize.height;
    NSNumber *num = [[_walkableData objectAtIndex:x] objectAtIndex:y];
    if (num.boolValue == YES) {
      // Make sure it is not too close to another sprite
      BOOL acceptable = YES;
      for (CCNode *child in self.children) {
        if ([child isKindOfClass:[CharacterSprite class]]) {
          CharacterSprite *cs = (CharacterSprite *)child;
          int xDiff = ABS(cs.location.origin.x-x);
          int yDiff = ABS(cs.location.origin.y-y);
          if (xDiff <= 2 && yDiff <= 2) {
            acceptable = NO;
            break;
          }
        }
      }
      
      if (acceptable) {
        return CGPointMake(x, y);
      }
    }
  }
}

- (CGPoint) nextWalkablePositionFromPoint:(CGPoint)point prevPoint:(CGPoint)prevPt {
  CGPoint diff = ccpSub(point, prevPt);
  if (diff.y > 0.5f) {
    diff = ccp(0, 1);
  } else if (diff.y < -0.5f) {
    diff = ccp(0, -1);
  } else if (diff.x > 0.5f) {
    diff = ccp(1, 0);
  } else {
    // Use some default :/ in case stuck
    diff = ccp(-1, 0);
  }
  
  CGPoint straight = ccpAdd(point, diff);
  CGPoint left = ccpAdd(point, ccpRotateByAngle(diff, ccp(0,0), M_PI_2));
  CGPoint right = ccpAdd(point, ccpRotateByAngle(diff, ccp(0,0), -M_PI_2));
  CGPoint back = ccpSub(point, diff);
  
  CGPoint pts[4] = {straight, right, left, back};
  int width = mapSize_.width;
  int height = mapSize_.height;
  
  // Don't let it infinite loop in case its stuck
  int max = 50;
  while (max > 0) {
    // 75% chance to go straight, 10% chance to turn (for each way), 5% chance to go back
    int x = arc4random() % 100;
    if (x <= 75) x = 0;
    else if (x <= 85) x = 1;
    else if (x <= 95) x = 2;
    else x = 3;
    
    CGPoint pt = pts[x];
    if (pt.x >= 0 && pt.x < width && pt.y >= 0 && pt.y < height) {
      if ([[[_walkableData objectAtIndex:pt.x] objectAtIndex:pt.y] boolValue] == YES) {
        return ccp((int)pt.x, (int)pt.y);
      }
    }
    max--;
  }
  return point;
}

- (void) moveToCenter {
  // move map to the center of the screen
  CGSize ms = [self mapSize];
  CGSize ts = [self tileSizeInPoints];
  CGSize size = [[CCDirector sharedDirector] winSize];
  
  float x = -ms.width*ts.width/2*scaleX_+size.width/2;
  float y = -ms.height*ts.height/2*scaleY_+size.height/2;
  self.position = ccp(x,y);
}

- (void) moveToSprite:(CCSprite *)spr {
  if (spr) {
    CGPoint pt = spr.position;
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    // Since all sprites have anchor point ccp(0.5,0) adjust accordingly
    float x = -pt.x*scaleX_+size.width/2;
    float y = (-pt.y-spr.contentSize.height*3/4)*scaleY_+size.height/2;
    self.position = ccp(x,y);
  }
}

- (CGPoint) convertTilePointToCCPoint:(CGPoint)pt {
  CGSize ms = mapSize_;
  CGSize ts = tileSizeInPoints;
  return ccp( ms.width * ts.width/2.f + ts.width * (pt.x-pt.y)/2.f, 
      ts.height * (pt.y+pt.x)/2.f);
}

- (CGPoint) convertCCPointToTilePoint:(CGPoint)pt {
  CGSize ms = mapSize_;
  CGSize ts = tileSizeInPoints;
  float a = (pt.x - ms.width*ts.width/2.f)/ts.width;
  float b = pt.y/ts.height;
  float x = a+b;
  float y = b-a;
  return ccp(x,y);
}

- (void) reloadQuestGivers {
  NSAssert(NO, @"Implement reloadQuestGivers in map");
}

- (void) questAccepted:(FullQuestProto *)fqp {
  NSAssert(NO, @"Implement questAccepted: in map");
}

- (void) questRedeemed:(FullQuestProto *)fqp {
  NSAssert(NO, @"Implement questAccepted: in map");
}

- (void) moveToEnemyType:(DefeatTypeJobProto_DefeatTypeJobEnemyType)type {
  Enemy *enemyWithType = nil;
  for (CCNode *child in children_) {
    if ([child isKindOfClass:[Enemy class]]) {
      Enemy *enemy = (Enemy *)child;
      if (enemy.user.userType == type || type == DefeatTypeJobProto_DefeatTypeJobEnemyTypeAllTypesFromOpposingSide) {
        enemyWithType = enemy;
        break;
      }
    }
  }
  [self moveToSprite:enemyWithType];
}

- (void) onExit {
  [super onExit];
  self.selected = nil;
}

- (void) dealloc {
  [self.enemyMenu removeFromSuperview];
  self.enemyMenu = nil;
  self.walkableData = nil;
  self.mapSprites = nil;
  [super dealloc];
}

@end
