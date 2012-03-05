//
//  AppDelegate.h
//  Utopia
//
//  Created by Ashwin Kamath on 12/9/11.
//  Copyright LVL6 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end
