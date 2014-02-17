//
//  FMSectionView.m
//  NewsColumns
//
//  Created by Dean on 14-2-17.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import "FMSectionView.h"
#import "ItemView.h"
#import "UIGestureRecognizer+GMGridViewAdditions.h"

#define  kEditeItemSelectedDefaultTag   50
#define  kEditeItemCandidateDefaultTag  10000


#define  kFM_INVALID_POSITION  -1

static const CGFloat kDefaultAnimationDuration = 0.3;

@interface FMSectionView ()<UIGestureRecognizerDelegate>
{
    BOOL _canMoved;
    
    NSInteger _sortFuturePosition;
    
    BOOL  _isFirstLoad;
}

@property (nonatomic, retain) NSMutableArray *seletedArray;
@property (nonatomic, retain) NSMutableArray *moreArray;

@property (nonatomic, retain) UIView *tipsView;
@property (nonatomic, retain) UILabel *tipLabel;

@property (nonatomic, retain) UIScrollView *moreScrollView;

@property (nonatomic, retain) UITapGestureRecognizer *selectedViewTapGesture;
@property (nonatomic, retain) UITapGestureRecognizer *candidateViewTapGesture;
@property (nonatomic, retain) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, retain) UIPanGestureRecognizer *panGesture;


@property (nonatomic, assign) NSInteger firstPositionLoaded;
@property (nonatomic, assign) NSInteger lastPositionLoaded;



@property (nonatomic, retain) ItemView *movingItemView;
@end

@implementation FMSectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commitInit];
        
        self.seletedArray = [NSMutableArray arrayWithObjects:@"头条",@"娱乐",@"财经",@"科技",@"手机",@"北京",@"军事",@"游戏",@"汽车",@"轻松一刻",@"房产",@"时尚",@"历史",nil];
        self.moreArray = [NSMutableArray arrayWithObjects:@"电影",@"体育",@"彩票",@"微博",@"社会",@"历史",@"移动互联",@"教育",@"CBA",@"原创",@"养生",nil];
        //self.moreArray = [NSMutableArray arrayWithObjects:@"电影",@"体育",@"彩票",@"微博",@"社会",@"历史",@"论坛",@"家居",@"真话",@"旅游",@"移动互联",@"教育",@"CBA",@"原创",@"养生",nil];
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
    _tipsView = [[UIView alloc] initWithFrame:self.frame];
    _tipsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _tipsView.height = 40.f;
    _tipsView.backgroundColor = [UIColor grayColor];
    [self addSubview:self.tipsView];
    
    _tipLabel = [[UILabel alloc] initWithFrame:_tipsView.bounds];
    _tipLabel.textColor = [UIColor whiteColor];
    _tipLabel.textAlignment = UITextAlignmentCenter;
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.text = @"———— 点击增删 拖曳排序 ————";
    [self.tipsView addSubview:self.tipLabel];
    [_tipLabel release];
    
    _moreScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _moreScrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.moreScrollView];
    
    _selectedViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureUpdated:)];
    _selectedViewTapGesture.delegate = self;
    _selectedViewTapGesture.numberOfTapsRequired = 1;
    _selectedViewTapGesture.numberOfTouchesRequired = 1;
    _selectedViewTapGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:_selectedViewTapGesture];
    
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
}

- (NSInteger)numOfPerRow
{
    CGFloat mainViewWidth = CGRectGetWidth(self.frame);
    NSInteger numOfPerRow = self.itemSize.width ? mainViewWidth/self.itemSize.width : 0;
    
    return numOfPerRow;
}

- (NSInteger)numOfTotalRowIsSelected:(BOOL)flag
{
    NSInteger numOfTotal = flag ? self.seletedArray.count : self.moreArray.count;
    
    NSInteger rowNums = self.numOfPerRow  ? (numOfTotal + (self.numOfPerRow - 1)) / (self.numOfPerRow) : 0;
    
    return rowNums;
}

