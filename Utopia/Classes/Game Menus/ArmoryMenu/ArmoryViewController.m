//
//  ArmoryViewController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/25/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ArmoryViewController.h"
#import "SynthesizeSingleton.h"

@implementation ArmoryItemView

@end

@implementation MaskView

@synthesize xOffset;

- (id) initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    // Load the alpha image, which is just the same Ship.png image used in the clipping demo
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"itemmask.png" ofType:nil];
    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
    size = img.size;
    CGImageRef alphaImage = CGImageRetain(img.CGImage);
    
    // To show the difference with an image mask, we take the above image and process it to extract
    // the alpha channel as a mask.
    // Allocate data
    NSMutableData *data = [NSMutableData dataWithLength:size.height * size.width * 1];
    // Create a bitmap context
    CGContextRef context = CGBitmapContextCreate([data mutableBytes], size.width, size.height, 8, size.width, NULL, kCGImageAlphaOnly);
    // Set the blend mode to copy to avoid any alteration of the source data
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    // Draw the image to extract the alpha channel
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, size.width, size.height), alphaImage);
    // Now the alpha channel has been copied into our NSData object above, so discard the context and lets make an image mask.
    CGContextRelease(context);
    // Create a data provider for our data object (NSMutableData is tollfree bridged to CFMutableDataRef, which is compatible with CFDataRef)
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((CFMutableDataRef)data);
    // Create our new mask image with the same size as the original image
    maskedImage = CGImageMaskCreate(size.width, size.height, 8, 8, size.width, dataProvider, NULL, YES);
    // And release the provider.
    CGDataProviderRelease(dataProvider);
  }
  return self;
}

- (void) drawRect:(CGRect)rect {
  [super drawRect:rect];
  CGContextRef context = UIGraphicsGetCurrentContext();
  
	CGFloat height = self.bounds.size.height;
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0);
  
  CGRect locRect = CGRectMake(xOffset, 0.0, size.width, size.height);
	
	CGContextSetRGBFillColor(context, 0,0,0,0.5);
	CGContextSaveGState(context);
	// You can also use the clip rect given to scale the mask image
  CGContextAddRect(context, locRect);
  CGContextAddRect(context, self.bounds);
  CGContextClosePath(context);
  CGContextEOClip(context);
  //	CGContextClipToMask(context, CGRectMake(110.0, height - 390.0, 180.0, 180.0), maskingImage);
	// As above, not being careful with bounds since we are clipping.
	CGContextFillRect(context, self.bounds);
	CGContextRestoreGState(context);
  
	CGContextSaveGState(context);
	// You can also use the clip rect given to scale the mask image
  //  CGContextDrawImage(context, CGRectMake(110.0, height - 390.0, 180.0, 180.0), maskingImage);
	CGContextClipToMask(context, locRect, maskedImage);
	// As above, not being careful with bounds since we are clipping.
	CGContextFillRect(context, self.bounds);
	CGContextRestoreGState(context);
}

@end

@implementation ArmoryViewController

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(ArmoryViewController);

@synthesize scrollView, itemView;
@synthesize buySellView, buyButton, sellButton;
@synthesize maskView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  self.scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"storebackbg.png"]];
  
  UINib *nib = [UINib nibWithNibName:@"ArmoryItemView" bundle:nil];
  for (int i = 0; i < 12; i++) {
    // Make a new itemView for each product
    [nib instantiateWithOwner:self options:nil];
    
    self.itemView.frame = CGRectMake(i*self.itemView.frame.size.width,63, self.itemView.frame.size.width, self.itemView.frame.size.height);
    
    [self.scrollView addSubview:self.itemView];
  }
  [self setScrollViewContentWidth:12*self.itemView.frame.size.width];
  
  UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemClicked:)];
  tgr.delegate = self;
  [self.scrollView addGestureRecognizer:tgr];
  
  CGRect r = CGRectZero;
  r.size = self.scrollView.contentSize;
  self.maskView = [[MaskView alloc] initWithFrame:r];
  self.maskView.backgroundColor = [UIColor clearColor];
  [self.scrollView addSubview:self.maskView];
}

- (void) setScrollViewContentWidth:(float)width {
  float w = ceilf(width/self.scrollView.frame.size.width)*self.scrollView.frame.size.width;
  self.scrollView.contentSize = CGSizeMake(w, self.scrollView.frame.size.height);
}

- (void) moveBuySellOffscreen {
  CGRect x = self.buySellView.frame;
  x.origin.x = -x.size.width;
  self.buySellView.frame = x;
  self.buySellView.hidden = YES;
  self.maskView.hidden = YES;
}

- (IBAction)backClicked:(id)sender {
  [ArmoryViewController removeView];
}

- (void)itemClicked:(id)sender {
  UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
  
  if (tap.state == UIGestureRecognizerStateEnded) {
    CGPoint pt = [tap locationInView:self.scrollView];
    
    // Make sure buySellView width is the same as ArmoryItemView width
    CGRect fr = self.buySellView.frame;
    fr.origin.x = floorf(pt.x/fr.size.width)*fr.size.width;
    self.buySellView.frame = fr;
    self.buySellView.hidden = NO;
    
    self.maskView.hidden = NO;
    [self.maskView setNeedsDisplay];
    self.maskView.xOffset = fr.origin.x;
  }
}

- (IBAction)buyClicked:(id)sender {
  NSLog(@"buy");
}

- (IBAction)sellClicked:(id)sender {
  NSLog(@"sell");
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
  [self moveBuySellOffscreen];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  if ([self.buyButton pointInside:[touch locationInView:self.buyButton] withEvent:nil]) {
    return NO;
  }
  if ([self.sellButton pointInside:[touch locationInView:self.sellButton] withEvent:nil]) {
    return NO;
  }
  return YES;
}

- (void) viewDidAppear:(BOOL)animated {
  [[CCDirector sharedDirector] openGLView].userInteractionEnabled = NO;
  [[CCDirector sharedDirector] pause];
  
  [self moveBuySellOffscreen];
  [super viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
  [[CCDirector sharedDirector] openGLView].userInteractionEnabled = YES;
  [[CCDirector sharedDirector] resume];
  [super viewDidDisappear:animated];
}

@end
