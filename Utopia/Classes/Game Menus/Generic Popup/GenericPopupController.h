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

@property (nonatomic, retain) IBOutlet UIButton *okButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdColorView;

@property (nonatomic, retain) NSInvocation *okInvocation;
@property (nonatomic, retain) NSInvocation *cancelInvocation;

@property (nonatomic, assign) BOOL toAppStore;
@property (nonatomic, assign) BOOL toReviewPage;

- (void) close;
- (IBAction)redOkayClicked:(id)sender;
- (IBAction)greenOkayClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;

@end

@interface GenericPopupController : UIViewController

@property (nonatomic, retain) NSString *appStoreLink;
@property (nonatomic, retain) NSString *reviewPageLink;
@property (nonatomic, retain) IBOutlet GenericPopup *genPopup;

+ (id) sharedGenericPopupController;
+ (GenericPopup *) displayMajorUpdatePopup:(NSString *)appStoreLink;
+ (GenericPopup *) displayNotificationViewWithText:(NSString *)string title:(NSString *)title;
+ (GenericPopup *) displayNotificationViewWithText:(NSString *)string title:(NSString *)title okayButton:(NSString *)okay target:(id)target selector:(SEL)selector;
+ (GenericPopup *) displayNotificationViewWithMiddleView:(UIView *)view title:(NSString *)title okayButton:(NSString *)okay target:(id)target selector:(SEL)selector;
+ (GenericPopup *) displayConfirmationWithDescription:(NSString *)description title:(NSString *)title okayButton:(NSString *)okay cancelButton:(NSString *)cancel target:(id)target selector:(SEL)selector;
+ (GenericPopup *) displayConfirmationWithDescription:(NSString *)description title:(NSString *)title okayButton:(NSString *)okay cancelButton:(NSString *)cancel okTarget:(id)okTarget okSelector:(SEL)okSelector cancelTarget:(id)cancelTarget cancelSelector:(SEL)cancelSelector;
+ (void) removeView;
+ (void) purgeSingleton;
- (void) openAppStoreLink;

@end
