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
#import "GameLayer.h"
#import "HomeMap.h"

#define QUEST_ITEM_HEIGHT 31.f


@implementation QuestCompleteView

@synthesize questNameLabel, visitDescLabel;

- (IBAction)okayClicked:(id)sender {
  [self removeFromSuperview];
}

- (void) dealloc {
  self.questNameLabel = nil;
  self.visitDescLabel = nil;
  [super dealloc];
}

@end


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
    [self addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewClicked:)] autorelease]];
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
  self.label = nil;
  self.fqp = nil;
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
  
  if (_clickedView) {
    _clickedView.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.5f];
    
    [[QuestLogController sharedQuestLogController] resetToQuestDescView:sender.fqp];
  }
}

- (void) dealloc {
  self.questItemViews = nil;
  self.curQuestsLabel = nil;
  self.scrollView = nil;
  [super dealloc];
}

@end

@implementation RewardsView

@synthesize rewardLabel, coinRewardLabel, expLabel, expRewardLabel;
@synthesize equipIcon, equipView, equipAttLabel, equipDefLabel, equipNameLabel;

- (void) awakeFromNib {
  UIFont *font = [UIFont fontWithName:@"AJensonPro-BoldCapt" size:14];
  self.rewardLabel.font = font;
  self.coinRewardLabel.font = font;
  self.expLabel.font = font;
  self.expRewardLabel.font = font;
}

- (void) setFrame:(CGRect)frame {
  [super setFrame:frame];
  [self setNeedsDisplay];
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

- (void) updateForQuest:(FullQuestProto *)fqp {
  coinRewardLabel.text = [NSString stringWithFormat:@"+%d", fqp.coinsGained];
  expRewardLabel.text = [NSString stringWithFormat:@"+%d", fqp.expGained];
  
  if (fqp.equipIdGained != 0) {
    FullEquipProto *fep = [[GameState sharedGameState] equipWithId:fqp.equipIdGained];
    equipIcon.image = [Globals imageForEquip:fep.equipId];
    equipNameLabel.text = fep.name;
    equipNameLabel.textColor = [Globals colorForRarity:fep.rarity];
    equipAttLabel.text = [NSString stringWithFormat:@"%d", fep.attackBoost];
    equipDefLabel.text = [NSString stringWithFormat:@"%d", fep.defenseBoost];
    
    equipView.hidden = NO;
    
    CGRect rect = self.frame;
    rect.size.height = CGRectGetMaxY(equipView.frame) + 10;
    self.frame = rect;
  } else {
    equipView.hidden = YES;
    
    CGRect rect = self.frame;
    rect.size.height = equipView.frame.origin.y + 10;
    self.frame = rect;
  }
}

- (void) dealloc {
  self.rewardLabel = nil;
  self.coinRewardLabel = nil;
  self.expLabel = nil;
  self.expRewardLabel = nil;
  self.equipIcon = nil;
  self.equipView = nil;
  self.equipAttLabel = nil;
  self.equipDefLabel = nil;
  self.equipNameLabel = nil;
  [super dealloc];
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
  self.questNameLabel.text = fqp.name;
  [self.rewardView updateForQuest:fqp];
  [self setQuestDescription:fqp.description];
}

- (void) setQuestDescription:(NSString *)description {
  [self.questDescLabel removeFromSuperview];
  
  // Update the quest description label
  // We will find out how many lines need to be used, so init to zero
  UILabel *tmplabel = [[UILabel alloc] initWithFrame:CGRectZero];
  self.questDescLabel = tmplabel;
  [tmplabel release];
  self.questDescLabel.text = description;
  self.questDescLabel.textColor = [UIColor blackColor];
  self.questDescLabel.font = [UIFont fontWithName:@"AJensonPro-SemiboldDisp" size:14];
  self.questDescLabel.numberOfLines = 0;
  self.questDescLabel.lineBreakMode = UILineBreakModeWordWrap;
  self.questDescLabel.backgroundColor = [UIColor clearColor];
  
  //Calculate the expected size based on the font and linebreak mode of label
  CGSize maximumLabelSize = CGSizeMake(self.scrollView.frame.size.width-10, 9999);
  CGSize expectedLabelSize = [questDescLabel.text sizeWithFont:self.questDescLabel.font constrainedToSize:maximumLabelSize lineBreakMode:self.questDescLabel.lineBreakMode];
  
  //Adjust the label the the new height
  CGRect newFrame = self.questDescLabel.frame;
  newFrame.origin.x = 5;
  newFrame.origin.y = self.scrollView.topGradient.frame.size.height;
  newFrame.size.width = expectedLabelSize.width;
  newFrame.size.height = expectedLabelSize.height;
  self.questDescLabel.frame = newFrame;
  [self.scrollView insertSubview:self.questDescLabel atIndex:0];
  
  newFrame = self.rewardView.frame;
  newFrame.origin = CGPointMake(0, CGRectGetMaxY(self.questDescLabel.frame));
  self.rewardView.frame = newFrame;
  
  self.scrollView.contentOffset = CGPointMake(0, 0);
  self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(self.rewardView.frame)+self.scrollView.botGradient.frame.size.height);
}

