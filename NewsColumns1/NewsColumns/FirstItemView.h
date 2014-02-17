//
//  FirstItemView.h
//  NewsColumns
//
//  Created by Dean on 14-2-16.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import "FMEditItemView.h"

@interface FirstItemView : FMEditItemView
@property (retain, nonatomic) IBOutlet UILabel *tipsLabel;

+ (id)loadViewFromXib;

@end
