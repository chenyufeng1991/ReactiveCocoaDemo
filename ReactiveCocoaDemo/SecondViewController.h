//
//  SecondViewController.h
//  ReactiveCocoaDemo
//
//  Created by chenyufeng on 16/5/16.
//  Copyright © 2016年 chenyufengweb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *currentUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPasswordLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end
