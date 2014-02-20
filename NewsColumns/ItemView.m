//
//  ItemView.m
//  NewsColumns
//
//  Created by Dean on 14-2-17.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import "ItemView.h"

@implementation ItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)loadViewFromXib
{
    return [[NSBundle mainBundle] loadNibNamed:@"ItemView" owner:nil options:nil][0];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_contentView release];
    [_tipsLabel release];
    [super dealloc];
}
@end
