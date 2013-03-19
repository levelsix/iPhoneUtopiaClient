//
//  ArmoryTutorialView.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/12/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArmoryTutorialView : UIView

@property (nonatomic, retain) IBOutlet UILabel *speechLabel;
@property (nonatomic, retain) IBOutlet UIView *speechBubble;
@property (nonatomic, retain) IBOutlet UIImageView *girlImageView;
@property (nonatomic, retain) IBOutlet UIView *buttonView;
@property (nonatomic, retain) IBOutlet UILabel *buttonLabel;
@property (nonatomic, retain) IBOutlet UIButton *closeButton;

- (void) displayDescriptionForFirstLossTutorial;
- (void) displayInfoForStarterPack;
- (void) displayCloseClicked;
- (void) displayNotEnoughGold;

- (IBAction)closeClicked:(id)sender;

@end
