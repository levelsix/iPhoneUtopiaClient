//
//  PullRefreshTableViewController.m
//  Plancast
//
//  Created by Leah Culver on 7/2/10.
//  Copyright (c) 2010 Leah Culver
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <QuartzCore/QuartzCore.h>
#import "PullRefreshTableViewController.h"
#import "CGPointExtension.h"

#define REFRESH_HEADER_HEIGHT 55.0f

@implementation PullRefreshTableViewController

@synthesize textPull, textRelease, textLoading, refreshHeaderView, refreshLabel, refreshArrow, refreshSpinner, tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self != nil) {
    [self setupStrings];
  }
  return self;
}

- (void)setupStrings{
  textPull = [[NSString alloc] initWithString:@"Pull down to refresh..."];
  textRelease = [[NSString alloc] initWithString:@"Release to refresh..."];
  textLoading = [[NSString alloc] initWithString:@"Loading..."];
}

- (void)addPullToRefreshHeader:(UITableView *)tableView {
  self.tableView = tableView;
  refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  refreshSpinner.frame = refreshArrow.frame;
  refreshSpinner.hidesWhenStopped = YES;
  [refreshHeaderView addSubview:refreshSpinner];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  if (isLoading) return;
  isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  refreshHeaderView.alpha = clampf(scrollView.contentOffset.y/-REFRESH_HEADER_HEIGHT, 0.f, 1.f);
  if (isLoading) {
    refreshHeaderView.alpha = 1.f;
  } else if (isDragging && scrollView.contentOffset.y < 0) {
    // Update the arrow direction and label
    [UIView beginAnimations:nil context:NULL];
    if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
      // User is scrolling above the header
      refreshLabel.text = self.textRelease;
      [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
    } else { // User is scrolling somewhere within the header
      refreshLabel.text = self.textPull;
      [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    }
    [UIView commitAnimations];
  }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (isLoading) return;
  isDragging = NO;
  if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
    // Released above the header
    [self startLoading];
  }
}

- (void)startLoading {
  isLoading = YES;
  
  // Show the header
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.3];
  self.tableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
  refreshLabel.text = self.textLoading;
  refreshArrow.hidden = YES;
  [refreshSpinner startAnimating];
  [UIView commitAnimations];
  
  // Refresh action!
  [self refresh];
}

- (void)stopLoading {
  if (isLoading) {
    isLoading = NO;
    
    // Hide the header
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDidStopSelector:@selector(stopLoadingComplete:finished:context:)];
    self.tableView.contentInset = UIEdgeInsetsZero;
    UIEdgeInsets tableContentInset = self.tableView.contentInset;
    tableContentInset.top = 0.0;
    self.tableView.contentInset = tableContentInset;
    [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    [UIView commitAnimations];
  }
}

- (void)stopLoadingComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
  // Reset the header
  refreshLabel.text = self.textPull;
  refreshArrow.hidden = NO;
  [refreshSpinner stopAnimating];
}

- (void)refresh {
  // This is just a demo. Override this method with your custom reload action.
  // Don't forget to call stopLoading at the end.
  [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
}

- (void)dealloc {
  [_tableView release];
  [refreshHeaderView release];
  [refreshLabel release];
  [refreshArrow release];
  [refreshSpinner release];
  [textPull release];
  [textRelease release];
  [textLoading release];
  [super dealloc];
}

@end
