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

#define MAP_OFFSET 100

#define REORDER_START_Z 150

@implementation EnemyPopupView

@synthesize nameLabel, levelLabel;

@end

@implementation GameMap

@synthesize selected = _selected;
@synthesize tileSizeInPoints;
@synthesize aviaryMenu, enemyMenu;
@synthesize mapSprites = _mapSprites;

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
      [[self.enemyMenu nameLabel] setText:[(Enemy *)selected user].name];
      [[self.enemyMenu levelLabel] setText:[NSString stringWithFormat:@"Lvl %d", [(Enemy *)selected user].level]];
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
    [node stopAllActions];
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
    [node runAction:[CCEaseSineOut actionWithAction:actionID]];
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

-(void) dealloc {
  [self.enemyMenu removeFromSuperview];
  self.enemyMenu = nil;
  [self.aviaryMenu removeFromSuperview];
  self.aviaryMenu = nil;
  [_mapSprites release];
  [super dealloc];
}

@end
