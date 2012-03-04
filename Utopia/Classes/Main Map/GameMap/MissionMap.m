//
//  MissionMap.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/3/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MissionMap.h"
#import "GameState.h"
#import "Globals.h"
#import "UserData.h"

#define ASSET_TAG_BASE 2555
#define OVER_HOME_BUILDING_MENU_OFFSET 5.f

#define SUMMARY_MENU_ANIMATION_DURATION 0.3f

@implementation MissionBuildingSummaryMenu

@synthesize titleLabel, descriptionLabel, energyLabel, rewardLabel, experienceLabel;

- (void) updateLabelsForTask:(FullTaskProto *)ftp name:(NSString *)name {
  titleLabel.text = name;
  descriptionLabel.text = ftp.name;
  energyLabel.text = [NSString stringWithFormat:@"%d", ftp.energyCost];
  rewardLabel.text = [Globals commafyNumber:(ftp.maxCoinsGained-ftp.minCoinsGained)/2];
  experienceLabel.text = [NSString stringWithFormat:@"%d Exp.", ftp.expGained];
}

@end

@implementation MissionOverBuildingMenu

@synthesize progressBar;

- (void) awakeFromNib {
  _separators = [[NSMutableArray array] retain];
  
  if ([[UIScreen mainScreen] scale] == 2.00) {
    CGRect r = progressBar.frame;
    r.origin.y += 0.5;
    progressBar.frame = r;
  }
}

- (void) removeAllSeperators {
  [_separators enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [obj removeFromSuperview];
  }];
  [_separators removeAllObjects];
}

- (void) updateMenuForTotal:(int)total numTimesActed:(int)numTimesActed {
  [self removeAllSeperators];
  
  // Add the segmentors for each total-1 spot
  UIImage *taskSeg = [UIImage imageNamed: @"inbetweenbar.png"];
  float width = progressBar.image.size.width;
  
  CGRect r = progressBar.frame;
  r.size.width = width * numTimesActed / total;
  progressBar.frame = r;
  for (float i = 1; i < total; i+=1) {
    UIImageView *tmpView = [[UIImageView alloc] initWithImage:taskSeg];
    tmpView.center = CGPointMake(progressBar.frame.origin.x+i/total*width, progressBar.center.y+0.5);
    [self addSubview:tmpView];
    [_separators addObject:tmpView];
    [tmpView release];
  }
}

- (void) setFrameForPoint:(CGPoint)pt {
  // place it so that the bottom middle is at pt
  // Remember, frame is relative to top left corner
  float width = self.frame.size.width;
  float height = self.frame.size.height;
  self.frame = CGRectMake(pt.x-width/2, ([[CCDirector sharedDirector] winSize].height - pt.y)-height, width, height);
}

- (void) dealloc {
  [_separators release];
  [super dealloc];
}

@end

@implementation MissionMap

@synthesize summaryMenu, obMenu;

