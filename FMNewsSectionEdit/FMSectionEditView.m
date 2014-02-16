//
//  FMSectionEditView.m
//  NewsColumns
//
//  Created by Apple on 14-2-14.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import "FMSectionEditView.h"
#import "FMEditItemView.h"
#import "FMSectionEditViewLayOutStrategy.h"

#define  kEditeItemSelectedDefaultTag   50
#define  kEditeItemCandidateDefaultTag  10000

@interface FMSectionEditView ()<UIGestureRecognizerDelegate>
{
    CGSize _itemSize;
    
    NSInteger _numOfTotalItem;
    NSInteger _maxOfItemsNum;
    
    NSInteger _numOfPerRow;
    
    NSInteger _sortFuturePosition;
}
@property (nonatomic, retain) UIView *selectedView;
@property (nonatomic, retain) UIView *tipsView;
@property (nonatomic, retain) UIScrollView *candidateView; //候选栏目视图

@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
@property (nonatomic, retain) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, retain) UIPanGestureRecognizer *panGesture;

@property (nonatomic, retain) NSMutableArray *itemViewArray;

@property (nonatomic, retain) NSMutableArray *candidateArray;

@property (nonatomic, retain) FMEditItemView *movingItemView;
@end

@implementation FMSectionEditView

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureUpdated:)];
    _tapGesture.delegate = self;
    _tapGesture.numberOfTapsRequired = 1;
    _tapGesture.numberOfTouchesRequired = 1;
    _tapGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:_tapGesture];
    
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureUpdated:)];
    _longPressGesture.delegate = self;
    _longPressGesture.numberOfTouchesRequired = 1;
    _longPressGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:_longPressGesture];
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureUpdated:)];
    _panGesture.delegate = self;
    [self addGestureRecognizer:_panGesture];
    
    _selectedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 0)];
    _selectedView.backgroundColor = [UIColor yellowColor];
    [self addSubview:_selectedView];
    
    _candidateView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _candidateView.backgroundColor = [UIColor clearColor];
    [self addSubview:_candidateView];
    
    
    _borderWidthX = 0.f;
    _borderHeightY = 0.f;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self show];
    
    CGSize itemSize = [self.dataSource sizeForSectionEditItemView:self];
    if (!CGSizeEqualToSize(_itemSize, itemSize)) {
        _itemSize = itemSize;
        [[self itemSubViews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            FMEditItemView *itemView = (FMEditItemView *)obj;
            itemView.bounds = CGRectMake(0, 0, _itemSize.width, _itemSize.height);
            itemView.contentView.frame = itemView.bounds;
        }];
    }
}

- (NSArray *)itemSubViews
{
    NSArray *subviews = nil;
    @synchronized(self) {
        NSMutableArray *itemSubViews = [NSMutableArray arrayWithCapacity:_numOfTotalItem];
        
        for (UIView *v in self.subviews) {
            if ([v isKindOfClass:[FMEditItemView class]]) {
                [itemSubViews addObject:v];
            }
        }
        subviews = itemSubViews;
        self.itemViewArray = itemSubViews;
    }
    return subviews;
}

- (void)relayoutItemsAnimated:(BOOL)animated
{
    void (^layoutBlcok)(void) = ^{
        for (UIView *v in [self itemSubViews]) {
            if (v != _movingItemView) {
                NSInteger index = v.tag - kEditeItemSelectedDefaultTag;
                
            }
        }
    };
}


- (NSInteger)numItemsForPerRow
{
    CGSize itemSize = [self.dataSource sizeForSectionEditItemView:self];
    if (!CGSizeEqualToSize(_itemSize, itemSize)) {
        _itemSize = itemSize;
    }
    CGFloat mainViewWidth = CGRectGetWidth(self.frame);
    _numOfPerRow = _itemSize.width ? mainViewWidth/_itemSize.width : 0;
    
    return _numOfPerRow;
}

- (NSInteger)numOfTotalRow
{
    NSInteger numOfTotal = [self.dataSource numberOfItemsInFMSectionEditView:self withIsSelectedView:YES];
    
    NSInteger rowNums = _numOfPerRow  ? (numOfTotal + ([self numItemsForPerRow] - 1)) / ([self numItemsForPerRow]) : 0;
    
    return rowNums;
}

