//
//  TutorialTopBar.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/16/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TopBar.h"

@interface TutorialTopBar : TopBar {
  BOOL _myCityPhase;
  BOOL _questsPhase;
  BOOL _attackPhase;
  BOOL _finishedFirstQuestPhase;
}

- (void) updateIcon;
- (void) beginMyCityPhase;
- (void) beginQuestsPhase;
- (void) beginAttackPhase;

@end
