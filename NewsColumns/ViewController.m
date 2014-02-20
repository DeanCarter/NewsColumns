//
//  ViewController.m
//  NewsColumns
//
//  Created by Dean on 14-2-13.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import "ViewController.h"
#import "GMGridView.h"
#import "FirstViewController.h"


@interface ViewController ()<GMGridViewActionDelegate, GMGridViewDataSource,GMGridViewSortingDelegate,GMGridViewTransformationDelegate>
@property (retain, nonatomic) IBOutlet UIButton *arrowButton;

@property (retain, nonatomic) IBOutlet UIView *topView;
@property (retain, nonatomic) IBOutlet UILabel *tipsLabel;
@property (retain, nonatomic) IBOutlet UIButton *operatoionButton;

@property (retain, nonatomic) IBOutlet UIView *contentView;

@property (retain, nonatomic) IBOutlet UIView *orderView;

@property (retain, nonatomic) IBOutlet UIView *tipView;


@property (retain, nonatomic) IBOutlet UIView *alternativeView;


@property (retain, nonatomic) GMGridView *orderGridView;

@property (retain, nonatomic) GMGridView *moreGridView;

@property (retain, nonatomic) NSMutableArray *orderList;
@property (retain, nonatomic) NSMutableArray *moreList;


@end

@implementation ViewController

- (void)initGridView
{
    _orderGridView = [[GMGridView alloc] initWithFrame:(CGRect){0,0,self.orderView.frame.size.width, self.orderView.size.height}];
    
    [self.orderGridView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
    
    _orderGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _orderGridView.backgroundColor = [UIColor yellowColor];
    [self.orderView addSubview:self.orderGridView];
    
    NSInteger spacing = 4.f;
    _orderGridView.style = GMGridViewStyleSwap;
    _orderGridView.itemSpacing = spacing;
    _orderGridView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    _orderGridView.centerGrid = NO;
    _orderGridView.sortingDelegate = self;
    _orderGridView.actionDelegate = self;
    _orderGridView.dataSource = self;
    _orderGridView.transformDelegate = self;
    
    _orderGridView.mainSuperView = self.orderView;
    
   // DLog(@"GridView ContentSize:   %@",NSStringFromCGSize(_orderGridView.contentSize));

    
    _moreGridView = [[GMGridView alloc] initWithFrame:(CGRect){0,0,self.view.frame.size.width, CGRectGetHeight(self.alternativeView.frame)}];
    _moreGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _moreGridView.backgroundColor = [UIColor yellowColor];
    [self.alternativeView addSubview:self.moreGridView];
    
    _moreGridView.style = GMGridViewStyleSwap;
    _moreGridView.itemSpacing = spacing;
    _moreGridView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    _moreGridView.centerGrid = NO;
    _moreGridView.sortingDelegate = self;
    _moreGridView.actionDelegate = self;
    _moreGridView.dataSource = self;
    _moreGridView.transformDelegate = self;
    
    [self.moreGridView setCanEditing:NO];
    
    _moreGridView.mainSuperView = self.moreGridView;

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DLog(@"keyPath:  %@\n object:  %@\n",keyPath,object);
    DLog(@"改变了OrderGridView的contentSize");
    
    self.orderView.height = self.orderGridView.contentSize.height;
    
    self.tipView.top = self.orderView.bottom + 10.f;
    self.alternativeView.top = self.tipView.bottom;
    self.alternativeView.height = self.contentView.height - self.tipView.bottom;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    UIImage *arrowImage = [UIImage imageNamed:@"channel_nav_arrow"];
    UIImage *selectedArrowImage = [UIImage imageWithCGImage:arrowImage.CGImage scale:2 orientation:UIImageOrientationDown];
    [self.arrowButton setImage:selectedArrowImage forState:UIControlStateNormal];
    [self.arrowButton setImage:arrowImage forState:UIControlStateSelected];
    
    
    self.orderList = [NSMutableArray arrayWithObjects:@"头条",@"娱乐",@"财经",@"科技",@"手机",@"北京",@"军事",@"游戏",@"汽车",@"轻松一刻",@"房产",@"时尚",@"历史",nil];
    self.moreList = [NSMutableArray arrayWithObjects:@"电影",@"体育",@"彩票",@"微博",@"社会",@"历史",@"论坛",@"家居",@"真话",@"旅游",@"移动互联",@"教育",@"CBA",@"原创",@"养生",nil];

    [self initGridView];
    DLog(@"viewDidLoad");

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DLog(@"viewWillAppear");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_arrowButton release];
    [_topView release];
    [_tipsLabel release];
    [_operatoionButton release];
    [_orderView release];
    [_tipView release];
    [_alternativeView release];
    [_contentView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setArrowButton:nil];
    [self setTopView:nil];
    [self setTipsLabel:nil];
    [self setOperatoionButton:nil];
    [self setOrderView:nil];
    [self setTipView:nil];
    [self setAlternativeView:nil];
    [self setContentView:nil];
    [super viewDidUnload];
}