- (CGFloat)itemSpacing
{
    CGFloat mainViewWidth = CGRectGetWidth(self.frame);
    
    //每个ItemView的间距
    CGFloat itemSpacing = self.numOfPerRow > 0 ? (mainViewWidth - 2 * self.borderWidthX - self.numOfPerRow * self.itemSize.width) / ((CGFloat)(self.numOfPerRow - 1)) : 0.f;
    
    return itemSpacing;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self show];
}

- (void)show
{
    
    NSInteger numOfPerRow = [self numOfPerRow];
    if (numOfPerRow > 0) {
        NSInteger selectedRowNums = (self.seletedArray.count + (numOfPerRow - 1))/numOfPerRow;
        
        for (int i = 0; i < self.seletedArray.count; i++) {
            if (![self lookForAppointItemView:i withIsSelectedView:YES] && _isFirstLoad) {
                ItemView *itemView = [self newItemViewSubViewForPosition:i withIsSelectedView:YES];
                [self addSubview:itemView];
            }
        }
        
        CGFloat selectedViewHeight = self.borderHeightY * 2 + self.itemSize.height * selectedRowNums + (selectedRowNums - 1) * [self itemSpacing];
        
        self.tipsView.top = selectedViewHeight;
        
        NSInteger moreRowNums = (self.moreArray.count + (numOfPerRow - 1))/numOfPerRow;
        CGFloat contentHeight = self.borderHeightY * 2 + self.itemSize.height * moreRowNums + (moreRowNums - 1) * [self itemSpacing];
        
        self.moreScrollView.frame = CGRectMake(0, self.tipsView.bottom, self.frame.size.width, self.frame.size.height - self.tipsView.bottom);
        
        self.moreScrollView.backgroundColor = [UIColor yellowColor];
        
        self.moreScrollView.contentSize = CGSizeMake(self.moreScrollView.frame.size.width, contentHeight);
        
        for (int j = 0; j < self.moreArray.count; j++) {
            if (![self lookForAppointItemView:j withIsSelectedView:NO] && _isFirstLoad) {
                ItemView *itemView = [self newItemViewSubViewForPosition:j withIsSelectedView:NO];
                [self.moreScrollView addSubview:itemView];
            }
        }
        
        _isFirstLoad = NO;
    }
}

- (void)reloadData
{
    
}

#pragma mark -- 寻找指定的itemView
- (ItemView *)lookForAppointItemView:(NSInteger)position withIsSelectedView:(BOOL)flag
{
    ItemView *itemView = nil;
    UIView *view = flag ? self : self.moreScrollView;
    NSInteger viewTag = flag ? (kEditeItemSelectedDefaultTag + position) : (kEditeItemCandidateDefaultTag + position);
    for (UIView *v in view.subviews) {
        if ([v isKindOfClass:[ItemView class]] && v.tag == viewTag) {
            itemView = (ItemView *)v;
            return itemView;
        }
    }
    return itemView;
}