- (void) dealloc {
  self.questNameLabel = nil;
  self.rewardView = nil;
  self.questDescLabel = nil;
  self.scrollView = nil;
  [super dealloc];
}

@end

@implementation TaskItemView

@synthesize label, taskBar, bgdBar, visitButton;
@synthesize type, jobId;

- (id) initWithFrame:(CGRect)frame text: (NSString *)string taskFinished:(int)completed outOf:(int)total type:(TaskItemType)t jobId:(int)j {
  if ((self = [super initWithFrame:frame])) {
    CGRect tmpRect;
    self.backgroundColor = [UIColor clearColor];
    
    self.type = t;
    self.jobId = j;
    
    UIImage *visit = nil;
    if (t != kPossessEquipJob && completed < total && jobId != 0) {
      self.visitButton = [UIButton buttonWithType:UIButtonTypeCustom];
      visit = [Globals imageNamed:@"visit.png"];
      [self.visitButton setImage:visit forState:UIControlStateNormal];
      [self.visitButton addTarget:self action:@selector(visitClicked) forControlEvents:UIControlEventTouchUpInside];
      [self addSubview:self.visitButton];
    }
    
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
    UIImageView *tmpView = [[UIImageView alloc] initWithImage:[Globals imageNamed: @"taskbarinset.png"]];
    self.bgdBar = tmpView;
    [tmpView release];
    [self addSubview:tmpView];
    
    // Create the actual task bar and give it the correct percentage
    tmpView = [[UIImageView alloc] initWithImage:[Globals imageNamed: @"taskyellowbar.png"]];
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
    UIImage *taskSeg = [Globals imageNamed: @"tasksepline.png"];
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
  }
  return self;
}

- (void) visitClicked {
  GameState *gs = [GameState sharedGameState];
  
  if (type == kTask) {
    FullTaskProto *ftp = [gs taskWithId:jobId];
    [[OutgoingEventController sharedOutgoingEventController] loadNeutralCity:ftp.cityId asset:ftp.assetNumWithinCity];
    [[QuestLogController sharedQuestLogController] closeButtonClicked:nil];
  } else if (type == kDefeatTypeJob) {
    DefeatTypeJobProto *p = [gs.staticDefeatTypeJobs objectForKey:[NSNumber numberWithInt:jobId]];
    [[OutgoingEventController sharedOutgoingEventController] loadNeutralCity:p.cityId enemyType:p.typeOfEnemy];
  } else if (type == kUpgradeStructJob) {
    UpgradeStructJobProto *p = [gs.staticUpgradeStructJobs objectForKey:[NSNumber numberWithInt:jobId]];
    [[GameLayer sharedGameLayer] loadHomeMap];
    [[HomeMap sharedHomeMap] moveToStruct:p.structId];
  } else if (type == kBuildStructJob) {
    [[GameLayer sharedGameLayer] loadHomeMap];
    [[HomeMap sharedHomeMap] moveToCritStruct:CritStructTypeCarpenter];
  }
  [[QuestLogController sharedQuestLogController] closeButtonClicked:nil];
  
  [Analytics clickedVisit];
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
  
  self.taskItemViews = [NSMutableArray array];
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
                                         text:[NSString stringWithFormat:@"Defeat %d %@ %@%@ in %@", q.numEnemiesToDefeat, [Globals factionForUserType:q.typeOfEnemy], [Globals classForUserType:q.typeOfEnemy], q.numEnemiesToDefeat == 1 ? @"" : @"s", [gs cityWithId:q.cityId].name]
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
  
  self.scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, CGRectGetMaxY([[taskItemViews lastObject] frame]));
  self.scrollView.scrollEnabled = self.scrollView.contentSize.height > self.scrollView.frame.size.height;
}

- (void) dealloc {
  self.taskItemViews = nil;
  self.scrollView = nil;
  self.questNameLabel = nil;
  [super dealloc];
}

