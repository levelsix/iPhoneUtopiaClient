//
//  LevelUpViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 3/11/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"

@interface LevelUpViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) LevelUpResponseProto *levelUpResponse;
@property (nonatomic, retain) IBOutlet UIView *itemView;
@property (nonatomic, retain) IBOutlet UIImageView *itemIcon;
@property (nonatomic, retain) IBOutlet UILabel *itemLabel;
@property (nonatomic, retain) IBOutlet UILabel *congratsLabel;

- (id) initWithLevelUpResponse:(LevelUpResponseProto *)lurp;

@end
