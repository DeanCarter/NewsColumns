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
#import "SecondViewController.h"

@interface FirstViewController ()<FMSectionEditViewActionDelegate,FMSectionEditViewDataSource,FMSectionEditViewSortDelegate>
@property (retain, nonatomic) IBOutlet UIButton *backBtn;
@property (retain, nonatomic) NSMutableArray *selectedArray;
@property (retain, nonatomic) NSMutableArray *candidateArray;

@property (retain, nonatomic) IBOutlet FMSectionEditView *sectionEditView;

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
    SecondViewController *vc = [[SecondViewController alloc] initWithNibName:@"SecondViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.selectedArray = [NSMutableArray arrayWithObjects:@"头条",@"娱乐",@"财经",@"科技",@"手机",@"北京",@"军事",@"游戏",@"汽车",@"轻松一刻",@"房产",@"时尚",@"历史",nil];
    self.candidateArray = [NSMutableArray arrayWithObjects:@"电影",@"体育",@"彩票",@"微博",@"社会",@"历史",@"论坛",@"家居",@"真话",@"旅游",@"移动互联",@"教育",@"CBA",@"原创",@"养生",nil];
    
    self.sectionEditView.borderWidthX = 5.f;
    self.sectionEditView.borderHeightY = 5.f;
    
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
- (CGSize)sizeForSectionEditItemView:(FMSectionEditView *)sectionEditView
{
    return CGSizeMake(70, 40);
}

- (NSInteger)numberOfItemsInFMSectionEditView:(FMSectionEditView *)sectionEditView withIsSelectedView:(BOOL)flag
{
    return flag ? self.selectedArray.count : self.candidateArray.count;
}


- (UIView *)tipsViewForFMSectionEditView:(FMSectionEditView *)sectionEditView
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

- (FMEditItemView *)fMSectionEditView:(FMSectionEditView *)sectionEditView itemViewForItemAtIndex:(NSInteger)index withIsSelectedView:(BOOL)flag
{
    FirstItemView *itemView = (FirstItemView *)[FirstItemView loadViewFromXib];
    itemView.tipsLabel.text = [NSString stringWithFormat:@"%@",flag ? _selectedArray[index] : _candidateArray[index]];
    return itemView;
}

- (void)fMSelectionEditView:(FMSectionEditView *)sectionEditView didTapOnItemAtIndex:(NSInteger)position withIsSelectedView:(BOOL)flag
{
    if(flag) {
        NSObject *object = [_selectedArray objectAtIndex:position];
        [_selectedArray removeObject:object];
        [_candidateArray insertObject:object atIndex:0];
    }else {
        NSObject *object = [_candidateArray objectAtIndex:position];
        [_candidateArray removeObject:object];
        [_selectedArray addObject:object];

    }
    [self.sectionEditView reloadData];
    DLog(@"%@  第%d个",(flag ? @"已选区": @"未选取"),position);
}

- (void)fmSelectionEditView:(FMSectionEditView *)sectionEditView
            moveItemAtIndex:(NSInteger)oldIndex
                    toIndex:(NSInteger)newIndex
{
    
    NSObject *object = [_selectedArray objectAtIndex:oldIndex];
    [_selectedArray removeObject:object];
    [_selectedArray insertObject:object atIndex:newIndex];
}

- (void)fmSelectionEditView:(FMSectionEditView *)sectionEditView
        exchangeItemAtIndex:(NSInteger)oldIndex
            withItemAtIndex:(NSInteger)newIndex;
{
    
 //   [_orderList exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}

@end
