//
//  ImageDownloader.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Downloader.h"
#import "SynthesizeSingleton.h"

#define URL_BASE @"https://s3.amazonaws.com/lvl6utopia/Resources/";

@implementation Downloader

SYNTHESIZE_SINGLETON_FOR_CLASS(Downloader);

- (id) init {
  if ((self = [super init])) {
    _queue = dispatch_queue_create("Image Downloader", NULL);
    _cacheDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] copy];
  }
  return self;
}

- (void) downloadImage:(NSString *)imageName {
  // NSLogs here are NOT thread safe, be careful
  NSString *urlBase = URL_BASE;
  NSURL *url = [NSURL URLWithString:[urlBase stringByAppendingString:imageName]];
  NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",_cacheDir, [[url pathComponents] lastObject]];
  if (![[NSFileManager defaultManager] fileExistsAtPath:pngFilePath]) {
    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:url]];
    
    if (image) {
      NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(image)];
      
      [data1 writeToFile:pngFilePath atomically:YES];
    }
    [image release];
  }
}

- (void) downloadImage:(NSString *)imageName completion:(void (^)(void))completed {
  // Get an image from the URL below
  NSLog(@"Beginning async download of %@", imageName);
  dispatch_async(_queue, ^{
    [self downloadImage:imageName];
    dispatch_async(dispatch_get_main_queue(), completed);
  });
  NSLog(@"Download of %@ complete", imageName);
}

- (void) syncDownloadImage:(NSString *)imageName {
  NSLog(@"Beginning sync download of %@", imageName);
  dispatch_sync(_queue, ^{
    [self downloadImage:imageName];
  });
  NSLog(@"Download of %@ complete", imageName);
}

- (void) syncDownloadMap:(NSString *)mapName {
  NSLog(@"Beginning sync download of map %@", mapName);
  dispatch_sync(_queue, ^{
    NSString *urlBase = URL_BASE;
    NSURL *url = [NSURL URLWithString:[urlBase stringByAppendingString:mapName]];
    NSString *mapFilePath = [NSString stringWithFormat:@"%@/%@",_cacheDir, [[url pathComponents] lastObject]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:mapFilePath]) {
      NSData *map = [NSData dataWithContentsOfURL:url];
      if (map) {
        [map writeToFile:mapFilePath atomically:YES];
      }
    }
  });
  NSLog(@"Download of %@ complete", mapName);
}

- (void) dealloc {
  dispatch_release(_queue);
  [_cacheDir release];
  [super dealloc];
}

@end
