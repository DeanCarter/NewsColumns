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
#import "UIGestureRecognizer+GMGridViewAdditions.h"

#define  kEditeItemSelectedDefaultTag   50
#define  kEditeItemCandidateDefaultTag  10000

#define  kFM_INVALID_POSITION  -1


static const CGFloat kDefaultAnimationDuration = 0.3;
static const UIViewAnimationOptions kDefaultAnimationOptions = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction;



@interface FMSectionEditView ()<UIGestureRecognizerDelegate>
{
    CGSize _itemSize;
    
    NSInteger _numOfTotalItem;
    NSInteger _maxOfItemsNum;
    
    NSInteger _sortFuturePosition;
    
    BOOL  _canMoved;
}
@property (nonatomic, assign) NSInteger numOfPerRow;
@property (nonatomic, assign) CGSize itemSize;

@property (nonatomic, retain) UIView *selectedView;
@property (nonatomic, retain) UIView *tipsView;
@property (nonatomic, retain) UIScrollView *candidateView; //候选栏目视图

@property (nonatomic, retain) UITapGestureRecognizer *selectedViewTapGesture;
@property (nonatomic, retain) UITapGestureRecognizer *candidateViewTapGesture;
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
    _selectedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 0)];
    _selectedView.backgroundColor = [UIColor yellowColor];
    [self addSubview:_selectedView];
    
    _candidateView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _candidateView.backgroundColor = [UIColor clearColor];
    [self addSubview:_candidateView];
    
    _selectedViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureUpdatedForSelectedView:)];
    _selectedViewTapGesture.delegate = self;
    _selectedViewTapGesture.numberOfTapsRequired = 1;
    _selectedViewTapGesture.numberOfTouchesRequired = 1;
    _selectedViewTapGesture.cancelsTouchesInView = NO;
    [self.selectedView addGestureRecognizer:_selectedViewTapGesture];
    
    _candidateViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureUpdatedForcandidateView:)];
    _candidateViewTapGesture.delegate = self;
    _candidateViewTapGesture.numberOfTapsRequired = 1;
    _candidateViewTapGesture.numberOfTouchesRequired = 1;
    _candidateViewTapGesture.cancelsTouchesInView = NO;
    [self.candidateView addGestureRecognizer:_candidateViewTapGesture];
    
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureUpdated:)];
    _longPressGesture.delegate = self;
    _longPressGesture.numberOfTouchesRequired = 1;
    _longPressGesture.cancelsTouchesInView = NO;
    [self.selectedView addGestureRecognizer:_longPressGesture];
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureUpdated:)];
    _panGesture.delegate = self;
    [self.selectedView addGestureRecognizer:_panGesture];
    
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

- (NSArray *)itemSubViewsIsSelectedView:(BOOL)flag
{
    NSArray *subviews = nil;
    @synchronized(self) {
        NSMutableArray *itemSubViews = [NSMutableArray arrayWithCapacity:_numOfTotalItem];
        
        for (UIView *v in (flag ? self.selectedView.subviews : self.candidateView.subviews)) {
            if ([v isKindOfClass:[FMEditItemView class]]) {
                [itemSubViews addObject:v];
            }
        }
        subviews = itemSubViews;
    }
    return subviews;
}


