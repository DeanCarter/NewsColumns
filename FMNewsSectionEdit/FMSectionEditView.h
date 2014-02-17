//
//  FMSectionEditView.h
//  NewsColumns
//
//  Created by Apple on 14-2-14.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FMSectionEditView;
@class FMEditItemView;
@class FMSectionEditViewLayOutStrategy;

@protocol FMSectionEditViewDataSource <NSObject>
@required
- (CGSize)sizeForSectionEditItemView:(FMSectionEditView *)sectionEditView ;
- (NSInteger)numberOfItemsInFMSectionEditView:(FMSectionEditView *)sectionEditView withIsSelectedView:(BOOL)flag;
- (FMEditItemView *)fMSectionEditView:(FMSectionEditView *)sectionEditView itemViewForItemAtIndex:(NSInteger)index withIsSelectedView:(BOOL)flag;


@optional
- (UIView *)tipsViewForFMSectionEditView:(FMSectionEditView *)sectionEditView;
- (BOOL)fMSectionEditView:(FMSectionEditView *)sectionEditView canDeleteItemAtIndex:(NSInteger)index;

@end


@protocol FMSectionEditViewActionDelegate <NSObject>
@required
- (void)fMSelectionEditView:(FMSectionEditView *)sectionEditView
        didTapOnItemAtIndex:(NSInteger)position
         withIsSelectedView:(BOOL)flag;
@optional
- (void)fMSelectionEditView:(FMSectionEditView *)sectionEditView deleteActionForItemAtIndex:(NSInteger)index;

@end

@protocol FMSectionEditViewSortDelegate <NSObject>
@required
- (void)fmSelectionEditView:(FMSectionEditView *)sectionEditView
            moveItemAtIndex:(NSInteger)oldIndex
                    toIndex:(NSInteger)newIndex;
- (void)fmSelectionEditView:(FMSectionEditView *)sectionEditView
        exchangeItemAtIndex:(NSInteger)oldIndex
            withItemAtIndex:(NSInteger)newIndex;
@optional
- (void)fMSelectionEditView:(FMSectionEditView *)sectionEditView didStartMovingItemView:(FMEditItemView *)itemView;
- (void)fMSelectionEditView:(FMSectionEditView *)sectionEditView didEndMovingItemView:(FMEditItemView *)itemView;

@end


@interface FMSectionEditView : UIView
@property (nonatomic, assign) IBOutlet id<FMSectionEditViewDataSource> dataSource;
@property (nonatomic, assign) IBOutlet id<FMSectionEditViewActionDelegate> actionDelegate;
@property (nonatomic, assign) IBOutlet id<FMSectionEditViewSortDelegate> sortDelegate;
@property (nonatomic, getter = isEditing) BOOL editing;
@property (nonatomic) BOOL enableEditOnLongPress;
@property (nonatomic, readwrite) CGFloat borderWidthX;
@property (nonatomic, readwrite) CGFloat borderHeightY;

- (void)setEditing:(BOOL)editing animated:(BOOL)animated;

- (void)show;

- (void)reloadSelectedData;
- (void)reloadcandidateData;

@end