- (void)show
{
    
    CGSize itemSize = [self.dataSource sizeForSectionEditItemView:self];
    if (!CGSizeEqualToSize(_itemSize, itemSize)) {
        _itemSize = itemSize;
    }
    
    [self numItemsForPerRow];
    
    //创建已选得项目视图
    NSInteger numOfTotal = [self.dataSource numberOfItemsInFMSectionEditView:self withIsSelectedView:YES] ;
    
    CGFloat mainViewWidth = CGRectGetWidth(self.frame);
    
    //每个ItemView的间距
    CGFloat itemSpacing = (mainViewWidth - 2 * self.borderWidthX - _numOfPerRow * itemSize.width) / ((CGFloat)(_numOfPerRow - 1));
    
    
    if (_numOfPerRow <= 0) {
        return;
    }
    if (_numOfPerRow <= 0) {
#warning 每行的个数不能少于1；
    }
    if (_numOfPerRow > 0) {
        NSInteger rowNums = (numOfTotal + (_numOfPerRow - 1))/_numOfPerRow;
        
        CGFloat selectedViewHeight = self.borderHeightY * 2 + _itemSize.height * rowNums + (rowNums - 1) * itemSpacing;
        self.selectedView.frame = CGRectMake(self.selectedView.frame.origin.x, self.selectedView.frame.origin.y, self.frame.size.width, selectedViewHeight);
        
        for (int i = 0; i < numOfTotal; i++) {
            FMEditItemView *itemView = [[self newItemViewSubViewForPosition:i withIsSelectedView:YES] retain];
            [self.selectedView addSubview:itemView];
            [itemView release];
        }
        
    }else {
        self.selectedView.frame = CGRectMake(self.selectedView.frame.origin.x, self.selectedView.frame.origin.y, self.frame.size.width, 0.f);
    }
    
    //添加TipsView
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(tipsViewForFMSectionEditView:)]) {
        self.tipsView = [self.dataSource tipsViewForFMSectionEditView:self];
        self.tipsView.frame = CGRectMake(0, self.selectedView.frame.origin.y + self.selectedView.frame.size.height, self.tipsView.bounds.size.width, self.tipsView.bounds.size.height);
        [self addSubview:self.tipsView];
    }
    
    //创建备选项目视图
    NSInteger allCandidateNums = [self.dataSource numberOfItemsInFMSectionEditView:self withIsSelectedView:NO];
    if (allCandidateNums > 0) {
        NSInteger rowNums = (allCandidateNums + (_numOfPerRow - 1))/_numOfPerRow;
        CGFloat selectedViewHeight = self.borderHeightY * 2 + _itemSize.height * rowNums + (rowNums - 1) * itemSpacing;
        CGFloat candidateViewOrignY = self.tipsView.height ? (self.tipsView.origin.y + self.tipsView.frame.size.height) : (self.selectedView.origin.y + self.selectedView.frame.size.height);
        
        self.candidateView.frame = CGRectMake(0, candidateViewOrignY, self.frame.size.width, (self.frame.size.height - candidateViewOrignY));
        self.candidateView.contentSize = CGSizeMake(self.candidateView.frame.size.width, selectedViewHeight);
        
        for (int position = 0; position < allCandidateNums; position++) {
            FMEditItemView *itemView = [[self newItemViewSubViewForPosition:position withIsSelectedView:NO] retain];
            [self.candidateView addSubview:itemView];
            [itemView release];
        }
    }
    
}


- (FMEditItemView *)newItemViewSubViewForPosition:(NSInteger)position withIsSelectedView:(BOOL)flag
{
    
    
    [self numItemsForPerRow];
    
    CGSize itemSize = [self.dataSource sizeForSectionEditItemView:self];
    if (!CGSizeEqualToSize(_itemSize, itemSize)) {
        _itemSize = itemSize;
    }
    
    CGFloat mainViewWidth = CGRectGetWidth(self.frame);
    
    
    //每个ItemView的间距
    CGFloat itemSpacing = (mainViewWidth - 2 * self.borderWidthX - _numOfPerRow * itemSize.width) / ((CGFloat)(_numOfPerRow - 1));
    
    //当前的ItemView所在的列
    NSInteger  currentIndex = position % _numOfPerRow;
    //当前ItemView所在的行
    NSInteger currentRow = ((position + 1) + (_numOfPerRow - 1))/_numOfPerRow  - 1;//因为传进来的初始位置都是0
    
    DLog(@"当前所在位置： 第%d行  第%d列",currentRow,currentIndex);
    
    FMEditItemView *itemView = [[self.dataSource fMSectionEditView:self itemViewForItemAtIndex:position withIsSelectedView:flag] retain];
    itemView.frame = CGRectMake((_borderWidthX + (_itemSize.width + itemSpacing) * currentIndex) , (_borderHeightY + (_itemSize.height + itemSpacing) * currentRow),_itemSize.width,_itemSize.height);
    itemView.contentView.frame = itemView.bounds;
    itemView.tag = flag ? (kEditeItemSelectedDefaultTag + position) : (kEditeItemCandidateDefaultTag + position);
    BOOL canEdit = NO;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(fMSectionEditView:canDeleteItemAtIndex:)]) {
        canEdit = [self.dataSource fMSectionEditView:self canDeleteItemAtIndex:position] && self.editing && flag;
    }
    [itemView setEditing:canEdit animated:NO];
    
    return [itemView autorelease];
}


#pragma mark -- ReloadSelectedData method
- (void)reloadSelectedData
{
    [[self itemSubViews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[FMEditItemView class]]) {
            
        }
    }];
}


#pragma mark -- getter && setter
- (void)setDataSource:(id<FMSectionEditViewDataSource>)dataSource
{
    _dataSource = dataSource;
    [self reloadSelectedData];
    [self setNeedsDisplay];
}

- (void)setEditing:(BOOL)editing
{
    [self setEditing:editing animated:NO];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if ([self.actionDelegate respondsToSelector:@selector(fMSelectionEditView:deleteActionForItemAtIndex:)] && ((self.isEditing && !editing) || (!self.isEditing && editing))) {
        
        for (FMEditItemView *cell in [self itemSubViews]) {
            //NSInteger index = [self positionForItemSubView:cell];
        }
    }
}


#pragma mark LayOut
- (void)layoutSubviewsWithAnimation
{
    
}
@end
