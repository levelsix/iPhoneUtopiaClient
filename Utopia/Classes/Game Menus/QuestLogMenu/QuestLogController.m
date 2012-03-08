//
//  QuestLogController.m
//  Utopia
//
//  Created by Ashwin Kamath on 1/17/12.
//  Copyright (c) 2012 LVL6. All rights reserved.
//

#import "QuestLogController.h"
#import "SynthesizeSingleton.h"
#import "GameState.h"
#import "Globals.h"
#import "OutgoingEventController.h"

#define QUEST_ITEM_HEIGHT 31.f

@implementation GradientScrollView

@synthesize topGradient, botGradient;
@synthesize timer;

- (void) awakeFromNib {
  self.delegate = self;
  [super awakeFromNib];
  self.showsVerticalScrollIndicator = NO;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
  GradientScrollView *gradScrollView = (GradientScrollView *)scrollView;
  gradScrollView.topGradient.frame = CGRectMake(gradScrollView.contentOffset.x, 
                                                gradScrollView.contentOffset.y, 
                                                self.contentSize.width, 
                                                gradScrollView.topGradient.frame.size.height);
  gradScrollView.botGradient.frame = CGRectMake(gradScrollView.contentOffset.x, 
                                                gradScrollView.contentOffset.y+gradScrollView.frame.size.height-gradScrollView.botGradient.frame.size.height, 
                                                self.contentSize.width, 
                                                gradScrollView.botGradient.frame.size.height);
  
  if  (self.timer == nil) {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60 target:self selector:@selector(updateCCDirector) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
  }
  [self setNeedsDisplay];
}

- (void) addSubview:(UIView *)view {
  [super addSubview:view];
  [self bringSubviewToFront:topGradient];
  [self bringSubviewToFront:botGradient];
}

- (void)updateCCDirector
{
  [[CCDirector sharedDirector] drawScene];
  if (!self.dragging && !self.decelerating) {
    [self.timer invalidate]; 
    self.timer = nil;
  }
}

- (void) dealloc {
  self.topGradient = nil;
  self.botGradient = nil;
  [self.timer invalidate];
  self.timer = nil;
  [super dealloc];
}

@end

@implementation QuestListScrollView

- (void) drawRect:(CGRect)rect {
  [super drawRect:rect];
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 0.35);
	
  CGFloat dashPattern[] = {3.f, 2.f};
	CGContextSetLineDash(context, 0, dashPattern, 2);
	
  int max = self.contentSize.height - self.botGradient.frame.size.height;
  for (int x = self.topGradient.frame.size.height+QUEST_ITEM_HEIGHT; x < max; x += QUEST_ITEM_HEIGHT) {
    CGContextMoveToPoint(context, 0.0, x);
    CGContextAddLineToPoint(context, self.frame.size.width, x);
  }
	// And width 2.0 so they are a bit more visible
  CGContextSetLineWidth(context, 0.5f);
	CGContextStrokePath(context);
}

@end

@implementation QuestItemView

@synthesize label, fqp;

- (id) initWithFrame:(CGRect)frame quest:(FullQuestProto *)f {
  if ((self = [super initWithFrame:frame])) {
    self.fqp = f;
    self.backgroundColor = [UIColor clearColor];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewClicked:)]];
    label = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, self.frame.size.width-20, self.frame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AJensonPro-SemiboldDisp" size:18];
    label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    label.textColor = [UIColor colorWithRed:170/256.f green:42/256.f blue:13/256.f alpha:1.f];
    [self addSubview:label];
    label.text = f.name;
  }
  return self;
}

- (void) viewClicked:(id)sender {
  [(QuestListView *)self.superview.superview viewClicked:self];
}

- (void) dealloc {
  [label release];
  [super dealloc];
}

@end

@implementation QuestListView

@synthesize questItemViews;
@synthesize curQuestsLabel;
@synthesize scrollView;

- (void) awakeFromNib {
  [super awakeFromNib];
  self.curQuestsLabel.font = [UIFont fontWithName:@"Adobe Jenson Pro" size:18];
  
  self.questItemViews = [NSMutableArray array];
}

- (void) refresh {
  GameState *gs = [GameState sharedGameState];
  
  [questItemViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [(UIView *)obj removeFromSuperview];
  }];
  [questItemViews removeAllObjects];
  
  [gs.inProgressQuests.allValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    UIView *view = [[QuestItemView alloc] initWithFrame:CGRectMake(0, QUEST_ITEM_HEIGHT*idx+self.scrollView.topGradient.frame.size.height, self.scrollView.frame.size.width, QUEST_ITEM_HEIGHT) quest:obj];
    [self.scrollView insertSubview:view atIndex:0];
    [self.questItemViews addObject:view];
    [view release];
  }];
  self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, QUEST_ITEM_HEIGHT*gs.inProgressQuests.allValues.count+self.scrollView.topGradient.frame.size.height+self.scrollView.botGradient.frame.size.height);
  
  [self.scrollView setNeedsDisplay];
  
  _clickedView = nil;
}

