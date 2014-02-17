//
//  FMEditItemView.h
//  NewsColumns
//
//  Created by Apple on 14-2-14.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FMEditItemView;
typedef void(^FMEditItemViewDeleteBlock)(FMEditItemView *);

@interface FMEditItemView : UIView
@property (nonatomic, retain) IBOutlet UIView *contentView;

@property (nonatomic, copy) FMEditItemViewDeleteBlock deleteBlock;

@property (nonatomic, getter = isHighlighted) BOOL highlighted;

@property (nonatomic, getter = isEditing) BOOL editing;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;

@end
