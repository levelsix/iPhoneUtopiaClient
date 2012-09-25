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
#import "GameState.h"

@implementation ChatLineView

@synthesize factionLabel, textLabel, hasBeenUsed;

- (void) updateForChat:(ChatMessage *)chat {
  self.hasBeenUsed = YES;
  self.factionLabel.text = [Globals userTypeIsGood:chat.sender.userType] ? @"[A]" : @"[L]";
  self.factionLabel.textColor = [Globals userTypeIsGood:chat.sender.userType] ? [Globals blueColor] : [Globals redColor];
  self.textLabel.text = [NSString stringWithFormat:@"%@: %@", [Globals fullNameWithName:chat.sender.name clanTag:chat.sender.clan.tag], chat.message];
}

- (void) updateForNotification:(NSString *)string {
  self.hasBeenUsed = YES;
  self.factionLabel.text = string;
  self.factionLabel.textColor = [Globals goldColor];
  self.textLabel.text = nil;
}

- (void) dealloc {
  self.factionLabel = nil;
  self.textLabel = nil;
  [super dealloc];
}

@end

@implementation ChatBottomView

@synthesize chatView1, chatView2, chatView3;
@synthesize globalIcon, clanIcon, isGlobal;
@synthesize mainView;

- (void) awakeFromNib {
  [self.mainView addSubview:chatView3];
  self.chatView1.hidden = YES;
  self.chatView2.hidden = YES;
  self.chatView3.hidden = YES;
  self.isGlobal = YES;
}

- (void) setIsGlobal:(BOOL)i {
  isGlobal = i;
  
  GameState *gs = [GameState sharedGameState];
  NSArray *arr = nil;
  if (isGlobal) {
    globalIcon.hidden = NO;
    clanIcon.hidden = YES;
    arr = gs.globalChatMessages;
  } else {
    globalIcon.hidden = YES;
    clanIcon.hidden = NO;
    arr = gs.clanChatMessages;
  }
  self.chatView1.hidden = YES;
  self.chatView2.hidden = YES;
  self.chatView3.hidden = YES;
  self.chatView1.hasBeenUsed = NO;
  self.chatView2.hasBeenUsed = NO;
  self.chatView3.hasBeenUsed = NO;
  
  if (arr.count >= 2) {
    [self addChat:[arr objectAtIndex:arr.count-2]];
  } else {
    [self addNotification:[NSString stringWithFormat:@"You have entered %@ chat!", isGlobal?@"Global":@"Clan"]];
  }
  if (arr.count >= 1) {
    [self addChat:arr.lastObject];
  }
}

- (void) addChat:(ChatMessage *)chat orNotification:(NSString *)notification {
  // Check if 1 and 2 have been used
  ChatLineView *clView = nil;
  if (!self.chatView1.hasBeenUsed) {
    clView = self.chatView1;
  } else if (!self.chatView2.hasBeenUsed) {
    clView = self.chatView2;
  }
  
  if (clView) {
    if (chat) [clView updateForChat:chat];
    else if (notification) [clView updateForNotification:notification];
    clView.hidden = NO;
    clView.alpha = 0.f;
    [UIView animateWithDuration:0.2f animations:^{
      clView.alpha = 1.f;
    }];
  } else {
    clView = self.chatView3;
    clView.hidden = NO;
    if (chat) [clView updateForChat:chat];
    else if (notification) [clView updateForNotification:notification];
    
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

- (void) addChat:(ChatMessage *)chat {
  [self addChat:chat orNotification:nil];
}

- (void) addNotification:(NSString *)notification {
  [self addChat:nil orNotification:notification];
}

- (IBAction)toggleChatMode:(id)sender {
  GameState *gs = [GameState sharedGameState];
  if (isGlobal && !gs.clan) {
    [self addNotification:@"Join a clan to chat with them!"];
    [self addNotification:@"You are in Global chat!"];
  } else {
    self.isGlobal = !isGlobal;
  }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint pt = [touch locationInView:self];
  
  if ([self pointInside:pt withEvent:event]) {
    [ChatMenuController displayView];
    [[ChatMenuController sharedChatMenuController] setIsGlobal:self.isGlobal];
  }
}

- (void) dealloc {
  self.chatView1 = nil;
  self.chatView2 = nil;
  self.chatView3 = nil;
  self.globalIcon = nil;
  self.clanIcon = nil;
  self.mainView = nil;
  [super dealloc];
}

@end
