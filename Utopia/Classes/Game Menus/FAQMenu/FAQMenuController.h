//
//  FAQMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/19/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface FAQMenuController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) NSArray *gameplayTextStrings;
@property (nonatomic, retain) NSArray *faqTextStrings;

+ (FAQMenuController *) sharedFAQMenuController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

- (IBAction)emailButtonClicked:(id)sender;
- (IBAction)closeClicked:(id)sender;
- (IBAction)feedbackButtonClicked:(id)sender;
- (IBAction)forumButtonClicked:(id)sender;

@end