#pragma mark -- 寻找指定的itemView
- (FMEditItemView *)lookForAppointItemView:(NSInteger)position withIsSelectedView:(BOOL)flag
{
    FMEditItemView *itemView = nil;
    for (UIView *v in (flag ? self.selectedView.subviews : self.candidateView.subviews)) {
        if ([v isKindOfClass:[FMEditItemView class]] && v.tag == ((flag ? kEditeItemSelectedDefaultTag : kEditeItemCandidateDefaultTag) + position)) {
            itemView = (FMEditItemView *)v;
            return itemView;
        }
    }
    return itemView;
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


- (NSInteger)numOfPerRow
{
    CGFloat mainViewWidth = CGRectGetWidth(self.frame);
    _numOfPerRow = self.itemSize.width ? mainViewWidth/self.itemSize.width : 0;
    
    return _numOfPerRow;
}

- (NSInteger)numOfTotalRowIsSelectedView:(BOOL)flag
{
    NSInteger numOfTotal = [self.dataSource numberOfItemsInFMSectionEditView:self withIsSelectedView:flag];
    
    NSInteger rowNums = self.numOfPerRow  ? (numOfTotal + (self.numOfPerRow - 1)) / (self.numOfPerRow) : 0;
    
    return rowNums;
}

- (CGSize)itemSize
{
    CGSize itemSize = [self.dataSource sizeForSectionEditItemView:self];
    if (!CGSizeEqualToSize(_itemSize, itemSize)) {
        _itemSize = itemSize;
    }
    return _itemSize;
}

- (CGFloat)itemSpacing
{
    CGFloat mainViewWidth = CGRectGetWidth(self.frame);
    
    //每个ItemView的间距
    CGFloat itemSpacing = self.numOfPerRow > 0 ? (mainViewWidth - 2 * self.borderWidthX - self.numOfPerRow * self.itemSize.width) / ((CGFloat)(self.numOfPerRow - 1)) : 0.f;
    
    return itemSpacing;
}

- (void)show
{
    
    //创建已选得项目视图
    NSInteger numOfTotal = [self.dataSource numberOfItemsInFMSectionEditView:self withIsSelectedView:YES] ;
    
    CGFloat mainViewWidth = CGRectGetWidth(self.frame);
    
    //每个ItemView的间距
    CGFloat itemSpacing = (mainViewWidth - 2 * self.borderWidthX - self.numOfPerRow * self.itemSize.width) / ((CGFloat)(self.numOfPerRow - 1));
    
    
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
        [self sendSubviewToBack:self.tipsView];
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
    
    //当前的ItemView所在的列
    NSInteger  currentCol = position % self.numOfPerRow;
    //当前ItemView所在的行
    NSInteger  currentRow = position/self.numOfPerRow;
    
    DLog(@"当前所在位置： 第%d行  第%d列",currentRow,currentCol);
    
    FMEditItemView *itemView = [[self.dataSource fMSectionEditView:self itemViewForItemAtIndex:position withIsSelectedView:flag] retain];
    itemView.frame = CGRectMake((_borderWidthX + (self.itemSize.width + [self itemSpacing]) * currentCol) , (_borderHeightY + (self.itemSize.height + [self itemSpacing ]) * currentRow),self.itemSize.width,self.itemSize.height);
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
    return;
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

- (NSInteger)positionForCurrentLocation:(CGPoint)locationTouch isSelectedView:(BOOL)flag
{
    
    CGPoint relativeLocation = CGPointMake(locationTouch.x - self.borderWidthX, locationTouch.y - self.borderHeightY);
    //列
    int col = (int)(relativeLocation.x)/(self.itemSize.width + [self itemSpacing]);
    //行
    int row = (int)(relativeLocation.y)/(self.itemSize.height + [self itemSpacing]);
    int position = col + row * self.numOfPerRow;
    if (position >= [self.dataSource numberOfItemsInFMSectionEditView:self withIsSelectedView:flag] || position < 0) {
        position = kFM_INVALID_POSITION;
    }else {
        CGPoint itemOrigin = [self originForItemAtPosition:position];
        CGRect itemFrame = CGRectMake(itemOrigin.x,
                                      itemOrigin.y,
                                      self.itemSize.width,
                                      self.itemSize.height);
        if (!CGRectContainsPoint(itemFrame, relativeLocation))
        {
            position = kFM_INVALID_POSITION;
        }
    }
    
    return position;
}

#pragma mark -- UIGestureRecongnizerDelegate method
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL valid = YES;
    
    if (gestureRecognizer == _selectedViewTapGesture)
    {
        valid = ![_longPressGesture hasRecognizedValidGesture];
    }
    else if (gestureRecognizer == _longPressGesture)
    {
        //Dean修改
        valid = (self.sortDelegate || self.enableEditOnLongPress);
        //valid = (self.sortingDelegate || self.enableEditOnLongPress) && !isScrolling && !self.isEditing;
    }
    else if (gestureRecognizer == _panGesture)
    {
        valid = (self.movingItemView != nil && [_longPressGesture hasRecognizedValidGesture]);
    }else if (gestureRecognizer == _candidateViewTapGesture) {
        valid = YES;
    }
    else
    {
        valid = NO;
    }
    
    return valid;
}


- (void)tapGestureUpdatedForSelectedView:(UITapGestureRecognizer *)tapGesture
{
    CGPoint locationTouch = [tapGesture locationInView:self.selectedView];

    NSInteger position = [self positionForCurrentLocation:locationTouch isSelectedView:YES];
    
    if (position != kFM_INVALID_POSITION) {
        if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(fMSelectionEditView:didTapOnItemAtIndex:withIsSelectedView:)]) {
            if (!self.editing) {
                [self lookForAppointItemView:position withIsSelectedView:YES].highlighted = NO;
            }
            [self.actionDelegate fMSelectionEditView:self didTapOnItemAtIndex:position withIsSelectedView:YES];
        }
    }
}

