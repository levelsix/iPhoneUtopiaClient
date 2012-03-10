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
#import "OutgoingEventController.h"
#import "RefillMenuController.h"
#import "AnimatedSprite.h"

#define ASSET_TAG_BASE 2555
#define OVER_HOME_BUILDING_MENU_OFFSET 5.f

#define SUMMARY_MENU_ANIMATION_DURATION 0.15f

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
  if (total == 0) {
    CGRect r = progressBar.frame;
    r.size.width = 0;
    progressBar.frame = r;
    return;
  }
  
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

- (void) setMissionMap:(MissionMap *)m {
  missionMap = m;
}

- (void) setFrameForPoint:(CGPoint)pt {
  // place it so that the bottom middle is at pt
  // Remember, frame is relative to top left corner
  float width = self.frame.size.width;
  float height = self.frame.size.height;
  self.frame = CGRectMake(pt.x-width/2, ([[CCDirector sharedDirector] winSize].height - pt.y)-height, width, height);
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [missionMap performCurrentTask];
}

- (void) dealloc {
  [_separators release];
  [super dealloc];
}

@end

@implementation MissionMap

@synthesize summaryMenu, obMenu;
@synthesize walkableData = _walkableData;

- (id) initWithProto:(LoadNeutralCityResponseProto *)proto {
//  NSString *tmxFile = @"villa_montalvo.tmx";
  FullCityProto *fcp = [[GameState sharedGameState] cityWithId:proto.cityId];
  if ((self = [super initWithTMXFile:fcp.mapImgName])) {
    GameState *gs = [GameState sharedGameState];
    FullCityProto *fcp = [gs cityWithId:proto.cityId];
    
    self.walkableData = [NSMutableArray arrayWithCapacity:[self mapSize].width];
    for (int i = 0; i < self.mapSize.width; i++) {
      NSMutableArray *row = [NSMutableArray arrayWithCapacity:self.mapSize.height];
      for (int j = 0; j < self.mapSize.height; j++) {
        [row addObject:[NSNumber numberWithBool:YES]];
      }
      [self.walkableData addObject:row];
    }
    
    int width = self.mapSize.width;
    int height = self.mapSize.height;
    for (CCNode *node in self.children) {
      if (![node isKindOfClass:[CCTMXLayer class]]) {
        continue;
      }
      CCTMXLayer *layer = (CCTMXLayer *)node;
      
      for (int i = 0; i < width; i++) {
        for (int j = 0; j < height; j++) {
          NSMutableArray *row = [self.walkableData objectAtIndex:i];
          NSNumber *curVal = [row objectAtIndex:j];
          if (curVal.boolValue == YES) {
            // Convert their coordinates to our coordinate system
            CGPoint tileCoord = ccp(height-j-1, width-i-1);
            int tileGid = [layer tileGIDAt:tileCoord];
            if (tileGid) {
              NSDictionary *properties = [self propertiesForGID:tileGid];
              if (properties) {
                NSString *collision = [properties valueForKey:@"Walkable"];
                if (collision && [collision isEqualToString:@"No"]) {
                  [row replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:NO]];
                }
              }
            }
          }
        }
      }
    }
    
    // Add all the buildings
    for (NeutralCityElementProto *ncep in proto.cityElementsList) {
      if (ncep.type == NeutralCityElementProto_NeutralCityElemTypeBuilding) {
        // Add a mission building
        CGRect loc = CGRectMake(ncep.coords.x, ncep.coords.y, ncep.xLength, ncep.yLength);
        MissionBuilding *mb = [[MissionBuilding alloc] initWithFile:ncep.imgId location:loc map:self];
        mb.name = ncep.name;
        mb.orientation = ncep.orientation;
        [self addChild:mb z:1 tag:ncep.assetId+ASSET_TAG_BASE];
        [mb release];
        
        for (int i = 0; i < mb.location.size.width; i++) {
          for (int j = 0; j < mb.location.size.height; j++) {
            // Transform to the map's coordinates
            NSMutableArray *row = [_walkableData objectAtIndex:i+mb.location.origin.x];
            NSNumber *num = [row objectAtIndex:j+mb.location.origin.y];
            if ([num boolValue] == YES) {
              [row replaceObjectAtIndex:j+mb.location.origin.y withObject:[NSNumber numberWithBool:NO]];
            }
          }
        }
      } else if (ncep.type == NeutralCityElementProto_NeutralCityElemTypeDecoration) {
        // Decorations aren't selectable so just make a map sprite
        CGRect loc = CGRectMake(ncep.coords.x, ncep.coords.y, ncep.xLength, ncep.yLength);
        MapSprite *s = [[MapSprite alloc] initWithFile:ncep.imgId location:loc map:self];
        [self addChild:s z:1 tag:ncep.assetId+ASSET_TAG_BASE];
        
        for (int i = 0; i < s.location.size.width; i++) {
          for (int j = 0; j < s.location.size.height; j++) {
            // Transform to the map's coordinates
            NSMutableArray *row = [_walkableData objectAtIndex:i+s.location.origin.x];
            NSNumber *num = [row objectAtIndex:j+s.location.origin.y];
            if ([num boolValue] == YES) {
              [row replaceObjectAtIndex:j+s.location.origin.y withObject:[NSNumber numberWithBool:NO]];
            }
          }
        }
      }
    }
    [self doReorder];
    
    
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
    [obMenu setMissionMap:self];
    obMenu.hidden = YES;
    
    summaryMenu.center = CGPointMake(-summaryMenu.frame.size.width, 290);
    
//    NSMutableString *str = [NSMutableString stringWithString:@"\n"];
//    for (int i=0; i < width; i++) {
//      for (int j=0; j < height; j++) {
//        [str appendString:[[[_walkableData objectAtIndex:i] objectAtIndex:j] description]];
//      }
//      [str appendString:@"\n"];
//    }
//    NSLog(@"%@", str);
    
//    for (int i = 0; i < 6; i++) {
//      CGRect r = CGRectZero;
//      r.origin = [self randomWalkablePosition];
//      AnimatedSprite *anim = [[AnimatedSprite alloc] initWithFile:nil location:r map:self];
//      [self addChild:anim];
//    }
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

- (void) performCurrentTask {
  if ([_selected isKindOfClass:[MissionBuilding class]]) {
    MissionBuilding *mb = (MissionBuilding *)_selected;
    FullTaskProto *ftp = mb.ftp;
    GameState *gs = [GameState sharedGameState];
    
    // Perform checks
    if (gs.currentEnergy < ftp.energyCost) {
      // Not enough energy
      [[RefillMenuController sharedRefillMenuController] displayEnstView:YES];
    } else {
      NSMutableArray *arr = [NSMutableArray array];
      for (FullTaskProto_FullTaskEquipReqProto *equipReq in ftp.equipReqsList) {
        UserEquip *ue = [gs myEquipWithId:equipReq.equipId];
        if (!ue || ue.quantity < equipReq.quantity) {
          [arr addObject:[NSNumber numberWithInt:equipReq.equipId]];
        }
      }
      
      if (arr.count > 0) {
        [[RefillMenuController sharedRefillMenuController] displayEquipsView:arr];
      } else {
        BOOL success = [[OutgoingEventController sharedOutgoingEventController] taskAction:ftp.taskId];
        
        if (success) {
          mb.numTimesActed = MIN(mb.numTimesActed+1, ftp.numRequiredForCompletion);
        }
      }
    }
    
    self.selected = nil;
    [self closeMenus];
  }
}

- (void) doMenuAnimations {
  int width = summaryMenu.frame.size.width;
  
  summaryMenu.center = CGPointMake(-width/2, summaryMenu.center.y);
  
  [self updateMissionBuildingMenu];
  obMenu.alpha = 0.f;
  
  [UIView animateWithDuration:SUMMARY_MENU_ANIMATION_DURATION animations:^{
    summaryMenu.center = CGPointMake(width/2, summaryMenu.center.y);
    obMenu.alpha = 1.f;
  }];
}

- (void) closeMenus {
  int width = summaryMenu.frame.size.width;
  
  [UIView animateWithDuration:SUMMARY_MENU_ANIMATION_DURATION animations:^{
    summaryMenu.center = CGPointMake(-width/2, summaryMenu.center.y);
    obMenu.alpha = 0.f;
  } completion:^(BOOL finished) {
    [self updateMissionBuildingMenu];
  }];
}

- (void) tap:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  SelectableSprite *oldSelected = _selected;
  [super tap:recognizer node:node];
  if (oldSelected == _selected && [_selected isKindOfClass:[MissionBuilding class]]) {
    [self performCurrentTask];
    return;
  }
  
  if (_selected){
    if ([_selected isKindOfClass:[MissionBuilding class]]) {
      MissionBuilding *mb = (MissionBuilding *)_selected;
      [summaryMenu updateLabelsForTask:mb.ftp name:mb.name];
      [obMenu updateMenuForTotal:mb.ftp.numRequiredForCompletion numTimesActed:mb.numTimesActed];
      [self doMenuAnimations];
    }
  } else {
    [self closeMenus];
  }
}

