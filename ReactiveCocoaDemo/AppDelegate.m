//
//  AppDelegate.m
//  ReactiveCocoaDemo
//
//  Created by chenyufeng on 16/5/16.
//  Copyright © 2016年 chenyufengweb. All rights reserved.
//

#import "AppDelegate.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.tabController = [[UITabBarController alloc] init];

    FirstViewController *firstVC = [[FirstViewController alloc] init];
    firstVC.title = @"第一页";
    SecondViewController *secondVC = [[SecondViewController alloc] init];
    secondVC.title = @"第二页";
    ThirdViewController *thirdVC = [[ThirdViewController alloc] init];
    thirdVC.title = @"第三页";

    UINavigationController *firstNavi = [[UINavigationController alloc] initWithRootViewController:firstVC];
    UINavigationController *secondNavi = [[UINavigationController alloc] initWithRootViewController:secondVC];
    UINavigationController *thirdNavi = [[UINavigationController alloc] initWithRootViewController:thirdVC];

    self.tabController.viewControllers = @[firstNavi,secondNavi,thirdNavi];
    self.window.rootViewController = self.tabController;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
