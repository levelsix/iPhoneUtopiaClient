//
//  ArmoryViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/25/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface ArmoryItemView : UIView 

@end

@interface MaskView : UIView {
@private
  CGImageRef maskedImage;
  CGSize size;
}

@property (nonatomic, assign) float xOffset;
@end

@interface ArmoryViewController : UIViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet ArmoryItemView *itemView;
@property (nonatomic, retain) IBOutlet UIView *buySellView;
@property (nonatomic, retain) IBOutlet UIButton *buyButton;
@property (nonatomic, retain) IBOutlet UIButton *sellButton;

@property (nonatomic, retain) MaskView *maskView;

+ (ArmoryViewController *) sharedArmoryViewController;
+ (void) displayView;
+ (void) removeView;
- (void) moveBuySellOffscreen;
- (void) setScrollViewContentWidth:(float)width;

@end
