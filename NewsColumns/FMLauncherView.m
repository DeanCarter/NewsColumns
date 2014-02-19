//
//  FMLauncherView.m
//  NewsColumns
//
//  Created by Apple on 14-2-19.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import "FMLauncherView.h"
#import "FMItemView.h"
#import "UIGestureRecognizer+GMGridViewAdditions.h"


#define  kEditeItemSelectedDefaultTag   50
#define  kEditeItemCandidateDefaultTag  10000


#define  kFM_INVALID_POSITION  -1

static const CGFloat kDefaultAnimationDuration = 0.3;

typedef enum {
    FMItemSubViewForAll,
    FMItemSubViewFoIsSelected,
    FMItemSubViewForMore
}FMItemSubViewType;

typedef enum {
    FMSelectedRowNumNomal,
    FMSelectedRowNumAdd,
    FMSelectedRowNumMinus
}FMSelectedRowNumStatus;


@interface FMLauncherView ()<UIGestureRecognizerDelegate>
{
    BOOL _canMoved;
    BOOL _canEdited;
    BOOL _isFirstLoad;
    
    NSInteger _sortFuturePosition;
    
}
@property (nonatomic, retain) FMItemView *movingItemView;

@property (nonatomic, retain) UIView *tipsView;

@property (nonatomic, retain) NSMutableArray *selectedPointArray;
@property (nonatomic, retain) NSMutableArray *morePointArray;

@property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
@property (nonatomic, retain) UIPanGestureRecognizer *panGesture;
@property (nonatomic, retain) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation FMLauncherView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commitInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commitInit];
    }
    return self;
}

- (void)commitInit
{
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureUpdated:)];
    _tapGesture.delegate = self;
    _tapGesture.numberOfTapsRequired = 1;
    _tapGesture.numberOfTouchesRequired = 1;
    _tapGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:self.tapGesture];
    
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureUpdated:)];
    _longPressGesture.delegate = self;
    _longPressGesture.numberOfTouchesRequired = 1;
    _longPressGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:_longPressGesture];
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureUpdated:)];
    _panGesture.delegate = self;
    [self addGestureRecognizer:_panGesture];
    
    _sortFuturePosition = kFM_INVALID_POSITION;
    
    _isFirstLoad = YES;
    
    _canEdited = NO;
    
    _canMoved = YES;
}

- (NSArray *)itemSubviewForType:(FMItemSubViewType)type
{
    NSArray *subviews = nil;
    @synchronized(self) {
        NSMutableArray *itemViewArray = [NSMutableArray array];
        for (UIView *v in self.subviews) {
            if ([v isKindOfClass:[FMItemView class]]) {
                if (type == FMItemSubViewForAll) {
                    [itemViewArray addObject:v];
                }else if (type == FMItemSubViewFoIsSelected) {
                    if (v.tag >= kEditeItemSelectedDefaultTag && v.tag < kEditeItemCandidateDefaultTag) {
                        [itemViewArray addObject:v];
                    }
                }else if (type == FMItemSubViewForMore) {
                    if (v.tag >= kEditeItemCandidateDefaultTag) {
                        [itemViewArray addObject:v];
                    }
                }
            }
        }
        subviews = itemViewArray;
    }
    return subviews;
}

- (NSInteger)numOfPerRow
{
    CGSize itemSize = [self.dataSource sizeForLauncherItemView];
    CGFloat mainViewWidth = CGRectGetWidth(self.frame);
    NSInteger numOfPerRow = itemSize.width ? (mainViewWidth - 2 * _borderX)/itemSize.width : 0;
    
    return numOfPerRow;
}

- (NSInteger)numOfTotalRowIsSelected:(BOOL)flag
{
    
    NSInteger numOfTotal = [self.dataSource numberOfItemsForLauncherWithIsSelected:flag];
    
    NSInteger rowNums = self.numOfPerRow  ? (numOfTotal + (self.numOfPerRow - 1)) / (self.numOfPerRow) : 0;
    
    return rowNums;
}

