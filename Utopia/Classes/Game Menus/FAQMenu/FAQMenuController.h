//
//  FAQMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/19/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "NibUtils.h"

@interface FAQMenuController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, SwitchButtonDelegate>

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UIView *faqView;
@property (nonatomic, retain) IBOutlet UIView *settingsView;

@property (nonatomic, retain) NSArray *textStrings;

@property (nonatomic, retain) IBOutlet UITableView *faqTable;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

@property (nonatomic, retain) IBOutlet SwitchButton *musicSwitchButton;
@property (nonatomic, retain) IBOutlet SwitchButton *soundEffectsSwitchButton;
@property (nonatomic, retain) IBOutlet SwitchButton *shakeSwitchButton;

+ (FAQMenuController *) sharedFAQMenuController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

- (IBAction)emailButtonClicked:(id)sender;
- (IBAction)closeClicked:(id)sender;
- (IBAction)forumButtonClicked:(id)sender;

- (void) loadFAQ;
- (void) loadPrestigeInfo;
- (void) loadSettings;

@end
