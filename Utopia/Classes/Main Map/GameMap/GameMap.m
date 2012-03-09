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

#define MAP_OFFSET 100

#define REORDER_START_Z 150

@implementation GameMap

@synthesize selected = _selected;
@synthesize tileSizeInPoints;

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
  }
  return self;
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

- (void) setSelected:(SelectableSprite *)selected {
  if (_selected != selected) {
    _selected.isSelected = NO;
    _selected = selected;
    _selected.isSelected = YES;
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
    if ([child isPointInArea:pt]) {
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
  // First check if a sprite was clicked
  CGPoint pt = [recognizer locationInView:recognizer.view];
  pt = [self convertToNodeSpace:pt];
  
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
    
  } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
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
}

-(void) setPosition:(CGPoint)position {
  float x = MAX(MIN(MAP_OFFSET, position.x), -self.contentSize.width*self.scaleX + [[CCDirector sharedDirector] winSize].width-MAP_OFFSET);
  float y = MAX(MIN(MAP_OFFSET, position.y), -self.contentSize.height*self.scaleY + [[CCDirector sharedDirector] winSize].height-MAP_OFFSET);
  [super setPosition:ccp(x,y)];
}

-(void) dealloc {
  [_mapSprites release];
  [super dealloc];
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

@end
