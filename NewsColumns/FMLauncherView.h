//
//  FMLauncherView.h
//  NewsColumns
//
//  Created by Apple on 14-2-19.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FMLauncherView;
@class FMItemView;

@protocol FMLauncherViewDataSource <NSObject>
@required
- (CGSize)sizeForLauncherItemView;
- (NSInteger)numberOfItemsForLauncherWithIsSelected:(BOOL)flag;
- (FMItemView *)fMLauncherView:(FMLauncherView *)launcherView
        itemViewForItemAtIndex:(NSInteger)index
                    isSelected:(BOOL)flag;
@optional
- (UIView *)tipsViewForLauncherView:(FMLauncherView *)launcherView;
- (BOOL)fMLancherView:(FMLauncherView *)launcherView canEditItemForIsSelectedAtIndex:(NSInteger)index;
@end

@protocol FMLauncherViewDelegate <NSObject>
@required
- (void)fMLauncherView:(FMLauncherView *)launcherView didSelectedItemAtIndex:(NSInteger)index isSelected:(BOOL)flag;
- (void)insertItemAtIndex:(NSInteger)index isSelected:(BOOL)flag;

@end

@interface FMLauncherView : UIView
@property (nonatomic, assign) IBOutlet id<FMLauncherViewDataSource>dataSource;
@property (nonatomic, assign) IBOutlet id<FMLauncherViewDelegate>delegate;

@property (nonatomic, assign) CGFloat borderX;
@property (nonatomic, assign) CGFloat borderY;

- (void)show;
@end
