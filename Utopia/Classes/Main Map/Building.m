//
//  Building.m
//  IsoMap
//
//  Created by Ashwin Kamath on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Building.h"
#import "GameLayer.h"
#import "GameMap.h"

@implementation SelectableSprite

@synthesize isSelected = _isSelected;
@synthesize location = _location;
@synthesize name = _name;

-(id) initWithFile: (NSString *) file  location: (CGRect)loc map: (GameMap *) map{
  if ((self = [super initWithFile:file])) {
    // Add to map first or else reorder does weird stuff..
    [map addChild:self];
    
    _map = map;
    self.isSelected = NO;
    self.location = loc;
    self.anchorPoint = ccp(0.5,0);
    
    _glow = [[CCSprite spriteWithFile:@"glow.png"] retain];
    _glow.scale = 0.55;
    _glow.anchorPoint = ccp(0.5,0.08);
    _glow.position = ccp(self.contentSize.width/2, 0);
    _glow.visible = NO;
    _glow.opacity = 20;
    [self addChild:_glow z:-1];
    
    _pin = [[CCSprite spriteWithFile:@"pin.png"] retain];
    _pin.visible = NO;
    [self addChild:_pin z:1];
  }
  return self;
}

-(void) setIsSelected:(BOOL)isSelected {
  if (self.isSelected == isSelected) {
    return;
  }
  
  _isSelected = isSelected;
  if (isSelected) {
    int pinDrop = [[CCDirector sharedDirector] winSize].height;
    _glow.visible = YES;
    _pin.visible = YES;
    _pin.position = ccp(self.contentSize.width/2, self.contentSize.height+_pin.contentSize.height/5+pinDrop);
    [_pin runAction:[CCSpawn actions:
                     [CCEaseExponentialIn actionWithAction:
                      [CCMoveBy actionWithDuration:0.5 position:ccp(0, -pinDrop)]],
                     [CCFadeIn actionWithDuration:0.5], nil]];
  } else {
    _glow.visible = NO;
    _pin.visible = NO;
  }
}

-(void) setLocation:(CGRect)location {
  CGSize ms = _map.mapSize;
  CGSize ts = _map.tileSize;
  
  location.origin.x = MIN(ms.width-location.size.width, MAX(0, location.origin.x));
  location.origin.y = MIN(ms.height-location.size.height, MAX(0, location.origin.y));
  _location = location;
  self.position = ccp( ms.width * ts.width/2 + ts.width * (location.origin.x-location.origin.y)/2, 
                      ts.height * (location.origin.y+location.origin.x)/2);
  
  [_map doReorder];
}

-(NSString *) description {
  return [NSString stringWithFormat:@"%f, %f, %f, %f", self.location.origin.x, self.location.origin.y, self.location.size.width, self.location.size.height];
}

-(void) dealloc {
  [_glow release];
  [_pin release];
  [super dealloc];
}

@end

@implementation Building

+(id) buildingWithFile: (NSString *) file location: (CGRect) loc map: (GameMap *) map{
  return [[[self alloc] initWithFile:file location:loc map:map] autorelease];
}

@end

@implementation HomeBuilding

@synthesize level = _level;
@synthesize startTouchLocation = _startTouchLocation;
@synthesize isSetDown = _isSetDown;

+(id) homeWithFile: (NSString *) file location: (CGRect) loc map: (GameMap *) map {
  return [[[self alloc] initWithFile:file location:loc map:map] autorelease];
}

-(id) initWithFile: (NSString *) file location: (CGRect)loc map: (GameMap *) map{
  if ((self = [super initWithFile:file location:loc map: map])) {
    _map = [map retain];
    [self placeBlock];
  }
  return self;
}

-(void) updateMeta {
  CCTMXLayer *meta = [_map layerNamed:@"MetaLayer"];
  int red = [meta tileGIDAt:ccp(0,63)];
  int green = [meta tileGIDAt:ccp(0,62)];
  for (int i = 0; i < self.location.size.width; i++) {
    for (int j = 0; j < self.location.size.height; j++) {
      // Transform to the map's coordinates
      CGPoint tileCoord = ccp(63-(self.location.origin.y+j), 63-(self.location.origin.x+i));
      int tileGid = [meta tileGIDAt:tileCoord];
      if ([[[_map.buildableData objectAtIndex:i+self.location.origin.x] objectAtIndex:j+self.location.origin.y] boolValue]) {
        if (tileGid != red) {
          [meta setTileGID:green at:tileCoord];
        }
      } else {
        if (tileGid != green) {
          [meta setTileGID:red at:tileCoord];
        }
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

-(void) locationAfterTouch: (CGPoint) touchLocation {
  // Subtract the touch location from the start location to find the distance moved
  CGPoint vector = ccpSub(touchLocation, _startTouchLocation);
  CGSize ts = [(CCTMXTiledMap *)[self parent] tileSize];
  if (abs(vector.x)+abs(2*vector.y) >= ts.width) {
    float angle = CC_RADIANS_TO_DEGREES(ccpToAngle(ccpSub(touchLocation, _startTouchLocation)));
    
    CGRect loc = self.location;
    CGRect oldLoc = self.location;
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
@synthesize experience = _experience;

+(id) missionBuildingWithFile: (NSString *) file location: (CGRect) loc map: (GameMap *) map {
  return [[[self alloc] initWithFile:file location:loc map:map] autorelease];
}

-(id) initWithFile: (NSString *) file location: (CGRect)loc map: (GameMap *) map{
  //  if ((self = [super initWithFile:file location:loc])) {
  //  }
  return self;
}

@end