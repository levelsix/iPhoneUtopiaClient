//
//  TutorialMapViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/16/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "MapViewController.h"

@interface TutorialMapViewController : MapViewController {
  BOOL _travelHomePhase;
  BOOL _toAttackMapPhase;
  BOOL _enemyTabPhase;
  
  UIImageView *_arrow;
}

@end
