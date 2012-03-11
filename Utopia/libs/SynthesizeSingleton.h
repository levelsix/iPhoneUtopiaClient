//
//  SynthesizeSingleton.h
//  CocoaWithLove
//
//  Created by Matt Gallagher on 20/10/08.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//
// To use:
//
//     SYNTHESIZE_SINGLETON_FOR_CLASS(MyClassName);
//
// inside the @implementation MyClassName declaration and your class will become a singleton. You will also need to add the line:
// 
//     + (MyClassName *)sharedMyClassName;
// 
// to the header file for MyClassName so the singleton accessor method can be found from other source files if they #import the header.
// 
// Once your class is a singleton, you can access the instance of it using the line:
//
//     [MyClassName sharedMyClassName];
//

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
 \
static classname *shared##classname = nil; \
 \
+ (classname *)shared##classname \
{ \
	@synchronized(self) \
	{ \
		if (shared##classname == nil) \
		{ \
			shared##classname = [[self alloc] init]; \
      \
      if ([shared##classname isKindOfClass:[UIViewController class]]) { \
        [(UIViewController *)shared##classname view]; \
      } \
		} \
	} \
	 \
	return shared##classname; \
} \
 \
+ (id)allocWithZone:(NSZone *)zone \
{ \
	@synchronized(self) \
	{ \
		if (shared##classname == nil) \
		{ \
			shared##classname = [super allocWithZone:zone]; \
			return shared##classname; \
		} \
	} \
	 \
	return nil; \
} \
 \
- (id)copyWithZone:(NSZone *)zone \
{ \
	return self; \
} \
 \
- (id)retain \
{ \
	return self; \
} \
 \
- (NSUInteger)retainCount \
{ \
	return NSUIntegerMax; \
} \
 \
- (oneway void)release \
{ \
} \
 \
- (id)autorelease \
{ \
	return self; \
}

#define SYNTHESIZE_SINGLETON_FOR_CONTROLLER(controllername) \
\
SYNTHESIZE_SINGLETON_FOR_CLASS(controllername) \
\
+ (void) displayView {\
  controllername *c = [controllername shared##controllername];\
  if (!c.view.superview) {\
    [[[[CCDirector sharedDirector] openGLView] superview] addSubview:c.view];\
    c.view.center = c.view.superview.center;\
  } else { \
    [[[[CCDirector sharedDirector] openGLView] superview] bringSubviewToFront:c.view]; \
  }\
}\
\
+ (void) removeView {\
  [shared##controllername.view removeFromSuperview];\
}
