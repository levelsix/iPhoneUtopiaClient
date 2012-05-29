//
//  DecorationLayer.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/23/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "DecorationLayer.h"
#import "cocos2d.h"
#import "GameMap.h"

#define CLOUD_INITIAL_COUNT 3
#define CLOUD_PERCENTAGE 0.1
#define CLOUD_MIN_SCALE 0.8
#define CLOUD_MAX_SCALE 1.2
#define CLOUD_MAX_OPACITY 180
#define CLOUD_SHADOW_OPACITY 250
#define CLOUD_ZERO_OPACITY_SCALE 1.f
#define CLOUD_SHADOW_Y_OFFSET 60.f
#define CLOUD_MIN_SPEED 5
#define CLOUD_MAX_SPEED 12
#define CLOUD_BASE_Z 30

@implementation DecorationLayer

- (id) initWithSize:(CGSize)size {
  if ((self = [super init])) {
    self.contentSize = size;
    
    [self schedule:@selector(spawnItems) interval:1.f];
    
    _clouds = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < CLOUD_INITIAL_COUNT; i++) {
      [self spawnCloud];
    }
  }
  return self;
}

- (void) spawnItems {
  float rand = [self rand];
  if (rand < CLOUD_PERCENTAGE) {
    [self spawnCloud];
  }
}

- (void) spawnCloud {
  BOOL isMovingRight = [self rand] < 0.5;
  float scale = CLOUD_MIN_SCALE+[self rand]*(CLOUD_MAX_SCALE-CLOUD_MIN_SCALE);
  float xPos = [self rand]*self.contentSize.width;
  float yPos = [self rand]*self.contentSize.height;
  BOOL flipX = [self rand] < 0.5;
  
  CCSprite *cloud = [CCSprite spriteWithFile:@"cloud1.png"];
  cloud.scale = scale;
  cloud.position = ccp(xPos, yPos);
  cloud.flipX = flipX;
  
  CGPoint endPos;
  if (isMovingRight) {
    endPos = ccp(self.contentSize.width+cloud.contentSize.width/2*cloud.scale, yPos);
  } else {
    endPos = ccp(-cloud.contentSize.width/2*cloud.scale, yPos);
  }
  
  [self addChild:cloud z:CLOUD_BASE_Z+(self.contentSize.height-yPos)];
  [_clouds addObject:cloud];
  
  CCSprite *shadow = [CCSprite spriteWithFile:@"cloud1shadow.png"];
  [cloud addChild:shadow z:-1];
  shadow.position = ccp(cloud.contentSize.width/2, -CLOUD_SHADOW_Y_OFFSET);
  shadow.opacity = CLOUD_SHADOW_OPACITY;
  shadow.color = ccc3(0,0,0);
  shadow.flipX = flipX;
  [shadow runAction:[CCFadeIn actionWithDuration:1.2f]];
  
  cloud.opacity = 0.f;
  int opacity = [self opacityForCloud:cloud];
  [cloud runAction:[CCFadeTo actionWithDuration:1.2f opacity:opacity]];
  
  float speed = CLOUD_MIN_SPEED+[self rand]*(CLOUD_MAX_SPEED-CLOUD_MIN_SPEED);
  float dist = ccpDistance(cloud.position, endPos);
  [cloud runAction:[CCSequence actions:
                    [CCMoveTo actionWithDuration:dist/speed position:endPos],
                    [CCFadeTo actionWithDuration:0.3f opacity:0],
                    [CCCallBlockN actionWithBlock:^(CCNode *node) 
                     {
                       [_clouds removeObject:node];
                       [node removeFromParentAndCleanup:YES];
                     }], nil]];
  
  [shadow runAction:[CCSequence actions:
                    [CCDelayTime actionWithDuration:dist/speed],
                    [CCFadeOut actionWithDuration:0.3f]
                     , nil]];
                    
}

- (void) updateAllCloudOpacities {
  for (CCSprite *cloud in _clouds) {
    cloud.opacity = [self opacityForCloud:cloud];
  }
}

- (int) opacityForCloud:(CCSprite *)cloud {
  float scale = self.parent.scale > 0 ? self.parent.scale : 1.f;
  float newOpacity = ((CLOUD_ZERO_OPACITY_SCALE-scale)/(CLOUD_ZERO_OPACITY_SCALE-MIN_ZOOM)*CLOUD_MAX_OPACITY);
  return (int)clampf(newOpacity, 0, CLOUD_MAX_OPACITY);
}

- (float) rand {
  return ((float)(arc4random()%((unsigned)RAND_MAX+1))/RAND_MAX);
}

- (void) dealloc {
  [_clouds release];
  [super dealloc];
}

@end
