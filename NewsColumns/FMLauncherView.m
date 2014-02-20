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



static const CGFloat kDefaultAnimationDuration = 0.3;

typedef enum {
    FMItemSubViewForAll,
    FMItemSubViewForIsSelected,
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
    
    NSInteger _selectedItemTag;
    
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
    
    _selectedItemTag = kFM_INVALID_POSITION;
    
    _isFirstLoad = YES;
    
    _canEdited = YES;
    
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
                }else if (type == FMItemSubViewForIsSelected) {
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
    
//    CGSize itemSize = [self.dataSource sizeForLauncherItemView];
//    [[self itemSubviewForType:FMItemSubViewForAll] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        FMItemView *itemview = (FMItemView *)obj;
//        itemview.size = itemSize;
//    }];
    
    [self show];
    
}

- (void)show
{
    NSAssert([self numOfPerRow] != 0, @"每行的Item个数为0，不符合逻辑!");
    DLog(@"\n     *     \n    ***    \n   *****   \n  *******  \n ********* \n***********\n");
    NSInteger selectedTotalNum = [self.dataSource numberOfItemsForLauncherWithIsSelected:YES];
    NSInteger moreTotalNum = [self.dataSource numberOfItemsForLauncherWithIsSelected:NO];
    
    CGSize itemSize = [self.dataSource sizeForLauncherItemView];
    
    NSInteger selectedRowNums = (selectedTotalNum + (self.numOfPerRow - 1))/self.numOfPerRow;
    for (int i = 0; i < selectedTotalNum; i++) {
        if (![self lookForAppointItemView:i withIsSelectedView:YES] && _isFirstLoad) {
            FMItemView *itemview = [self newItemViewSubViewForPosition:i withIsSelectedView:YES];
            [self addSubview:itemview];
            
        }
    }
    
    CGFloat selectedViewHeight = _borderY * 2 + itemSize.height * selectedRowNums + (selectedRowNums - 1) * self.itemSpacing;
    if (![self.subviews containsObject:self.tipsView]) {
        [self addSubview:self.tipsView];
    }
    if (_isFirstLoad) {
        self.tipsView.top = selectedViewHeight;
    }
    
    for (int j = 0; j < moreTotalNum; j++) {
        if (![self lookForAppointItemView:j withIsSelectedView:NO] && _isFirstLoad) {
            FMItemView *itemView = [self newItemViewSubViewForPosition:j withIsSelectedView:NO];
            [self addSubview:itemView];
        }
    }
    
    _isFirstLoad = NO;
    
    DLog(@"\n     &     \n    &&&    \n   &&&&&   \n  &&&&&&&  \n &&&&&&&&& \n&&&&&&&&&&&&\n");
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
    
    CGFloat itemOriginY = flag ? (_borderY + (itemSize.height + self.itemSpacing) * currentRow) : (self.tipsView.bottom + (_borderY + (itemSize.height + self.itemSpacing) * currentRow));
    
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
    for (UIView *v in [self itemSubviewForType:(flag ? FMItemSubViewForIsSelected : FMItemSubViewForMore)]) {
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
    
    CGPoint relativeLocation = CGPointMake(locationTouch.x - _borderX, locationTouch.y - _borderY - (!flag ? self.tipsView.bottom : 0));
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
        if (!CGRectContainsPoint(itemFrame, locationTouch))
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


#pragma mark -- 从选中第index项移除，插入到备选项的第position的位置
- (void)removeItemView:(FMItemView *)itemView
         removeAtIndex:(NSInteger)index
      insertAtPosition:(NSInteger)position
   isSelectedForRemove:(BOOL)flag
{
    [self.delegate fMLauncherView:self
                    removeAtIndex:index
                 insertAtPosition:position
              isSelectedForRemove:flag
     ];
    
    [self insertItemAtPosition:position
             removeItemAtIndex:index
                  withItemView:itemView
         isSelectedFromRemoved:flag
     ];
    
}

#pragma mark -- 点击选中事件
- (void)selectedItemView:(FMItemView *)itemView
                 AtIndex:(NSInteger)position
      withIsSelectedView:(BOOL)flag
{
    NSInteger selectedTotalNum = [self.dataSource numberOfItemsForLauncherWithIsSelected:YES];
    
    [self removeItemView:itemView
           removeAtIndex:position
        insertAtPosition:(flag ? 0 : selectedTotalNum)
     isSelectedForRemove:flag
     ];
    
    return;
    [self.delegate fMLauncherView:self
           didSelectedItemAtIndex:position
                       isSelected:flag];
    
    [self insertObjectAtIndex:position
                 withItemView:itemView
               withIsSelected:!flag
                withAnimation:YES
     ];
}

- (void)insertItemAtPosition:(NSInteger)position
                withItemView:(FMItemView *)itemView
                  isSelected:(BOOL)flag
{
    CGSize itemSize = [self.dataSource sizeForLauncherItemView];
    
    NSInteger selectedTotalNum = [self.dataSource numberOfItemsForLauncherWithIsSelected:YES];
    NSInteger moreTotalNum = [self.dataSource numberOfItemsForLauncherWithIsSelected:NO];
    NSInteger selectedRowNums = (selectedTotalNum + (self.numOfPerRow - 1))/self.numOfPerRow;
    
    [self bringSubviewToFront:itemView];
    
    

}

- (void)removeItemAtPosition:(NSInteger)position
                withItemView:(FMItemView *)itemView
                  isSelected:(BOOL)flag
{
    
}


#pragma mark -- 移除&&插入事件
- (void)insertItemAtPosition:(NSInteger)position
           removeItemAtIndex:(NSInteger)index
                withItemView:(FMItemView *)itemView
       isSelectedFromRemoved:(BOOL)flag
{
    CGSize itemSize = [self.dataSource sizeForLauncherItemView];
    
    NSInteger selectedTotalNum = [self.dataSource numberOfItemsForLauncherWithIsSelected:YES];
    NSInteger moreTotalNum = [self.dataSource numberOfItemsForLauncherWithIsSelected:NO];
    NSInteger selectedRowNums = (selectedTotalNum + (self.numOfPerRow - 1))/self.numOfPerRow;
    
    _canEdited = YES;
    [self bringSubviewToFront:itemView];
    
    //从备选项移除，插入到已选项中
    if (!flag) {
        CGPoint newPoint = [self originForItemAtPosition:position isSelectedView:YES selectedRowNumStatus:FMSelectedRowNumNomal];
        
        BOOL isNewRow = (((selectedTotalNum - 1)%([self numOfPerRow])) == 0);
        
        NSMutableArray *moreItemsArray = [NSMutableArray array];
        NSMutableArray *newMorePointsArray = [NSMutableArray array];
        
        for (int i = 0; i <= moreTotalNum ; i++) {
            FMItemView *cell = [self lookForAppointItemView:i withIsSelectedView:NO];
            CGPoint newItemPoint = [self originForItemAtPosition:(i > index ? (i - 1) :i)
                                                  isSelectedView:NO
                                            selectedRowNumStatus:(isNewRow ? FMSelectedRowNumAdd : FMSelectedRowNumNomal)
                                    ];
            if (index == i) {
                cell.tag = kFM_INVALID_POSITION;
            }
            cell.tag = (i > index ? (cell.tag - 1) : cell.tag);
            if (cell.tag != itemView.tag) {
                [moreItemsArray addObject:cell];
                [newMorePointsArray addObject:[NSValue valueWithCGPoint:newItemPoint]];
            }
        }

        
        NSMutableArray *selectedItemsArray = [NSMutableArray array];
        NSMutableArray *newSelectedPointsArray = [NSMutableArray array];
        for (int j = position; j < (selectedTotalNum - 1); j++) {
            FMItemView *selectedCell = [self lookForAppointItemView:j withIsSelectedView:YES];
            //selectedCell.tag += 1;//写的有问题，每次加1，下次取的cell还是当前的cell
            [selectedItemsArray addObject:selectedCell];
            
            CGPoint newItemPoint = [self originForItemAtPosition:(j + 1)
                                                  isSelectedView:YES
                                            selectedRowNumStatus:FMSelectedRowNumNomal];
            [newSelectedPointsArray addObject:[NSValue valueWithCGPoint:newItemPoint]];
        }

        
        [UIView animateWithDuration:kDefaultAnimationDuration
                              delay:0
                            options:0
                         animations:^{
                             itemView.frame = CGRectMake(newPoint.x, newPoint.y, itemSize.width, itemSize.height);
                             itemView.tag = kEditeItemSelectedDefaultTag + position;
                             
                             for (int n = 0; n < moreItemsArray.count; n++) {
                                 FMItemView *cell = [moreItemsArray objectAtIndex:n];
                                 CGPoint newItemPoint = [[newMorePointsArray objectAtIndex:n] CGPointValue];
                                 cell.frame = CGRectMake(newItemPoint.x, newItemPoint.y, itemSize.width, itemSize.height);
                             }
                             
                             for (int m = 0; m < selectedItemsArray.count; m++) {
                                 FMItemView *cell = [selectedItemsArray objectAtIndex:m];
                                 CGPoint newItemPoint = [[newSelectedPointsArray objectAtIndex:m] CGPointValue];
                                 cell.tag += 1;
                                 cell.frame = CGRectMake(newItemPoint.x, newItemPoint.y, itemSize.width, itemSize.height);
                             }
                             
                             CGFloat selectedViewHeight = _borderY * 2 + itemSize.height * selectedRowNums + (selectedRowNums - 1) * self.itemSpacing;
                             self.tipsView.top = selectedViewHeight;
                             
                         } completion:^(BOOL finished) {
                             _canEdited = YES;
                         }];

    }else {
        //从已选项移除，插入到背选项中
        BOOL isNewRow = ((selectedTotalNum %([self numOfPerRow])) == 0);
        
        CGPoint newPoint = [self originForItemAtPosition:position
                                          isSelectedView:NO
                                    selectedRowNumStatus:(isNewRow ? FMSelectedRowNumMinus : FMSelectedRowNumNomal)
                            ];
        
        
        
        NSMutableArray *selectedItemsArray = [NSMutableArray array];
        NSMutableArray *newSelectedPointsArray = [NSMutableArray array];

        
        for (int i = 0; i <= selectedTotalNum ; i++) {
            FMItemView *cell = [self lookForAppointItemView:i withIsSelectedView:YES];
            CGPoint newItemPoint = [self originForItemAtPosition:(i > index ? (i - 1) :i)
                                                  isSelectedView:YES
                                            selectedRowNumStatus:(isNewRow ? FMSelectedRowNumMinus : FMSelectedRowNumNomal)
                                    ];
            if (index == i) {
                cell.tag = kFM_INVALID_POSITION;
            }else {
                [selectedItemsArray addObject:cell];
                [newSelectedPointsArray addObject:[NSValue valueWithCGPoint:newItemPoint]];
            }
        }
        
        for (int i = 0; i < selectedItemsArray.count; i++) {
            FMItemView *cell = [selectedItemsArray objectAtIndex:i];
            cell.tag -= (i >= index ? 1 : 0);
        }
        
        NSMutableArray *moreItemsArray = [NSMutableArray array];
        NSMutableArray *newMorePointsArray = [NSMutableArray array];

        for (int j = 0; j < (moreTotalNum - 1); j++) {
            FMItemView *moreCell = [self lookForAppointItemView:j withIsSelectedView:NO];
           // moreCell.tag += 1; //写的有问题，每次加1，下次取的cell还是当前的cell
            [moreItemsArray addObject:moreCell];
            

            
            CGPoint newItemPoint = [self originForItemAtPosition:(j >= position ? (j + 1) : j)
                                                  isSelectedView:NO
                                            selectedRowNumStatus:(isNewRow ? FMSelectedRowNumMinus : FMSelectedRowNumNomal)
                                    ];
            
            [newMorePointsArray addObject:[NSValue valueWithCGPoint:newItemPoint]];
        }
        for (int a = 0; a < moreItemsArray.count; a++) {
            FMItemView *moreCell = [moreItemsArray objectAtIndex:a];
            moreCell.tag += (a >= position ? 1 : 0);
        }
        
        itemView.tag = kEditeItemCandidateDefaultTag + position;

        [UIView animateWithDuration:kDefaultAnimationDuration
                              delay:0
                            options:0
                         animations:^{
                             //itemView.transform = CGAffineTransformIdentity;
                             //itemView.frame = CGRectMake(newPoint.x, newPoint.y, itemSize.width, itemSize.height);
                             
                             for (int n = 0; n < moreItemsArray.count; n++) {
                                 FMItemView *cell = [moreItemsArray objectAtIndex:n];
                                 CGPoint newMoreItemPoint = [[newMorePointsArray objectAtIndex:n] CGPointValue];
                                 cell.frame = CGRectMake(newMoreItemPoint.x, newMoreItemPoint.y, itemSize.width, itemSize.height);
    
                             }

                             for (int m = 0; m < selectedItemsArray.count; m++) {
                                 FMItemView *cell = [selectedItemsArray objectAtIndex:m];
                                 CGPoint newItemPoint = [[newSelectedPointsArray objectAtIndex:m] CGPointValue];
                                 cell.frame = CGRectMake(newItemPoint.x, newItemPoint.y, itemSize.width, itemSize.height);
                             }
                             
                             CGFloat selectedViewHeight = _borderY * 2 + itemSize.height * selectedRowNums + (selectedRowNums - 1) * self.itemSpacing;
                             self.tipsView.top = selectedViewHeight;

                         } completion:^(BOOL finished) {
                             //_canEdited = YES;
                         }];

        
    }
}



#pragma mark -- 插入事件
- (void)insertObjectAtIndex:(NSInteger)index
               withItemView:(FMItemView *)itemView
             withIsSelected:(BOOL)flag
              withAnimation:(BOOL)animation
{
    CGSize itemSize = [self.dataSource sizeForLauncherItemView];
    
    NSInteger selectedTotalNum = [self.dataSource numberOfItemsForLauncherWithIsSelected:YES];
    NSInteger moreTotalNum = [self.dataSource numberOfItemsForLauncherWithIsSelected:NO];
    NSInteger selectedRowNums = (selectedTotalNum + (self.numOfPerRow - 1))/self.numOfPerRow;

    _canEdited = NO;
    [self bringSubviewToFront:itemView];
    if (flag) {
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
            CGPoint newItemPoint = [self originForItemAtPosition:j
                                              isSelectedView:NO
                                        selectedRowNumStatus:(isNewRow ? FMSelectedRowNumAdd : FMSelectedRowNumNomal)
                                ];
            [newPointsArray addObject:[NSValue valueWithCGPoint:newItemPoint]];
        }
        
        [UIView animateWithDuration:kDefaultAnimationDuration
                              delay:0
                            options:0
                         animations:^{
                             itemView.frame = CGRectMake(newPoint.x, newPoint.y, itemSize.width, itemSize.height);
                             itemView.tag = kEditeItemSelectedDefaultTag + (selectedTotalNum - 1);
                             
                             for (int n = 0; n < itemViewsArray.count; n++) {
                                 FMItemView *cell = [itemViewsArray objectAtIndex:n];
                                 CGPoint newItemPoint = [[newPointsArray objectAtIndex:n] CGPointValue];
                                 cell.frame = CGRectMake(newItemPoint.x, newItemPoint.y, itemSize.width, itemSize.height);
                                 cell.tag = kEditeItemCandidateDefaultTag + n;
                                 
                             }
                             
                             CGFloat selectedViewHeight = _borderY * 2 + itemSize.height * selectedRowNums + (selectedRowNums - 1) * self.itemSpacing;
                             self.tipsView.top = selectedViewHeight;
                             
                         } completion:^(BOOL finished) {
                             _canEdited = YES;
                         }];
        
    }else {
        BOOL isNewRow = ((selectedTotalNum %([self numOfPerRow])) == 0);
        CGPoint newPoint = [self originForItemAtPosition:0
                                          isSelectedView:NO
                                    selectedRowNumStatus:(isNewRow ? FMSelectedRowNumMinus : FMSelectedRowNumNomal)
                            ];
        
        NSMutableArray *moreItemsArray = [NSMutableArray array];
        for (int i = 1; i < moreTotalNum; i++) {
            FMItemView *moreCell = [self lookForAppointItemView:(i - 1) withIsSelectedView:NO];
            [moreItemsArray addObject:moreCell];
        }
        
        
        NSMutableArray *selectedItemsArray = [NSMutableArray array];
        NSMutableArray *newPointsArray = [NSMutableArray array];
        for (int j = (index + 1); j <= selectedTotalNum; j++) {
            FMItemView *selectedCell = [self lookForAppointItemView:j withIsSelectedView:YES];
            selectedCell.tag = kEditeItemSelectedDefaultTag + (j - 1);
            [selectedItemsArray addObject:selectedCell];
            
            CGPoint newItemPoint = [self originForItemAtPosition:(j - 1)
                                                  isSelectedView:YES
                                            selectedRowNumStatus:FMSelectedRowNumNomal];
            [newPointsArray addObject:[NSValue valueWithCGPoint:newItemPoint]];
        }
        
        [UIView animateWithDuration:kDefaultAnimationDuration
                              delay:0
                            options:0
                         animations:^{
                             
                             itemView.tag = kEditeItemCandidateDefaultTag;
                             itemView.frame = CGRectMake(newPoint.x, newPoint.y, itemSize.width, itemSize.height);
                             
                             for (int i = 0; i < moreItemsArray.count; i++) {
                                 FMItemView *moreCell = [moreItemsArray objectAtIndex:i];
                                 moreCell.tag += 1;
                                 
                                 CGPoint moreNewPoint = [self originForItemAtPosition:(i + 1)
                                                                       isSelectedView:NO
                                                                 selectedRowNumStatus:(isNewRow ? FMSelectedRowNumMinus : FMSelectedRowNumNomal)
                                                         ];
                                 moreCell.frame = CGRectMake(moreNewPoint.x, moreNewPoint.y, itemSize.width, itemSize.height);
                             }
                             
                             for (int j = 0; j < selectedItemsArray.count; j++) {
                                 FMItemView *selectedCell = [selectedItemsArray objectAtIndex:j];
                                 CGPoint selectedNewPoint = [[newPointsArray objectAtIndex:j] CGPointValue];
                                 selectedCell.frame = CGRectMake(selectedNewPoint.x, selectedNewPoint.y, itemSize.width, itemSize.height);
                             }
                             
                             CGFloat selectedViewHeight = _borderY * 2 + itemSize.height * selectedRowNums + (selectedRowNums - 1) * self.itemSpacing;
                             self.tipsView.top = selectedViewHeight;
                             
                         } completion:^(BOOL finished) {
                             _canEdited = YES;
                         }];
    }
    
}

- (void)sortingMoveDidStartAtPoint:(CGPoint)point isSelected:(BOOL)flag
{
    NSInteger position = [self positionForCurrentLocation:point isSelectedView:flag];
    
    FMItemView *itemView = [self lookForAppointItemView:position withIsSelectedView:flag];
    self.movingItemView = itemView;
    [self bringSubviewToFront:self.movingItemView];
    
    _sortFuturePosition = position;
    
    _selectedItemTag = position + (flag ? kEditeItemSelectedDefaultTag : kEditeItemCandidateDefaultTag);
    
    _canMoved = YES;
    if (position == kFM_INVALID_POSITION) {
        _canMoved = NO;
    }
    if (flag) {
        if (![self.dataSource fMLancherView:self canEditItemForIsSelectedAtIndex:position]) {
            _canMoved = NO;
        }
    }
    
    self.movingItemView.tag = 0;
    
}

- (void)sortingMoveDidStopAtPoint:(CGPoint)point isSelected:(BOOL)flag
{
    
    CGSize itemSize = [self.dataSource sizeForLauncherItemView];
    
    self.movingItemView.tag = _sortFuturePosition + (flag ? kEditeItemSelectedDefaultTag : kEditeItemCandidateDefaultTag);
    
    CGPoint newOrign = [self originForItemAtPosition:_sortFuturePosition
                                      isSelectedView:flag
                                selectedRowNumStatus:FMSelectedRowNumNomal];
    CGRect newRect = CGRectMake(newOrign.x, newOrign.y, itemSize.width, itemSize.height);
    
    [UIView animateWithDuration:kDefaultAnimationDuration
                          delay:0
                        options:0
                     animations:^{
                         self.movingItemView.transform = CGAffineTransformIdentity;
                         self.movingItemView.frame = newRect;
                     } completion:^(BOOL finished) {
                         self.movingItemView = nil;
                         _sortFuturePosition = kFM_INVALID_POSITION;
                         _selectedItemTag = kFM_INVALID_POSITION;
                     }
     ];

}

- (void)sortingMoveDidContinueToPoint:(CGPoint)point isSelected:(BOOL)flag
{
    
    CGSize itemSize = [self.dataSource sizeForLauncherItemView];
    
    BOOL movingIsSelected = YES;
    if (_selectedItemTag - kEditeItemCandidateDefaultTag >= 0) {
        movingIsSelected = NO;
    }
 
    int position = [self positionForCurrentLocation:point isSelectedView:flag];
    
    int currentItemTag = position + (flag ? kEditeItemSelectedDefaultTag : kEditeItemCandidateDefaultTag);
    
    
    NSInteger status = kFM_INVALID_POSITION;
    if (_selectedItemTag >= kEditeItemCandidateDefaultTag && currentItemTag < kEditeItemCandidateDefaultTag) {
        //从备选项移到已选项
        if (position == kFM_INVALID_POSITION || position > [self.dataSource numberOfItemsForLauncherWithIsSelected:NO]) {
            position = [self.dataSource numberOfItemsForLauncherWithIsSelected:NO];
        }
        status = 1;
        [self removeItemView:self.movingItemView
               removeAtIndex:_sortFuturePosition
            insertAtPosition:position
         isSelectedForRemove:NO
         ];
        
        
    }else if (currentItemTag >= kEditeItemCandidateDefaultTag && _selectedItemTag < kEditeItemCandidateDefaultTag) {
        //从已选项移到备选项
        if (position == kFM_INVALID_POSITION || position > [self.dataSource numberOfItemsForLauncherWithIsSelected:NO]) {
            position = [self.dataSource numberOfItemsForLauncherWithIsSelected:NO];
        }
        status = 2;
        [self removeItemView:self.movingItemView
               removeAtIndex:_sortFuturePosition
            insertAtPosition:position
         isSelectedForRemove:YES
         ];
        
        _sortFuturePosition = position;
        _selectedItemTag = currentItemTag;
    }else if (currentItemTag < kEditeItemCandidateDefaultTag && _selectedItemTag < kEditeItemCandidateDefaultTag) {
        //在已选项移动
        status = 3;
        if (position == kFM_INVALID_POSITION || position == _sortFuturePosition || (position >= [self.dataSource numberOfItemsForLauncherWithIsSelected:YES])) {
            return;
        }
        if (flag) {
            if (![self.dataSource fMLancherView:self canEditItemForIsSelectedAtIndex:position]) {
                return;
            }
        }
        
        BOOL positionToken = NO;
        
        for (UIView *v in [self itemSubviewForType:FMItemSubViewForIsSelected]) {
            if ([v isKindOfClass:[FMItemView class]] && v.tag == currentItemTag && v != self.movingItemView) {
                positionToken = YES;
                break;
            }
        }
 
        if (positionToken) {
            if (self.movingItemView) {
                //移动当前移动的ItemView移动到的地方的ItemView到初始移动位置
                UIView *v = [self lookForAppointItemView:position withIsSelectedView:YES];
                v.tag = _sortFuturePosition + kEditeItemSelectedDefaultTag;
                CGPoint origin = [self originForItemAtPosition:_sortFuturePosition
                                                isSelectedView:YES
                                          selectedRowNumStatus:FMSelectedRowNumNomal
                                  ];
                
                [UIView animateWithDuration:(kDefaultAnimationDuration - .1)
                                      delay:0
                                    options:0
                                 animations:^{
                                     v.frame = CGRectMake(origin.x, origin.y, itemSize.width,itemSize.height);
                                 } completion:^(BOOL finished) {
                                     
                                 }];
            }
            _sortFuturePosition = position;
            _selectedItemTag = currentItemTag;
        }
        
    }else if (currentItemTag >= kEditeItemCandidateDefaultTag && _selectedItemTag >= kEditeItemCandidateDefaultTag) {
        //在备选项移动
        status = 4;
        
        if (position == kFM_INVALID_POSITION || position == _sortFuturePosition || (position >= [self.dataSource numberOfItemsForLauncherWithIsSelected:YES])) {
            return;
        }
        
        BOOL positionToken = NO;
        
        for (UIView *v in [self itemSubviewForType:FMItemSubViewForMore]) {
            if ([v isKindOfClass:[FMItemView class]] && v.tag == currentItemTag && v != self.movingItemView) {
                positionToken = YES;
                break;
            }
        }
        
        if (positionToken) {
            if (self.movingItemView) {
                //移动当前移动的ItemView移动到的地方的ItemView到初始移动位置
                UIView *v = [self lookForAppointItemView:position withIsSelectedView:NO];
                v.tag = _sortFuturePosition + kEditeItemCandidateDefaultTag;
                CGPoint origin = [self originForItemAtPosition:_sortFuturePosition
                                                isSelectedView:NO
                                          selectedRowNumStatus:FMSelectedRowNumNomal
                                  ];
                
                [UIView animateWithDuration:(kDefaultAnimationDuration - .1)
                                      delay:0
                                    options:0
                                 animations:^{
                                     v.frame = CGRectMake(origin.x, origin.y, itemSize.width,itemSize.height);
                                 } completion:^(BOOL finished) {
                                     
                                 }];
            }
            DLog(@"被调用了!");
            _sortFuturePosition = position;
            _selectedItemTag = currentItemTag;
        }

    }
    
    
    return;
    BOOL hasChangeArea = NO;
    if ((_selectedItemTag >= kEditeItemCandidateDefaultTag && currentItemTag < kEditeItemCandidateDefaultTag) || (currentItemTag >= kEditeItemCandidateDefaultTag && _selectedItemTag < kEditeItemSelectedDefaultTag) ) {
        hasChangeArea = YES;
    }
    
    if (movingIsSelected && point.y > self.tipsView.bottom && position != kFM_INVALID_POSITION) {
        //这是属于从已选项里移除，然后插入在备选项中
        [self removeItemView:self.movingItemView
               removeAtIndex:_sortFuturePosition
            insertAtPosition:position
         isSelectedForRemove:!flag
         ];
    }else if (!movingIsSelected && point.y < self.tipsView.top && position != kFM_INVALID_POSITION && [self.dataSource fMLancherView:self canEditItemForIsSelectedAtIndex:position]) {
        //这属于从备选项里移除，插入到已选项里
    }else {
        
    }
    
//    if (movingIsSelected && point.y >= self.tipsView.bottom) {
//        if (position == kFM_INVALID_POSITION) {
//           // position = [self.dataSource numberOfItemsForLauncherWithIsSelected:NO];
//            position = 0;
//        }
//        DLog(@"_sortIndex: %d    insertIndex: %d",_sortFuturePosition,position);
//
//        //这是属于从已选项里移除，然后插入在备选项中
//        [self removeItemView:self.movingItemView
//               removeAtIndex:_sortFuturePosition
//            insertAtPosition:position
//         isSelectedForRemove:!flag
//         ];
//    }else if (!movingIsSelected && point.y <= self.tipsView.top) {
//        //这属于从备选项里移除，插入到已选项里
//        [self removeItemView:self.movingItemView
//               removeAtIndex:_sortFuturePosition
//            insertAtPosition:position
//         isSelectedForRemove:!flag
//         ];
//    }
    
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
    BOOL isSelected = [self isLocatedOnSelectedViewForPoint:locationTouch];
    
    
    NSInteger position = [self positionForCurrentLocation:locationTouch isSelectedView:isSelected];
    if (position == kFM_INVALID_POSITION) {
        return;
    }
    if (isSelected) {
        if (![self.dataSource fMLancherView:self canEditItemForIsSelectedAtIndex:position]) {
            return;
        }
    }
    
    
    switch (longPressGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (!_movingItemView) {
                CGPoint locationTouch = [longPressGesture locationInView:self];
                NSInteger position = [self positionForCurrentLocation:locationTouch isSelectedView:isSelected];
                
                if (position != kFM_INVALID_POSITION) {
                    [self sortingMoveDidStartAtPoint:locationTouch isSelected:isSelected];
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
                [self sortingMoveDidStopAtPoint:touchLocation isSelected:isSelected];
            }
        }
            break;
        default:
            break;
    }
}

- (void)panGestureUpdated:(UIPanGestureRecognizer *)panGesture
{
    if (!_canMoved || !_canEdited) {
        return;
    }
    
    CGPoint locationTouch = [panGesture locationInView:self];
    BOOL isSelected = [self isLocatedOnSelectedViewForPoint:locationTouch];

    switch (panGesture.state) {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [self sortingMoveDidStopAtPoint:locationTouch isSelected:isSelected];
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
            
            self.movingItemView.transform = CGAffineTransformMakeTranslation(offset.x, offset.y);
            [self sortingMoveDidContinueToPoint:locationTouch isSelected:isSelected];
            
        }
            break;
        default:
            break;
    }
    
}


@end
