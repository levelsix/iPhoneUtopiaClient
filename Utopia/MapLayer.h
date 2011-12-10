//
//  HelloWorldLayer.h
//  IsoMap
//
//  Created by Ashwin Kamath on 12/7/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

#define MAPSIZE CGSizeMake(64, 64)
#define TILESIZE CGSizeMake(64, 32)

// HelloWorldLayer
@interface MapLayer : CCLayer
{
  float _slideVelocity;
  float _slideDirection;
  NSTimeInterval _prevTouchTime;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
