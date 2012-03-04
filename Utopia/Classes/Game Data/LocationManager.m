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
    NSLog(@"Location services: %d", [CLLocationManager locationServicesEnabled]);
    if ([CLLocationManager locationServicesEnabled]) {
      locManager = [[CLLocationManager alloc] init];
      locManager.delegate = self;
      locManager.desiredAccuracy = kCLLocationAccuracyKilometer;
      locManager.distanceFilter = 1000;
      
      [self.locManager startUpdatingLocation];
    }
  }
  return self;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
  NSLog(@"in fail with error");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
  NSLog(@"Received new location: lat %f, long %f with timestamp: %@", newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.timestamp);
  [[GameState sharedGameState] setLocation:newLocation.coordinate];
}

- (void) dealloc {
  self.locManager = nil;
  [super dealloc];
}

@end
