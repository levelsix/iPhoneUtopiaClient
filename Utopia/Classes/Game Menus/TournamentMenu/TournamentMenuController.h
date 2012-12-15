//
//  TournamentMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface TournamentMenuController : UIViewController

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

+ (TournamentMenuController *) sharedTournamentMenuController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

@end
