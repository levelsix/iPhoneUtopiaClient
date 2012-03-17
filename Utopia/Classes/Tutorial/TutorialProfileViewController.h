//
//  TutorialProfileViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/16/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ProfileViewController.h"

@interface TutorialProfileViewController : ProfileViewController {
  BOOL _addingStatsPhase;
  BOOL _moveToEquipScreenPhase;
  BOOL _equippingPhase;
  BOOL _closingPhase;
  
  UIImageView *_arrow;
}

@end