- (void) scale:(UIGestureRecognizer *)recognizer node:(CCNode *)node {
  [super scale:recognizer node:node];
  [self updateMissionBuildingMenu];
}

- (CGPoint) randomWalkablePosition {
  while (true) {
    int x = arc4random() % (int)self.mapSize.width;
    int y = arc4random() % (int)self.mapSize.height;
    NSNumber *num = [[_walkableData objectAtIndex:x] objectAtIndex:y];
    if (num.boolValue == YES) {
      return CGPointMake(x, y);
    }
  }
}

- (CGPoint) nextWalkablePositionFromPoint:(CGPoint) point {
  CGPoint left = CGPointMake(point.x-1, point.y);
  CGPoint right = CGPointMake(point.x+1, point.y);
  CGPoint up = CGPointMake(point.x, point.y+1);
  CGPoint down = CGPointMake(point.x, point.y-1);
  CGPoint pts[4] = {left, right, up, down};
  int width = mapSize_.width;
  int height = mapSize_.height;
  
  int max = 30;
  while (max > 0) {
    int x = arc4random() % 4;
    CGPoint pt = pts[x];
    if (pt.x >= 0 && pt.x < width && pt.y >= 0 && pt.y < height) {
      if ([[[_walkableData objectAtIndex:pt.x] objectAtIndex:pt.y] boolValue] == YES) {
        return pt;
      }
    }
    max--;
  }
  return point;
}

- (void) dealloc {
  [summaryMenu removeFromSuperview];
  self.summaryMenu = nil;
  [obMenu removeFromSuperview];
  self.obMenu = nil;
  [super dealloc];
}

@end
