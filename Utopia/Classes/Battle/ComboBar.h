//
//  ComboBar.h
//  Utopia
//
//  Created by Ashwin Kamath on 1/10/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "cocos2d.h"

@interface Notch : CCSprite {
@private
  NSRange _place;
}

@property (nonatomic, assign) NSRange place;

@end

@interface ComboBar : CCSprite <CCTargetedTouchDelegate> {
  CCProgressTimer *_progressBar;
  Notch *_bigBar, *_lilBar1, *_lilBar2;
}

@property (nonatomic, retain) CCProgressTimer * progressBar;

+ (id) bar;
- (id) initBar;
- (void) randomizeNotches;
- (void) doComboSequence;

@end
