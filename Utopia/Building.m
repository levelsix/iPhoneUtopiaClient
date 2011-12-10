//
//  Building.m
//  IsoMap
//
//  Created by Ashwin Kamath on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Building.h"
#import "MapLayer.h"
#import "GameMap.h"

@implementation Building

@synthesize name = _name;
@synthesize location = _location;
@synthesize outline = _outline;
@synthesize isSelected = _isSelected;

+(id) buildingWithFile: (NSString *) file location: (CGRect) loc {
  return [[[self alloc] initWithFile:file location:loc] autorelease];
}

-(id) initWithFile: (NSString *) file location: (CGRect)loc {
  if ((self = [super initWithFile:file])) {
    self.location = loc;
    self.anchorPoint = ccp(0.5,0);
    self.isSelected = NO;
    _glow = [[CCSprite spriteWithFile:@"glow.png"] retain];
    _glow.scale = loc.size.width/4+0.1;
    _glow.anchorPoint = ccp(0.5,0.08);
    _glow.position = ccp(self.contentSize.width/2, 0);
    _glow.visible = NO;
    _glow.opacity = 140;
    [self addChild:_glow z:-1];
  }
  return self;
}

-(void) setLocation:(CGRect)location {
  CGSize ms = MAPSIZE;
  CGSize ts = TILESIZE;
  
  location.origin.x = MIN(ms.width-location.size.width, MAX(0, location.origin.x));
  location.origin.y = MIN(ms.height-location.size.height, MAX(0, location.origin.y));
  _location = location;
  self.position = ccp( ms.width * ts.width/2 + ts.width * (location.origin.x-location.origin.y)/2, 
                      ts.height * (location.origin.y+location.origin.x)/2);
}

-(void) setIsSelected:(BOOL)isSelected {
  if (self.isSelected == isSelected) {
    return;
  }
  
  _isSelected = isSelected;
  if (isSelected) {
    _glow.visible = YES;
  } else {
    _glow.visible = NO;
  }
}

-(void) dealloc {
  [_glow release];
  [super dealloc];
}

@end

@implementation HomeBuilding

@synthesize level = _level;

+(id) homeWithFile: (NSString *) file location: (CGRect) loc map: (GameMap *) map {
  return [[[self alloc] initWithFile:file location:loc map:map] autorelease];
}

-(id) initWithFile: (NSString *) file location: (CGRect)loc map: (GameMap *) map{
  if ((self = [super initWithFile:file location:loc])) {
    _map = [map retain];
    [self placeBlock];
    //[self createStrokeWithSize:50 color: ccYELLOW];
    
  }
  return self;
}

-(void) createStrokeWithSize:(float)size color:(ccColor3B)cor
{
	self.outline = [CCSprite spriteWithTexture:[self texture]];
  self.outline.position = ccp(self.contentSize.width/2, self.contentSize.height/2);
  self.outline.color = ccRED;
  self.outline.scale = 1.05;
  
	[self addChild:self.outline z:-1];
}

-(void) updateMeta {
  CCTMXLayer *meta = [_map layerNamed:@"MetaLayer"];
  int red = [meta tileGIDAt:ccp(0,63)];
  int green = [meta tileGIDAt:ccp(0,62)];
  for (int i = 0; i < self.location.size.width; i++) {
    for (int j = 0; j < self.location.size.height; j++) {
      // Transform to the map's coordinates
      CGPoint tileCoord = ccp(63-(self.location.origin.y+j), 63-(self.location.origin.x+i));
      if ([[[_map.buildableData objectAtIndex:i+self.location.origin.x] objectAtIndex:j+self.location.origin.y] boolValue]) {
        [meta setTileGID:green at:tileCoord];
      } else {
        [meta setTileGID:red at:tileCoord];
      }
    }
  }
}

-(void) clearMeta {
  CCTMXLayer *meta = [_map layerNamed:@"MetaLayer"];
  for (int i = 0; i < self.location.size.width; i++) {
    for (int j = 0; j < self.location.size.height; j++) {
      CGPoint tileCoord = ccp(63-(self.location.origin.y+j), 63-(self.location.origin.x+i));
      [meta removeTileAt:tileCoord];
    }
  }
}

-(void) placeBlock {
  if ([_map isBlockBuildable:self.location]) {
    self.opacity = 255;
    [_map changeTiles:self.location toBuildable:NO];
    _isSetDown = YES;
  } else {
    self.opacity = 150;
  }
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  _alreadyClicked = self.isSelected;
  if (![super ccTouchBegan:touch withEvent:event])
    return NO;
  
  if (_alreadyClicked) {
    _startTouchLocation = [[self parent] convertTouchToNodeSpace:touch];
    
    if (_isSetDown) {
      self.opacity = 120;
      [_map changeTiles:self.location toBuildable:YES];
    }
    _isSetDown = NO;
    [self updateMeta];
  }
  return YES;
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
  if (_alreadyClicked) {
    [self clearMeta];
    CGPoint touchLocation = [touch locationInView: [touch view]];	
    CGPoint prevLocation = [touch previousLocationInView: [touch view]];	
    
    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];
    
    [self locationAfterTouch:[[self parent] convertToNodeSpace:touchLocation]];
    [self updateMeta];
  }
}

-(void) locationAfterTouch: (CGPoint) touchLocation {
  if (ccpDistance(touchLocation, _startTouchLocation) >= 32) {
    float angle = CC_RADIANS_TO_DEGREES(ccpToAngle(ccpSub(touchLocation, _startTouchLocation)));
    
    CGRect loc = self.location;
    CGRect oldLoc = self.location;
    CGSize ts = TILESIZE;
    // Adjust the location in the map to the correct angle
    if (angle >= 165 || angle <= -165) {
      loc.origin.x -= 1;
      loc.origin.y += 1;
    } else if (angle >= 120) {
      loc.origin.y += 1;
    } else if (angle >= 60) {
      loc.origin.x += 1;
      loc.origin.y += 1;
    } else if (angle >= 15) {
      loc.origin.x += 1;
    } else if (angle >= -15) {
      loc.origin.x += 1;
      loc.origin.y -= 1;
    } else if (angle >= -60) {
      loc.origin.y -= 1;
    } else if (angle >= -120) {
      loc.origin.y -= 1;
      loc.origin.x -= 1;
    } else if (angle >= -165) {
      loc.origin.x -= 1;
    }
    self.location = loc;
    int diffX = self.location.origin.x - oldLoc.origin.x;
    int diffY = self.location.origin.y - oldLoc.origin.y;
    _startTouchLocation.x += ts.width * (diffX-diffY)/2, 
    _startTouchLocation.y += ts.height * (diffX+diffY)/2;
  }
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
  if (_alreadyClicked) {
    [self clearMeta];
    [self placeBlock];
  }
}

-(void) dealloc {
  [_map release];
  [super dealloc];
}

@end

@implementation MoneyBuilding

@synthesize timeLeft = _timeLeft;
@synthesize income = _income;

@end

@implementation DefenseBuilding

@synthesize defense = _defense;

@end

@implementation MissionBuilding

@synthesize bountyRange = _bountyRange;

@end