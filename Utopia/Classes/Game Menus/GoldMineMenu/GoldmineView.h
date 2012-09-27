//
//  GoldMineView.h
//  Utopia
//
//  Created by Ashwin Kamath on 9/25/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"

@interface GoldMineView : UIView

@property (nonatomic, retain) IBOutlet UILabel *timeLeftLabel;
@property (nonatomic, retain) IBOutlet UILabel *buttonLabel;
@property (nonatomic, retain) IBOutlet ProgressBar *progressBar;

@property (nonatomic, retain) IBOutlet UIView *hazardSign;
@property (nonatomic, retain) IBOutlet UIView *collectingView;
@property (nonatomic, retain) IBOutlet UIView *descriptionView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) NSTimer *timer;

- (void) displayForCurrentState;

- (IBAction)closeClicked:(id)sender;

@end