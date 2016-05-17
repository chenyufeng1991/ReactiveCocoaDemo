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

/**
*  注意：RAC()和RACObserve()中传入的是keypath，只要是keypath的路径正确，点语法的前后顺序无所谓的。
如：
RAC(self.objc,attribute) 等价于 RAC(self,objc.attribute);

RACObserce()也是一样。
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

#if 0
    //绑定对象，显示UI。
    self.loginMgr = [[LoginManager alloc] init];
    RAC(self,currentUsernameLabel.text) = RACObserve(self, loginMgr.username);
    RAC(self,currentPasswordLabel.text) = RACObserve(self, loginMgr.password);

    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        self.loginMgr.username = self.usernameTextField.text;
        self.loginMgr.password = self.passwordTextField.text;
    }];
#endif

#if 0
    // KVO，监听对象中属性的改变,只要值改变就会发送信号。
    // 也是通过keypath去找到该值
    self.loginMgr = [[LoginManager alloc] init];
    [[self.loginMgr rac_valuesAndChangesForKeyPath:@"username" options:NSKeyValueObservingOptionNew observer:nil] subscribeNext:^(NSArray *x) {
        NSLog(@"%@",x[0]);
    }];

    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        self.loginMgr.username = self.usernameTextField.text;
        self.loginMgr.password = self.passwordTextField.text;
    }];
#endif
}


@end