@end


@implementation QuestLogController

@synthesize taskView, questDescView, questListView, userLogData, rightPage;
@synthesize redeemButton, redeemLabel, toTaskButton, acceptButtons, qcView;

SYNTHESIZE_SINGLETON_FOR_CONTROLLER(QuestLogController);

#pragma mark - View lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  taskView.alpha = 0.0;
  questDescView.alpha = 0.0;
  [questDescView addSubview:redeemButton];
  [questDescView addSubview:acceptButtons];
  // Other button has tag in 15
  redeemButton.center = toTaskButton.center;
  acceptButtons.center = toTaskButton.center;
}

- (void) viewWillAppear:(BOOL)animated {
  CGRect r = rightPage.frame;
  r.origin.x = CGRectGetMaxX(questListView.frame)-5;
  r.origin.y = CGRectGetMinY(questListView.frame)-16;
  rightPage.frame = r;
  [self.view addSubview:rightPage];
  
  taskView.alpha = 0.0;
  questDescView.alpha = 0.0;
  [questListView viewClicked:nil];
  [questListView refresh];
  
  [[OutgoingEventController sharedOutgoingEventController] retrieveQuestLog];
  _curView = nil;
  self.userLogData = nil;
  _fqp = nil;
  
  redeemButton.hidden = YES;
  acceptButtons.hidden = YES;
  toTaskButton.hidden = NO;
  
  [taskView unloadTasks];
  
  rightPage.alpha = 1.f;
  
  self.view.alpha = 0.f;
  [UIView animateWithDuration:0.5f animations:^{
    self.view.alpha = 1.f;
  }];
}

- (void) displayRightPageForQuest:(FullQuestProto *)fqp inProgress:(BOOL)inProgress {
  if (fqp == nil) {
    LNLog(@"nil quest for displaying right page");
    return;
  }
  // Need to do this in case 
  [self view];
  
  CGRect r = rightPage.frame;
  r.origin.x = 265;
  r.origin.y = 12;
  rightPage.frame = r;
  [questDescView refreshWithQuest:fqp];
  [[[[CCDirector sharedDirector] openGLView] superview] addSubview:rightPage];
  questDescView.alpha = 1.f;
  taskView.alpha = 0.f;
  redeemButton.hidden = YES;
  acceptButtons.hidden = inProgress;
  toTaskButton.hidden = YES;
  _fqp = fqp;
  
  [taskView unloadTasks];
  
  rightPage.alpha = 0.f;
  [UIView animateWithDuration:0.5f animations:^{
    rightPage.alpha = 1.f;
  }];
}

- (void) loadQuestData:(NSArray *)quests {
  self.userLogData = quests;
  [self reloadTaskView:_fqp];
  
  FullUserQuestDataLargeProto *quest = nil;
  for (FullUserQuestDataLargeProto *q in self.userLogData) {
    if (q.questId == _fqp.questId) {
      quest = q;
      break;
    }
  }
  
  if (quest && quest.isComplete) {
    redeemButton.hidden = NO;
    redeemLabel.text = @"Redeem";
    toTaskButton.hidden = YES;
  } else {
    redeemButton.hidden = YES;
    toTaskButton.hidden = NO;
  }
}

