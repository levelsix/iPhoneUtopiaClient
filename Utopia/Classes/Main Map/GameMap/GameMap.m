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
#import "LabelButton.h"

@implementation GameMap

@synthesize selected = _selected;
@synthesize tileSizeInPoints;

+(id) tiledMapWithTMXFile:(NSString*)tmxFile
{
	return [[[self alloc] initWithTMXFile:tmxFile] autorelease];
}

-(void) addChild:(CCNode *)node z:(NSInteger)z tag:(NSInteger)tag {
  if ([[node class] isSubclassOfClass:[SelectableSprite class]]) {
    [_selectables addObject:node];
  }
  [super addChild:node z:z tag:tag];
}

- (void) removeChild:(CCNode *)node cleanup:(BOOL)cleanup {
  if ([_selectables containsObject:node]) {
    [_selectables removeObject:node];
  }
  [super removeChild:node cleanup:cleanup];
}

-(id) initWithTMXFile:(NSString *)tmxFile {
  if ((self = [super initWithTMXFile:tmxFile])) {
    _selectables = [[NSMutableArray array] retain];
    
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
  }
  return self;
}

- (CGSize) tileSizeInPoints {
  if (CC_CONTENT_SCALE_FACTOR() == 2) {
    return CGSizeMake(self.tileSize.width/2, self.tileSize.height/2);
  }
  return self.tileSize;
}

- (BOOL) selectable:(SelectableSprite *)front isInFrontOfSelectable: (SelectableSprite *)back {
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
  for (int i = 1; i < [_selectables count]; i++) {
    SelectableSprite *toSort = [_selectables objectAtIndex:i];
    SelectableSprite *sorted = [_selectables objectAtIndex:i-1];
    if (![self selectable:toSort isInFrontOfSelectable:sorted]) {
      int j;
      for (j = i-2; j >= 0; j--) {
        sorted = [_selectables objectAtIndex:j];
        if ([self selectable:toSort isInFrontOfSelectable:sorted]) {
          break;
        }
      }
      
      [_selectables removeObjectAtIndex:i];
      [_selectables insertObject:toSort atIndex:j+1];
    }
  }
  
  for (int i = 0; i < [_selectables count]; i++) {
    SelectableSprite *child = [_selectables objectAtIndex:i];
    [self reorderChild:child z:i];
  }
}

- (void) tap:(UIGestureRecognizer*)recognizer node:(CCNode*)node
{
  CGPoint pt = [recognizer locationInView:recognizer.view];
  pt = [[CCDirector sharedDirector] convertToGL:pt];
  
  if (_selected && ![_selected isPointInArea:pt]) {
    self.selected = nil;
    [self doReorder];
  }
  
  for(SelectableSprite *child in _selectables) {
    if ([child isPointInArea:pt]) {
      if (_selected) {
        if ([self selectable:child isInFrontOfSelectable:_selected] && child != _selected) {
          self.selected = child;
          break;
        }
      } else {
        self.selected = child;
        break;
      }
    }
  }
}

- (void) drag:(UIGestureRecognizer*)recognizer node:(CCNode*)node
{
  // First check if a sprite was clicked
  CGPoint pt = [recognizer locationInView:recognizer.view];
  pt = [[CCDirector sharedDirector] convertToGL:pt];
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
  float x = MAX(MIN(0, position.x), -self.contentSize.width*self.scaleX + [[CCDirector sharedDirector] winSize].width);
  float y = MAX(MIN(0, position.y), -self.contentSize.height*self.scaleY + [[CCDirector sharedDirector] winSize].height);
  [super setPosition:ccp(x,y)];
}

-(void) dealloc {
  [_selectables release];
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
