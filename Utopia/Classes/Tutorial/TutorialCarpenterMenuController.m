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
  self.state = kIncomeCarp;
  
  self.carpTable.scrollEnabled = NO;
  NSMutableArray *structs = [[[TutorialConstants sharedTutorialConstants] carpenterStructs] mutableCopy];
  self.structsList = structs;
  [structs release];
  [self.carpTable reloadData];
  
  self.carpBar.userInteractionEnabled = NO;
}

- (void) viewDidAppear:(BOOL)animated {
  TutorialConstants *tc = [TutorialConstants sharedTutorialConstants];
  [DialogMenuController displayViewForText:tc.insideCarpenterText1 callbackTarget:self action:@selector(insideCarpDialog)];
  
  [self.coinBar updateLabels];
}

- (void) viewWillAppear:(BOOL)animated {
  [self.carpBar clickButton:kIncomeButton];
  [self.carpBar unclickButton:kFunctionalButton];
  
  [self.coinBar updateLabels];
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
  
  _arrow = [[UIImageView alloc] initWithImage:[Globals imageNamed:@"green.png"]];
  [cell addSubview:_arrow];
  [_arrow release];
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
  }
}

- (void) dealloc {
  [super dealloc];
}

@end
