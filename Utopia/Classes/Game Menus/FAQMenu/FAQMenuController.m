//
//  FAQMenuController.m
//  Utopia
//
//  Created by Ashwin Kamath on 4/19/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "FAQMenuController.h"
#import "Globals.h"
#import "LNSynthesizeSingleton.h"
#import "cocos2d.h"
#import "GameState.h"
#import "GameViewController.h"
#import "SoundEngine.h"

#define FAQ_FILE_NAME @"FAQ.2.txt"
#define PRESTIGE_FAQ_FILE_NAME @"PrestigeFAQ.txt"

#define SECTION_IDENTIFIER @"Section"
#define QUESTION_IDENTIFIER @"Question"
#define TEXT_IDENTIFIER @"Text"
#define NEWLINE_IDENTIFIER @"Newline"

#define HEADER_SUFFIX @"<h>"
#define SECTION_SUFFIX @"<s>"
#define QUESTION_SUFFIX @"?"
#define REPLACEMENT_DELIMITER @"`"
#define LABEL_TAG 51

#define SECTION_FONT_SIZE 20
#define TEXT_FONT_SIZE 14
#define QUESTION_FONT_SIZE 13

#define TEXT_LEFT_RIGHT_OFFSET 20
#define NEWLINE_VERTICAL_SPACING 10

@implementation FAQMenuController

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(FAQMenuController);

@synthesize textStrings;
@synthesize mainView, bgdView;

- (void) viewDidLoad {
  [super viewDidLoad];
  
  self.settingsView.frame = self.faqView.frame;
  [self.mainView addSubview:self.settingsView];
  
  self.settingsView.hidden = YES;
}

- (void) viewWillAppear:(BOOL)animated {
  if (!self.view.superview) {
    [super viewWillAppear:animated];
    [Globals bounceView:self.mainView fadeInBgdView:self.bgdView];
    
    self.faqTable.contentOffset = ccp(0,0);
  }
}

- (void) loadFAQ {
  Globals *gl = [Globals sharedGlobals];
  [self loadFile:gl.faqFileName];
  self.titleLabel.text = @"Help";
  
  self.settingsView.hidden = YES;
  self.faqView.hidden = NO;
}

- (void) loadPrestigeInfo {
  Globals *gl = [Globals sharedGlobals];
  [self loadFile:gl.prestigeFaqFileName];
  self.titleLabel.text = @"Prestige Info";
  
  self.settingsView.hidden = YES;
  self.faqView.hidden = NO;
}

- (void) loadSettings {
  self.titleLabel.text = @"Settings";
  
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  self.musicSwitchButton.isOn = ![ud boolForKey:MUSIC_DEFAULTS_KEY];
  self.soundEffectsSwitchButton.isOn = ![ud boolForKey:SOUND_EFFECTS_DEFAULTS_KEY];
  self.shakeSwitchButton.isOn = [ud boolForKey:SHAKE_DEFAULTS_KEY];
  
  self.settingsView.hidden = NO;
  self.faqView.hidden = YES;
}

- (void) switchButtonWasTurnedOn:(SwitchButton *)b {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  if (b.tag == 1) {
    [ud setBool:NO forKey:MUSIC_DEFAULTS_KEY];
    [[SoundEngine sharedSoundEngine] resumeBackgroundMusic];
  } else if (b.tag == 2) {
    [ud setBool:NO forKey:SOUND_EFFECTS_DEFAULTS_KEY];
  } else if (b.tag == 3) {
    [ud setBool:YES forKey:SHAKE_DEFAULTS_KEY];
  }
}

- (void) switchButtonWasTurnedOff:(SwitchButton *)b {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  if (b.tag == 1) {
    [ud setBool:YES forKey:MUSIC_DEFAULTS_KEY];
    [[SoundEngine sharedSoundEngine] stopBackgroundMusic];
  } else if (b.tag == 2) {
    [ud setBool:YES forKey:SOUND_EFFECTS_DEFAULTS_KEY];
  } else if (b.tag == 3) {
    [ud setBool:NO forKey:SHAKE_DEFAULTS_KEY];
  }
}

- (void) loadFile:(NSString *)file {
  [self parseFile:file];
  [self.faqTable reloadData];
}

