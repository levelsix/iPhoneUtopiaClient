//
//  MissionBuildingMenus.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/24/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MissionBuildingMenus.h"
#import "Protocols.pb.h"
#import "GameState.h"
#import "Globals.h"
#import "MissionMap.h"

@implementation MissionBuildingSummaryMenu

@synthesize titleLabel, descriptionLabel, energyLabel, rewardLabel, experienceLabel, itemChanceLabel;

- (void) updateLabelsForTask:(FullTaskProto *)ftp name:(NSString *)name {
  titleLabel.text = name;
  descriptionLabel.text = ftp.name;
  energyLabel.text = [NSString stringWithFormat:@"%d", ftp.energyCost];
  rewardLabel.text = [NSString stringWithFormat:@"%d-%d", ftp.minCoinsGained, ftp.maxCoinsGained];
  experienceLabel.text = [NSString stringWithFormat:@"%d", ftp.expGained];
  
  if (ftp.potentialLootEquipIdsList.count > 0) {
    FullEquipProto_Rarity rarity = 0;
    GameState *gs = [GameState sharedGameState];
    for (NSNumber *n in ftp.potentialLootEquipIdsList) {
      FullEquipProto *fep = [gs equipWithId:n.intValue];
      if (fep.rarity > rarity) {
        rarity = fep.rarity;
      }
    }
    itemChanceLabel.text = [Globals stringForRarity:rarity];
    itemChanceLabel.textColor = [Globals colorForRarity:rarity];
  } else {
    itemChanceLabel.text = @"None";
    itemChanceLabel.textColor = [UIColor whiteColor];
  }
}

- (void) dealloc {
  self.titleLabel = nil;
  self.descriptionLabel = nil;
  self.energyLabel = nil;
  self.rewardLabel = nil;
  self.experienceLabel = nil;
  self.itemChanceLabel = nil;
  [super dealloc];
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
  UIImage *taskSeg = [Globals imageNamed: @"inbetweenbar.png"];
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
  self.progressBar = nil;
  [super dealloc];
}

@end
