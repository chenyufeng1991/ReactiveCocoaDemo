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
#import "RACEXTScope.h"

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

/**
*  RAC常见宏
（1）RAC(TARGET, ...)   :用于给某个对象的某个属性绑定。
（2）RACObserve(TARGET, KEYPATH)  :监听某个对象的某个属性，返回的是信号。
 (3) RACTuplePack   :把数据包装成RACTuple（元祖类）。
 (4) RACTupleUnpack   :把RACTuple（元组类）解包成对应的数据。
*/

- (void)viewDidLoad
{
    [super viewDidLoad];

#if 0
    // (1) 对文本输入监听，并且绑定Label显示
    [self.usernameTextField.rac_textSignal subscribeNext:^(id x) {
        self.currentUsernameLabel.text = self.usernameTextField.text;
    }];
    [self.passwordTextField.rac_textSignal subscribeNext:^(id x) {
        self.currentPasswordLabel.text = self.passwordTextField.text;
    }];
#endif

#if 0
    // (2)绑定对象，显示UI。
    self.loginMgr = [[LoginManager alloc] init];
    RAC(self,currentUsernameLabel.text) = RACObserve(self, loginMgr.username);
    RAC(self,currentPasswordLabel.text) = RACObserve(self, loginMgr.password);

    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        self.loginMgr.username = self.usernameTextField.text;
        self.loginMgr.password = self.passwordTextField.text;
    }];
#endif

#if 0
    // (3)KVO，监听对象中属性的改变,只要值改变就会发送信号。
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

#if 0
    // (4)  对（1）的简便写法
    RAC(self,currentUsernameLabel.text) = self.usernameTextField.rac_textSignal;
    RAC(self,currentPasswordLabel.text) = self.passwordTextField.rac_textSignal;
#endif

#if 0
    // 把数据包装成元祖
    RACTuple *tuple = RACTuplePack(@10,@20);
#endif


#if 0
    // 把参数中的数据包装成元组
    RACTuple *tuple = RACTuplePack(@"chenyufeng",@20);

    // 解包元组，会把元组的值，按顺序给参数里面的变量赋值
    RACTupleUnpack(NSString *name,NSNumber *age) = tuple;
    NSLog(@"name = %@,age = %@",name,age);
#endif



}


@end





