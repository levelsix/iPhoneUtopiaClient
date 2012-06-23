//
//  TutorialProfileViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/16/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ProfileViewController.h"

@interface TutorialProfileViewController : ProfileViewController {
  // justLoaded is used to determine if this is the first or second time profile has been opened
  BOOL _justLoaded;
  BOOL _addingStatsPhase;
  BOOL _moveToEquipScreenPhase;
  BOOL _equippingPhase;
  BOOL _closingPhase;
  BOOL _tutorialEnding;
  
  UIImageView *_arrow;
}

@end
