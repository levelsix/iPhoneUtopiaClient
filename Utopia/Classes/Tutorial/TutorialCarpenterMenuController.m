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

- (void) viewDidAppear:(BOOL)animated {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.insideCarpenterText1 callbackTarget:self action:@selector(insideCarpDialog)];
  
  [self.coinBar updateLabels];
  [Analytics tutorialEnterCarpenter];
  
  self.carpTable.scrollEnabled = NO;
}

- (void) viewWillAppear:(BOOL)animated {
  CGRect f = self.view.frame;
  self.view.center = CGPointMake(f.size.width/2, f.size.height*3/2);
  [UIView animateWithDuration:FULL_SCREEN_APPEAR_ANIMATION_DURATION animations:^{
    self.view.center = CGPointMake(f.size.width/2, f.size.height/2);
  }];
}

- (void) insideCarpDialog {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.insideCarpenterText2 callbackTarget:self action:@selector(beforePurchaseDialog)];
}

- (void) beforePurchaseDialog {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.beforePurchaseText callbackTarget:nil action:nil];
  
  CarpenterRow *cell = (CarpenterRow *)[self.carpTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
  [_arrow removeFromSuperview];
  
  _arrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"3darrow.png"]];
  [cell addSubview:_arrow];
  _arrow.layer.transform = CATransform3DMakeRotation(M_PI/2, 0.0f, 0.0f, 1.0f);
  
  _arrow.center = CGPointMake(CGRectGetMaxX(cell.listing1.frame)+_arrow.frame.size.width/2-5, cell.listing1.center.y);
  
  UIViewAnimationOptions opt = UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat;
  [UIView animateWithDuration:1.f delay:0.f options:opt animations:^{
    _arrow.center = CGPointMake(CGRectGetMaxX(cell.listing1.frame)+_arrow.frame.size.width/2+5, cell.listing1.center.y);
  } completion:nil];
}

- (IBAction)closeClicked:(id)sender {
  return;
}

- (void) carpListingClicked:(CarpenterListing *)carp {
  if (carp.fsp.structId == 1) {
    [super carpListingClicked:carp];
    [CarpenterMenuController purgeSingleton];
    [Analytics tutorialPurchaseInn];
  }
}

- (void) viewDidUnload {
  [super viewDidUnload];
}

- (void) dealloc {
  [_arrow release];
  [super dealloc];
}

@end