- (NSString *) replaceDelimitersInString:(NSString *)line {
  Globals *gl = [Globals sharedGlobals];
  while (true) {
    NSRange delimStart = [line rangeOfString:REPLACEMENT_DELIMITER];
    if (delimStart.location == NSNotFound) {
      break;
    }
    
    line = [line stringByReplacingCharactersInRange:delimStart withString:@""];
    NSRange delimEnd = [line rangeOfString:REPLACEMENT_DELIMITER];
    
    if (delimEnd.location == NSNotFound) {
      break;
    }
    
    line = [line stringByReplacingCharactersInRange:delimEnd withString:@""];
    NSString *val = [line substringWithRange:NSMakeRange(delimStart.location, delimEnd.location-delimStart.location)];
    id glVal = [gl performSelector:NSSelectorFromString(val)];
    // Get the letter right after the selector, it gives us the interpretation
    NSString *interp = [line substringWithRange:delimEnd];
    
    if ([interp isEqualToString:@"f"]) {
      float *x = (float *)&glVal;
      line = [line stringByReplacingOccurrencesOfString:[val stringByAppendingString:interp] withString:[NSString stringWithFormat:@"%d", (int)*x]];
    } else if ([interp isEqualToString:@"i"]) {
      int *x = (int *)&glVal;
      line = [line stringByReplacingOccurrencesOfString:[val stringByAppendingString:interp] withString:[NSString stringWithFormat:@"%d", *x]];
    } else if ([interp isEqualToString:@"p"]) {
      float *x = (float *)&glVal;
      line = [line stringByReplacingOccurrencesOfString:[val stringByAppendingString:interp] withString:[NSString stringWithFormat:@"%d", (int)((*x)*100)]];
    }
  }
  return line;
}

