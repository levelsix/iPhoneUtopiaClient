//
//  MapSprite.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/8/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MapSprite.h"
#import "GameMap.h"

#define GLOW_ACTION_TAG 3021
#define GLOW_DURATION 0.6f

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
    self.anchorPoint = ccp(loc.size.height/(loc.size.width+loc.size.height), 0);
  }
  return self;
}

- (void) setLocation:(CGRect)location {
  CGSize ms = _map.mapSize;
  location.origin.x = MIN(ms.width-location.size.width, MAX(0, location.origin.x));
  location.origin.y = MIN(ms.height-location.size.height, MAX(0, location.origin.y));
  _location = location;
  self.position = [_map convertTilePointToCCPoint:location.origin];
  
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
  //  _glow = [[CCSprite spriteWithFile:@"glow.png"] retain];
  //  _glow.scale = 0.55;
  //  _glow.position = ccp(self.contentSize.width/2, _map.tileSizeInPoints.height*self.location.size.width/2);
  //  _glow.visible = NO;
  //  [self addChild:_glow z:-1];
}

-(void) setIsSelected:(BOOL)isSelected {
  if (self.isSelected == isSelected) {
    return;
  }
  
  _isSelected = isSelected;
  if (isSelected) {
    //    _glow.visible = YES;
    int amt = 120;
    CCTintBy *tint = [CCTintBy actionWithDuration:GLOW_DURATION red:-amt green:-amt blue:-amt];
    CCAction *action = [CCRepeatForever actionWithAction:[CCSequence actions:tint, tint.reverse, nil]];
    action.tag = GLOW_ACTION_TAG;
    [self runAction:action];
  } else {
    //    _glow.visible = NO;
    [self stopActionByTag:GLOW_ACTION_TAG];
    self.color = ccc3(255, 255, 255);
  }
}

- (void) displayArrow {
  [self removeArrowAnimated:NO];
  _arrow = [CCSprite spriteWithFile:@"3darrow.png"];
  [self addChild:_arrow];
  
  _arrow.anchorPoint = ccp(0.5f, 0.f);
  _arrow.position = ccp(self.contentSize.width/2, self.contentSize.height+5.f);
  
  CCSpawn *down = [CCSpawn actions:
                   [CCEaseSineInOut actionWithAction:[CCScaleBy actionWithDuration:0.7f scaleX:1.f scaleY:0.88f]],
                   [CCEaseSineInOut actionWithAction:[CCMoveBy actionWithDuration:0.7f position:ccp(0.f, -5.f)]], 
                   nil];
  CCActionInterval *up = [down reverse];
  [_arrow runAction:[CCRepeatForever actionWithAction:[CCSequence actions:down, up, nil]]];
}

- (void) removeArrowAnimated:(BOOL)animated {
  if (_arrow) {
    if (!animated) {
      [self removeChild:_arrow cleanup:YES];
    } else {
      [_arrow runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.2f], [CCCallBlock actionWithBlock:^{
        [_arrow removeFromParentAndCleanup:YES];
      }], nil]];
    }
    _arrow = nil;
  }
}

- (void) displayCheck {
  if (_arrow) {
    CCSprite *check = [CCSprite spriteWithFile:@"3dcheckmark.png"];
    [self addChild:check];
    check.anchorPoint = ccp(0.5, 0.f);
    check.position = _arrow.position;
    
    [check runAction:[CCSequence actions:
                      [CCDelayTime actionWithDuration:1.5f],
                      [CCSpawn actions:
                       [CCMoveBy actionWithDuration:1.5f position:ccp(0, 20.f)],
                       [CCFadeOut actionWithDuration:1.5f],
                       nil], 
                      nil]];
    
    [self removeArrowAnimated:YES];
  }
}

-(NSString *) description {
  return [NSString stringWithFormat:@"%f, %f, %f, %f", self.location.origin.x, self.location.origin.y, self.location.size.width, self.location.size.height];
}

-(void) dealloc {
  [_glow release];
  [super dealloc];
}

@end