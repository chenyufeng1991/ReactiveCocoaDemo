
//
//  LoginViewController.m
//  ReactiveCocoaDemo
//
//  Created by chenyufeng on 16/5/18.
//  Copyright © 2016年 chenyufengweb. All rights reserved.
//

#import "LoginViewController.h"
#import "ReactiveCocoa.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"登录界面";

    // 只有当用户名密码长度都超过6时，按钮才会启用。
    RAC(self,loginButton.enabled) = [RACSignal combineLatest:@[self.usernameTextField.rac_textSignal,self.passwordTextField.rac_textSignal] reduce:^id(NSString *username,NSString *password){
        return @(username.length >= 6 && password.length >= 6);
    }]; 
    
}

@end
