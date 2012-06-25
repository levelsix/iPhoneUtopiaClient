//
//  RootViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/9/11.
//  Copyright LVL6 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"

@interface GameView : UIView

@property (nonatomic, retain) EAGLView *glView;

@end

@interface GameViewController : UIViewController {
  BOOL _isRunning;
  BOOL _canOpenDoor;
  CCSprite *doorright;
  CCSprite *doorleft;
  CCSprite *splash;
  CCSprite *eyes;
  CCSprite *loadingLabel;
  CCSprite *enterLabel;
  CCParticleSystemQuad *leftBurn;
  CCParticleSystemQuad *rightBurn;
}

@property (assign) BOOL canLoad;

- (void) startDoorAnimation;
- (void) setupCocos2D;
- (void) allowOpeningOfDoor;
- (void) loadGame:(BOOL)isTutorial;

+ (GameViewController *) sharedGameViewController;
+ (void) releaseAllViews;

@end
