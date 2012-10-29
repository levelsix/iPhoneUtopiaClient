//
//  AppDelegate.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/9/11.
//  Copyright LVL6 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "KiipDelegate.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate> {
//  id<TJCVideoAdDelegate>     tapJoyDelegate; 
//  id<AdColonyDelegate>       adColonyDelegate;
//  id<FlurryAdDelegate>       flurryClipsDelegate;
//  id<FacebookGlobalDelegate> facebookDelegate;
  id<KPManagerDelegate>      kiipDelegate;
	UIWindow			*window;
}
@property (nonatomic, assign) int isActive;

@property (nonatomic, retain) UIWindow *window;

- (void) registerForPushNotifications;
- (void) removeLocalNotifications;

@end