- (void)longPressGestureUpdated:(UILongPressGestureRecognizer *)longPressGesture
{
    if (self.enableEditOnLongPress && !self.editing) {
        CGPoint locationTouch = [longPressGesture locationInView:self];
        NSInteger position = [self positionForCurrentLocation:locationTouch isSelectedView:YES];
        
        if (position != kFM_INVALID_POSITION) {
            if (!self.editing) {
                self.editing = YES;
            }
            return;
        }
    }
    switch (longPressGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (!_movingItemView) {
                CGPoint locationTouch = [longPressGesture locationInView:self];
                NSInteger position = [self positionForCurrentLocation:locationTouch isSelectedView:YES];
                
                if (position != kFM_INVALID_POSITION) {
                    [self sortingMoveDidStartAtPoint:locationTouch];
                }
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [_panGesture end];
            if (_movingItemView) {
                CGPoint touchLocation = [longPressGesture locationInView:self];
                [self sortingMoveDidStopAtPoint:touchLocation];
            }
        }
            break;
        default:
            break;
    }
}

- (void)panGestureUpdated:(UIPanGestureRecognizer *)panGesture
{
    if (!_canMoved) {
        return;
    }
    switch (panGesture.state) {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            
        }
            break;
        case UIGestureRecognizerStateBegan:
        {
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [panGesture translationInView:self];
            CGPoint offset = translation;
            CGPoint locationInScroll = [panGesture locationInView:self];
            
            self.movingItemView.transform = CGAffineTransformMakeTranslation(offset.x, offset.y);
            [self sortingMoveDidContinueToPoint:locationInScroll];
            
        }
            break;
        default:
            break;
    }
}


- (void)tapGestureUpdatedForcandidateView:(UITapGestureRecognizer *)tapGesture
{
    
}

#pragma mark -- 根据传进来的index得到对于ItemView的origin
- (CGPoint)originForItemAtPosition:(NSInteger)position
{
    CGPoint origin = CGPointZero;
    
    if (self.numOfPerRow > 0 && position >= 0) {
        NSUInteger col = position % self.numOfPerRow;
        NSUInteger row = position/self.numOfPerRow;
        
        origin = CGPointMake((_borderWidthX + (self.itemSize.width + [self itemSpacing]) * col) , (_borderHeightY + (self.itemSize.height + [self itemSpacing]) * row));
    }
    return origin;
}

- (void)sortingMoveDidStartAtPoint:(CGPoint)point
{
    NSInteger position = [self positionForCurrentLocation:point];

    NSInteger flag = 0;
    if (CGRectContainsPoint(self.selectedView.frame, point)) {
        flag = 1;
    }else if (CGRectContainsPoint(self.candidateView.frame, point)) {
        flag = 2;
    }else {
        flag = 3;
    }
    
    BOOL isSelectedView = (flag == 1 ? YES : NO);
    
    UIView *view = isSelectedView ? self.selectedView : self.candidateView;
    
    FMEditItemView *itemView = [self lookForAppointItemView:position withIsSelectedView:isSelectedView];
    self.movingItemView = itemView;
    
    CGRect frameInMainView = [view convertRect:self.movingItemView.frame toView:self];
    [itemView removeFromSuperview];
    self.movingItemView.frame = frameInMainView;
    [self addSubview:self.movingItemView];
    [self bringSubviewToFront:self.movingItemView];
    
    self.movingItemView.backgroundColor = [UIColor redColor];
    
    _sortFuturePosition = self.movingItemView.tag - (isSelectedView ? kEditeItemSelectedDefaultTag : kEditeItemCandidateDefaultTag);
    
    _canMoved = YES;
    if ((isSelectedView && position == 0) || position == kFM_INVALID_POSITION) {
        _canMoved = NO;
    }
    
    self.movingItemView.tag = 0;

    if (self.sortDelegate && [self.sortDelegate respondsToSelector:@selector(fMSelectionEditView:didStartMovingItemView:)]) {
        if (!_canMoved) {
            return;
        }
        [self.sortDelegate fMSelectionEditView:self didStartMovingItemView:self.movingItemView];
    }
}