- (CGFloat)itemSpacing
{
    CGSize itemSize = [self.dataSource sizeForLauncherItemView];
    CGFloat mainViewWidth = CGRectGetWidth(self.frame);
    
    //每个ItemView的间距
    CGFloat itemSpacing = self.numOfPerRow > 1 ? (mainViewWidth - 2 * _borderX - self.numOfPerRow * itemSize.width) / ((CGFloat)(self.numOfPerRow - 1)) : 0.f;
    
    return itemSpacing;
}

- (UIView *)tipsView
{
    if (_tipsView) {
        return _tipsView;
    }
    
    [_tipsView release];
    _tipsView = nil;
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(tipsViewForLauncherView:)]) {
        _tipsView = [[self.dataSource tipsViewForLauncherView:self] retain];
    }
    return _tipsView;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize itemSize = [self.dataSource sizeForLauncherItemView];
    [[self itemSubviewForType:FMItemSubViewForAll] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FMItemView *itemview = (FMItemView *)obj;
        itemview.size = itemSize;
    }];
    
}

- (void)show
{
    NSAssert([self numOfPerRow] != 0, @"每行的Item个数为0，不符合逻辑!");
    
    NSInteger selectedTotalNum = [self.dataSource numberOfItemsForLauncherWithIsSelected:YES];
    NSInteger moreTotalNum = [self.dataSource numberOfItemsForLauncherWithIsSelected:NO];
    
    CGSize itemSize = [self.dataSource sizeForLauncherItemView];
    
    NSInteger selectedRowNums = (selectedTotalNum + (self.numOfPerRow - 1))/self.numOfPerRow;
    for (int i = 0; i < selectedRowNums; i++) {
        if (![self lookForAppointItemView:i withIsSelectedView:YES] && _isFirstLoad) {
            FMItemView *itemview = [self newItemViewSubViewForPosition:i withIsSelectedView:YES];
            [self addSubview:itemview];
        }
    }
    
    CGFloat selectedViewHeight = _borderY * 2 + itemSize.height * selectedRowNums + (selectedRowNums - 1) * self.itemSpacing;
    if (![self.subviews containsObject:self.tipsView]) {
        [self addSubview:self.tipsView];
    }
    self.tipsView.top = selectedViewHeight;
    
    for (int j = 0; j < moreTotalNum; j++) {
        if (![self lookForAppointItemView:j withIsSelectedView:NO] && _isFirstLoad) {
            FMItemView *itemView = [self newItemViewSubViewForPosition:j withIsSelectedView:NO];
            [self addSubview:itemView];
        }
    }
    
    _isFirstLoad = NO;
}

#pragma mark -- 根据Index和是否是已选，生成新的ItemView
- (FMItemView *)newItemViewSubViewForPosition:(NSInteger)position
                           withIsSelectedView:(BOOL)flag
{
    
    CGSize itemSize = [self.dataSource sizeForLauncherItemView];
    
    NSInteger numOfPerRow = [self numOfPerRow];
    //当前的ItemView所在的列
    NSInteger  currentCol = position % numOfPerRow;
    //当前ItemView所在的行
    NSInteger  currentRow = position/numOfPerRow;
    
    //DLog(@"当前所在位置： 第%d行  第%d列",currentRow,currentCol);
    
    FMItemView *itemView = [[self.dataSource fMLauncherView:self itemViewForItemAtIndex:position isSelected:flag] retain];
    
    CGFloat itemOriginY = flag ? (_borderY + (itemSize.height + self.itemSpacing) * currentRow) : self.tipsView.bottom;
    
    itemView.frame = CGRectMake((_borderX + (itemSize.width + self.itemSpacing) * currentCol),itemOriginY,itemSize.width,itemSize.height);
    itemView.tag = flag ? (kEditeItemSelectedDefaultTag + position) : (kEditeItemCandidateDefaultTag + position);
    return [itemView autorelease];
}

