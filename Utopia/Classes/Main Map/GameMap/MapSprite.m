//
//  MapSprite.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/8/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MapSprite.h"
#import "GameMap.h"

@implementation MapSprite

@synthesize location = _location;

- (id) initWithFile: (NSString *) file  location: (CGRect)loc map: (GameMap *) map {
  if (file) {
    self = [super initWithFile:file];
  } else {
    self = [super init];
    
  }
  if (self) {
    _map = map;
    self.location = loc;
    self.anchorPoint = ccp(0.5,0);
  }
  return self;
}

- (void) setLocation:(CGRect)location {
  CGSize ms = _map.mapSize;
  CGSize ts = _map.tileSizeInPoints;
  
  location.origin.x = MIN(ms.width-location.size.width, MAX(0, location.origin.x));
  location.origin.y = MIN(ms.height-location.size.height, MAX(0, location.origin.y));
  _location = location;
  self.position = ccp( ms.width * ts.width/2.f + ts.width * (location.origin.x-location.origin.y)/2.f, 
                      ts.height * (location.origin.y+location.origin.x)/2.f);
  
  [_map doReorder];
}

@end

@implementation SelectableSprite

@synthesize isSelected = _isSelected;

-(id) initWithFile: (NSString *) file  location: (CGRect)loc map: (GameMap *) map{
  if ((self = [super initWithFile:file location:loc map:map])) {
    _isSelected = NO;
    [self setUpGlow];
  }
  return self;
}

- (void) setUpGlow {
  _glow = [[CCSprite spriteWithFile:@"glow.png"] retain];
  _glow.scale = 0.55;
  _glow.anchorPoint = ccp(0.5,0);
  _glow.position = ccp(self.contentSize.width/2, 0);
  _glow.visible = NO;
  _glow.opacity = 100;
  [self addChild:_glow z:-1];
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

-(NSString *) description {
  return [NSString stringWithFormat:@"%f, %f, %f, %f", self.location.origin.x, self.location.origin.y, self.location.size.width, self.location.size.height];
}

-(void) dealloc {
  [_glow release];
  [_map release];
  [super dealloc];
}

@end