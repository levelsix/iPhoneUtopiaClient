//
//  LevelUpViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/11/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"

@interface LevelUpViewController : UIViewController {
  NSMutableArray *_itemViews;
  int _currentIndex;
}

@property (nonatomic, retain) LevelUpResponseProto *levelUpResponse;

@property (nonatomic, retain) IBOutlet UIView *itemView;
@property (nonatomic, retain) IBOutlet UIImageView *itemIcon;
@property (nonatomic, retain) IBOutlet UILabel *itemLabel;
@property (nonatomic, retain) IBOutlet UIImageView *itemBackground;
@property (nonatomic, retain) IBOutlet UIImageView *cityUnlocked;

@property (nonatomic, retain) IBOutlet UIView *staminaView;
@property (nonatomic, retain) IBOutlet UIView *energyView;
@property (nonatomic, retain) IBOutlet UIView *statsView;
@property (nonatomic, retain) IBOutlet UILabel *congratsLabel;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIImageView *glowingStars;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

- (id) initWithLevelUpResponse:(LevelUpResponseProto *)lurp;

@end