- (id) initWithProto:(LoadNeutralCityResponseProto *)proto {
  NSString *tmxFile = @"iso-test2.tmx";
  if ((self = [super initWithTMXFile:tmxFile])) {
    GameState *gs = [GameState sharedGameState];
    FullCityProto *fcp = [gs cityWithId:proto.cityId];
    
    // Add all the buildings
    for (NeutralCityElementProto *ncep in proto.cityElementsList) {
      if (ncep.type == NeutralCityElementProto_NeutralCityElemTypeBuilding) {
        CGRect loc = CGRectMake(ncep.coords.x, ncep.coords.y, 0, 0);
        MissionBuilding *mb = [[MissionBuilding alloc] initWithFile:ncep.imgId location:loc map:self];
        mb.name = ncep.name;
        [self addChild:mb z:1 tag:ncep.assetId+ASSET_TAG_BASE];
        [mb release];
      }
    }
    
    // Load up the full task protos
    for (NSNumber *taskId in fcp.taskIdsList) {
      FullTaskProto *ftp = [gs taskWithId:taskId.intValue];
      MissionBuilding *asset = (MissionBuilding *)[self getChildByTag:ftp.assetNumWithinCity+ASSET_TAG_BASE];
      if (asset) {
        asset.ftp = ftp;
      } else {
        NSLog(@"Could not find asset number %d.", ftp.assetNumWithinCity);
      }
    }
    
    // Load up the minimum user task protos
    for (MinimumUserTaskProto *mutp in proto.userTasksInfoList) {
      FullTaskProto *ftp = [gs taskWithId:mutp.taskId];
      MissionBuilding *asset = [self assetWithId:ftp.assetNumWithinCity];
      if (asset) {
        asset.numTimesActed = mutp.numTimesActed;
      } else {
        NSLog(@"Could not find asset number %d.", ftp.assetNumWithinCity);
      }
    }
    
    [[NSBundle mainBundle] loadNibNamed:@"MissionBuildingMenu" owner:self options:nil];
    [[[CCDirector sharedDirector] openGLView] addSubview:obMenu];
    [[[CCDirector sharedDirector] openGLView] addSubview:summaryMenu];
    summaryMenu.hidden = YES;
    obMenu.hidden = YES;
    
    summaryMenu.center = CGPointMake(-summaryMenu.frame.size.width, 290);
  }
  return self;
}

- (id) assetWithId:(int)assetId {
  return [self getChildByTag:assetId+ASSET_TAG_BASE];
}

- (void) setPosition:(CGPoint)position {
  CGPoint oldPos = position_;
  [super setPosition:position];
  if (!obMenu.hidden) {
    CGPoint diff = ccpSub(oldPos, position_);
    diff.x *= -1;
    CGRect curRect = obMenu.frame;
    curRect.origin = ccpAdd(curRect.origin, diff);
    obMenu.frame = curRect;
  }
}

- (void) updateMissionBuildingMenu {
  if (_selected && [_selected isKindOfClass:[MissionBuilding class]]) {
    CGPoint pt = [_selected convertToWorldSpace:ccp(_selected.contentSize.width/2, _selected.contentSize.height-OVER_HOME_BUILDING_MENU_OFFSET)];
    [obMenu setFrameForPoint:pt];
    obMenu.hidden = NO;
  } else {
    obMenu.hidden = YES;
  }
}

- (void) doSummaryMenuAnimation {
  int width = summaryMenu.frame.size.width;
  
  summaryMenu.hidden = NO;
  summaryMenu.center = CGPointMake(-width/2, summaryMenu.center.y);
  
  [UIView animateWithDuration:SUMMARY_MENU_ANIMATION_DURATION animations:^{
    summaryMenu.center = CGPointMake(width/2, summaryMenu.center.y);
  }];
}

- (void) closeSummaryMenu {
  int width = summaryMenu.frame.size.width;
  
  [UIView animateWithDuration:SUMMARY_MENU_ANIMATION_DURATION animations:^{
    summaryMenu.center = CGPointMake(-width/2, summaryMenu.center.y);
  } completion:^(BOOL finished) {
    summaryMenu.hidden = YES;
  }];
}

- (void) tap:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  [super tap:recognizer node:node];
  if (_selected && [_selected isKindOfClass:[MissionBuilding class]]) {
    MissionBuilding *mb = (MissionBuilding *)_selected;
    [summaryMenu updateLabelsForTask:mb.ftp name:mb.name];
    [obMenu updateMenuForTotal:mb.ftp.numRequiredForCompletion numTimesActed:mb.numTimesActed];
    [self doSummaryMenuAnimation];
  } else if (!summaryMenu.hidden) {
    [self closeSummaryMenu];
  }
  [self updateMissionBuildingMenu];
}

- (void) dealloc {
  [summaryMenu removeFromSuperview];
  self.summaryMenu = nil;
  [obMenu removeFromSuperview];
  self.obMenu = nil;
  [super dealloc];
}

@end
