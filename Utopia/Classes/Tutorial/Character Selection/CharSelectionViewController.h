//
//  CharSelectionViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"

@interface CharSelectionViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate> {
  float _pageWidth;
  float _barWidth;
  int _curPage;
  BOOL _isScrolling;
  BOOL _submitted;
}

@property (nonatomic, retain) IBOutlet UIView *goodWarriorView;
@property (nonatomic, retain) IBOutlet UIView *goodArcherView;
@property (nonatomic, retain) IBOutlet UIView *goodMageView;
@property (nonatomic, retain) IBOutlet UIView *badWarriorView;
@property (nonatomic, retain) IBOutlet UIView *badArcherView;
@property (nonatomic, retain) IBOutlet UIView *badMageView;

@property (nonatomic, retain) IBOutlet UIButton *leftArrowButton;
@property (nonatomic, retain) IBOutlet UIButton *rightArrowButton;
@property (nonatomic, retain) IBOutlet UIView *submitButton;

@property (nonatomic, retain) IBOutlet UIScrollView *charScrollView;

@property (nonatomic, retain) IBOutlet UIImageView *smallAttBar;
@property (nonatomic, retain) IBOutlet UIImageView *medAttBar;
@property (nonatomic, retain) IBOutlet UIImageView *bigAttBar;
@property (nonatomic, retain) IBOutlet UIImageView *smallDefBar;
@property (nonatomic, retain) IBOutlet UIImageView *medDefBar;
@property (nonatomic, retain) IBOutlet UIImageView *bigDefBar;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

@property (nonatomic, retain) IBOutlet UIImageView *greenGlow;
@property (nonatomic, retain) IBOutlet UIImageView *redGlow;

@property (nonatomic, retain) IBOutlet UIView *bottomBar;
@property (nonatomic, retain) IBOutlet UIView *chooseNameView;

@property (nonatomic, retain) IBOutlet NiceFontTextField *nameTextField;

@end