#pragma mark -- 根据当前的坐标点寻找ItemView的位置
- (NSInteger)positionForCurrentLocation:(CGPoint)location isSelectedView:(BOOL)flag
{
    CGPoint locationTouch = location;
    if (flag == NO) {
        locationTouch = [self convertPoint:location toView:self.moreScrollView];
    }
    
    NSInteger numOfPerRow = [self numOfPerRow];
    
    CGPoint relativeLocation = CGPointMake(locationTouch.x - self.borderWidthX, locationTouch.y - self.borderHeightY);
    //列
    int col = (int)(relativeLocation.x)/(self.itemSize.width + [self itemSpacing]);
    //行
    int row = (int)(relativeLocation.y)/(self.itemSize.height + [self itemSpacing]);
    int position = col + row * numOfPerRow;
    
    if (position >= (flag ? self.seletedArray.count : self.moreArray.count) || position < 0) {
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

#pragma mark -- 根据传进来的index得到对于ItemView的origin
- (CGPoint)originForItemAtPosition:(NSInteger)position
{
    CGPoint origin = CGPointZero;
    NSInteger numOfPerRow = [self numOfPerRow];
    if (numOfPerRow > 0 && position >= 0) {
        NSUInteger col = position % numOfPerRow;
        NSUInteger row = position/numOfPerRow;
        
        origin = CGPointMake((_borderWidthX + (self.itemSize.width + [self itemSpacing]) * col) , (_borderHeightY + (self.itemSize.height + [self itemSpacing]) * row));
    }
    return origin;
}


#pragma mark -- 根据Index和是否是已选，生成新的ItemView
- (ItemView *)newItemViewSubViewForPosition:(NSInteger)position withIsSelectedView:(BOOL)flag
{
    
    NSInteger numOfPerRow = [self numOfPerRow];
    //当前的ItemView所在的列
    NSInteger  currentCol = position % numOfPerRow;
    //当前ItemView所在的行
    NSInteger  currentRow = position/numOfPerRow;
    
    //DLog(@"当前所在位置： 第%d行  第%d列",currentRow,currentCol);
    
    ItemView *itemView = [[ItemView loadViewFromXib] retain];
    itemView.frame = CGRectMake((_borderWidthX + (self.itemSize.width + [self itemSpacing]) * currentCol) , (_borderHeightY + (self.itemSize.height + [self itemSpacing ]) * currentRow),self.itemSize.width,self.itemSize.height);
    itemView.contentView.frame = itemView.bounds;
    itemView.tipsLabel.text = [NSString stringWithFormat:@"%@",[(flag ? self.seletedArray : self.moreArray) objectAtIndex:position] ];
    itemView.tag = flag ? (kEditeItemSelectedDefaultTag + position) : (kEditeItemCandidateDefaultTag + position);
    return [itemView autorelease];
}

#pragma mark -- UIGesture method
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
    
    return valid;
}


- (void)tapGestureUpdated:(UITapGestureRecognizer *)tapGesture
{
    CGPoint locationTouch = [tapGesture locationInView:self];
    BOOL isSelected = YES;
    if (CGRectContainsPoint(self.moreScrollView.frame, locationTouch)) {
        isSelected = NO;
    }
    
    
    NSInteger position = [self positionForCurrentLocation:locationTouch isSelectedView:isSelected];
    ItemView *itemView = [self lookForAppointItemView:position withIsSelectedView:isSelected];
    
    if (position != kFM_INVALID_POSITION) {
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

- (void)sortingMoveDidStartAtPoint:(CGPoint)point
{
    NSInteger position = [self positionForCurrentLocation:point isSelectedView:YES];
    
    ItemView *itemView = [self lookForAppointItemView:position withIsSelectedView:YES];
    self.movingItemView = itemView;
    [self bringSubviewToFront:self.movingItemView];
    
    self.movingItemView.contentView.backgroundColor = [UIColor redColor];
    self.movingItemView.tipsLabel.textColor = [UIColor blackColor];
    
    self.firstPositionLoaded = position;
    
    _sortFuturePosition = position;
    
    _canMoved = YES;
    if (position == 0 || position == 1 || position == kFM_INVALID_POSITION) {
        _canMoved = NO;
    }
    
    self.movingItemView.tag = 0;
    
    [self startMovingItemView:self.movingItemView isSelectedView:YES];

    NSInteger itemViewCounts = 0;
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:[ItemView class]]) {
            itemViewCounts++;
        }
    }
    DLog(@"之后             有多少个视图：  %d",itemViewCounts);
    

}

- (void)sortingMoveDidStopAtPoint:(CGPoint)point
{
    self.movingItemView.tag = _sortFuturePosition + kEditeItemSelectedDefaultTag;
    self.movingItemView.contentView.backgroundColor = [UIColor yellowColor];
    
    CGPoint newOrign = [self originForItemAtPosition:_sortFuturePosition];
    CGRect newFrame = CGRectMake(newOrign.x, newOrign.y, self.itemSize.width, self.itemSize.height);
    
    [UIView animateWithDuration:kDefaultAnimationDuration
                          delay:0
                        options:0
                     animations:^{
                         self.movingItemView.transform = CGAffineTransformIdentity;
                         self.movingItemView.frame = newFrame;
                     } completion:^(BOOL finished) {
                         [self endMovingItemView:self.movingItemView isSelectedView:YES];
                
                         self.movingItemView = nil;
                         _sortFuturePosition = kFM_INVALID_POSITION;
                     }
     ];
    
}

