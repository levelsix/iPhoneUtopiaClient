//
//  HelloWorldLayer.h
//  IsoMap
//
//  Created by Ashwin Kamath on 12/7/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Protocols.pb.h"

@class ShopLayer;
@class MaskedBar;
@class ProfilePicture;
@class GameMap;
@class TopBar;
@class HomeMap;
@class MissionMap;
@class LoadNeutralCityResponseProto;

typedef enum {
  kHomeMusic = 1,
  kMissionMusic
} MusicState;

// HelloWorldLayer
@interface GameLayer : CCLayerGradient
{
  float _slideVelocity;
  float _slideDirection;
  NSTimeInterval _prevTouchTime;
  
  HomeMap *_homeMap;
  MissionMap *_missionMap;
  
  ProfilePicture *_profileBgd;
  TopBar *_topBar;
  
  MusicState _curMusic;
  
  BOOL _shouldCenterOnEnemy;
}

@property (nonatomic, assign) int assetId;
@property (nonatomic, assign) UserType enemyType;
@property (nonatomic, assign) int currentCity;
@property (nonatomic, retain) MissionMap *missionMap;

- (void) loadHomeMap;
- (void) loadMissionMapWithProto:(LoadNeutralCityResponseProto *)proto;
- (void) closeMenus;
- (void) unloadTutorialMissionMap;
- (void) loadTutorialMissionMap;
- (GameMap *) currentMap;

// returns a CCScene that contains the HelloWorldLayer as the only child
+ (CCScene *) scene;
+ (GameLayer *) sharedGameLayer;
+ (void) purgeSingleton;

@end
