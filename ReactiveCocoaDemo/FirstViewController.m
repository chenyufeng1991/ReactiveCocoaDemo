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

/**
 *  map:修改；
    filter:过滤；
    combine:叠加；
    chain:串联；
 */

/**Signal and Subscriber
 *  这是RAC最核心的内容，这里我想用插头和插座来描述，插座是Signal，插头是Subscriber。想象某个遥远的星球，他们的电像某种物质一样被集中存储，且很珍贵。插座负责去获取电，插头负责使用电，而且一个插座可以插任意数量的插头。当一个插座(Signal)没有插头(Subscriber)时什么也不干，也就是处于冷(Cold)的状态，只有插了插头时才会去获取，这个时候就处于热(Hot)的状态。
 */

/**
 *  Signal获取到数据后，会调用Subscriber的sendNext,sendComplete,sendError方法来传送数据给Subscriber,Subscriber也有方法来获取传过来的数据。如：[signal subscriberNext:error:completed].这样只要没有sendCompleted和sendError,新的值就会通过sendNext源源不断传送过来。
 
 RACObserve使用KVO来监听property的变化，只要属性被自己或者外部改变，block就会被执行。
 */

@interface FirstViewController ()

@property (strong, nonatomic) NSString *nameStr;
@property (strong, nonatomic) NSArray *familyArr;

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

#if 0
    //监听输入框的输入内容,只需要signal和block,不需要target-action,也不需要delegate
    //rac_textSignal是添加到UITextField上面的category。
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
     subscribeNext:^(id x) {
         NSLog(@"%@",text);
     }];
#endif


#if 0
    // 使用map改变了事件的数据，map从上一个next事件接收数据，通过执行block把返回值传给下一个next事件。
    // map以NSString为输入，取字符串的长度，返回一个NSNumber。
    [[[self.nameTextField.rac_textSignal
       map:^id(NSString *text) {
           return @(text.length);
       }]
      //通过上面的管道，要处理的值变为NSNumber类型
      filter:^BOOL(NSNumber *length) {
          return [length integerValue] > 3;
      }]
     subscribeNext:^(id x) {
         NSLog(@"%@",x);
     }];
#endif

#if 0
    //冷信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"trigger");
        [subscriber sendNext:@"sendNext"];
        [subscriber sendCompleted];
        return nil;
    }];

    //变成热信号
    [signal subscribeCompleted:^{
        NSLog(@"subscription");
    }];
#endif

#if 0
    //绑定一个对象，当一个对象的dealloc被触发时，执行block。
    self.familyArr = @[@"foo"];
    [[self.familyArr rac_willDeallocSignal] subscribeCompleted:^{
        NSLog(@"对象被销毁");
    }];
#endif

}

- (IBAction)loginButtonClicked:(id)sender
{
#if 0
    //不断改变nameStr的值，测试nameTextField上显示的文本
    int value = arc4random() % 100;
    self.nameStr = [NSString stringWithFormat:@"%d",value];
    NSLog(@"%d",value);
#endif

#if 0
    //点击按钮销毁数组
    self.familyArr = nil;
#endif
}


@end













