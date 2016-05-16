//
//  FirstViewController.m
//  ReactiveCocoaDemo
//
//  Created by chenyufeng on 16/5/16.
//  Copyright © 2016年 chenyufengweb. All rights reserved.
//

#import "FirstViewController.h"
#import "ReactiveCocoa.h"

/**
 *  RAC的核心概念就是“响应数据的变化”--->数据与视图绑定。
 *
 *
 */

/**
 *  使用cocoapods导入ReactiveCocoa要注意，Podfile头部要用：
 use_frameworks!
 否则导入不成功

 并且要指定RAC的版本为2.0，不能使用默认的RAC版本，使用默认的RAC版本会有result包，会导致项目编译失败。Podfile文件如下：
 
 use_frameworks!

 platform:ios,'8.0'
 pod 'ReactiveCocoa', '2.0'
 */

/**
 *  不需要使用pch文件，只要导入头文件
 #import "ReactiveCocoa.h"
 即可。

 */

/**
 *  ReactiveCocoa signal(RACSignal)发送事件流给它的subscriber.目前总共有三种类型的事件：next,error,compeleted.一个signal在因error终止或者完成前，可以发送任意数量的next事件。
 */

@interface FirstViewController ()

@property (strong, nonatomic) NSString *nameStr;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

#if 0
    //监听输入框的输入内容,只需要signal和block,不需要target-action,也不需要delegate
    [self.nameTextField.rac_textSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
#endif

#if 0
    // 将nameStr这个值和nameTextField进行绑定，只要nameStr值改变了，nameTextField上显示的值也就改变了
    // RACObserve中的第二个参数就是要监听的值
    // 在实际的开发中，View会和Model绑定，Model中数据发生改变，UI也会直接更新
    // RACObserve只能对属性、变量，Model进行观察，不能对View视图进行观察。
    self.nameStr = @"chen";
    [RACObserve(self, nameStr) subscribeNext:^(NSString *nameStr) {
        self.nameTextField.text = nameStr;
    }];
#endif

#if 0
    //在输出的时候过滤，字符大于3时才打印
    [[self.nameTextField.rac_textSignal
      filter:^BOOL(id value) {
          NSString *text = value;//隐式的类型转化
          return text.length > 3;
      }]

     subscribeNext:^(id x) {
         NSLog(@"%@",x);
     }];
#endif

#if 0
    //理解RACSignal.RACSignal的每个操作都会返回一个RACSignal,类似于链式编程，不用每一步都使用本地变量。
    RACSignal *nameSourceSignal = self.nameTextField.rac_textSignal;
    RACSignal *filterNameSignal = [nameSourceSignal filter:^BOOL(id value) {

        NSString *text = value;
        return text.length > 3;
    }];
    [filterNameSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
#endif

#if 0
    //在输出的时候过滤，字符大于3时才打印
    //我们常常手动修改block中的变量类型
    [[self.nameTextField.rac_textSignal
      filter:^BOOL(NSString *text) {
          return text.length > 3;
      }]
     subscribeNext:^(NSString *text) {
         NSLog(@"%@",text);
     }];
#endif

}

//不断改变nameStr的值，测试nameTextField上显示的文本
- (IBAction)loginButtonClicked:(id)sender
{
    int value = arc4random() % 100;
    self.nameStr = [NSString stringWithFormat:@"%d",value];
    NSLog(@"%d",value);
}


@end













