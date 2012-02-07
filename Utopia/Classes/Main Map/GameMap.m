//
//  GameMap.m
//  IsoMap
//
//  Created by Ashwin Kamath on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GameMap.h"
#import "Building.h"

@implementation GameMap

@synthesize buildableData = _buildableData;

+(id) tiledMapWithTMXFile:(NSString*)tmxFile
{
	return [[[self alloc] initWithTMXFile:tmxFile] autorelease];
}

-(void) addChild:(CCNode *)node {
  if ([[node class] isSubclassOfClass:[SelectableSprite class]]) {
    [_selectables addObject:node];
  }
  [super addChild:node];
}

-(id) initWithTMXFile:(NSString *)tmxFile {
  if ((self = [super initWithTMXFile:tmxFile])) {
    self.buildableData = [NSMutableArray arrayWithCapacity:[self mapSize].width];
    _selectables = [[CCArray array] retain];
    
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

- (BOOL) selectable:(SelectableSprite *)front isInFrontOfSelectable: (SelectableSprite *)back {
  CGRect frontLoc = front.location;
  CGRect backLoc = back.location;
  
  if ((frontLoc.origin.x < backLoc.origin.x && frontLoc.origin.x+frontLoc.size.width-1 < backLoc.origin.x) || (frontLoc.origin.x > backLoc.origin.x+backLoc.size.width-1 && frontLoc.origin.x+frontLoc.size.width-1 > backLoc.origin.x+backLoc.size.width-1)) {
    return frontLoc.origin.x <= backLoc.origin.x;
  }
  return frontLoc.origin.y <= backLoc.origin.y;
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
    if (child != _selected) {
      [self reorderChild:child z:i];
    }
  }
  
  if (_selected) {
    [self reorderChild:_selected z:1000];
  }
}

- (void) tap:(UIGestureRecognizer*)recognizer node:(CCNode*)node
{
  CGPoint pt = [recognizer locationInView:recognizer.view];
  pt = [[CCDirector sharedDirector] convertToGL:pt];
  
  if (_selected && ![_selected isPointInArea:pt]) {
    _selected.isSelected = NO;
    _selected = nil;
    [self doReorder];
  }
  
  SelectableSprite *child;
  CCARRAY_FOREACH(_selectables, child) {
    if ([child isPointInArea:pt]) {
      if (_selected) {
        if ([self selectable:child isInFrontOfSelectable:_selected]) {
          _selected = child;
        }
      } else {
        _selected = child;
      }
    }
  }
  [_selected setIsSelected:YES];
  
//  ShopMenuController *smc = [[ShopMenuController alloc] initWithNibName:nil bundle:nil];
//  [[[CCDirector sharedDirector] openGLView] addSubview: smc.view];
}
- (void) drag:(UIGestureRecognizer*)recognizer node:(CCNode*)node
{
  // First check if a sprite was clicked
  CGPoint pt = [recognizer locationInView:recognizer.view];
  pt = [[CCDirector sharedDirector] convertToGL:pt];
  pt = [self convertToNodeSpace:pt];
  
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
        _moveSprite = YES;
        return;
      }
    } else if (_moveSprite && [recognizer state] == UIGestureRecognizerStateChanged) {
      [homeBuilding clearMeta];
      [homeBuilding locationAfterTouch:pt];
      [homeBuilding updateMeta];
      return;
    } else if (_moveSprite && [recognizer state] == UIGestureRecognizerStateEnded) {
      [homeBuilding clearMeta];
      [homeBuilding placeBlock];
      homeBuilding.isSelected = NO;
      _selected = nil;
      [self doReorder];
      return;
    }
    // Unset moveSprite when drag is not near the sprite
    _moveSprite = NO;
  }
  
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

-(void) setPosition:(CGPoint)position {
  float x = MAX(MIN(0, position.x), -self.contentSize.width*self.scaleX + [[CCDirector sharedDirector] winSize].width);
  float y = MAX(MIN(0, position.y), -self.contentSize.height*self.scaleY + [[CCDirector sharedDirector] winSize].height);
  [super setPosition:ccp(x,y)];
}

-(void) dealloc {
  self.buildableData = nil;
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
