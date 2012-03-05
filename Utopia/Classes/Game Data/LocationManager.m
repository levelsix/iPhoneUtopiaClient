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

- (id) initWithDelegate:(id<CLLocationManagerDelegate>)del {
  if ((self = [super init])) {
    if ([CLLocationManager locationServicesEnabled]) {
      locManager = [[CLLocationManager alloc] init];
      locManager.delegate = del;
      locManager.desiredAccuracy = kCLLocationAccuracyKilometer;
      locManager.distanceFilter = 1000;
      
      [self.locManager startUpdatingLocation];
    } else {
      NSLog(@"Location services disabled..");
      [self release];
      return nil;
    }
  }
  return self;
}

- (void) dealloc {
  self.locManager = nil;
  [super dealloc];
}

@end
