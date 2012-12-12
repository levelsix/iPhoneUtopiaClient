//
//  ClanTowerTab.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/5/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NibUtils.h"

@interface ClanTowerInfoView : UIView

@property (nonatomic, retain) IBOutlet UILabel *ownerNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackerNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *ownerWinsLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackerWinsLabel;
@property (nonatomic, retain) IBOutlet UILabel *ownerPercentLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackerPercentLabel;

@property (nonatomic, retain) IBOutlet ProgressBar *goodProgressBar;
@property (nonatomic, retain) IBOutlet ProgressBar *badProgressBar;

@property (nonatomic, retain) IBOutlet UIView *warView;
@property (nonatomic, retain) IBOutlet UIView *notWarView;
@property (nonatomic, retain) IBOutlet UILabel *buttonLabel;
@property (nonatomic, retain) IBOutlet UILabel *middleLabel;
@property (nonatomic, retain) IBOutlet UILabel *ownerLabel;

@property (nonatomic, retain) IBOutlet UILabel *leftHourLabel;
@property (nonatomic, retain) IBOutlet UILabel *rightHourLabel;
@property (nonatomic, retain) IBOutlet UILabel *leftMinuteLabel;
@property (nonatomic, retain) IBOutlet UILabel *rightMinuteLabel;
@property (nonatomic, retain) IBOutlet UILabel *leftSecondLabel;
@property (nonatomic, retain) IBOutlet UILabel *rightSecondLabel;

@property (nonatomic, retain) IBOutlet UILabel *bottomLabel;

@property (nonatomic, retain) IBOutlet UIView *concedeView;

@property (nonatomic, retain) IBOutlet UIView *claimButtonView;
@property (nonatomic, retain) IBOutlet UIView *sameSideLabel;

@end

@interface ClanTowerView : UIView

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIButton *bgdButton;
@property (nonatomic, retain) IBOutlet UILabel *tickerLabel;
@property (nonatomic, retain) IBOutlet UILabel *aboveTickerLabel;

@property (nonatomic, retain) IBOutlet UILabel *ownerWarLabel;
@property (nonatomic, retain) IBOutlet UILabel *ownerPeaceLabel;
@property (nonatomic, retain) IBOutlet UILabel *attackerLabel;

@property (nonatomic, retain) IBOutlet UIView *peaceView;
@property (nonatomic, retain) IBOutlet UIView *warView;

@end

@interface ClanTowerTab : UIView {
  int _currentTowerId;
  ClanTowerView *_selectedView;
}

@property (nonatomic, retain) NSMutableArray *towerViews;
@property (nonatomic, retain) IBOutlet ClanTowerView *nibView;
@property (nonatomic, retain) IBOutlet ClanTowerInfoView *infoView;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) NSTimer *timer;

- (void) loadClanTowerList:(BOOL)animated;
- (void) updateForCurrentTowers;

- (IBAction)redButtonClicked:(id)sender;
- (IBAction)concedeClicked:(id)sender;

@end

@interface NSString (ReverseString)

-(NSString *) reverseString;

@end
