//
//  MNAppDelegate.m
//  MNPageExample
//
//  Created by Min Kim on 7/22/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNAppDelegate.h"
#import "MNViewController.h"

@interface MNAppDelegate() <MNPageViewControllerDataSource, MNPageViewControllerDelegate>

@property(nonatomic,strong) NSArray *colors;
@property(nonatomic,strong) MNPageViewController *pageViewController;
@end

@implementation MNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  self.colors = @[UIColor.greenColor, UIColor.blueColor, UIColor.orangeColor, UIColor.purpleColor];
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor blackColor];
  
  _pageViewController = [[MNPageViewController alloc] init];
  _pageViewController.viewController = [[MNViewController alloc] initWithColor:self.colors[0] withIndex:0];
  _pageViewController.dataSource = self;
  _pageViewController.delegate = self;
  
  self.window.rootViewController = self.pageViewController;

    [self performSelector:@selector(addButton) withObject:nil afterDelay:0.f];

    
  [self.window makeKeyAndVisible];
  
  return YES;
}

- (void)addButton
{
    UIButton *dataButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dataButton.backgroundColor = [UIColor redColor];
    dataButton.frame = CGRectMake(130, 100, 60, 40);
    [dataButton setTitle:@"第二页" forState:UIControlStateNormal];
    [dataButton addTarget:self action:@selector(buttonForAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:dataButton];
    
    [self.window bringSubviewToFront:dataButton];
}

- (void)buttonForAction:(UIButton *)button
{
    NSInteger index = 2;
    [self.pageViewController setCurrentViewController:[[MNViewController alloc] initWithColor:self.colors[index] withIndex:index] withIndex:index];
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

#pragma mark - MNPageViewControllerDataSource

- (UIViewController *)mn_pageViewController:(MNPageViewController *)pageViewController viewControllerBeforeViewController:(MNViewController *)viewController {
  NSUInteger index = [self.colors indexOfObject:viewController.color];
  if (index == NSNotFound || index == 0) {
    return nil;
  }
  return [[MNViewController alloc] initWithColor:self.colors[index - 1] withIndex:(index - 1)];
}

- (UIViewController *)mn_pageViewController:(MNPageViewController *)pageViewController viewControllerAfterViewController:(MNViewController *)viewController {
  NSUInteger index = [self.colors indexOfObject:viewController.color];

  if (index == NSNotFound || index == (self.colors.count - 1)) {
    return nil;
  }
  return [[MNViewController alloc] initWithColor:self.colors[index + 1] withIndex:(index + 1)];
}

#pragma mark - MNPageViewControllerDelegate

- (void)mn_pageViewController:(MNPageViewController *)pageViewController willPageToViewController:(MNViewController *)viewController withRatio:(CGFloat)ratio {
  [viewController setRatio:ratio];
}

- (void)mn_pageViewController:(MNPageViewController *)pageViewController willPageFromViewController:(MNViewController *)viewController withRatio:(CGFloat)ratio {
  [viewController setRatio:ratio];
}

@end
