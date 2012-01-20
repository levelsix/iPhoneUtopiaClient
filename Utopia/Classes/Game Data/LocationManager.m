//
//  LocationManager.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/8/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "LocationManager.h"
#import "GameState.h"

@implementation LocationManager

@synthesize locManager;

- (id) init {
  if ((self = [super init])) {
    self.locManager = [[CLLocationManager alloc] init];
    locManager.delegate = self;
    [self.locManager startUpdatingLocation];
  }
  return self;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
  NSLog(@"in fail with error");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
  NSLog(@"%f, %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
  [[GameState sharedGameState] setLocation:newLocation.coordinate];
}

@end
