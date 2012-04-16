//
//  UVHelper.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/16/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserVoice.h"

@interface UVHelper : NSObject <UVDelegate>

- (void) openUserVoice;
+ (UVHelper *) sharedUVHelper;

@end
