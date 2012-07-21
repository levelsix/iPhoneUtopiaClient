//
//  GenericPopupController.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/5/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GenericPopup : UIView

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, retain) IBOutlet UILabel *greenButtonLabel;
@property (nonatomic, retain) IBOutlet UILabel *blackButtonLabel;
@property (nonatomic, retain) IBOutlet UILabel *redButtonLabel;

@property (nonatomic, retain) IBOutlet UIView *notificationView;
@property (nonatomic, retain) IBOutlet UIView *confirmationView;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdColorView;

@property (nonatomic, retain) NSInvocation *okInvocation;
@property (nonatomic, retain) NSInvocation *cancelInvocation;

@property (nonatomic, assign) BOOL toAppStore;

@end

@interface GenericPopupController : UIViewController

@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) IBOutlet GenericPopup *genPopup;

+ (id) sharedGenericPopupController;
+ (void) displayMajorUpdatePopup:(NSString *)appStoreLink;
+ (void) displayViewWithText:(NSString *)string title:(NSString *)title;
+ (void) displayConfirmationWithDescription:(NSString *)description title:(NSString *)title okayButton:(NSString *)okay cancelButton:(NSString *)cancel target:(id)target selector:(SEL)selector;
+ (void) displayConfirmationWithDescription:(NSString *)description title:(NSString *)title okayButton:(NSString *)okay cancelButton:(NSString *)cancel okTarget:(id)okTarget okSelector:(SEL)okSelector cancelTarget:(id)cancelTarget cancelSelector:(SEL)cancelSelector;
+ (void) removeView;
+ (void) purgeSingleton;
+ (void) openAppStoreLink;

@end
