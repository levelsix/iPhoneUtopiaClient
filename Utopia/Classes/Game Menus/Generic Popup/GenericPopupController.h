//
//  GenericPopupController.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/5/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GenericPopupController : UIViewController

@property (nonatomic, assign) BOOL toAppStore;

@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;

+ (void) displayViewWithText:(NSString *)string;
+ (void) displayMajorUpdatePopup;
+ (void) removeView;
+ (void) purgeSingleton;

@end
