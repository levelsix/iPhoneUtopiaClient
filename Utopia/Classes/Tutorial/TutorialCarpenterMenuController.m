//
//  TutorialCarpenterMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TutorialCarpenterMenuController.h"
#import "Protocols.pb.h"
#import "Globals.h"
#import "TutorialConstants.h"
#import "DialogMenuController.h"
#import "HomeMap.h"
#import "SoundEngine.h"

@implementation TutorialCarpenterMenuController

- (id) init {
  // Need to load it with carpenter's nib
  return [super initWithNibName:@"CarpenterMenuController" bundle:nil];
}

- (void) viewDidLoad {
  self.structsList = (NSMutableArray *)[[TutorialConstants sharedTutorialConstants] carpenterStructs];
  [self.carpTable reloadData];
  self.coinBar.userInteractionEnabled = NO;
}

- (void) viewDidDisappear:(BOOL)animated {
  [CarpenterMenuController purgeSingleton];
}

- (void) viewDidAppear:(BOOL)animated {
  [self.coinBar updateLabels];
  
  [Analytics tutCarpenterClicked];
  
  self.carpTable.scrollEnabled = NO;
  
  [self beforePurchaseDialog];
}

- (void) viewWillAppear:(BOOL)animated {
  [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
  
  [[SoundEngine sharedSoundEngine] carpenterEnter];
}

- (void) beforePurchaseDialog {
  CarpenterRow *cell = (CarpenterRow *)[self.carpTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  
  _arrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3darrow.png"]];
  [cell addSubview:_arrow];
  _arrow.center = CGPointMake(CGRectGetMaxX(cell.listing1.frame)+_arrow.frame.size.width/2-5, cell.listing1.center.y);
  [Globals animateUIArrow:_arrow atAngle:M_PI];
}

- (IBAction)closeClicked:(id)sender {
  if (_canClose) {
    [super closeClicked:sender];
  }
}

- (void) carpListingClicked:(CarpenterListing *)carp {
  if (carp.fsp.structId == 1) {
    _canClose = YES;
    [super carpListingClicked:carp];
    [Analytics tutPurchaseInn];
  }
}

- (void) dealloc {
  [_arrow release];
  [super dealloc];
}

@end
