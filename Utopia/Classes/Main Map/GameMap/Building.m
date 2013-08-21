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

#define CONSTRUCTION_TAG 49

@implementation Building

@synthesize orientation;
@synthesize verticalOffset;

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

- (void) setLocation:(CGRect)location {
  [super setLocation:location];
  self.position = ccpAdd(self.position, ccp(0,self.verticalOffset));
}

- (void) setVerticalOffset:(float)v {
  if (v != verticalOffset) {
    verticalOffset = v;
    self.location = self.location;
  }
}

@end

@implementation HomeBuilding

@synthesize startTouchLocation = _startTouchLocation;
@synthesize isSetDown = _isSetDown;
@synthesize isConstructing = _isConstructing;

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

- (void) setOpacity:(GLubyte)opacity {
  if (_isConstructing) {
    CCSprite *sprite = (CCSprite *)[self getChildByTag:CONSTRUCTION_TAG];
    sprite.opacity = opacity;
  } else {
    [super setOpacity:opacity];
  }
}

- (CGSize) contentSize {
  CCNode *spr = [self getChildByTag:CONSTRUCTION_TAG];
  if (spr) {
    return spr.contentSize;
  }
  return [super contentSize];
}

- (void) setIsConstructing:(BOOL)isConstructing {
  if (_isConstructing != isConstructing) {
    if (isConstructing) {
      [self setOpacity:1];
      _isConstructing = isConstructing;
      
      CCSprite *sprite = [CCSprite spriteWithFile:[Globals imageNameForConstructionWithSize:self.location.size]];
      sprite.anchorPoint = ccp(0.5, 0.f);
      sprite.position = ccp(self.contentSize.width/2, 0);
      [self addChild:sprite z:1 tag:CONSTRUCTION_TAG];
    } else {
      _isConstructing = isConstructing;
      self.opacity = 255;
      [self removeChildByTag:CONSTRUCTION_TAG cleanup:YES];
    }
  }
}

- (void) cancelMove {
  [self clearMeta];
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
  
  CCSprite *sprite = (CCSprite *)[self getChildByTag:CONSTRUCTION_TAG];
  sprite = sprite ? sprite : self;
  
  if ([_homeMap isBlockBuildable:self.location]) {
    sprite.opacity = 255;
    [_homeMap changeTiles:self.location toBuildable:NO];
    _isSetDown = YES;
  } else {
    sprite.opacity = 150;
  }
}

- (void) liftBlock {
  CCSprite *sprite = (CCSprite *)[self getChildByTag:CONSTRUCTION_TAG];
  sprite = sprite ? sprite : self;
  
  if (self.isSetDown) {
    sprite.opacity = 150;
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
  _retrieveBubble = [[CCSprite spriteWithFile:@"silverover.png"] retain];
  [self addChild:_retrieveBubble];
  _retrieveBubble.position = ccp(self.contentSize.width/2,self.contentSize.height-OVER_HOME_BUILDING_MENU_OFFSET);
}

- (void) setUserStruct:(UserStruct *)userStruct {
  if (_userStruct != userStruct) {
    [_userStruct release];
    _userStruct = [userStruct retain];
    
    // Re-set location
    if (userStruct) {
      FullStructureProto *fsp = [[GameState sharedGameState] structWithId:userStruct.structId];
      self.verticalOffset = fsp.imgVerticalPixelOffset;
    }
  }
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

#define UPGRADING_TAG 123

- (void) displayUpgradeIcon {
  if (![self getChildByTag:UPGRADING_TAG]) {
    CCSprite *upgrIcon = [CCSprite spriteWithFile:@"upgrading.png"];
    [self addChild:upgrIcon z:1 tag:UPGRADING_TAG];
    upgrIcon.position = ccp(self.contentSize.width/2, self.contentSize.height);
  }
}

- (void) removeUpgradeIcon {
  [self removeChildByTag:UPGRADING_TAG cleanup:YES];
}

- (void) setTimer:(NSTimer *)timer {
  if (_timer != timer) {
    [_timer invalidate];
    [_timer release];
    _timer = [timer retain];
  }
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

@synthesize critStruct, retrievable = _retrievable;

- (id) initWithCritStruct:(CritStruct *)cs location:(CGRect)loc map:(GameMap *)map {
  NSString *fileName = [[cs.name stringByReplacingOccurrencesOfString:@" " withString:@""] stringByAppendingString:@".png"];
  if ((self = [super initWithFile:fileName location:loc map:map])) {
    self.critStruct = cs;
    
    CCSprite *label = [CCSprite spriteWithFile:[@"The" stringByAppendingString:fileName]];
    [self addChild:label z:1];
    label.position = ccp(self.contentSize.width/2, 45);
    
    self.tag = cs.type;
  }
  return self;
}

- (void) updateLock {
  GameState *gs = [GameState sharedGameState];
  if (gs.level < self.critStruct.minLevel && gs.prestigeLevel == 0) {
    self.color = ccc3(80, 80, 80);
    
    CCNode *lock = [self getChildByTag:5];
    if (!lock) {
      lock = [CCSprite spriteWithFile:@"missionlock.png"];
      [self addChild:lock z:1 tag:5];
      lock.position = ccp(self.contentSize.width/2, self.contentSize.height*2.5/4);
    }
  } else {
    self.color = ccc3(255, 255, 255);
    CCNode *lock = [self getChildByTag:5];
    [lock removeFromParentAndCleanup:YES];
  }
}

- (void) initializeRetrieveBubble {
  if (_retrieveBubble) {
    // Make sure to cleanup just in case
    [self removeChild:_retrieveBubble cleanup:YES];
    [_retrieveBubble release];
  }
  _retrieveBubble = [[CCSprite spriteWithFile:@"goldover.png"] retain];
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

- (void) dealloc {
  self.critStruct = nil;
  [super dealloc];
}

@end

@implementation MissionBuilding

@synthesize ftp, numTimesActedForTask, numTimesActedForQuest, name, partOfQuest;

- (void) setIsSelected:(BOOL)isSelected {
  [super setIsSelected:isSelected];
  if (isSelected) {
    [Analytics taskViewed:ftp.taskId];
  } else {
    [Analytics taskClosed:ftp.taskId];
  }
}

- (void) dealloc {
  self.ftp = nil;
  self.name = nil;
  [super dealloc];
}

@end

@implementation ExpansionBoard

@synthesize direction = _direction;

- (id) initForDirection:(ExpansionDirection)direction location:(CGRect)location map:(GameMap *)map isExpanding:(BOOL)isExpanding {
  NSString *file = nil;
  if (direction == ExpansionDirectionFarLeft || direction == ExpansionDirectionNearRight) {
    file = @"leftexpand.png";
  } else if (direction == ExpansionDirectionFarRight || direction == ExpansionDirectionNearLeft) {
    file = @"rightexpand.png";
  }
  if ((self = [super initWithFile:file location:location map:map])) {
    _direction = direction;
    
    if (isExpanding) {
      CCSprite *yellow = nil;
      if (direction == ExpansionDirectionFarLeft || direction == ExpansionDirectionNearRight) {
        yellow = [CCSprite spriteWithFile:@"leftexpanding.png"];
      } else if (direction == ExpansionDirectionFarRight || direction == ExpansionDirectionNearLeft) {
        yellow = [CCSprite spriteWithFile:@"expandingright.png"];
      }
      yellow.anchorPoint = ccp(0,0);
      yellow.position = ccp(18*DEVICE_SCALE, 25*DEVICE_SCALE);
      [self addChild:yellow];
    }
  }
  return self;
}

@end