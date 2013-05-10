//
//  ArmoryFeedView.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/3/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"
#import "NibUtils.h"

@class ArmoryFeedView;

@interface ArmoryFeedDragView : UIView {
  BOOL _isOpen;
  float _initialY;
  float _touchOffset;
  BOOL _passedThreshold;
}

@property (nonatomic, assign) IBOutlet ArmoryFeedView *feedView;

@end

@interface ArmoryFeedCell : UITableViewCell

@property (nonatomic, retain) RareBoosterPurchaseProto *boosterPurchase;

@property (nonatomic, retain) IBOutlet UIButton *typeIcon;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *leftMiddleLabel;
@property (nonatomic, retain) IBOutlet UILabel *equipLabel;
@property (nonatomic, retain) IBOutlet UILabel *rightMiddleLabel;
@property (nonatomic, retain) IBOutlet UILabel *chestLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UIImageView *equipBgdButton;
@property (nonatomic, retain) IBOutlet EquipButton *equipIcon;

@end

@interface ArmoryFeedLineView : UIView

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *leftMiddleLabel;
@property (nonatomic, retain) IBOutlet UILabel *equipLabel;
@property (nonatomic, retain) IBOutlet UILabel *rightMiddleLabel;
@property (nonatomic, retain) IBOutlet UILabel *chestLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

@end

@interface ArmoryFeedView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *feedTable;

@property (nonatomic, retain) IBOutlet UIView *closedClearView;

@property (nonatomic, retain) IBOutlet ArmoryFeedLineView *curLineView;
@property (nonatomic, retain) IBOutlet ArmoryFeedLineView *bgdLineView;

@property (nonatomic, retain) IBOutlet ArmoryFeedCell *feedCell;

- (float) maxY;
- (float) minY;
- (void) openFeedAnimated:(BOOL)animated;
- (void) closeFeedAnimated:(BOOL)animated;
- (void) addedBoosterPurchase;

@end
