//
//  MNViewController.m
//  MNPageExample
//
//  Created by Min Kim on 7/22/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNViewController.h"

@interface MNViewController ()
{
    NSInteger _page;
}
@property(nonatomic,strong,readwrite) UIColor *color;
@property(nonatomic,strong,readwrite) UIView  *colorView;
@property(nonatomic,strong,readwrite) UILabel *tipsLable;
@end

@implementation MNViewController

- (id)initWithColor:(UIColor *)color withIndex:(NSInteger)index
{
    if (self = [super init]) {
        self.color = color;
        _page = index;
  }
  return self;
}

- (void)dealloc {
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.colorView = [[UIView alloc] initWithFrame:self.view.bounds];
  self.colorView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
  self.colorView.backgroundColor = self.color;
  [self.view addSubview:self.colorView];
    
    
    self.tipsLable = [[UILabel alloc] initWithFrame:self.colorView.bounds];
    self.tipsLable.backgroundColor = [UIColor clearColor];
    self.tipsLable.textAlignment = UITextAlignmentCenter;
    self.tipsLable.text = [NSString stringWithFormat:@"第%d页",_page];
    [self.colorView addSubview:self.tipsLable];
    
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (NSString *)description {
  return [self.color description];
}

- (void)setRatio:(CGFloat)ratio {
  CGFloat scale = 1.f - (0.05f - (ratio * 0.05f));
  self.colorView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
}

@end