#pragma mark -- 寻找指定的itemView
- (FMItemView *)lookForAppointItemView:(NSInteger)position
                    withIsSelectedView:(BOOL)flag
{
    FMItemView *itemView = nil;
    NSInteger viewTag = flag ? (kEditeItemSelectedDefaultTag + position) : (kEditeItemCandidateDefaultTag + position);
    for (UIView *v in [self itemSubviewForType:flag ? FMItemSubViewFoIsSelected : FMItemSubViewForMore]) {
        if ([v isKindOfClass:[FMItemView class]] && v.tag == viewTag) {
            itemView = (FMItemView *)v;
            return itemView;
        }
    }
    return itemView;
}


#pragma mark -- 根据当前的坐标点寻找ItemView的位置
- (NSInteger)positionForCurrentLocation:(CGPoint)location isSelectedView:(BOOL)flag
{
    CGSize itemSize = [self.dataSource sizeForLauncherItemView];
    
    CGPoint locationTouch = location;
    NSInteger numOfPerRow = [self numOfPerRow];
    
    CGPoint relativeLocation = CGPointMake(locationTouch.x - _borderX, locationTouch.y - _borderY - (flag ? self.tipsView.bottom : 0));
    //列
    int col = (int)(relativeLocation.x)/(itemSize.width + [self itemSpacing]);
    //行
    int row = (int)(relativeLocation.y)/(itemSize.height + [self itemSpacing]);
    int position = col + row * numOfPerRow;
    
    
    if (position >= [self.dataSource numberOfItemsForLauncherWithIsSelected:flag] || position < 0) {
        position = kFM_INVALID_POSITION;
    }else {
        CGPoint itemOrigin = [self originForItemAtPosition:position isSelectedView:flag selectedRowNumStatus:FMSelectedRowNumNomal];
        CGRect itemFrame = CGRectMake(itemOrigin.x,
                                      itemOrigin.y,
                                      itemSize.width,
                                      itemSize.height);
        if (!CGRectContainsPoint(itemFrame, relativeLocation))
        {
            position = kFM_INVALID_POSITION;
        }
    }
    
    return position;
}


#pragma mark -- 根据传进来的index得到对于ItemView的origin
- (CGPoint)originForItemAtPosition:(NSInteger)position
                    isSelectedView:(BOOL)flag
              selectedRowNumStatus:(FMSelectedRowNumStatus)status
{
    CGSize itemSize = [self.dataSource sizeForLauncherItemView];
    
    CGPoint origin = CGPointZero;
    NSInteger numOfPerRow = [self numOfPerRow];
    if (numOfPerRow > 0 && position >= 0) {
        NSUInteger col = position % numOfPerRow;
        NSUInteger row = position/numOfPerRow;
        
        CGFloat tipsViewOffsetY = 0;
        if (!flag) {
            if (status == FMSelectedRowNumAdd) {
                tipsViewOffsetY = itemSize.height + [self itemSpacing];
            }else if (status == FMSelectedRowNumMinus) {
                tipsViewOffsetY = -(itemSize.height + [self itemSpacing]);
            }
        }
        
        CGFloat originX = _borderX + (itemSize.width + [self itemSpacing]) * col;
        CGFloat originY = (_borderY + (itemSize.height + [self itemSpacing]) * row) + (!flag ? self.tipsView.bottom + tipsViewOffsetY : 0 );
        
        origin = CGPointMake(originX,originY);
    }
    return origin;
}

#pragma mark -- 检测当前点位于是否位于SelectedView
- (BOOL)isLocatedOnSelectedViewForPoint:(CGPoint)point
{
    BOOL flag = YES;
    if (self.tipsView.bottom <= point.y) {
        flag = NO;
    }
    return flag;
}

#pragma mark -- 点击选中事件
- (void)selectedItemView:(FMItemView *)itemView
                 AtIndex:(NSInteger)position
      withIsSelectedView:(BOOL)flag
{
    [self.delegate fMLauncherView:self didSelectedItemAtIndex:position isSelected:flag];
    
    [self insertObjectAtIndex:position
                 withItemView:itemView
               withIsSelected:!flag
                withAnimation:YES
     ];
}