- (void)sortingMoveDidContinueToPoint:(CGPoint)point
{
    int position = [self positionForCurrentLocation:point];
    
    NSInteger flag = 0;
    if (CGRectContainsPoint(self.selectedView.frame, point)) {
        flag = 1;
    }else if (CGRectContainsPoint(self.candidateView.frame, point)) {
        flag = 2;
    }else {
        flag = 3;
    }
    
    BOOL isSelectedView = (flag == 1 ? YES : NO);
    int tag = (isSelectedView ? kEditeItemSelectedDefaultTag : kEditeItemCandidateDefaultTag) + position;
    
    if (position != kFM_INVALID_POSITION && !(position == 0 && isSelectedView) && position != _sortFuturePosition && position < ([self.dataSource numberOfItemsInFMSectionEditView:self withIsSelectedView:isSelectedView])) {
        BOOL positionToken = NO;
        
        for (UIView *v in [self itemSubViewsIsSelectedView:isSelectedView]) {
            if (v != _movingItemView && v.tag == tag) {
                positionToken = YES;
                break;
            }
        }
        
        if (positionToken) {
            if (_movingItemView) {
                FMEditItemView *v = [self lookForAppointItemView:position withIsSelectedView:isSelectedView];
                
                v.tag = _sortFuturePosition + (isSelectedView ? kEditeItemSelectedDefaultTag : kEditeItemCandidateDefaultTag);
                CGPoint orgin = [self originForItemAtPosition:_sortFuturePosition];
                
                [UIView animateWithDuration:kDefaultAnimationDuration
                                      delay:0
                                    options:kDefaultAnimationOptions
                                 animations:^{
                                     v.frame = CGRectMake(orgin.x, orgin.y, self.itemSize.width, self.itemSize.height);
                                 } completion:^(BOOL finished) {
                                     
                                 }];
            }
            if (self.sortDelegate && [self.sortDelegate respondsToSelector:@selector(fmSelectionEditView:exchangeItemAtIndex:withItemAtIndex:)]) {
                [self.sortDelegate fmSelectionEditView:self exchangeItemAtIndex:_sortFuturePosition withItemAtIndex:position];
            }
        }
        _sortFuturePosition = position;
    }
}

- (void)sortingMoveDidStopAtPoint:(CGPoint)point
{
    NSInteger flag = 0;
    if (CGRectContainsPoint(self.selectedView.frame, point)) {
        flag = 1;
    }else if (CGRectContainsPoint(self.candidateView.frame, point)) {
        flag = 2;
    }else {
        flag = 3;
    }
    
    BOOL isSelectedView = (flag == 1 ? YES : NO);
    self.movingItemView.tag = _sortFuturePosition + (isSelectedView ? kEditeItemSelectedDefaultTag : kEditeItemCandidateDefaultTag);
    UIView *view = isSelectedView ? self.selectedView : self.candidateView;
    CGRect frameInScroll = [self convertRect:self.movingItemView.frame toView:view];
    [_movingItemView removeFromSuperview];
    self.movingItemView.frame = frameInScroll;
    [view addSubview:self.movingItemView];
    self.movingItemView.backgroundColor = [UIColor clearColor];
    
    [_movingItemView setHighlighted:NO];
    
    CGPoint newOrign = [self originForItemAtPosition:_sortFuturePosition];
    CGRect newFrame = CGRectMake(newOrign.x, newOrign.y, self.itemSize.width, self.itemSize.height);
    
    [UIView animateWithDuration:kDefaultAnimationDuration
                          delay:0
                        options:0
                     animations:^{
                         self.movingItemView.transform = CGAffineTransformIdentity;
                         self.movingItemView.frame = newFrame;
                     } completion:^(BOOL finished) {
                         if (self.sortDelegate && [self.sortDelegate respondsToSelector:@selector(fMSelectionEditView:didEndMovingItemView:)]) {
                             [self.sortDelegate fMSelectionEditView:self didEndMovingItemView:self.movingItemView];
                             
                             self.movingItemView = nil;
                             _sortFuturePosition = kFM_INVALID_POSITION;
                             
                             
                         }
                     }];

}

#pragma mark LayOut
- (void)layoutSubviewsWithAnimation
{
    
}
@end
