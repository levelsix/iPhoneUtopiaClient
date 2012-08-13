//
//  InGameNotification.m
//  Utopia
//
//  Created by Ashwin Kamath on 8/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "InGameNotification.h"
#import "ActivityFeedController.h"

@implementation InGameNotification

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  self.hidden = YES;
  [ActivityFeedController displayView];
}

@end
