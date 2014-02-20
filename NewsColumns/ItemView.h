//
//  ItemView.h
//  NewsColumns
//
//  Created by Dean on 14-2-17.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemView : UIView
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UILabel *tipsLabel;

+ (id)loadViewFromXib;
@end
