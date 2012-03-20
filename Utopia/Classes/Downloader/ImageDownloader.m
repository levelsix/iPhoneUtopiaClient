//
//  ImageDownloader.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ImageDownloader.h"
#import "SynthesizeSingleton.h"

@implementation ImageDownloader

static NSString *urlBase = @"https://s3.amazonaws.com/lvl6utopia/Resources/";

SYNTHESIZE_SINGLETON_FOR_CLASS(ImageDownloader);

- (id) init {
  if ((self = [super init])) {
    _queue = dispatch_queue_create("Image Downloader", NULL);
    _cacheDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] copy];
  }
  return self;
}

- (void) downloadImage:(NSString *)imageName {
  // NSLogs here are NOT thread safe, be careful
  NSURL *url = [NSURL URLWithString:[urlBase stringByAppendingString:imageName]];
  NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",_cacheDir, [[url pathComponents] lastObject]];
  if (![[NSFileManager defaultManager] fileExistsAtPath:pngFilePath]) {
//    NSLog(@"Beginning download of %@ from %@", imageName, [urlBase stringByAppendingString:imageName]);
    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
    
    if (image) {
      NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
      
      [data1 writeToFile:pngFilePath atomically:YES];
      
//      NSLog(@"%@ image saved to %@", imageName, pngFilePath);
    } else {
//      NSLog(@"%@ image failed to download", imageName);
    }
    [image release];
  } else {
//    NSLog(@"%@ has already been downloaded..", imageName);
  }
}

- (void) downloadImage:(NSString *)imageName completion:(void (^)(void))completed {
  // Get an image from the URL below
  dispatch_async(_queue, ^{
    [self downloadImage:imageName];
    dispatch_async(dispatch_get_main_queue(), completed);
  });
}

- (void) dealloc {
  dispatch_release(_queue);
  [_cacheDir release];
  [super dealloc];
}

@end
