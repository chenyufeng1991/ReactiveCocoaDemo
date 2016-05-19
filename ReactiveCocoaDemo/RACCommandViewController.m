//
//  RACCommandViewController.m
//  ReactiveCocoaDemo
//
//  Created by chenyufeng on 16/5/18.
//  Copyright © 2016年 chenyufengweb. All rights reserved.
//

#import "RACCommandViewController.h"
#import "LoginManager.h"
#import "ReactiveCocoa.h"

@interface RACCommandViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) LoginManager *loginMgr;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (nonatomic, strong) RACCommand *loginCommand;

@end

@implementation RACCommandViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    RACSignal* textSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"first"];
        [subscriber sendNext:@"second"];
        [subscriber sendCompleted];
        return nil;
    }];

    // 设置signal的名字，方便调试
    [textSignal setNameWithFormat:@"MY_SIGNAL"];

    RACCommand* textCommad = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        return textSignal;
    }];

    self.loginButton.rac_command = textCommad;

    // 传入布尔值，当正在执行时为true，否则为false
    [textCommad.executing subscribeNext:^(id x) {
        NSLog(@"executing ---> %@",x);
    }];

    // 这里收到的signal就是上面的textSignal
    [textCommad.executionSignals subscribeNext:^(RACSignal *sig) {
        [sig subscribeNext:^(id x) {
            NSLog(@"Subscriber 1 receive:%@",x);
        }];
    }];

    [textCommad.errors subscribeNext:^(id x) {
        NSLog(@"errors ---> x");
    }];
}


@end
