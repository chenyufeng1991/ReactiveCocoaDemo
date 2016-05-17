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

/**
 *  目前我的需求是：输入用户名密码，点击登录按钮，改变loginMgr对象的值；并且绑定该对象和Label的显示，让Label显示登录的用户。
 */
- (void)viewDidLoad
{
    [super viewDidLoad];

#if 0
    // 对文本输入监听，并且绑定Label显示
    [self.usernameTextField.rac_textSignal subscribeNext:^(id x) {
        self.currentUsernameLabel.text = self.usernameTextField.text;
    }];
    [self.passwordTextField.rac_textSignal subscribeNext:^(id x) {
        self.currentPasswordLabel.text = self.passwordTextField.text;
    }];
#endif

    self.loginMgr = [[LoginManager alloc] init];
    RAC(self,currentUsernameLabel.text) = RACObserve(self, loginMgr.username);
    RAC(self,currentPasswordLabel.text) = RACObserve(self, loginMgr.password);

    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        self.loginMgr.username = self.usernameTextField.text;
        self.loginMgr.password = self.passwordTextField.text;
    }];
}


@end
