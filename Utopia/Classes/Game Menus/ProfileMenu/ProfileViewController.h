//
//  ProfileViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/26/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"

@interface ProfileViewController : UIViewController

+ (ProfileViewController *) sharedProfileViewController;
+ (void) displayView;
+ (void) removeView;

@end
