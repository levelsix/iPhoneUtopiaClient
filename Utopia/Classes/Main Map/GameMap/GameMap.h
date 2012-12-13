//
//  GameMap.h
//  IsoMap
//
//  Created by Ashwin Kamath on 12/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "NibUtils.h"
#import "Building.h"
#import "AnimatedSprite.h"
#import "Drops.h"
#import "DecorationLayer.h"
#import "MyPlayer.h"

#define OVER_HOME_BUILDING_MENU_OFFSET 5.f

#define MAX_ZOOM 1.8f
#define MIN_ZOOM 0.3f
#define DEFAULT_ZOOM 0.8f

@class Building;
@class SelectableSprite;

@interface EnemyPopupView : UIView

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *levelLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageIcon;
@property (nonatomic, retain) IBOutlet UIView *enemyView;
@property (nonatomic, retain) IBOutlet UIView *allyView;

@end

@interface GameMap : CCTMXTiledMap {
  SelectableSprite *_selected;
  NSMutableArray *_mapSprites;
  NSMutableArray *_walkableData;
  
  // These points are used to make the map rectangular
  CGPoint bottomLeftCorner;
  CGPoint topRightCorner;
  
  MyPlayer *_myPlayer;
}

@property (nonatomic, retain) IBOutlet EnemyPopupView *enemyMenu;

@property (nonatomic, assign) SelectableSprite *selected;
@property (nonatomic, retain) NSArray *mapSprites;

@property (nonatomic, retain) DecorationLayer *decLayer;

@property (nonatomic, retain) NSMutableArray *walkableData;

@property (nonatomic, assign) CGSize tileSizeInPoints;

@property (nonatomic, assign) int silverOnMap;
@property (nonatomic, assign) int goldOnMap;

+ (id) tiledMapWithTMXFile:(NSString*)tmxFile;
- (id) initWithTMXFile:(NSString *)tmxFile;
- (CGPoint)convertVectorToGL:(CGPoint)uiPoint;
- (void) doReorder;
- (SelectableSprite *) selectableForPt:(CGPoint)pt;
- (void) layerWillDisappear;

- (Enemy *) enemyWithUserId:(int)userId;

- (void) moveToCenterAnimated:(BOOL)animatedr;
- (void) moveToSprite:(CCSprite *)spr animated:(BOOL)animated;
- (void) moveToEnemyType:(DefeatTypeJobProto_DefeatTypeJobEnemyType)type animated:(BOOL)animated;

- (CGPoint) randomWalkablePosition;
- (CGPoint) nextWalkablePositionFromPoint:(CGPoint)point prevPoint:(CGPoint)prevPt;

- (void) addSilverDrop:(int)amount fromSprite:(MapSprite *)sprite toPosition:(CGPoint)pt secondsToPickup:(int)secondsToPickup ;
- (void) pickUpSilverDrop:(SilverStack *)ss;
- (void) addGoldDrop:(int)amount fromSprite:(MapSprite *)sprite toPosition:(CGPoint)pt secondsToPickup:(int)secondsToPickup ;
- (void) pickUpGoldDrop:(GoldStack *)ss;
- (void) addEquipDrop:(int)equipId fromSprite:(MapSprite *)sprite toPosition:(CGPoint)pt secondsToPickup:(int)secondsToPickup ;
- (void) pickUpEquipDrop:(EquipDrop *)ed;
- (void) addLockBoxDrop:(int)eventId fromSprite:(MapSprite *)sprite secondsToPickup:(int)secondsToPickup ;
- (void) pickUpLockBoxDrop:(LockBoxDrop *)lbd;
- (void) pickUpAllDrops;

- (IBAction)attackClicked:(id)sender;
- (IBAction)enemyProfileClicked:(id)sender;
- (IBAction)allyProfileClicked:(id)sender;

- (void) reloadQuestGivers;
- (void) questRedeemed:(FullQuestProto *)fqp;
- (void) questAccepted:(FullQuestProto *)fqp;

- (void) drag:(UIGestureRecognizer*)recognizer node:(CCNode*)node;
- (void) tap:(UIGestureRecognizer*)recognizer node:(CCNode*)node;
- (void) scale:(UIGestureRecognizer*)recognizer node:(CCNode*)node;

- (CGPoint) convertTilePointToCCPoint:(CGPoint)pt;
- (CGPoint) convertCCPointToTilePoint:(CGPoint)pt;

@end