- (void) viewClicked:(QuestItemView *)sender {
  if (_clickedView == sender) {
    return;
  }
  
  _clickedView.backgroundColor = [UIColor clearColor];
  
  _clickedView = sender;
  _clickedView.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.5f];
  
  [[QuestLogController sharedQuestLogController] resetToQuestDescView:sender.fqp];
}

@end

@implementation RewardsView

@synthesize rewardLabel, coinRewardLabel, expLabel, expRewardLabel, rewardWebView;

- (void) awakeFromNib {
  UIFont *font = [UIFont fontWithName:@"AJensonPro-BoldCapt" size:14];
  self.rewardLabel.font = font;
  self.coinRewardLabel.font = font;
  self.expLabel.font = font;
  self.expRewardLabel.font = font;
  
  // Disable bouncing on the webview
  id scrollview = [rewardWebView.subviews objectAtIndex:0];
  if ([scrollview respondsToSelector:@selector(setBounces:)])
    [scrollview setBounces:NO];
  rewardWebView.backgroundColor = [UIColor clearColor];
  [self updateWebView];
  
  //  [[NSRunLoop mainRunLoop] addTimer:[NSTimer timerWithTimeInterval:2 target:self selector:@selector(updateWebView) userInfo:nil repeats:YES] forMode:NSRunLoopCommonModes];
}

- (void) updateWebView {
  NSLog(@"updating..");
  NSString *p = @"<style type=\"text/css\">"
  "#id1 {font-size:9px;font-family : AJensonPro-BoldCapt; -webkit-user-select: none;}"
  "g { color : green; } go { color : #FFCC00; } pi { color : #FF0099; }"
  "</style></head><body>"
  "<span id=\"id1\">%d%% chance of <g>Regular</g><br>"
  "%d%% chance of <go>Special</go><br>"
  "%d%% chance of <pi>Epic</pi></span>";
  
  p = [NSString stringWithFormat:p, arc4random()%100, arc4random()%40, arc4random()%5];
  [self.rewardWebView loadHTMLString:p baseURL:nil];
}

- (void) drawRect:(CGRect)rect {
  [super drawRect:rect];
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetRGBStrokeColor(context, 0.6, 0.6, 0.6, 1.0);
	
  // Draw two lines around rewards label
  float mid = self.rewardLabel.center.y-2;
  CGContextMoveToPoint(context, 0.0, mid-1);
  CGContextAddLineToPoint(context, self.rewardLabel.frame.origin.x, mid-1);
  CGContextMoveToPoint(context, CGRectGetMaxX(self.rewardLabel.frame), mid-1);
  CGContextAddLineToPoint(context, self.frame.size.width, mid-1);
  CGContextMoveToPoint(context, 0.0, mid+1);
  CGContextAddLineToPoint(context, self.rewardLabel.frame.origin.x, mid+1);
  CGContextMoveToPoint(context, CGRectGetMaxX(self.rewardLabel.frame), mid+1);
  CGContextAddLineToPoint(context, self.frame.size.width, mid+1);
  
  // Draw two lines at bottom
  mid = self.frame.size.height -5;
  CGContextMoveToPoint(context, 0.0, mid-1);
  CGContextAddLineToPoint(context, self.frame.size.width, mid-1);
  CGContextMoveToPoint(context, 0.0, mid+1);
  CGContextAddLineToPoint(context, self.frame.size.width, mid+1);
  
	CGContextStrokePath(context);
  
}

@end

@implementation QuestDescriptionView

@synthesize questNameLabel;
@synthesize rewardView;
@synthesize questDescLabel;
@synthesize scrollView;

- (void) awakeFromNib {
  self.questNameLabel.font = [UIFont fontWithName:@"AJensonPro-SemiboldDisp" size:18];
}

