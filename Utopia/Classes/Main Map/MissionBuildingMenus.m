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

- (void) updateMenuForTotal:(int)total numTimesActed:(int)numTimesActed isForQuest:(BOOL)highlighted {
  if (total == 0) {
    progressBar.percentage = 0.f;
    return;
  }
  progressBar.percentage = ((float)numTimesActed)/total;
  progressBar.highlighted = highlighted;
}

- (void) setMissionMap:(MissionMap *)m {
  missionMap = m;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [missionMap performCurrentTask];
}

- (void) dealloc {
  self.progressBar = nil;
  [super dealloc];
}

@end
