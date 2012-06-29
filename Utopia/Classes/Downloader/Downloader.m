//
//  ImageDownloader.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/14/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "Downloader.h"
#import "LNSynthesizeSingleton.h"
#import "Globals.h"

#define URL_BASE @"https://s3.amazonaws.com/lvl6utopia/Resources/";

@implementation Downloader

SYNTHESIZE_SINGLETON_FOR_CLASS(Downloader);

@synthesize loadingView;

- (id) init {
  if ((self = [super init])) {
    _queue = dispatch_queue_create("Image Downloader", NULL);
    _cacheDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] copy];
    
//    [[NSBundle mainBundle] loadNibNamed:@"DownloaderSpinner" owner:self options:nil];
  }
  return self;
}

- (void) downloadImage:(NSString *)imageName {
  // LNLogs here are NOT thread safe, be careful
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

- (void) asyncDownloadImage:(NSString *)imageName completion:(void (^)(void))completed {
  // Get an image from the URL below
  LNLog(@"Beginning async download of %@", imageName);
  dispatch_async(_queue, ^{
    [self downloadImage:imageName];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      if (completed) {
        completed();
      }
      LNLog(@"Download of %@ complete", imageName);
    });
  });
}

- (void) syncDownloadImage:(NSString *)imageName {
  LNLog(@"Beginning sync download of %@", imageName);
  dispatch_sync(_queue, ^{
    [self downloadImage:imageName];
  });
  LNLog(@"Download of %@ complete", imageName);
}

- (void) downloadFile:(NSString *)fileName {
  NSString *urlBase = URL_BASE;
  NSURL *url = [NSURL URLWithString:[urlBase stringByAppendingString:fileName]];
  NSString *filePath = [NSString stringWithFormat:@"%@/%@",_cacheDir, [[url pathComponents] lastObject]];
  if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    NSData *data = [NSData dataWithContentsOfURL:url];
    if (data) {
      [data writeToFile:filePath atomically:YES];
    }
  }
}

- (void) syncDownloadFile:(NSString *)fileName {
  LNLog(@"Beginning sync download of file %@", fileName);
  dispatch_sync(_queue, ^{
    [self downloadFile:fileName];
  });
  LNLog(@"Download of %@ complete", fileName);
}

- (void) asyncDownloadFile:(NSString *)fileName {
  LNLog(@"Beginning async download of file %@", fileName);
  dispatch_async(_queue, ^{
    [self downloadFile:fileName];
    dispatch_async(dispatch_get_main_queue(), ^{
      LNLog(@"Download of %@ complete", fileName);
    });
  });
}

//- (void) beginLoading {
//  dispatch_async(dispatch_get_main_queue(), ^{
//    [Globals displayUIView:loadingView];
//    [loadingView.actIndView startAnimating];
//  });
//}
//
//- (void) stopLoading {
//  dispatch_async(dispatch_get_main_queue(), ^{
//    [loadingView removeFromSuperview];
//    [loadingView.actIndView stopAnimating];
//  });
//}

- (void) dealloc {
  dispatch_release(_queue);
  [_cacheDir release];
  self.loadingView = nil;
  [super dealloc];
}

@end

@implementation DownloaderLoadingView

@synthesize darkView, actIndView, label;

- (void) awakeFromNib {
  self.darkView.layer.cornerRadius = 10.f;
}

- (void) dealloc {
  self.darkView = nil;
  self.actIndView = nil;
  self.label = nil;
  
  [super dealloc];
}

@end
