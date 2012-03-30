//
//  RootViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/9/11.
//  Copyright LVL6 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameView : UIView

@property (nonatomic, retain) EAGLView *glView;

@end

@interface GameViewController : UIViewController {
  BOOL _isRunning;
  CCSprite *doorright;
  CCSprite *doorleft;
  CCMenu *crest;
  CCSprite *splash;
}

@property (nonatomic, assign) BOOL isTutorial;
@property (assign) BOOL canLoad;

- (void) startDoorAnimation;
- (void) setupCocos2D;

+ (GameViewController *) sharedGameViewController;
+ (void) releaseAllViews;

@end
