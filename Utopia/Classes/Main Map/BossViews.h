//
//  BossViews.h
//  Utopia
//
//  Created by Ashwin Kamath on 6/13/13.
//  Copyright (c) 2013 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocols.pb.h"

@interface BossUnlockedView : UIView

@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet UIView *bgdView;

@property (nonatomic, retain) IBOutlet UIImageView *tutGirlImage;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

- (void) displayForBoss:(FullBossProto *)boss;

@end
