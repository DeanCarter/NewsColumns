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

#define  kEditeItemDefaultTag   50

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
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
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
    
    _selectedView = [[UIView alloc] initWithFrame:CGRectZero];
    _selectedView.backgroundColor = [UIColor clearColor];
    [self addSubview:_selectedView];
    
    _candidateView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _candidateView.backgroundColor = [UIColor clearColor];
    [self addSubview:_candidateView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
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
                NSInteger index = v.tag - kEditeItemDefaultTag;
                
            }
        }
    };
}

#pragma mark -- getter && setter
- (void)setDataSource:(id<FMSectionEditViewDataSource>)dataSource
{
    _dataSource = dataSource;
    [self reloadSelectedData];
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
