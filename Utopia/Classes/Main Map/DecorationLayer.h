//
//  DecorationLayer.h
//  Utopia
//
//  Created by Ashwin Kamath on 4/23/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "CCLayer.h"

@interface DecorationLayer : CCLayer {
  NSMutableArray *_clouds;
}

- (id) initWithSize:(CGSize)size;

- (void) updateAllCloudOpacities;

@end