- (void)sortingMoveDidContinueToPoint:(CGPoint)point
{
    
    BOOL isSelected = YES;
    if (CGRectContainsPoint(self.moreScrollView.frame, point)) {
        isSelected = NO;
        return;
    }
    int position = [self positionForCurrentLocation:point isSelectedView:YES];
    int tag = position + kEditeItemSelectedDefaultTag;
    
    if (position != kFM_INVALID_POSITION && position != 0 && position != 1 && position != _sortFuturePosition && position < self.seletedArray.count) {
        
        BOOL positionToken = NO;
        
        for (UIView *v in self.subviews) {
            if ([v isKindOfClass:[ItemView class]] && v.tag == tag && v != self.movingItemView) {
                
                positionToken = YES;
                break;
            }
        }
        
        if (positionToken) {
            if (self.movingItemView) {
                
                //                for (int i = 1; i <= abs(position - _sortFuturePosition); i++) {
                //                    //当前ItemView是往后移动，还是往前移动，往后移动为YES；
                //                    BOOL isForwardMoving = (position - _sortFuturePosition) > 0 ? YES : NO;
                //
                //                    NSInteger currentIndex = isForwardMoving > 0 ? _sortFuturePosition + i : _sortFuturePosition - i;
                //
                //                    ItemView *itemView = [self lookForAppointItemView:currentIndex withIsSelectedView:YES];
                //                    
                //                }

                
                
                //移动当前移动的ItemView移动到的地方的ItemView到初始移动位置
                UIView *v = [self lookForAppointItemView:position withIsSelectedView:YES];
                v.tag = _sortFuturePosition + kEditeItemSelectedDefaultTag;
                CGPoint origin = [self originForItemAtPosition:_sortFuturePosition];
                
                [UIView animateWithDuration:kDefaultAnimationDuration
                                      delay:0
                                    options:0
                                 animations:^{
                                     v.frame = CGRectMake(origin.x, origin.y, self.itemSize.width, self.itemSize.height);
                                 } completion:^(BOOL finished) {
                                     
                                 }];
            }
        }
        _sortFuturePosition = position;

    }
 }


