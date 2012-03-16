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
#import "HomeMap.h"
#import "GameState.h"
#import "Globals.h"

@implementation Building

@synthesize orientation;

- (void) setOrientation:(StructOrientation)o {
  orientation = o % 2;
  switch (orientation) {
    case StructOrientationPosition1:
      self.flipX = NO;
      break;
      
    case StructOrientationPosition2:
      self.flipX = YES;
      break;
      
    default:
      break;
  }
}

@end

@implementation Aviary

@end

@implementation HomeBuilding

@synthesize level = _level;
@synthesize startTouchLocation = _startTouchLocation;
@synthesize isSetDown = _isSetDown;

+ (id) homeWithFile: (NSString *) file location: (CGRect) loc map: (HomeMap *) map {
  return [[[self alloc] initWithFile:file location:loc map:map] autorelease];
}

- (id) initWithFile: (NSString *) file location: (CGRect)loc map: (HomeMap *) map {
  if ((self = [super initWithFile:file location:loc map:map])) {
    _homeMap = map;
    [self placeBlock];
    
  }
  return self;
}

- (void) setIsSelected:(BOOL)isSelected {
  [super setIsSelected:isSelected];
  if (isSelected) {
    _startMoveCoordinate = _location.origin;
    _startOrientation = self.orientation;
  } else {
    if (!_isSetDown) {
      [self cancelMove];
    }
  }
}

- (void) cancelMove {
  [self liftBlock];
  self.orientation = _startOrientation;
  CGRect x = self.location;
  x.origin = _startMoveCoordinate;
  self.location = x;
  [self placeBlock];
}

-(void) updateMeta {
  CCTMXLayer *meta = [_homeMap layerNamed:@"MetaLayer"];
  int red = _homeMap.redGid;
  int green = _homeMap.greenGid;
  for (int i = 0; i < self.location.size.width; i++) {
    for (int j = 0; j < self.location.size.height; j++) {
      // Transform to the map's coordinates
      CGPoint tileCoord = ccp(_homeMap.mapSize.height-1-(self.location.origin.y+j), _homeMap.mapSize.width-1-(self.location.origin.x+i));
      int tileGid = [meta tileGIDAt:tileCoord];
      if ([[[_homeMap.buildableData objectAtIndex:i+self.location.origin.x] objectAtIndex:j+self.location.origin.y] boolValue]) {
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
  CCTMXLayer *meta = [_homeMap layerNamed:@"MetaLayer"];
  for (int i = 0; i < self.location.size.width; i++) {
    for (int j = 0; j < self.location.size.height; j++) {
      CGPoint tileCoord = ccp(_homeMap.mapSize.height-1-(self.location.origin.y+j),_homeMap.mapSize.width-1-(self.location.origin.x+i));
      [meta removeTileAt:tileCoord];
    }
  }
}

-(void) placeBlock {
  if (_isSetDown) {
    return;
  }
  
  if ([_homeMap isBlockBuildable:self.location]) {
    self.opacity = 255;
    [_homeMap changeTiles:self.location toBuildable:NO];
    _isSetDown = YES;
  } else {
    self.opacity = 150;
  }
}

- (void) liftBlock {
  if (self.isSetDown) {
    self.opacity = 150;
    [_homeMap changeTiles:self.location toBuildable:YES];
  }
  self.isSetDown = NO;
}

-(void) locationAfterTouch: (CGPoint) touchLocation {
  // Subtract the touch location from the start location to find the distance moved
  CGPoint vector = ccpSub(touchLocation, _startTouchLocation);
  CGSize ts = _homeMap.tileSizeInPoints;
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
  [_homeMap release];
  [super dealloc];
}

@end

@implementation MoneyBuilding

@synthesize userStruct = _userStruct;
@synthesize retrievable = _retrievable;
@synthesize timer = _timer;

- (void) initializeRetrieveBubble {
  if (_retrieveBubble) {
    // Make sure to cleanup just in case
    [self removeChild:_retrieveBubble cleanup:YES];
    [_retrieveBubble release];
  }
  _retrieveBubble = [[CCSprite spriteWithFile:@"retrievebubble.png"] retain];
  [self addChild:_retrieveBubble];
  _retrieveBubble.position = ccp(self.contentSize.width/2,self.contentSize.height-OVER_HOME_BUILDING_MENU_OFFSET);
}

- (void) setRetrievable:(BOOL)retrievable {
  if (retrievable != _retrievable) {
    _retrievable = retrievable;
    
    if (retrievable) {
      if (!_retrieveBubble) {
        [self initializeRetrieveBubble];
      }
      _retrieveBubble.visible = YES;
    } else {
      _retrieveBubble.visible = NO;
    }
  }
}

- (void) setTimer:(NSTimer *)timer {
  if (_timer) {
    [_timer invalidate];
    [_timer release];
  }
  _timer = [timer retain];
}

- (void) createTimerForCurrentState {
  FullStructureProto *fsp = [[GameState sharedGameState] structWithId:self.userStruct.structId];
  Globals *gl = [Globals sharedGlobals];
  
  UserStructState st = self.userStruct.state;
  NSTimeInterval time;
  SEL selector = nil;
  switch (st) {
    case kUpgrading:
      time = [[NSDate dateWithTimeInterval:[gl calculateMinutesToUpgrade:self.userStruct]*60 sinceDate:self.userStruct.lastUpgradeTime] timeIntervalSinceNow];
      selector = @selector(upgradeComplete:);
      break;
      
    case kBuilding:
      time = [[NSDate dateWithTimeInterval:fsp.minutesToBuild*60 sinceDate:self.userStruct.purchaseTime] timeIntervalSinceNow];
      selector = @selector(buildComplete:);
      break;
      
    case kWaitingForIncome:
      time = [[NSDate dateWithTimeInterval:fsp.minutesToGain*60 sinceDate:self.userStruct.lastRetrieved] timeIntervalSinceNow];
      selector = @selector(waitForIncomeComplete:);
      break;
      
    case kRetrieving:
      self.retrievable = YES;
      break;
      
    default:
      break;
  }
  
  if (selector) {
    self.timer = [NSTimer timerWithTimeInterval:time target:_homeMap selector:selector userInfo:self repeats:NO];
  } else {
    self.timer = nil;
  }
}

- (void) dealloc {
  self.userStruct = nil;
  self.timer = nil;
  [_retrieveBubble release];
  [super dealloc];
}

@end

@implementation CritStructBuilding

@synthesize critStruct;

@end

@implementation MissionBuilding

@synthesize ftp, numTimesActed, name;

- (void) dealloc {
  self.ftp = nil;
  self.name = nil;
  [super dealloc];
}

@end