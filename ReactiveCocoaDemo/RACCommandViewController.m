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
        [subscriber sendNext:@"chenyufeng"];
        [subscriber sendNext:@"gaowenjing"];
        [subscriber sendCompleted];
        return nil;
    }];

    RACCommand* textCommad = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"input --> %@",input);
        return textSignal;
    }];

    self.loginButton.rac_command = textCommad;

    [textCommad.executing subscribeNext:^(id x) {
        NSLog(@"executing ---> %@",x);
    }];

    [textCommad.executionSignals subscribeNext:^(NSString *x) {
        NSLog(@"executionSignals ---> %@",x);
    }];

    [textCommad.errors subscribeNext:^(id x) {
        NSLog(@"errors ---> x");
    }];
}


@end
