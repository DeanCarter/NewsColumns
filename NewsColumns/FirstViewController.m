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

@interface FirstViewController ()<FMSectionEditViewActionDelegate,FMSectionEditViewDataSource>
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
    [self.navigationController popViewControllerAnimated:YES];
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

- (FMEditItemView *)fMSectionEditView:(FMSectionEditView *)sectionEditView itemViewForItemAtIndex:(NSInteger)index withIsSelectedView:(BOOL)flag
{
    FirstItemView *itemView = (FirstItemView *)[FirstItemView loadViewFromXib];
    itemView.tipsLabel.text = [NSString stringWithFormat:@"%@",flag ? _selectedArray[index] : _candidateArray[index]];
    return itemView;
}

- (void)fMSelectionEditView:(FMSectionEditView *)sectionEditView didTapOnItemAtIndex:(NSInteger)position
{
    
}


@end
