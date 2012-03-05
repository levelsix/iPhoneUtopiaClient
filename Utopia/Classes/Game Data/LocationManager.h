//
//  LocationManager.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/8/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject

@property (nonatomic, retain) CLLocationManager *locManager;

- (id) initWithDelegate:(id<CLLocationManagerDelegate>)del;

@end
