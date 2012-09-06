//
//  ChatBottomView.m
//  Utopia
//
//  Created by Ashwin Kamath on 9/5/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "ChatBottomView.h"
#import "ChatMenuController.h"
#import "Globals.h"

@implementation ChatLineView

@synthesize factionLabel, textLabel, hasBeenUsed;

- (void) updateForChat:(ChatMessage *)chat {
  self.hasBeenUsed = YES;
  self.factionLabel.text = [Globals userTypeIsGood:chat.sender.userType] ? @"[A]" : @"[L]";
  self.factionLabel.textColor = [Globals userTypeIsGood:chat.sender.userType] ? [Globals blueColor] : [Globals redColor];
  self.textLabel.text = [NSString stringWithFormat:@"%@: %@", chat.sender.name, chat.message];
}

- (void) dealloc {
  self.factionLabel = nil;
  self.textLabel = nil;
  [super dealloc];
}

@end

@implementation ChatBottomView

@synthesize chatView1, chatView2, chatView3;
@synthesize mainView;

- (void) awakeFromNib {
  [self.mainView addSubview:chatView3];
  self.chatView1.hidden = YES;
  self.chatView2.hidden = YES;
  self.chatView3.hidden = YES;
}

- (void) addChat:(ChatMessage *)chat {
  // Check if 1 and 2 have been used
  ChatLineView *clView = nil;
  if (!self.chatView1.hasBeenUsed) {
    clView = self.chatView1;
  } else if (!self.chatView2.hasBeenUsed) {
    clView = self.chatView2;
  }
  
  if (clView) {
    [clView updateForChat:chat];
    clView.hidden = NO;
    clView.alpha = 0.f;
    [UIView animateWithDuration:0.2f animations:^{
      clView.alpha = 1.f;
    }];
  } else {
    clView = self.chatView3;
    clView.hidden = NO;
    [clView updateForChat:chat];
    
    CGRect r = clView.frame;
    r.origin.y = self.mainView.frame.size.height;
    clView.frame = r;
    
    [UIView animateWithDuration:0.1f animations:^{
      ChatLineView *v = self.chatView1;
      CGRect r = v.frame;
      r.origin.y = -self.mainView.frame.size.height/2;
      v.frame = r;
      
      v = self.chatView2;
      r = v.frame;
      r.origin.y = 0;
      v.frame = r;
      
      v = self.chatView3;
      r = v.frame;
      r.origin.y = self.mainView.frame.size.height/2;
      v.frame = r;
    }];
    
    ChatLineView *v = self.chatView1;
    self.chatView1 = self.chatView2;
    self.chatView2 = self.chatView3;
    self.chatView3 = v;
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:self];
  
  if ([self pointInside:pt withEvent:event]) {
    [ChatMenuController displayView];
  }
}

- (void) dealloc {
  self.chatView1 = nil;
  self.chatView2 = nil;
  self.chatView3 = nil;
  self.mainView = nil;
  [super dealloc];
}

@end
