//
//  HomeMap.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GameMap.h"
#import "HomeBuildingMenus.h"
#import "AnimatedSprite.h"

#define CENTER_TILE_X 51
#define CENTER_TILE_Y 51
#define ROAD_SIZE 2

@class HomeBuildingMenu;

@interface HomeMap : GameMap {
  NSMutableArray *_buildableData;
  BOOL _isMoving;
  BOOL _canMove;
  BOOL _loading;
  BOOL _purchasing;
  int _purchStructId;
  
  MoneyBuilding *_constrBuilding;
  MoneyBuilding *_upgrBuilding;
  HomeBuilding *_purchBuilding;
  
  NSMutableArray *_timers;
  
  TutorialGirl *_tutGirl;
  Carpenter *_carpenter;
}

@property (nonatomic, retain) NSMutableArray *buildableData;

@property (nonatomic, retain) IBOutlet HomeBuildingMenu *hbMenu;
@property (nonatomic, retain) IBOutlet HomeBuildingCollectMenu *collectMenu;
@property (nonatomic, retain) IBOutlet UIView *moveMenu;
@property (nonatomic, retain) IBOutlet UpgradeBuildingMenu *upgradeMenu;
@property (nonatomic, retain) IBOutlet ExpansionView *expansionView;

@property (nonatomic, assign, readonly) BOOL loading;
@property (nonatomic, assign) int redGid;
@property (nonatomic, assign) int greenGid;

+ (HomeMap *)sharedHomeMap;
+ (void) purgeSingleton;
+ (BOOL) isInitialized;

- (void) doMenuAnimations;
- (void) closeMenus;
- (void) upgradeMenuClosed;
- (void) openMoveMenuOnSelected;

- (void) changeTiles: (CGRect) buildBlock toBuildable:(BOOL)canBuild;
- (BOOL) isBlockBuildable: (CGRect) buildBlock;
- (void) refresh;
- (int) baseTagForStructId:(int)structId;
- (void) preparePurchaseOfStruct:(int)structId;
- (void) scrollScreenForTouch:(CGPoint)pt;
- (void) retrieveFromBuilding:(HomeBuilding *)hb;
- (void) updateTimersForBuilding:(HomeBuilding *)hb;
- (void) invalidateAllTimers;

- (void) moveToStruct:(int)structId showArrow:(BOOL)showArrow;
- (void) moveToTutorialGirl;
- (void) moveToCarpenterShowArrow:(BOOL)showArrow structId:(int)structId;

- (void) beginTimers;

@end
