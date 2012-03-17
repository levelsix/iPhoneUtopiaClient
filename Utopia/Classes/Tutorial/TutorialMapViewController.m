//
//  TutorialMapViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 3/16/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "TutorialMapViewController.h"

@implementation TutorialMapViewController

- (id) init {
  return [super initWithNibName:@"MapViewController" bundle:nil];
}

- (void) viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  _travelHomePhase = YES;
}

- (IBAction)closeClicked:(id)sender {
  return;
}

- (IBAction)homeClicked:(id)sender {
  if (_travelHomePhase) {
    [super homeClicked:sender];
  }
}

@end
