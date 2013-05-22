//
//  TutorialBazaarMap.m
//  Utopia
//
//  Created by Ashwin Kamath on 5/22/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import "TutorialBazaarMap.h"
#import "TutorialConstants.h"
#import "DialogMenuController.h"
#import "TutorialForgeMenuController.h"

@implementation TutorialBazaarMap

- (void) beginForgePhase {
  [self moveToCritStruct:BazaarStructTypeBlacksmith animated:NO];
  self.position = ccpAdd(self.position, ccp(120, 0));
  
  _isForgePhase = YES;
  
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.beforeBlacksmithText];
  
  [TutorialForgeMenuController sharedForgeMenuController];
}

- (void) setSelected:(SelectableSprite *)selected {
  if ([selected isKindOfClass: [CritStructBuilding class]]) {
    CritStructBuilding *csb = (CritStructBuilding *)selected;
    if (_isForgePhase && csb.critStruct.type == BazaarStructTypeBlacksmith) {
      _isForgePhase = NO;
      [super setSelected:selected];
    }
  }
}

@end