#pragma mark -- 插入事件
- (void)insertObjectAtIndex:(NSInteger)index
               withItemView:(FMItemView *)itemView
             withIsSelected:(BOOL)flag
              withAnimation:(BOOL)animation
{
    NSInteger selectedTotalNum = [self.dataSource numberOfItemsForLauncherWithIsSelected:YES];
    NSInteger moreTotalNum = [self.dataSource numberOfItemsForLauncherWithIsSelected:NO];
    
    _canEdited = NO;
    [self bringSubviewToFront:itemView];
    if (flag) {
        NSInteger selectedTotalNum = [self.dataSource numberOfItemsForLauncherWithIsSelected:YES];
        CGPoint newPoint = [self originForItemAtPosition:(selectedTotalNum - 1) isSelectedView:YES selectedRowNumStatus:FMSelectedRowNumNomal];
        
        BOOL isNewRow = (((selectedTotalNum - 1)%([self numOfPerRow])) == 0);
        
        NSMutableArray *itemViewsArray = [NSMutableArray array];
        NSMutableArray *newPointsArray = [NSMutableArray array];
        
        for (int i = 0; i <= moreTotalNum ; i++) {
            FMItemView *cell = [self lookForAppointItemView:i withIsSelectedView:NO];
            if (cell.tag != itemView.tag) {
                [itemViewsArray addObject:cell];
            }
        }
        for (int j = 0; j < itemViewsArray.count; j++) {
            
        }
        
    }
    
}

#pragma mark -- UIGestureRegonizeDelegate method
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL valid = YES;
    
    if (gestureRecognizer == _tapGesture)
    {
        valid = ![_longPressGesture hasRecognizedValidGesture];
    }
    else if (gestureRecognizer == _longPressGesture)
    {
        //Dean修改
        valid = YES;
        //valid = (self.sortingDelegate || self.enableEditOnLongPress) && !isScrolling && !self.isEditing;
    }
    else if (gestureRecognizer == _panGesture)
    {
        valid = (self.movingItemView != nil && [_longPressGesture hasRecognizedValidGesture]);
    }
    else
    {
        valid = NO;
    }
    
    return (valid && _canEdited);
}

- (void)tapGestureUpdated:(UITapGestureRecognizer *)tapGesture
{
    CGPoint locationTouch = [tapGesture locationInView:self];
    BOOL isSelected = [self isLocatedOnSelectedViewForPoint:locationTouch];

    NSInteger position = [self positionForCurrentLocation:locationTouch isSelectedView:isSelected];
    FMItemView *itemView = [self lookForAppointItemView:position withIsSelectedView:isSelected];
    
    BOOL canEdit = YES;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(fMLancherView:canEditItemForIsSelectedAtIndex:)] && isSelected) {
        canEdit = [self.dataSource fMLancherView:self canEditItemForIsSelectedAtIndex:position];
        
    }
    
    if (position != kFM_INVALID_POSITION && canEdit) {
        [self selectedItemView:itemView
                       AtIndex:position
            withIsSelectedView:isSelected];
    }
}

- (void)longPressGestureUpdated:(UILongPressGestureRecognizer *)longPressGesture
{
    CGPoint locationTouch = [longPressGesture locationInView:self];
    BOOL isSelected = YES;
    if (CGRectContainsPoint(self.moreScrollView.frame, locationTouch)) {
        isSelected = NO;
        return;
    }
    
    NSInteger position = [self positionForCurrentLocation:locationTouch isSelectedView:isSelected];
    if (position == kFM_INVALID_POSITION || position == 0 || position == 1) {
        return;
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
            CGPoint locationTouch = [panGesture locationInView:self];
            BOOL isSelected = YES;
            if (CGRectContainsPoint(self.moreScrollView.frame, locationTouch)) {
                isSelected = NO;
                
            }
            [self sortingMoveDidStopAtPoint:locationTouch];
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


@end