- (void) refreshWithQuest:(FullQuestProto *)fqp {
  [self.questDescLabel removeFromSuperview];
  
  self.questNameLabel.text = fqp.name;
  
  // Update the quest description label
  // We will find out how many lines need to be used, so init to zero
  UILabel *tmplabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.questDescLabel = tmplabel;
  [tmplabel release];
  self.questDescLabel.textColor = [UIColor blackColor];
  self.questDescLabel.font = [UIFont fontWithName:@"AJensonPro-SemiboldDisp" size:14];
  self.questDescLabel.numberOfLines = 0;
  self.questDescLabel.lineBreakMode = UILineBreakModeWordWrap;
  self.questDescLabel.text = fqp.description;
  self.questDescLabel.backgroundColor = [UIColor clearColor];
  
  //Calculate the expected size based on the font and linebreak mode of label
  CGSize maximumLabelSize = CGSizeMake(self.scrollView.frame.size.width-10, 9999);
  CGSize expectedLabelSize = [questDescLabel.text sizeWithFont:self.questDescLabel.font constrainedToSize:maximumLabelSize lineBreakMode:self.questDescLabel.lineBreakMode];
  
  //Adjust the label the the new height
  CGRect newFrame = self.questDescLabel.frame;
  newFrame.origin.y = self.scrollView.topGradient.frame.size.height;
  newFrame.size.width = expectedLabelSize.width;
  newFrame.size.height = expectedLabelSize.height;
  self.questDescLabel.frame = newFrame;
  [self.scrollView insertSubview:self.questDescLabel atIndex:0];
  
  newFrame = self.rewardView.frame;
  newFrame.origin = CGPointMake(0, CGRectGetMaxY(self.questDescLabel.frame));
  self.rewardView.frame = newFrame;
  
  self.rewardView.coinRewardLabel.text = [NSString stringWithFormat:@"+%d", fqp.coinsGained];
  self.rewardView.expRewardLabel.text = [NSString stringWithFormat:@"+%d", fqp.expGained];
  
  self.scrollView.contentOffset = CGPointMake(0, 0);
  self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(self.rewardView.frame)+self.scrollView.botGradient.frame.size.height);
}

@end

@implementation TaskItemView

@synthesize label, taskBar, bgdBar, visitButton;
@synthesize type, jobId;

- (id) initWithFrame:(CGRect)frame text: (NSString *)string taskFinished:(int)completed outOf:(int)total type:(TaskItemType)t jobId:(int)j {
  if ((self = [super initWithFrame:frame])) {
    CGRect tmpRect;
    self.backgroundColor = [UIColor clearColor];
    
    self.visitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *visit = [UIImage imageNamed:@"visit.png"];
    [self.visitButton setImage:visit forState:UIControlStateNormal];
    if (completed < total)
      [self addSubview:self.visitButton];
    
    // We will find out how many lines need to be used, so init to zero
    UILabel *tmplabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 0, 0)];
    self.label = tmplabel;
    [tmplabel release];
    self.label.textColor = [UIColor colorWithRed:107/256.f green:59/256.f blue:8/256.f alpha:1.f];
    self.label.font = [UIFont fontWithName:@"AJensonPro-BoldCapt" size:12];
    self.label.numberOfLines = 0;
    self.label.lineBreakMode = UILineBreakModeWordWrap;
    self.label.text = string;
    self.label.backgroundColor = [UIColor clearColor];
    
    //Calculate the expected size based on the font and linebreak mode of label
    CGSize maximumLabelSize = CGSizeMake(frame.size.width-visit.size.width-10, 9999);
    CGSize expectedLabelSize = [string sizeWithFont:self.label.font constrainedToSize:maximumLabelSize lineBreakMode:self.label.lineBreakMode];
    
    //Adjust the label the the new height
    CGRect newFrame = self.label.frame;
    newFrame.size.width = expectedLabelSize.width;
    newFrame.size.height = expectedLabelSize.height;
    self.label.frame = newFrame;
    [self addSubview:self.label];
    
    // Create the image view for the task bar
    UIImageView *tmpView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"taskbarinset.png"]];
    self.bgdBar = tmpView;
    [tmpView release];
    [self addSubview:tmpView];
    
    // Create the actual task bar and give it the correct percentage
    tmpView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"taskyellowbar.png"]];
    self.taskBar = tmpView;
    [tmpView release];
    self.taskBar.contentMode = UIViewContentModeLeft;
    tmpRect = self.taskBar.frame;
    tmpRect.origin = CGPointMake(2, 1);
    tmpRect.size.width *= ((float)completed)/total;
    self.taskBar.frame = tmpRect;
    self.taskBar.clipsToBounds = YES;
    [self.bgdBar addSubview:self.taskBar];
    
    // Add the segmentors for each total-1 spot
    UIImage *taskSeg = [UIImage imageNamed: @"tasksepline.png"];
    for (float i = 1.f; i < total; i+=1) {
      tmpView = [[UIImageView alloc] initWithImage:taskSeg];
      tmpView.center = CGPointMake(i/total*self.bgdBar.frame.size.width, self.bgdBar.frame.size.height/2);
      [self.bgdBar addSubview:tmpView];
      [tmpView release];
    }
    
    tmpRect = self.bgdBar.frame;
    tmpRect.origin.y = 0;
    tmpRect.origin.y = CGRectGetMaxY(self.label.frame);
    self.bgdBar.frame = tmpRect;
    
    tmpRect = self.frame;
    tmpRect.size.height = CGRectGetMaxY(self.bgdBar.frame)+10;
    self.frame = tmpRect;
    
    tmpRect = self.visitButton.frame;
    tmpRect.origin.x = self.frame.size.width-visit.size.width;
    tmpRect.origin.y = self.frame.size.height/2-visit.size.height/2;
    tmpRect.size = visit.size;
    self.visitButton.frame = tmpRect;
    
    self.type = t;
    self.jobId = j;
  }
  return self;
}

