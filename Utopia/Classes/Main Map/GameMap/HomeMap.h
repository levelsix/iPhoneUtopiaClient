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

@property (nonatomic, assign, readonly) BOOL loading;
@property (nonatomic, assign) int redGid;
@property (nonatomic, assign) int greenGid;

+ (HomeMap *)sharedHomeMap;
+ (void) purgeSingleton;

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

- (void) moveToStruct:(int)structId;
- (void) moveToTutorialGirl;
- (void) moveToCarpenter;

- (void) beginTimers;

@end
