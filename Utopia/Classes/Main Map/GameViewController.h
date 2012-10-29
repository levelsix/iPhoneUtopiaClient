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
  BOOL _startedGame;
}

- (void) fadeToLoadingScreen;
- (void) connectedToHost;
- (void) startupComplete;
- (void) loadPlayerCityComplete;
- (void) setupCocos2D;
- (void) startGame;
- (void) allowRestartOfGame;
- (void) loadGame:(BOOL)isTutorial;

+ (GameViewController *) sharedGameViewController;
+ (void) releaseAllViews;
- (void) removeAllSubviews;

@end
