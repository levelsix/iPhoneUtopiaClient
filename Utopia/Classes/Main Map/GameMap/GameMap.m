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
#import "SimpleAudioEngine.h"
#import "TopBar.h"
#import "GameState.h"
#import "CCLabelFX.h"

#define MAP_OFFSET 100

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

//CCMoveToCustom
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

@end

@implementation GameMap

@synthesize selected = _selected;
@synthesize tileSizeInPoints;
@synthesize aviaryMenu, enemyMenu;
@synthesize mapSprites = _mapSprites;
@synthesize silverOnMap;
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
    
    [[NSBundle mainBundle] loadNibNamed:@"AviaryMenu" owner:self options:nil];
    [[[[CCDirector sharedDirector] openGLView] superview] addSubview:self.aviaryMenu];
    [[NSBundle mainBundle] loadNibNamed:@"EnemyPopupView" owner:self options:nil];
    [[[[CCDirector sharedDirector] openGLView] superview] addSubview:self.enemyMenu];
    [[[CCDirector sharedDirector] openGLView] setUserInteractionEnabled:YES];
    
    aviaryMenu.hidden = YES;
    enemyMenu.hidden = YES;
  }
  return self;
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
  
  [[SimpleAudioEngine sharedEngine] playEffect:@"Coin_drop.m4a"];
}

- (void) pickUpSilverDrop:(SilverStack *)ss {
  silverOnMap -= ss.amount;
  
  [ss stopAllActions];
  
  CCLabelTTF *coinLabel = [CCLabelFX labelWithString:[NSString stringWithFormat:@"+%d", ss.amount] fontName:@"DINCond-Black" fontSize:25 shadowOffset:CGSizeMake(0, -1) shadowBlur:1.f];
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

- (void) updateAviaryMenu {
  if (_selected && [_selected isKindOfClass:[Aviary class]]) {
    CGPoint pt = [_selected convertToWorldSpace:ccp(_selected.contentSize.width/2, _selected.contentSize.height-OVER_HOME_BUILDING_MENU_OFFSET)];
    
    float width = aviaryMenu.frame.size.width;
    float height = aviaryMenu.frame.size.height;
    aviaryMenu.frame = CGRectMake(pt.x-width/2, ([[CCDirector sharedDirector] winSize].height - pt.y)-height, width, height);
    
    aviaryMenu.hidden = NO;
  } else {
    aviaryMenu.hidden = YES;
  }
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
    [self updateAviaryMenu];
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
  SelectableSprite *toRet = nil;
  for(MapSprite *spr in _mapSprites) {
    if (![spr isKindOfClass:[MapSprite class]]) {
      continue;
    }
    SelectableSprite *child = (SelectableSprite *)spr;
    if ([child isPointInArea:pt] && child.visible && child.opacity > 0.f) {
      if (_selected) {
        if ([self mapSprite:child isInFrontOfMapSprite:_selected]) {
          toRet = child;
          break;
        }
      } else {
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
    self.aviaryMenu.hidden = YES;
    self.enemyMenu.hidden = YES;
  } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
    [self updateAviaryMenu];
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
  if (newScale > 2.0f || newScale < 0.5f) {
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
  
  [self updateAviaryMenu];
  [self updateEnemyMenu];
}

-(void) setPosition:(CGPoint)position {
  float x = MAX(MIN(MAP_OFFSET, position.x), -self.contentSize.width*self.scaleX + [[CCDirector sharedDirector] winSize].width-MAP_OFFSET);
  float y = MAX(MIN(MAP_OFFSET, position.y), -self.contentSize.height*self.scaleY + [[CCDirector sharedDirector] winSize].height-2*MAP_OFFSET);
  CGPoint oldPos = position_;
  [super setPosition:ccp(x,y)];
  if (!aviaryMenu.hidden) {
    CGPoint diff = ccpSub(oldPos, position_);
    diff.x *= -1;
    CGRect curRect = aviaryMenu.frame;
    curRect.origin = ccpAdd(curRect.origin, diff);
    aviaryMenu.frame = curRect;
  }
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

- (IBAction)enterAviaryClicked:(id)sender {
  self.selected = nil;
  [MapViewController displayView];
}

- (IBAction)attackClicked:(id)sender {
  if ([_selected isKindOfClass:[Enemy class]]) {
    Enemy *enemy = (Enemy *)_selected;
    FullUserProto *fup = enemy.user;
    if (fup) {
      [[BattleLayer sharedBattleLayer] beginBattleAgainst:fup inCity:[[GameLayer sharedGameLayer] currentCity]];
    }
  }
}

- (IBAction)profileClicked:(id)sender {
  if ([_selected isKindOfClass:[Enemy class]]) {
    Enemy *enemy = (Enemy *)_selected;
    [[ProfileViewController sharedProfileViewController] loadProfileForPlayer:enemy.user buttonsEnabled:YES];
    [ProfileViewController displayView];
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
    // 50% chance to go straight, 20% chance to turn (for each way), 10% chance to go back
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

-(void) dealloc {
  [self.enemyMenu removeFromSuperview];
  self.enemyMenu = nil;
  [self.aviaryMenu removeFromSuperview];
  self.aviaryMenu = nil;
  [_mapSprites release];
  [super dealloc];
}

@end
