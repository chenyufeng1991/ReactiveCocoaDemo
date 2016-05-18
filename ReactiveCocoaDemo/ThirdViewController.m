
//
//  ThirdViewController.m
//  ReactiveCocoaDemo
//
//  Created by chenyufeng on 16/5/17.
//  Copyright © 2016年 chenyufengweb. All rights reserved.
//

#import "ThirdViewController.h"
#import "ReactiveCocoa.h"
#import "LoginViewController.h"

/**
 *  RAC是一个线程安全的框架.
 replay后面的订阅者可以收到历史值。
 信号是一种数据流，可以被绑定和传递。
 */

/**
 *  FRP的核心是信号，信号是通过RACSignal表示，信号是数据流，可以被绑定和传递。
 可以把信号想象成水龙头，只不过里面不是水，而是玻璃球(value)，直径跟水管的内径一样，这样就能保证玻璃球是依次排列，不会出现并排的情况(数据都是线性处理的，不会出现并发情况)。水龙头的开关默认是关的，除非有了订阅者(subscriber)，才会打开。这样只要有新的玻璃球进来，就会自动传送给订阅者。可以在水龙头上加一个过滤嘴(filter)，不符合的不让通过，也可以加一个改动装置，把球改变成符合自己的需求(map)。也可以把多个水龙头合并成一个新的水龙头(combineLatest:reduce:)，这样只要其中的一个水龙头有玻璃球出来，这个新合并的水龙头就会得到这个球。
 */
@interface ThirdViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *myArray;
@property (strong, nonatomic) UITableView *myTableView;

@end

@implementation ThirdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myArray = [[NSMutableArray alloc] initWithObjects:@"冷信号",@"热信号",@"testSubject",@"testReplaySubject",@"将冷信号转化为热信号",@"将冷信号转化为热信号优化1",@"登录界面", @"模拟网络请求",@"testSideEffect_Signal",@"testSideEffect_ReplaySubject",nil];
    self.myTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;

    [self.view addSubview:self.myTableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = [self.myArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case 0:
            [self coldSignal];
            break;
        case 1:
            [self hotSignal];
            break;
        case 2:
            [self testSubject];
            break;
        case 3:
            [self testReplaySubject];
            break;
        case 4:
            [self coldSignalToHotSignal];
            break;
        case 5:
            [self coldSignalToHotSignalOptimize1];
            break;
        case 6:
        {
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            [self.navigationController pushViewController:loginVC animated:YES];
            break;
        }
        case 7:
            [self testNetwork];
            break;
        case 8:
            [self testSideEffect_Signal];
            break;
        case 9:
            [self testSideEffect_ReplaySubject];
            break;
        default:
            break;
    }
}

#pragma mark - 冷热信号入门

/**
 *  （1）热信号是主动的，尽管并没有订阅事件，但是会时刻推送；而冷信号是被动的，只有当你订阅的时候，它才会发布消息。
 *  （2）热信号可以有多个订阅者，是一对多，集合可以和订阅者共享信息；而冷信号只能一对一，当有不同的订阅者，消息是重新完整发送。
 *
 */

/**
 *  总结：
 * （1）热信号是主动的，即使没有订阅事件，它仍然会时刻推送。如第二个例子，信号被创建1s后，1这个值就推送出来了，但是当时还没有订阅者。而冷信号是被动的，只有当你订阅的时候，它才会发送消息。
 * （2）热信号可以有多个订阅者，是一对多，信号可以与订阅者共享信息。如第二个例子，订阅者1和订阅者2是共享的，他们都能在同一时间接收到3这个值。而冷信号只能一对一，当有不同的订阅者，消息会重新完整发送。如第一个例子，我们可以观察到两个订阅者没有联系，都是基于各自的订阅事件开始接收消息的。
 */

// 冷信号
/**
 *  冷信号就像是看下载好的电影。
 冷信号在两个不同时间段的订阅过程中，分别完整的发送了所有的消息。
 */
- (void)coldSignal
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        [subscriber sendNext:@3];
        [subscriber sendCompleted];

        return nil;
    }];
    NSLog(@"Signal was created");

    // 两个订阅者在不同的时间进行订阅
    [[RACScheduler mainThreadScheduler] afterDelay:0.1 schedule:^{
        [signal subscribeNext:^(id x) {
            NSLog(@"Subscriber 1 receive:%@",x);
        }];
    }];

    [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
        [signal subscribeNext:^(id x) {
            NSLog(@"Subscriber 2 receive:%@",x);
        }];
    }];
}

