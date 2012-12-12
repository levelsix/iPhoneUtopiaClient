//
//  ResetStaminaView.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/12/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetStaminaView : UIView

@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UIView *popupView;
@property (nonatomic, retain) IBOutlet UIView *dialogueView;

@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;

- (void) display;

@end
