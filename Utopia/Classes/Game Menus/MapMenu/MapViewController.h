//
//  MapViewController.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/7/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"
#import "Protocols.pb.h"

@interface MapViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIImageView *mapView;

@property (nonatomic, retain) NSMutableArray *pins;

- (void) retrieveAttackListForCurrentBounds;
- (void) removeAllPins;
- (void) addNewPins;
- (CGPoint) mapPointForCoordinate:(LocationProto *)coord;

+ (MapViewController *) sharedMapViewController;
+ (void) displayView;
+ (void) removeView;

@end