// 热信号
/**
 *  热信号就像是“直播”
 */
- (void)hotSignal
{
    RACMulticastConnection *connection = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
            [subscriber sendNext:@1];
        }];
        [[RACScheduler mainThreadScheduler] afterDelay:3 schedule:^{
            [subscriber sendNext:@2];
        }];
        [[RACScheduler mainThreadScheduler] afterDelay:5 schedule:^{
            [subscriber sendNext:@3];
        }];
        [[RACScheduler mainThreadScheduler] afterDelay:5.5 schedule:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }] publish];

    [connection connect];

    RACSignal *signal = connection.signal;
    NSLog(@"Signal was created");

    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
        [signal subscribeNext:^(id x) {
            NSLog(@"Subscriber 1 receive:%@",x);
        }];
    }];
    [[RACScheduler mainThreadScheduler] afterDelay:4 schedule:^{
        [signal subscribeNext:^(id x) {
            NSLog(@"Subscriber 2 receive:%@",x);
        }];
    }];
}


#pragma mark - 为什么要区分冷热信号
/**
 *  纯函数就是返回值只由输入值决定、而且没有可见副作用的函数或者表达式。和数学中的函数是一样的：
 f(x) = 5x+1;
 这个函数在调用的过程中除了返回值以外的没有任何对外界的影响，除了入参x以外也不受任何其他外界因素的影响。
 */

#pragma mark - RACSubject

/**
 *  四个订阅者实际上是共享subject的，一旦这个subject发送了值，当前的订阅者就会同时接收到。由于Subscriber3与Subscriber4的订阅事件稍晚，所以错过了第一次值的发送。
 subject类似于“直播”。而signal类似于“点播”，每次订阅都会重头开始。
 */
- (void)testSubject
{
    RACSubject *subject = [RACSubject subject];
    NSLog(@"Start");

    [[RACScheduler mainThreadScheduler] afterDelay:0.1 schedule:^{
        // Subscriber 1
        [subject subscribeNext:^(id x) {
            NSLog(@"Subscriber 1 get:%@",x);
        }];

        // Subscriber 2
        [subject subscribeNext:^(id x) {
            NSLog(@"Subscriber 2 get:%@",x);
        }];
    }];

    [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
        [subject sendNext:@"数据1"];
    }];

    [[RACScheduler mainThreadScheduler] afterDelay:1.1 schedule:^{
        // Subscriber 3
        [subject subscribeNext:^(id x) {
            NSLog(@"Subscriber 3 get:%@",x);
        }];

        // Subscriber 4
        [subject subscribeNext:^(id x) {
            NSLog(@"Subscriber 4 get:%@",x);
        }];
    }];

    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
        [subject sendNext:@"数据2"];
    }];
}

/**
 *  对于Subscriber3 和Subscriber4来说，只关心“历史的值”，而不关心"历史的时间线"。
 
 总结：
 （1）RACSubject及其子类是热信号；
 （2）RACSignal排除RACSubject以外的是冷信号；
 */
- (void)testReplaySubject
{
    RACSubject *replaySubject = [RACReplaySubject subject];
    NSLog(@"Start");

    [[RACScheduler mainThreadScheduler] afterDelay:0.1 schedule:^{
        // Subscriber 1
        [replaySubject subscribeNext:^(id x) {
            NSLog(@"Subscriber 1 get:%@",x);
        }];

        // Subscriber 2
        [replaySubject subscribeNext:^(id x) {
            NSLog(@"Subscriber 2 get:%@",x);
        }];
    }];

    [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
        [replaySubject sendNext:@"数据1"];
    }];

    [[RACScheduler mainThreadScheduler] afterDelay:1.1 schedule:^{
        // Subscriber 3
        [replaySubject subscribeNext:^(id x) {
            NSLog(@"Subscriber 3 get:%@",x);
        }];

        // Subscriber 4
        [replaySubject subscribeNext:^(id x) {
            NSLog(@"Subscriber 4 get:%@",x);
        }];
    }];

    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
        [replaySubject sendNext:@"数据2"];
    }];
}

#pragma mark - 将冷信号转化为热信号

/**
 *  冷信号与热信号的本质区别在于是否保持状态。冷信号的多次订阅是不保持状态的，而热信号的多次订阅可以保持状态。
 所以一种将冷信号转化为热信号的方法就是：将冷信号订阅，订阅到的每一个时间通过RACSubject发送出去，其他订阅者只订阅这个RACSubject.
 */
