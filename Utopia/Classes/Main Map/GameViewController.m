//
//  RootViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/9/11.
//  Copyright LVL6 2011. All rights reserved.
//

//
// RootViewController + iAd
// If you want to support iAd, use this class as the controller of your iAd
//

#import "cocos2d.h"

#import "GameViewController.h"
#import "GameConfig.h"
#import "GameLayer.h" 
#import "BattleLayer.h" 
#import "SynthesizeSingleton.h"
#import "QuestLogController.h"

@implementation GameView

@synthesize glView;

- (void) didAddSubview:(UIView *)subview {
  if ([subview isKindOfClass:[EAGLView class]]) {
    self.glView = (EAGLView *)subview;
  }
  else if (self.glView && subview != self.glView) {
    self.glView.userInteractionEnabled = NO;
  }
}

- (void) willRemoveSubview:(UIView *)subview {
  if (self.glView && subview != self.glView) {
    self.glView.userInteractionEnabled = YES;
  }
}

@end

@implementation GameViewController

SYNTHESIZE_SINGLETON_FOR_CLASS(GameViewController);

- (void)setupCocos2D {
  EAGLView *glView = [EAGLView viewWithFrame:self.view.bounds
                                 pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
                                 depthFormat:0                        // GL_DEPTH_COMPONENT16_OES
                          preserveBackbuffer:NO
                                  sharegroup:nil 
                               multiSampling:YES 
                             numberOfSamples:3];
  
  [self.view insertSubview:glView atIndex:0];
  [[CCDirector sharedDirector] setOpenGLView:glView];
  
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [[CCDirector sharedDirector] enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
  
  // Preload some of the controllers
  [[QuestLogController sharedQuestLogController] view];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  CCScene *scene = [GameLayer scene];
  [BattleLayer scene];
  [[CCDirector sharedDirector] runWithScene:scene];
}

- (void) loadView {
  CGRect rect = [[UIScreen mainScreen] bounds];
  rect.size = CGSizeMake( rect.size.height, rect.size.width );
  GameView *v = [[GameView alloc] initWithFrame:rect];
  self.view = v;
  [v release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return ( UIInterfaceOrientationIsLandscape( interfaceOrientation ) );
}

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupCocos2D];
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
  [[CCDirector sharedDirector] end];
}


- (void)dealloc {
  [super dealloc];
}


@end

