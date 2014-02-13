//
//  ViewController.m
//  NewsColumns
//
//  Created by Dean on 14-2-13.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import "ViewController.h"
#import "GMGridView.h"


@interface ViewController ()<GMGridViewActionDelegate, GMGridViewDataSource,GMGridViewSortingDelegate,GMGridViewTransformationDelegate>
@property (retain, nonatomic) IBOutlet UIButton *arrowButton;

@property (retain, nonatomic) IBOutlet UIView *topView;
@property (retain, nonatomic) IBOutlet UILabel *tipsLabel;
@property (retain, nonatomic) IBOutlet UIButton *operatoionButton;


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
    _orderGridView = [[GMGridView alloc] initWithFrame:(CGRect){0,0,self.view.frame.size.width, 200.f}];
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
    self.moreList = [NSMutableArray arrayWithObjects:@"电影",@"体育",@"彩票",@"博",@"社会",@"历史",@"论坛",@"家居",@"真话",@"旅游",@"移动互联",@"教育",@"CBA",@"原创",@"养",nil];

    [self initGridView];
    
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
    [super viewDidUnload];
}


- (IBAction)arrowButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
}


#pragma mark - GMGridViewDataSource
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return self.orderList.count;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(70, 37.f);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
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
    label.text = (NSString *)[_orderList objectAtIndex:index];
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
    if (index == 0) {
        return NO;
    }
    return YES; //index % 2 == 0;
}

#pragma mark GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    NSLog(@"Did tap at index %d", position);
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    NSLog(@"Tap on empty space");
}

- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index
{
    if (index >= 0 && index < _orderList.count) {
        [_orderList removeObjectAtIndex:index];
        [gridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade];
    }
}

- (void)GMGridView:(GMGridView *)gridView didStartMovingCell:(GMGridViewCell *)cell
{
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
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor redColor];
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
    NSObject *object = [_orderList objectAtIndex:oldIndex];
    [_orderList removeObject:object];
    [_orderList insertObject:object atIndex:newIndex];
}

- (void)GMGridView:(GMGridView *)gridView exchangeItemAtIndex:(NSInteger)index1 withItemAtIndex:(NSInteger)index2
{
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
