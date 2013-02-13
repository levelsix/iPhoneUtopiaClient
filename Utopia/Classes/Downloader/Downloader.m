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
#import "SSZipArchive.h"
#import "CharSelectionViewController.h"

#define URL_BASE @"https://s3.amazonaws.com/lvl6utopia/Resources/";

@implementation Downloader

SYNTHESIZE_SINGLETON_FOR_CLASS(Downloader);

@synthesize loadingView;

- (id) init {
  if ((self = [super init])) {
    _syncQueue = dispatch_queue_create("Sync Downloader", NULL);
    _asyncQueue = dispatch_queue_create("Async Downloader", NULL);
    _cacheDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] copy];
    
    [[NSBundle mainBundle] loadNibNamed:@"DownloaderSpinner" owner:self options:nil];
  }
  return self;
}

- (NSString *) downloadFile:(NSString *)imageName {
  // LNLogs here are NOT thread safe, be careful
  NSString *urlBase = URL_BASE;
  NSURL *url = [[NSURL alloc] initWithString:[urlBase stringByAppendingString:imageName]];
  NSString *filePath = [[NSString alloc] initWithFormat:@"%@/%@",_cacheDir, [[url pathComponents] lastObject]];
  BOOL success = YES;
  
  NSData *data = [[NSData alloc] initWithContentsOfURL:url];
  if (data) {
    success = [data writeToFile:filePath atomically:YES];
  }
  [data release];
  
  [url release];
  [filePath autorelease];
  return success ? filePath : nil;
}

- (void) asyncDownloadFile:(NSString *)imageName completion:(void (^)(void))completed {
  // Get an image from the URL below
  ContextLogInfo(LN_CONTEXT_DOWNLOAD, @"Beginning async download of %@", imageName);
  dispatch_async(_asyncQueue, ^{
    [self downloadFile:imageName];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      if (completed) {
        completed();
      }
      ContextLogInfo(LN_CONTEXT_DOWNLOAD, @"Download of %@ complete", imageName);
    });
  });
}

- (void) syncDownloadFile:(NSString *)fileName {
  ContextLogInfo(LN_CONTEXT_DOWNLOAD, @"Beginning sync download of file %@", fileName);
  [self beginLoading:fileName];
  [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
  dispatch_sync(_syncQueue, ^{
    [self downloadFile:fileName];
  });
  [self stopLoading];
  ContextLogInfo(LN_CONTEXT_DOWNLOAD, @"Download of %@ complete", fileName);
}

- (void) beginLoading:(NSString *)fileName {
  NSString *f = fileName;
  
  NSArray *removeStrings = [NSArray arrayWithObjects:@".", @"Walk", @"Generic", @"Attack", nil];
  
  for (NSString *str in removeStrings) {
    NSRange range = [fileName rangeOfString:str];
    if (range.length > 0) {
      range.length = fileName.length-range.location;
      f = [fileName stringByReplacingCharactersInRange:range withString:@""];
    }
  }
  
  f = [f stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
  
  NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"([a-z])([A-Z])" options:0 error:NULL];
  f = [regexp stringByReplacingMatchesInString:f options:0 range:NSMakeRange(0, f.length) withTemplate:@"$1 $2"];
  
  f = [f capitalizedString];
  loadingView.label.text = fileName ? [NSString stringWithFormat:@"Loading\n%@", f] : @"Loading Files";
  [Globals displayUIView:loadingView];
  
  // Put it under char selection view
  UIView *cv = [loadingView.superview viewWithTag:CHAR_SELECTION_VIEW_TAG];
  if (cv) {
    [cv.superview bringSubviewToFront:cv];
  }
}

- (void) stopLoading {
  [loadingView removeFromSuperview];
}

- (void) downloadBundle:(NSString *)zipFile
{
  NSString *filePath = [self downloadFile:zipFile];
  if (filePath) {
    [SSZipArchive unzipFileAtPath:filePath toDestination:_cacheDir];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
  }
}

- (void) deletePreviousBundles:(NSString *)bundleName {
  NSString *num = [bundleName pathExtension];
  NSString *base = [bundleName stringByDeletingPathExtension];
  int numVal = num.intValue;
  
  for (int i = 0; i < numVal; i++) {
    NSString *filePath = [[NSString alloc] initWithFormat:@"%@/%@.%d",_cacheDir, base, i];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
      BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
      dispatch_async(dispatch_get_main_queue(), ^(void) {
        LNLog(@"Found and %@ %@.", removed ? @"successfully removed" : @"failed to remove", filePath);
      });
    }
  }
}

- (void) syncDownloadBundle:(NSString *)bundleName {
  ContextLogInfo(LN_CONTEXT_DOWNLOAD, @"Beginning sync download of bundle %@", bundleName);
  [self beginLoading:bundleName];
  [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5f]];
  dispatch_sync(_syncQueue, ^{
    [self downloadBundle:[bundleName stringByAppendingString:@".zip"]];
    [self deletePreviousBundles:bundleName];
  });
  [self stopLoading];
  ContextLogInfo(LN_CONTEXT_DOWNLOAD, @"Download of bundle %@ complete", bundleName);
}

- (void) asyncDownloadBundle:(NSString *)bundleName {
  ContextLogInfo(LN_CONTEXT_DOWNLOAD, @"Beginning async download of bundle %@", bundleName);
  dispatch_async(_asyncQueue, ^{
    [self downloadBundle:[bundleName stringByAppendingString:@".zip"]];
    [self deletePreviousBundles:bundleName];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
      ContextLogInfo(LN_CONTEXT_DOWNLOAD, @"Download of bundle %@ complete", bundleName);
    });
  });
}

- (void) purgeAllDownloadedData {
  NSFileManager *fileMgr = [NSFileManager defaultManager];
  NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:_cacheDir error:nil];
  for (NSString *filename in fileArray)  {
    [fileMgr removeItemAtPath:[_cacheDir stringByAppendingPathComponent:filename] error:NULL];
  }
}

- (void) dealloc {
  dispatch_release(_syncQueue);
  dispatch_release(_asyncQueue);
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
