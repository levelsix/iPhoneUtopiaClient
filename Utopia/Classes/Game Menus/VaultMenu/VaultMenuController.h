//
//  VaultMenuController.h
//  Utopia
//
//  Created by Ashwin Kamath on 2/17/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "NibUtils.h"

@interface VaultMenuController : UIViewController  <UITextFieldDelegate> {
  BOOL _animating;
  int _index;
  int _numTicksComplete;
}

@property (nonatomic, retain) IBOutlet LabelButton *depositButton;
@property (nonatomic, retain) IBOutlet LabelButton *withdrawButton;
@property (nonatomic, retain) IBOutlet UITextField *transferField;
@property (nonatomic, retain) IBOutlet UIView *tickerHolderView;

@property (nonatomic, retain) NSArray *tickers;
@property (nonatomic, retain) NSString *vaultBalance;
@property (nonatomic, retain) NSTimer *timer;

+ (VaultMenuController *) sharedVaultMenuController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

- (IBAction)closeClicked:(id)sender;
- (IBAction)depositClicked:(id)sender;
- (IBAction)withdrawClicked:(id)sender;
- (IBAction)clearClicked:(id)sender;

- (void) updateBalance;
- (void) animateNextNum;

@end
