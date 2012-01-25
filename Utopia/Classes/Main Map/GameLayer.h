//
//  HelloWorldLayer.h
//  IsoMap
//
//  Created by Ashwin Kamath on 12/7/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

@class ShopLayer;
@class MaskedBar;
@class ProfilePicture;
@class GameMap;

// HelloWorldLayer
@interface GameLayer : CCLayer
{
  float _slideVelocity;
  float _slideDirection;
  NSTimeInterval _prevTouchTime;
  
  GameMap *_map;
  
  ShopLayer *_shopLayer;
  
  CCSprite *_enstBgd;
  MaskedBar *_energyBar;
  MaskedBar *_staminaBar;
  
  CCSprite *_coinBar;
  CCLabelTTF *_coinLabel;
  CCLabelTTF *_diamondLabel;
  CCLabelTTF *_diamondButton;
  
  ProfilePicture *_profileBgd;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end