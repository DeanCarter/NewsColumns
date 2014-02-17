//
//  FMEditItemView.m
//  NewsColumns
//
//  Created by Apple on 14-2-14.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import "FMEditItemView.h"
#import "UIView+GMGridViewAdditions.h"

@implementation FMEditItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setEditing:(BOOL)editing
{
    [self setEditing:editing animated:NO];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{

}

- (void)setHighlighted:(BOOL)aHighlighted
{
    _highlighted = aHighlighted;
    
    [self.contentView recursiveEnumerateSubviewsUsingBlock:^(UIView *view, BOOL *stop) {
        if ([view respondsToSelector:@selector(setHighlighted:)]) {
            [(UIControl *)view setHighlighted:aHighlighted];
        }
    }];
}

@end
