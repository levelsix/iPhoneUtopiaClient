//
//  CharSelectionViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"
#import "Protocols.pb.h"

#define CHAR_SELECTION_VIEW_TAG 923
#define CHAR_SELECTION_CLOSE_NOTIFICATION @"CharSelectionClose"

@interface ActionlessTextField : NiceFontTextField

@end

@interface CharSelectionViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate> {
  BOOL _isGoodSide;
  UserType _chosenType;
  BOOL _submitted;
  BOOL _animating;
}

@property (nonatomic, retain) IBOutlet UIButton *warriorButton;
@property (nonatomic, retain) IBOutlet UIButton *archerButton;
@property (nonatomic, retain) IBOutlet UIButton *mageButton;

@property (nonatomic, retain) IBOutlet UIView *selectSideView;
@property (nonatomic, retain) IBOutlet UIView *selectCharView;

@property (nonatomic, retain) IBOutlet UIView *submitButton;
@property (nonatomic, retain) IBOutlet UIView *backButton;
@property (nonatomic, retain) IBOutlet UIView *cancelView;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIView *chooseNameView;

@property (nonatomic, retain) IBOutlet NiceFontTextField *nameTextField;
@property (nonatomic, retain) IBOutlet LoadingView *loadingView;


@end