- (IBAction)arrowButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    FirstViewController *vc = [[FirstViewController alloc] initWithNibName:@"FirstViewController" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (IBAction)operationButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    self.orderGridView.editing = sender.selected;
    [self.orderGridView layoutSubviewsWithAnimation:GMGridViewItemAnimationFade];
    
    self.tipView.hidden = sender.selected;
    self.alternativeView.hidden = sender.selected;
    
}

#pragma mark - GMGridViewDataSource
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return   gridView == _orderGridView ? self.orderList.count : self.moreList.count;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(70, 37.f);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    if (gridView == _orderGridView) {
       // DLog(@"GridView ContentSize:   %@",NSStringFromCGSize(_orderGridView.contentSize));
    }
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    if (!cell) {
        cell = [[GMGridViewCell alloc] init];
        cell.deleteButtonIcon = [UIImage imageNamed:@"channel_edit_delete"];
        cell.deleteButtonOffset = CGPointMake(-2.5, -2.5);

        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor clearColor];

        cell.contentView = view;
    }
    
    [cell shake:NO];
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.text = (NSString *)[(gridView == _orderGridView ? _orderList : _moreList) objectAtIndex:index];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.highlightedTextColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:16];
    [cell.contentView addSubview:label];

    return cell;
}

- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    if (gridView == _moreGridView) {
        return NO;
    }
    if (index == 0) {
        return NO;
    }
    if (!self.operatoionButton.selected) {
        [self operationButtonAction: self.operatoionButton];
    }
    return YES; //index % 2 == 0;
}

#pragma mark GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    NSLog(@"Did tap at index %d", position);
    if (gridView == _moreGridView) {
        id selectedObj = [_moreList objectAtIndex:position];
        [self.orderList addObject:selectedObj];
        [_orderGridView reloadData];
        
        [_moreList removeObjectAtIndex:position];
        [gridView removeObjectAtIndex:position withAnimation:GMGridViewItemAnimationFade];
    }
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    NSLog(@"Tap on empty space");
}

- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index
{
    if (gridView == _moreGridView) {
        return;
    }

    if (index >= 0 && index < _orderList.count) {
        
        id deleteObj = [_orderList objectAtIndex:index];
        [_moreList insertObject:deleteObj atIndex:0];
        
        [_orderList removeObjectAtIndex:index];
        [gridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade];
        
        
        [_moreGridView reloadData];
    }
}

- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{
    if (gridView == _moreGridView) {
        return;
    }

    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor orangeColor];
                         cell.contentView.layer.shadowOpacity = 0.7;
                     }
                     completion:nil
     ];

}

- (void)GMGridView:(GMGridView *)gridView didEndMovingCell:(GMGridViewCell *)cell
{
    if (gridView == _moreGridView) {
        return;
    }

    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor clearColor];
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil
     ];
}

- (BOOL)GMGridView:(GMGridView *)gridView shouldAllowShakingBehaviorWhenMovingCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    return NO;
}

- (void)GMGridView:(GMGridView *)gridView moveItemAtIndex:(NSInteger)oldIndex toIndex:(NSInteger)newIndex
{
    if (gridView == _moreGridView) {
        return;
    }
    NSObject *object = [_orderList objectAtIndex:oldIndex];
    [_orderList removeObject:object];
    [_orderList insertObject:object atIndex:newIndex];
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
    if (gridView == _moreGridView) {
        return;
    }

    [_orderList exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
}

#pragma mark - DraggableGridViewTransformingDelegate
- (CGSize)GMGridView:(GMGridView *)gridView sizeInFullSizeForCell:(GMGridViewCell *)cell atIndex:(NSInteger)index inInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(300, 200);
    
}

- (UIView *)GMGridView:(GMGridView *)gridView fullSizeViewForCell:(GMGridViewCell *)cell atIndex:(NSInteger)index
{
    UIView *fullView = [[UIView alloc] init];
    fullView.backgroundColor = [UIColor yellowColor];
    fullView.layer.masksToBounds = NO;
    fullView.layer.cornerRadius = 8;
    
    CGSize size = [self GMGridView:gridView sizeInFullSizeForCell:cell atIndex:index inInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    fullView.bounds = CGRectMake(0, 0, size.width, size.height);
    
    UILabel *label = [[UILabel alloc] initWithFrame:fullView.bounds];
    label.text = [NSString stringWithFormat:@"Fullscreen View for cell at index %d", index];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    label.font = [UIFont boldSystemFontOfSize:15];
    
    [fullView addSubview:label];
    
    
    return fullView;
}

- (void)GMGridView:(GMGridView *)gridView didStartTransformingCell:(GMGridViewCell *)cell
{
    if (gridView == _moreGridView) {
        return;
    }

    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor blueColor];
                         cell.contentView.layer.shadowOpacity = 0.7;
                     }
                     completion:nil];
}

- (void)GMGridView:(GMGridView *)gridView didEndTransformingCell:(GMGridViewCell *)cell
{
    if (gridView == _moreGridView) {
        return;
    }

    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor redColor];
                         cell.contentView.layer.shadowOpacity = 0;
                     }
                     completion:nil];
}

- (void)GMGridView:(GMGridView *)gridView didEnterFullSizeForCell:(UIView *)cell
{
    
}



@end
