//
//  KiipDelegate.h
//  Utopia
//
//  Created by Kevin Calloway on 6/4/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Kiip.h"

@interface KiipDelegate : NSObject <KPManagerDelegate> {
  KPManager *kpManager;
}

+(void) postAchievementNotificationAchievement:(NSString *)achievement;
+(id<KPManagerDelegate>) create;
-(id)initWithKPManager:(KPManager *)manager;

@end
