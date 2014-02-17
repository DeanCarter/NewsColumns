//
//  FMNewsSectionView.m
//  NewsColumns
//
//  Created by Apple on 14-2-17.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import "FMNewsSectionView.h"
@interface FMNewsSectionView()
@property (nonatomic, retain) UITableView *previousTable;
@property (nonatomic, retain) UITableView *currentTable;
@property (nonatomic, retain) UITableView *laterTable;
@end


@implementation FMNewsSectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