- (IBAction)closeButtonClicked:(id)sender {
  if (!_closing) {
    _closing = YES;
    [UIView animateWithDuration:0.5f animations:^{
      if (self.view.superview) {
        self.view.alpha = 0.f;
      } else {
        self.rightPage.alpha = 0.f;
      }
    } completion:^(BOOL finished) {
      if (self.view.superview) {
        [QuestLogController removeView];
      } else {
        [self.rightPage removeFromSuperview];
      }
      _closing = NO;
    }];
    
    [[GameLayer sharedGameLayer] closeMenus];
  }
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

- (IBAction)redeemTapped:(id)sender {
  if ([redeemLabel.text isEqualToString:@"Redeem"]) {
    [[OutgoingEventController sharedOutgoingEventController] redeemQuest:_fqp.questId];
    
    redeemLabel.text = @"Quest Complete";
    [self.questDescView setQuestDescription:_fqp.doneResponse];
  } else {
    [self closeButtonClicked:nil];
  }
}

- (void) createFakeUserQuestData {
  
  // Lets create a fake FullUserQuestDataLarge for this quest
  GameState *gs = [GameState sharedGameState];
  FullUserQuestDataLargeProto_Builder *bldr = [FullUserQuestDataLargeProto builder];
  bldr.userId = gs.userId;
  bldr.questId = _fqp.questId;
  bldr.isRedeemed = NO;
  bldr.isComplete = NO;
  
  for (NSNumber *n in _fqp.defeatTypeReqsList) {
    MinimumUserDefeatTypeJobProto_Builder *b = [MinimumUserDefeatTypeJobProto builder];
    b.defeatTypeJobId = n.intValue;
    b.userId = gs.userId;
    b.questId = _fqp.questId;
    b.numDefeated = 0;
    [bldr addRequiredDefeatTypeJobProgress:[b build]];
  }
  for (NSNumber *n in _fqp.taskReqsList) {
    MinimumUserQuestTaskProto_Builder *b = [MinimumUserQuestTaskProto builder];
    b.taskId = n.intValue;
    b.userId = gs.userId;
    b.questId = _fqp.questId;
    b.numTimesActed = 0;
    [bldr addRequiredTasksProgress:[b build]];
  }
  for (NSNumber *n in _fqp.possessEquipJobReqsList) {
    MinimumUserPossessEquipJobProto_Builder *b = [MinimumUserPossessEquipJobProto builder];
    b.possessEquipJobId = n.intValue;
    b.userId = gs.userId;
    b.questId = _fqp.questId;
    b.numEquipUserHas = 0;
    [bldr addRequiredPossessEquipJobProgress:[b build]];
  }
  for (NSNumber *n in _fqp.buildStructJobsReqsList) {
    MinimumUserBuildStructJobProto_Builder *b = [MinimumUserBuildStructJobProto builder];
    b.buildStructJobId = n.intValue;
    b.userId = gs.userId;
    b.questId = _fqp.questId;
    b.numOfStructUserHas = 0;
    [bldr addRequiredBuildStructJobProgress:[b build]];
  }
  for (NSNumber *n in _fqp.upgradeStructJobsReqsList) {
    MinimumUserUpgradeStructJobProto_Builder *b = [MinimumUserUpgradeStructJobProto builder];
    b.upgradeStructJobId = n.intValue;
    b.userId = gs.userId;
    b.questId = _fqp.questId;
    b.currentLevel = 0;
    [bldr addRequiredUpgradeStructJobProgress:[b build]];
  }
  self.userLogData = [NSArray arrayWithObject:[bldr build]];
}

- (IBAction)acceptTapped:(id)sender {
  [[OutgoingEventController sharedOutgoingEventController] acceptQuest:_fqp.questId];
  
  [self createFakeUserQuestData];
  
  [self reloadTaskView:_fqp];
  self.acceptButtons.hidden = YES;
  self.toTaskButton.hidden = NO;
  [self taskButtonTapped:nil];
}

- (void) reloadTaskView:(FullQuestProto *)fqp {
  FullUserQuestDataLargeProto *quest = nil;
  for (FullUserQuestDataLargeProto *q in self.userLogData) {
    if (q.questId == fqp.questId) {
      quest = q;
      break;
    }
  }
  
  [self.taskView refreshWithQuestData:quest];
}

- (void)resetToQuestDescView:(FullQuestProto *)fqp {
  [self.questDescView refreshWithQuest:fqp];
  
  if (_curView == self.questDescView) {
    [self reloadTaskView:fqp];
  } else {
    [UIView animateWithDuration:0.5 animations:^{
      self.questDescView.alpha = 1.0;
      self.taskView.alpha = 0.0;
    } completion:^(BOOL finished) {
      [self reloadTaskView:fqp];
    }];
  }
  _fqp = fqp;
  _curView = self.questDescView;
}

- (QuestCompleteView *) createQuestCompleteView {
  [[NSBundle mainBundle] loadNibNamed:@"QuestCompleteView" owner:self options:nil];
  QuestCompleteView *q = [self.qcView retain];
  self.qcView = nil;
  return [q autorelease];
}

+ (void) cleanupAndPurgeSingleton {
  if (sharedQuestLogController) {
    [sharedQuestLogController.rightPage removeFromSuperview];
    [QuestLogController removeView];
    [QuestLogController purgeSingleton];
  }
}

- (void) didReceiveMemoryWarning {
  if (rightPage.superview) {
    return;
  }
  
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  
  self.questDescView = nil;
  self.taskView = nil;
  self.userLogData = nil;
  self.rightPage = nil;
  self.questListView = nil;
  self.redeemButton = nil;
  self.qcView = nil;
  self.redeemLabel = nil;
}

@end