- (void) dealloc {
  self.label = nil;
  self.bgdBar = nil;
  self.taskBar = nil;
  self.visitButton = nil;
  [super dealloc];
}

@end

@implementation TaskListScrollView

- (void) drawRect:(CGRect)rect {
  [super drawRect:rect];
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetRGBStrokeColor(context, 175/256.f, 170/256.f, 125/256.f, 0.7);
	
  CGFloat dashPattern[] = {3.f, 2.f};
	CGContextSetLineDash(context, 0, dashPattern, 2);
  
	// And width 2.0 so they are a bit more visible
  CGContextSetLineWidth(context, 0.5f);
	
  for (UIView *view in self.subviews) {
    if (view == self.topGradient || view == self.botGradient) {
      break;
    }
    CGContextSetRGBStrokeColor(context, 175/256.f, 170/256.f, 125/256.f, 1.0);
    CGContextMoveToPoint(context, 0.0, CGRectGetMaxY(view.frame));
    CGContextAddLineToPoint(context, self.frame.size.width, CGRectGetMaxY(view.frame));
    CGContextStrokePath(context);
    CGContextSetRGBStrokeColor(context, 1.0,1.0,1.0, 1.0);
    CGContextMoveToPoint(context, 0.0, CGRectGetMaxY(view.frame)+0.5);
    CGContextAddLineToPoint(context, self.frame.size.width, CGRectGetMaxY(view.frame)+0.5);
    CGContextStrokePath(context);
  }
}

@end

@implementation TaskListView

@synthesize taskItemViews;
@synthesize questNameLabel;
@synthesize scrollView;

- (void) awakeFromNib {
  self.questNameLabel.font = [UIFont fontWithName:@"AJensonPro-SemiboldDisp" size:18];
}

- (void) unloadTasks {
  [taskItemViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [(UIView *)obj removeFromSuperview];
  }];
  [taskItemViews removeAllObjects];
}

