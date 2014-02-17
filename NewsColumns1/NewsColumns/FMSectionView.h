//
//  FMSectionView.h
//  NewsColumns
//
//  Created by Dean on 14-2-17.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMSectionView : UIView
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGFloat borderWidthX;
@property (nonatomic, assign) CGFloat borderHeightY;

- (void)show;

@end