- (void) parseFile:(NSString *)faqFile {
  NSError *e;
  NSString* fileRoot = [Globals pathToFile:faqFile];
  NSString *fileContents = [NSString stringWithContentsOfFile:fileRoot encoding:NSUTF8StringEncoding error:&e];
  
  if (!fileContents) {
    DDLogError(@"fileContents is nil! error = %@", e);
    return;
  }
  
  NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
  
  NSMutableArray *text = [NSMutableArray array];
  NSMutableArray *curArr = nil;
  for (NSString *line in lines) {
    // Replace delimited strings with their proper constants..
    line = [self replaceDelimitersInString:line];
    
    if ([line hasSuffix:HEADER_SUFFIX]) {
      curArr = [NSMutableArray array];
      [text addObject:curArr];
      line = [line stringByReplacingOccurrencesOfString:HEADER_SUFFIX withString:@""];
      [curArr addObject:line];
    } else {
      [curArr addObject:line];
    }
  }
  self.textStrings = text;
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
  return self.textStrings.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 21.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIImageView *headerView = [[[UIImageView alloc] initWithImage:[Globals imageNamed:@"unlockedheader.png"]] autorelease];
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 1, 400, headerView.frame.size.height)];
  label.textColor = [Globals creamColor];
  label.font = [UIFont fontWithName:@"Trajan Pro" size:12];
  label.backgroundColor = [UIColor clearColor];
  [headerView addSubview:label];
  [label release];
  
  label.text = [[self.textStrings objectAtIndex:section] objectAtIndex:0];
  
  return headerView;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // First string is header title
  return [[self.textStrings objectAtIndex:section] count]-1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSArray *arr = [textStrings objectAtIndex:indexPath.section];
  NSString *text = [arr objectAtIndex:indexPath.row+1];
  
  BOOL isSectionTitle = NO;
  BOOL isQuestion = NO;
  BOOL isNewline = NO;
  NSString *reuseId = TEXT_IDENTIFIER;
  if (text.length == 0) {
    reuseId = NEWLINE_IDENTIFIER;
    isNewline = YES;
  } else if ([text hasSuffix:SECTION_SUFFIX]) {
    isSectionTitle = YES;
    text = [text stringByReplacingOccurrencesOfString:SECTION_SUFFIX withString:@""];
    reuseId = SECTION_IDENTIFIER;
  } else if ([text hasSuffix:QUESTION_SUFFIX]) {
    isQuestion = YES;
    reuseId = QUESTION_IDENTIFIER;
  }
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    [cell autorelease];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.tag = LABEL_TAG;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    [cell.contentView addSubview:label];
    [label release];
    
    if (!isNewline) {
      if (isSectionTitle) {
        label.font = [UIFont fontWithName:@"AJensonPro-BoldCapt" size:SECTION_FONT_SIZE];
        label.textColor = [Globals creamColor];
      } else if (isQuestion) {
        label.font = [UIFont fontWithName:@"AJensonPro-BoldCapt" size:QUESTION_FONT_SIZE];
        label.textColor = [Globals goldColor];
      } else {
        label.font = [UIFont fontWithName:@"AJensonPro-SemiboldDisp" size:TEXT_FONT_SIZE];
        label.textColor = [Globals creamColor];
      }
    }
  }
  
  UILabel *label = (UILabel *)[cell.contentView viewWithTag:LABEL_TAG];
  label.text = text;
  
  CGFloat height = [self tableView:tableView heightForRowAtIndexPath:indexPath];
  label.frame = CGRectMake(TEXT_LEFT_RIGHT_OFFSET,0,tableView.frame.size.width-2*TEXT_LEFT_RIGHT_OFFSET,height);
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSArray *arr = [textStrings objectAtIndex:indexPath.section];
  NSString *text = [arr objectAtIndex:indexPath.row+1];
  
  if (text.length == 0) {
    return NEWLINE_VERTICAL_SPACING;
  }
  
  UIFont *font = [UIFont fontWithName:@"AJensonPro-SemiboldDisp" size:TEXT_FONT_SIZE];
  
  if ([text hasSuffix:SECTION_SUFFIX]) {
    text = [text stringByReplacingOccurrencesOfString:SECTION_SUFFIX withString:@""];
    font = [UIFont fontWithName:@"AJensonPro-BoldCapt" size:SECTION_FONT_SIZE];
  } else if ([text hasSuffix:QUESTION_SUFFIX]) {
    font = [UIFont fontWithName:@"AJensonPro-BoldCapt" size:QUESTION_FONT_SIZE];
  }
  
  CGRect rect = CGRectMake(TEXT_LEFT_RIGHT_OFFSET,0,tableView.frame.size.width-2*TEXT_LEFT_RIGHT_OFFSET,9999);
  CGSize size = [text sizeWithFont:font constrainedToSize:rect.size];
  
  return size.height;
}

- (IBAction)emailButtonClicked:(id)sender {
#ifdef LEGENDS_OF_CHAOS
  NSString *e = @"support@bestfunfreegames.com";
#else
  NSString *e = @"support@lvl6.com";
#endif
  
  GameState *gs = [GameState sharedGameState];
  NSString *messageBody = [NSString stringWithFormat:@"\n\nSent by user %@ with referral code %@.", gs.name, gs.referralCode];
  if ([MFMailComposeViewController canSendMail]) {
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setToRecipients:[NSArray arrayWithObject:e]];
    
    [controller setMessageBody:messageBody isHTML:NO];
    if (controller) [[GameViewController sharedGameViewController] presentModalViewController:controller animated:YES];
    [controller release];
  } else {
    // Launches the Mail application on the device.
    
    NSString *email = [NSString stringWithFormat:@"mailto:%@?body=%@", e, messageBody];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
  }
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[controller.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)closeClicked:(id)sender {
  [Globals popOutView:self.mainView fadeOutBgdView:self.bgdView completion:^{
    [FAQMenuController removeView];
  }];
}

- (IBAction)forumButtonClicked:(id)sender {
#ifdef LEGENDS_OF_CHAOS
  NSString *forumLink = @"http://legendsofchaos.lefora.com/";
#else
  NSString *forumLink = @"http://forum.lvl6.com";
#endif
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:forumLink]];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  if (self.isViewLoaded && !self.view.superview) {
    self.view = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.textStrings = nil;
    self.mainView = nil;
    self.bgdView = nil;
    self.faqTable = nil;
    self.titleLabel = nil;
    self.faqView = nil;
    self.settingsView = nil;
  }
}

@end
