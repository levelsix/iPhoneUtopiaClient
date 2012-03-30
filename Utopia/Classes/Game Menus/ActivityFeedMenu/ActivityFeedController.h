//
//  ActivityFeedController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/17/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@interface ActivityFeedCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *userIcon;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *buttonLabel;
@property (nonatomic, retain) IBOutlet UIButton *button;

@property (nonatomic, retain) UserNotification *notification;

@end

@interface ActivityFeedController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UITableView *activityTableView;
@property (nonatomic, retain) IBOutlet ActivityFeedCell *actCell;

+ (ActivityFeedController *) sharedActivityFeedController;
+ (void) displayView;
+ (void) removeView;
+ (void) purgeSingleton;

@end