- (void)insertObjectAtIndex:(NSInteger)index withAnimation:(BOOL)animation withIsSelected:(BOOL)flag withItemView:(ItemView *)itemView
{
    if (flag) {
        
        CGRect newFrame = [self.moreScrollView convertRect:itemView.frame toView:self];
        
        __block ItemView *cell = [itemView retain];
        [itemView removeFromSuperview];
        
        cell.frame = newFrame;
        [self addSubview:cell];
        [self bringSubviewToFront:cell];
        
        CGPoint newPoint = [self originForItemAtPosition: self.seletedArray.count ?  (self.seletedArray.count - 1) : 0];
        [UIView animateWithDuration:kDefaultAnimationDuration
                              delay:0
                            options:0
                         animations:^{
                             cell.frame = CGRectMake(newPoint.x, newPoint.y, self.itemSize.width, self.itemSize.height);
                             cell.tag = kEditeItemSelectedDefaultTag + (self.seletedArray.count - 1);
                         } completion:^(BOOL finished) {
                             [cell release];
                         }];
        
        
        NSMutableArray *itemsArray = [NSMutableArray array];
        NSMutableArray *pointsArray = [NSMutableArray array];
        for (int i = (index + 1); i <= self.moreArray.count; i++) {
            ItemView *itemV = [self lookForAppointItemView:i withIsSelectedView:NO];
            itemV.tag = kEditeItemCandidateDefaultTag + (i - 1);
            CGPoint changePoint = [self originForItemAtPosition:(i - 1)];
            
            
            //            [CATransaction begin];
            //            [CATransaction setAnimationDuration:kDefaultAnimationDuration];
            //            [CATransaction setCompletionBlock:^{
            //               itemV.frame = CGRectMake(changePoint.x, changePoint.y, self.itemSize.width, self.itemSize.height);
            //            }];
            //            [CATransaction commit];
            
            [itemsArray addObject:itemV];
            [pointsArray addObject:[NSValue valueWithCGPoint:changePoint]];
        }
        
        
        
        [UIView animateWithDuration:kDefaultAnimationDuration
                              delay:0
                            options:0
                         animations:^{
                             for (int i = 0; i < itemsArray.count; i++) {
                                 ItemView *itemV = [itemsArray objectAtIndex:i];
                                 CGPoint newPoint = [[pointsArray objectAtIndex:i] CGPointValue];
                                 itemView.frame = CGRectMake(newPoint.x, newPoint.y, self.itemSize.width, self.itemSize.height);
                             }
                             
                         } completion:^(BOOL finished) {
                             
                         }];
    }else {
        return;
        [self bringSubviewToFront:itemView];
        
        CGRect moreFirstFrame = CGRectMake([self originForItemAtPosition:0].x, [self originForItemAtPosition:0].y, self.itemSize.width, self.itemSize.height);
        
        CGRect relativeFrame = [self.moreScrollView convertRect:moreFirstFrame toView:self];
        
        
        NSMutableArray *itemsArray = [NSMutableArray array];
        for (int i = 1; i < self.moreArray.count; i++) {
            ItemView *itemV = [self lookForAppointItemView:i-1 withIsSelectedView:NO];
            [itemsArray addObject:itemV];
        }
        
        [UIView animateWithDuration:kDefaultAnimationDuration
                              delay:0
                            options:0
                         animations:^{
                             itemView.tag = kEditeItemCandidateDefaultTag;
                             itemView.frame = relativeFrame;
                             for (int i = 0; i < itemsArray.count; i++) {
                                 ItemView *itemV = [itemsArray objectAtIndex:i];
                                 itemV.tag += 1;
                                 CGPoint newPoint = [self originForItemAtPosition:(i+1)];
                                 itemView.frame = CGRectMake(newPoint.x, newPoint.y, self.itemSize.width, self.itemSize.height);
                             }
                             
                         } completion:^(BOOL finished) {
                             ItemView *cell = [itemView retain];
                             [itemView removeFromSuperview];
                             
                             cell.frame = moreFirstFrame;
                             [self.moreScrollView addSubview:cell];
                             [cell release];
                             //[self bringSubviewToFront:cell];
                         }];
        
        
        for (UIView *v in self.moreScrollView.subviews) {
            if ([v isKindOfClass:[ItemView class]]) {
                v.tag += 1;
            }
        }
    }
}

- (void)removeObjectAtIndex:(NSInteger)index withAnimation:(BOOL)animation withIsSelected:(BOOL)flag
{
    
}

#pragma mark -- 点击选中事件
- (void)selectedItemView:(ItemView *)itemView AtIndex:(NSInteger)position withIsSelectedView:(BOOL)flag
{
    if (flag) {
        NSObject *obj = [self.seletedArray objectAtIndex:position];
        [self.seletedArray removeObject:obj];
        [self.moreArray insertObject:obj atIndex:0];
        
        [self insertObjectAtIndex:position withAnimation:YES withIsSelected:!flag withItemView:itemView];
    }else {
        NSObject *obj = [self.moreArray objectAtIndex:position];
        [self.moreArray removeObject:obj];
        [self.seletedArray addObject:obj];
        
        [self insertObjectAtIndex:position withAnimation:YES withIsSelected:!flag withItemView:itemView];
    }
   // [self reloadData];
}

- (void)startMovingItemView:(ItemView *)itemView isSelectedView:(BOOL)flag
{
    
}

- (void)endMovingItemView:(ItemView *)itemView isSelectedView:(BOOL)flag
{
    
}

@end
