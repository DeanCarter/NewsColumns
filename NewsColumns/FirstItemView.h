//
//  FirstItemView.h
//  NewsColumns
//
//  Created by Dean on 14-2-16.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import "FMEditItemView.h"
#import "FMItemView.h"

@interface FirstItemView : FMItemView
@property (retain, nonatomic) IBOutlet UILabel *tipsLabel;

+ (id)loadViewFromXib;

@end
