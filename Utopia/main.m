//
//  main.m
//  Utopia
//
//  Created by Ashwin Kamath on 12/9/11.
//  Copyright LVL6 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  int retVal = -1;
  @try {
    retVal = UIApplicationMain(argc, argv, nil, nil);
  }
  @catch (NSException* exception) {
    NSLog(@"Uncaught exception: %@", exception.description);
    NSLog(@"Stack trace: %@", [exception callStackSymbols]);
  }
  [pool release];
  return retVal;
}
