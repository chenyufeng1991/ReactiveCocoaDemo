
//
//  LoginViewController.m
//  ReactiveCocoaDemo
//
//  Created by chenyufeng on 16/5/18.
//  Copyright © 2016年 chenyufengweb. All rights reserved.
//

#import "LoginViewController.h"
#import "ReactiveCocoa.h"

/**
 *  自定义信号，也就是RACSubject，继承自RACSignal,可以理解为自由度更高的signal。
 */

/**
 *  重要注释：Snippets
 (1)SequenceNext可以将一组Signal转换成另一组Signal，不过会等待原先的Signal处理完成，配合doNext可以方便的实现side effect.
 (2)multicast常常和RACReplaySubject组合。
（3）[RACAble(obj.prop) take:n],只触发n次。
（4）deliverOn是deliver block result
 (5)combineLatest:reduce
 (6)map是对内容进行处理，返回的还是内容，如果要返回一个signal，需要flattenMap;
 (7)merge可以将多个Signal合并成一个，然后subscriberNext这个Signal即可。
（8）map只是对Signal做了点变动，如果没有subscriber也不会起作用；
（9）RAC(obj.prop)在左边；
（10）RACAble(obj.prop)在左边；
（11）RACAbleWithStart(obj.prop);
 (12)[RACSignal interval:x]定时吐数据；
（13）flattenMap先map然后flatten.
 */

/**
 *  重要注释：Subscriber
 (1)subscriberNext:error:completed
 */

/**
 *  重要注释：RACSignal
 (1)push-driven;
 (2)send 3 events:Next,Error,Completed
 (3)cold by default:start doing work each time a new subscription is added
 */

/**
 *  重要注释：RACCommand
 (1)a signal that is triggered in response to some action usually that action triggering a command is UI-driven.
 */

/**
 *  重要注释：RACScheduler
 （1）a serial execution queue for signals to perform work or deliver their results.
  (2) like GCD,but support cancellation (via disposables).
 */

/**
 *  重要注释：RACStream
 （1）Transform 
 map:transform a signal stream to new stream 
 filter:use a block to test each value
 
 (2)Combine
 concat:
 flatten:
 applied to a stream-of-streams .
 combine their values into s sigle new stream.
 */

/**
 *  重要注释：RACSequence
（1）pull-driven
 (2)kind of collection
 */

/**
 *  重要注释：RACSubject
（1）a signal that can be manullay controlled;
 (2) bridging non-ARC code into signals
 */

/**
 *  重要注释：RACReplaySubject
 can buffer event for future subscribers
 */
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
