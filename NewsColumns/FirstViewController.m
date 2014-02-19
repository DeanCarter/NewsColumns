//
//  FirstViewController.m
//  NewsColumns
//
//  Created by Dean on 14-2-16.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import "FirstViewController.h"
#import "FMSectionEditView.h"
#import "FirstItemView.h"

#import "FMLauncherView.h"


@interface FirstViewController ()<FMLauncherViewDataSource,FMLauncherViewDelegate>
@property (retain, nonatomic) IBOutlet UIButton *backBtn;
@property (retain, nonatomic) NSMutableArray *selectedArray;
@property (retain, nonatomic) NSMutableArray *candidateArray;

@property (retain, nonatomic) IBOutlet FMLauncherView *sectionEditView;

@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.selectedArray = [NSMutableArray arrayWithObjects:@"头条",@"娱乐",@"财经",@"科技",@"手机",@"北京",@"军事",@"游戏",@"汽车",@"轻松一刻",@"房产",@"时尚",@"历史",nil];
    
    self.candidateArray = [NSMutableArray arrayWithObjects:@"电影",@"体育",@"彩票",@"移动互联",@"教育",@"CBA",@"原创",@"养生",nil];

    
   // self.candidateArray = [NSMutableArray arrayWithObjects:@"电影",@"体育",@"彩票",@"微博",@"社会",@"本地",@"论坛",@"家居",@"真话",@"旅游",@"移动互联",@"教育",@"CBA",@"原创",@"养生",nil];
    
    self.sectionEditView.borderX = 5.f;
    self.sectionEditView.borderY = 5.f;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_backBtn release];
    [_sectionEditView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackBtn:nil];
    [self setSectionEditView:nil];
    [super viewDidUnload];
}


#pragma mark -- dataSource && actionDelegate method
- (CGSize)sizeForLauncherItemView
{
    return CGSizeMake(70, 40);
}

- (NSInteger)numberOfItemsForLauncherWithIsSelected:(BOOL)flag
{
    return flag ? self.selectedArray.count : self.candidateArray.count;
}


- (UIView *)tipsViewForLauncherView:(FMLauncherView *)launcherView
{
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)] autorelease];
    view.backgroundColor = [UIColor grayColor];
    
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:view.bounds];
    tipsLabel.textColor = [UIColor whiteColor];
    tipsLabel.textAlignment = UITextAlignmentCenter;
    tipsLabel.backgroundColor = [UIColor clearColor];
    tipsLabel.text = @"———— 点击增删 拖曳排序 ————";
    [view addSubview:tipsLabel];
    [tipsLabel release];
    
    return view;
}


- (FMItemView *)fMLauncherView:(FMLauncherView *)launcherView itemViewForItemAtIndex:(NSInteger)index isSelected:(BOOL)flag
{
    FirstItemView *itemView = (FirstItemView *)[FirstItemView loadViewFromXib];
    itemView.tipsLabel.text = [NSString stringWithFormat:@"%@",flag ? _selectedArray[index] : _candidateArray[index]];
    return itemView;
}


- (BOOL)fMLancherView:(FMLauncherView *)launcherView canEditItemForIsSelectedAtIndex:(NSInteger)index
{
    BOOL status = YES;
    if (index == 0 || index == 1 || index == kFM_INVALID_POSITION) {
        status = NO;
    }
    return status;
}

- (void)fMLauncherView:(FMLauncherView *)launcherView removeAtIndex:(NSInteger)index
      insertAtPosition:(NSInteger)position
   isSelectedForRemove:(BOOL)flag
{
    if (flag) {
        NSObject *obj = [self.selectedArray objectAtIndex:index];
        [self.candidateArray insertObject:obj atIndex:position];
        [self.selectedArray removeObject:obj];
        
    }else {
        NSObject *obj = [self.candidateArray objectAtIndex:index];
        [self.selectedArray insertObject:obj atIndex:position];
        [self.candidateArray removeObject:obj];

    }
}

- (void)fMLauncherView:(FMLauncherView *)launcherView didSelectedItemAtIndex:(NSInteger)index isSelected:(BOOL)flag
{
    if (flag) {
        NSObject *obj = [self.selectedArray objectAtIndex:index];
        [self.selectedArray removeObject:obj];
        [self.candidateArray insertObject:obj atIndex:0];
        
    }else {
        NSObject *obj = [self.candidateArray objectAtIndex:index];
        [self.candidateArray removeObject:obj];
        [self.selectedArray addObject:obj];
        
    }
}


@end
