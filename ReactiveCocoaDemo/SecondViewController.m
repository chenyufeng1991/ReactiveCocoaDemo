//
//  SecondViewController.m
//  ReactiveCocoaDemo
//
//  Created by chenyufeng on 16/5/16.
//  Copyright © 2016年 chenyufengweb. All rights reserved.
//

#import "SecondViewController.h"
#import "LoginManager.h"
#import "ReactiveCocoa.h"

@interface SecondViewController ()

@property (nonatomic, strong) LoginManager *loginMgr;

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {

        NSLog(@"123");
    }];
    
}


@end
