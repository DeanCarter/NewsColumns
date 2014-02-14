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
- (NSInteger)numberOfItemsInFMSectionEditView:(FMSectionEditView *)sectionEditView;
@optional
- (UIView *)tipsViewForFMSectionEditView:(FMSectionEditView *)sectionEditView;
- (BOOL)fMSectionEditView:(FMSectionEditView *)sectionEditView canDeleteItemAtIndex:(NSInteger)index;

@end


@protocol FMSectionEditViewActionDelegate <NSObject>
@required
- (void)fMSelectionEditView:(FMSectionEditView *)sectionEditView
        didTapOnItemAtIndex:(NSInteger)position;
@optional
- (void)fMSelectionEditView:(FMSectionEditView *)sectionEditView deleteActionForItemAtIndex:(NSInteger)index;
@end



@interface FMSectionEditView : UIView
@property (nonatomic, assign) IBOutlet id<FMSectionEditViewDataSource> dataSource;
@property (nonatomic, assign) IBOutlet id<FMSectionEditViewActionDelegate> actionDelegate;
@property (nonatomic, getter = isEditing) BOOL editing;

- (void)setEditing:(BOOL)editing animated:(BOOL)animated;

- (void)reloadSelectedData;
- (void)reloadcandidateData;

@end
