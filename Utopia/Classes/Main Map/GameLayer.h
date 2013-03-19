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
#import "BazaarMap.h"

@class ShopLayer;
@class MaskedBar;
@class ProfilePicture;
@class GameMap;
@class TopBar;
@class HomeMap;
@class MissionMap;
@class LoadNeutralCityResponseProto;

@interface TravelingLoadingView : LoadingView

@property (nonatomic, retain) IBOutlet UILabel *label;

- (void) displayWithText:(NSString *)text;

@end

@interface WelcomeView : UIView

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *rankLabel;
@property (nonatomic, retain) IBOutlet UIImageView *middleLine;

@end

// HelloWorldLayer
@interface GameLayer : CCLayerGradient
{
  float _slideVelocity;
  float _slideDirection;
  NSTimeInterval _prevTouchTime;
  
  HomeMap *_homeMap;
  BazaarMap *_bazaarMap;
  MissionMap *_missionMap;
  
  ProfilePicture *_profileBgd;
  TopBar *_topBar;
  
  BOOL _shouldCenterOnEnemy;
  
  BOOL _loading;
  
  BOOL _isForBattleLossTutorial;
}

@property (nonatomic, assign) int assetId;
@property (nonatomic, assign) DefeatTypeJobProto_DefeatTypeJobEnemyType enemyType;
@property (nonatomic, assign) int currentCity;
@property (nonatomic, retain) MissionMap *missionMap;

@property (nonatomic, retain) IBOutlet WelcomeView *welcomeView;
@property (nonatomic, retain) IBOutlet TravelingLoadingView *loadingView;

- (void) begin;
- (void) loadHomeMap;
- (void) closeHomeMap;
- (void) loadBazaarMap;
- (void) loadHomeMap;
- (void) loadMissionMapWithProto:(LoadNeutralCityResponseProto *)proto;
- (void) closeMenus;
- (void) unloadTutorialMissionMap;
- (void) loadTutorialMissionMap;
- (GameMap *) currentMap;
- (void) startHomeMapTimersIfOkay;

- (void) displayBazaarMap;
- (void) closeBazaarMap;
- (void) toggleBazaarMap;

- (void) performBattleLossTutorial;

// returns a CCScene that contains the HelloWorldLayer as the only child
+ (CCScene *) scene;
+ (GameLayer *) sharedGameLayer;
+ (void) purgeSingleton;

@end
