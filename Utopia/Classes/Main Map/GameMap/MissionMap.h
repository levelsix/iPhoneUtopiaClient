//
//  MissionMap.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "GameMap.h"
#import "Protocols.pb.h"
#import "CCLabelFX.h"
#import "MissionBuildingMenus.h"

#define ASSET_TAG_BASE 2555

@interface TaskProgressBar : CCSprite {
  CCProgressTimer *_progressBar;
  CCLabelFX *_label;
}

@property (nonatomic, assign) BOOL isAnimating;

- (void) animateBarWithText:(NSString *)str;

@end

@interface MissionMap : GameMap {
  int _cityId;
  
  TaskProgressBar *_taskProgBar;
  
  BOOL _receivedTaskActionResponse;
  BOOL _performingTask;
  
  NSMutableArray *_jobs;
}

@property (nonatomic, retain) IBOutlet MissionBuildingSummaryMenu *summaryMenu;
@property (nonatomic, retain) IBOutlet MissionOverBuildingMenu *obMenu;

- (id) initWithProto:(LoadNeutralCityResponseProto *)proto;
- (id) assetWithId:(int)assetId;
- (void) moveToAssetId:(int)a animated:(BOOL)animated;
- (void) performCurrentTask;
- (void) receivedTaskResponse:(TaskActionResponseProto *)tarp;
- (void) receivedBossResponse:(BossActionResponseProto *)barp;
- (void) changeTiles: (CGRect) buildBlock canWalk:(BOOL)canWalk;


- (void) killEnemy:(int)userId;

- (void) closeMenus;

@end
