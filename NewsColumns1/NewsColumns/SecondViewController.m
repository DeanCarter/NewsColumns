//
//  SecondViewController.m
//  NewsColumns
//
//  Created by Apple on 14-2-17.
//  Copyright (c) 2014年 Dean. All rights reserved.
//

#import "SecondViewController.h"
#import "FMSectionView.h"
@interface SecondViewController ()

@end

@implementation SecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    FMSectionView *sectionView = [[FMSectionView alloc] initWithFrame:self.view.frame];
    sectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    sectionView.backgroundColor = [UIColor clearColor];
    sectionView.itemSize = CGSizeMake(70, 40);
    sectionView.borderWidthX = 5.f;
    sectionView.borderHeightY = 5.f;
    [self.view addSubview:sectionView];
    [sectionView release];
    //[sectionView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
