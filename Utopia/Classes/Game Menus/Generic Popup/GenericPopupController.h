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
@property (nonatomic, retain) NSString *link;

@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdColorView;

+ (void) displayViewWithText:(NSString *)string;
+ (void) displayMajorUpdatePopup:(NSString *)appStoreLink;
+ (void) removeView;
+ (void) purgeSingleton;

@end
