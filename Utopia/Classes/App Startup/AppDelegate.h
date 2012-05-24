//
//  AppDelegate.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/9/11.
//  Copyright LVL6 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AdColonyPublic.h"

@interface AppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate, AdColonyDelegate> {
	UIWindow			*window;
}

@property (nonatomic, retain) UIWindow *window;

@end