- (void)coldSignalToHotSignal
{
    RACSignal *coldSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"创建冷信号");
        [[RACScheduler mainThreadScheduler] afterDelay:1.5 schedule:^{
            [subscriber sendNext:@"A"];
        }];

        [[RACScheduler mainThreadScheduler] afterDelay:3 schedule:^{
            [subscriber sendNext:@"B"];
        }];

        [[RACScheduler mainThreadScheduler] afterDelay:5 schedule:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }];

    // subject一开始就被创建
    RACSubject *subject = [RACSubject subject];
    NSLog(@"Subject创建");

    // 在2s后subject订阅coldSignal
    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
        [coldSignal subscribe:subject];
    }];

    // Subscriber 1是subject创建后开始订阅的，但是第一个接收时间与subject接收coldSignal第一个值的时间是一样的
    [subject subscribeNext:^(id x) {
        NSLog(@"Subscriber 1 receive value:%@",x);
    }];

    // Subscriber 2是subject创建4s后开始订阅的，所以只能接收到第二个值
    [[RACScheduler mainThreadScheduler] afterDelay:4 schedule:^{
        [subject subscribeNext:^(id x) {
            NSLog(@"Subscriber 2 receive value:%@",x);
        }];
    }];

}

// 将冷信号转化为热信号优化1
/**
 *  使用一个Subject来订阅原始信号，并让其他订阅者订阅这个Subject，这个Subject就是热信号。
 */
- (void)coldSignalToHotSignalOptimize1
{
    RACSignal *coldSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"创建冷信号");
        [[RACScheduler mainThreadScheduler] afterDelay:1.5 schedule:^{
            [subscriber sendNext:@"A"];
        }];

        [[RACScheduler mainThreadScheduler] afterDelay:3 schedule:^{
            [subscriber sendNext:@"B"];
        }];

        [[RACScheduler mainThreadScheduler] afterDelay:5 schedule:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }];

    RACSubject *subject = [RACSubject subject];
    NSLog(@"Subject创建");

    RACMulticastConnection *multicastConnection = [coldSignal multicast:subject];
    RACSignal *hotSignal = multicastConnection.signal;

    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
        [multicastConnection connect];
    }];

    [hotSignal subscribeNext:^(id x) {
        NSLog(@"Subscriber 1 receive value:%@",x);
    }];

    [[RACScheduler mainThreadScheduler] afterDelay:4 schedule:^{
        [hotSignal subscribeNext:^(id x) {
            NSLog(@"Subscriber 2 receive value:%@",x);
        }];
    }];

}

#pragma mark - 模拟网络请求和异步操作
- (void)testNetwork
{
    RACSubject *subject = [self doRequest];
    // subscriberNext就是定义了一个接收体（订阅者）
    [subject subscribeNext:^(NSString *value) {
        NSLog(@"value:%@",value);
    }];
}

- (RACSubject *)doRequest
{
    RACSubject *subject = [RACSubject subject];

    [[[[RACSignal interval:2 onScheduler:[RACScheduler schedulerWithPriority:RACSchedulerPriorityDefault name:@"RequestNetwork"]] take:1] map:^id(id value) {

        NSString *networkData = @"网络获得的数据";
        [subject sendNext:networkData];
        return nil;
    }] subscribeNext:^(id x) {

    }];

    return subject;
}

#pragma mark - side effect 信号的副作用
/**
 *  如果有多个subscriber,那么signal会被又一次触发。控制台会输出两次“signal triggering”
 */
- (void)testSideEffect_Signal
{
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

        NSLog(@"signal triggering");
        [subscriber sendNext:@"send data"];
        [subscriber sendCompleted];

        return nil;
    }];

    [signal subscribeNext:^(id x) {
        NSLog(@"subscriber 1 %@",x);
    }];

    [signal subscribeNext:^(id x) {
        NSLog(@"subscriber 2 %@",x);
    }];
}

/**
 *  使用replay可以保证signal只被触发一次。然后把sendNext的value存起来，下次再有subscriber时，直接发送缓存的数据。
 */
- (void)testSideEffect_ReplaySubject
{
    RACSubject *subject = [RACReplaySubject subject];
    NSLog(@"signal triggering");
    [subject sendNext:@"send data"];
    [subject sendCompleted];

    [subject subscribeNext:^(id x) {
        NSLog(@"subscriber 1 %@",x);
    }];

    [subject subscribeNext:^(id x) {
        NSLog(@"subscriber 2 %@",x);
    }];
}


@end

































