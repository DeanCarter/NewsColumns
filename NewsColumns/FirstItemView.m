//
//  FirstItemView.m
//  NewsColumns
//
//  Created by Dean on 14-2-16.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import "FirstItemView.h"

@interface FirstItemView ()

@end


@implementation FirstItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
   // DLog(@"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");

}

+ (id)loadViewFromXib
{
    return [[NSBundle mainBundle] loadNibNamed:@"FirstItemView" owner:nil options:nil][0];
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
    [_tipsLabel release];
    [super dealloc];
}
@end