- (void) refreshWithQuestData:(FullUserQuestDataLargeProto *)data {
  [self unloadTasks];
  
  TaskItemView *tiv = nil;
  GameState *gs = [GameState sharedGameState];
  
  for (MinimumUserDefeatTypeJobProto *p in data.requiredDefeatTypeJobProgressList) {
    DefeatTypeJobProto *q = [gs getStaticDataFrom:gs.staticDefeatTypeJobs withId:p.defeatTypeJobId];
    tiv = [[TaskItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tiv.frame), self.scrollView.frame.size.width, 0) 
                                         text:[NSString stringWithFormat:@"Defeat %d %@ %@s", q.numEnemiesToDefeat, [Globals factionForUserType:q.typeOfEnemy], [Globals classForUserType:q.typeOfEnemy]]
                                 taskFinished:p.numDefeated
                                        outOf:q.numEnemiesToDefeat
                                         type:kDefeatTypeJob 
                                        jobId:p.defeatTypeJobId];
    [self.scrollView addSubview:tiv];
    [taskItemViews addObject:tiv];
    [tiv release];
  }
  
  for (MinimumUserQuestTaskProto *p in data.requiredTasksProgressList) {
    FullTaskProto *q = [gs getStaticDataFrom:gs.staticTasks withId:p.taskId];
    tiv = [[TaskItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tiv.frame), self.scrollView.frame.size.width, 0) 
                                         text:q.name 
                                 taskFinished:p.numTimesActed
                                        outOf:q.numRequiredForCompletion
                                         type:kTask 
                                        jobId:p.taskId];
    [self.scrollView addSubview:tiv];
    [taskItemViews addObject:tiv];
    [tiv release];
  }
  
  for (MinimumUserPossessEquipJobProto *p in data.requiredPossessEquipJobProgressList) {
    PossessEquipJobProto *q = [gs getStaticDataFrom:gs.staticPossessEquipJobs withId:p.possessEquipJobId];
    FullEquipProto *r = [gs equipWithId:q.equipId];
    tiv = [[TaskItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tiv.frame), self.scrollView.frame.size.width, 0) 
                                         text:[NSString stringWithFormat:@"Attain %@%@", r.name, q.quantityReq == 1 ? @"" : [NSString stringWithFormat:@" (%d)", q.quantityReq]]
                                 taskFinished:p.numEquipUserHas
                                        outOf:q.quantityReq
                                         type:kPossessEquipJob 
                                        jobId:p.possessEquipJobId];
    [self.scrollView addSubview:tiv];
    [taskItemViews addObject:tiv];
    [tiv release];
  }
  
  for (MinimumUserBuildStructJobProto *p in data.requiredBuildStructJobProgressList) {
    BuildStructJobProto *q = [gs getStaticDataFrom:gs.staticBuildStructJobs withId:p.buildStructJobId];
    FullStructureProto *r = [gs structWithId:q.structId];
    tiv = [[TaskItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tiv.frame), self.scrollView.frame.size.width, 0) 
                                         text:[NSString stringWithFormat:@"Build %@%@", r.name, q.quantityRequired == 1 ? @"" : [NSString stringWithFormat:@" (%d)", q.quantityRequired]]
                                 taskFinished:p.numOfStructUserHas
                                        outOf:q.quantityRequired
                                         type:kBuildStructJob 
                                        jobId:p.buildStructJobId];
    [self.scrollView addSubview:tiv];
    [taskItemViews addObject:tiv];
    [tiv release];
  }
  
  for (MinimumUserUpgradeStructJobProto *p in data.requiredUpgradeStructJobProgressList) {
    UpgradeStructJobProto *q = [gs getStaticDataFrom:gs.staticUpgradeStructJobs withId:p.upgradeStructJobId];
    FullStructureProto *r = [gs structWithId:q.structId];
    tiv = [[TaskItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tiv.frame), self.scrollView.frame.size.width, 0) 
                                         text:[NSString stringWithFormat:@"Upgrade %@ to Level %d", r.name, q.levelReq]
                                 taskFinished:p.currentLevel
                                        outOf:q.levelReq
                                         type:kUpgradeStructJob 
                                        jobId:p.upgradeStructJobId];
    [self.scrollView addSubview:tiv];
    [taskItemViews addObject:tiv];
    [tiv release];
  }
}

@end


@implementation QuestLogController

@synthesize taskView, questDescView, questListView, userLogData;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(QuestLogController);

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  taskView.alpha = 0.0;
  questDescView.alpha = 0.0;
}

- (void) viewDidAppear:(BOOL)animated {
  taskView.alpha = 0.0;
  questDescView.alpha = 0.0;
  [questListView viewClicked:nil];
  [questListView refresh];
  [[OutgoingEventController sharedOutgoingEventController] retrieveQuestLog];
  _curView = nil;
  self.userLogData = nil;
}

- (void) refreshWithQuests:(NSArray *)quests {
  self.userLogData = quests;
}

- (IBAction)closeButtonClicked:(id)sender {
  [QuestLogController removeView];
}

- (IBAction)taskButtonTapped:(id)sender {
  [UIView animateWithDuration:0.5 animations:^{
    self.questDescView.alpha = 0.0;
    self.taskView.alpha = 1.0;
  }];
  _curView = self.taskView;
}

- (IBAction)questDescButtonTapped:(id)sender {
  [UIView animateWithDuration:0.5 animations:^{
    self.questDescView.alpha = 1.0;
    self.taskView.alpha = 0.0;
  }];
  _curView = self.questDescView;
}

- (void)resetToQuestDescView:(FullQuestProto *)fqp {
  [self.questDescView refreshWithQuest:fqp];
  if (_curView == self.questDescView) {
  } else {
    [UIView animateWithDuration:0.5 animations:^{
      self.questDescView.alpha = 1.0;
      self.taskView.alpha = 0.0;
    }];
  }
  _curView = self.questDescView;
  
  FullUserQuestDataLargeProto *quest = nil;
  for (FullUserQuestDataLargeProto *q in self.userLogData) {
    if (q.questId == fqp.questId) {
      quest = q;
      break;
    }
  }
  
if (quest) {
  [self.taskView refreshWithQuestData:quest];
}
}

- (void)viewDidUnload
{
  self.questDescView = nil;
  self.taskView = nil;
  [super viewDidUnload];
}

@end
