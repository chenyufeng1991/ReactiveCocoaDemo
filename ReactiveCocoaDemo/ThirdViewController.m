
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
#import "RACCommandViewController.h"

/**
 *  RAC是一个线程安全的框架.
 replay后面的订阅者可以收到历史值。
 信号是一种数据流，可以被绑定和传递。
 */

/**
 *  FRP的核心是信号，信号是通过RACSignal表示，信号是数据流，可以被绑定和传递。
 可以把信号想象成水龙头，只不过里面不是水，而是玻璃球(value)，直径跟水管的内径一样，这样就能保证玻璃球是依次排列，不会出现并排的情况(数据都是线性处理的，不会出现并发情况)。水龙头的开关默认是关的，除非有了订阅者(subscriber)，才会打开。这样只要有新的玻璃球进来，就会自动传送给订阅者。可以在水龙头上加一个过滤嘴(filter)，不符合的不让通过，也可以加一个改动装置，把球改变成符合自己的需求(map)。也可以把多个水龙头合并成一个新的水龙头(combineLatest:reduce:)，这样只要其中的一个水龙头有玻璃球出来，这个新合并的水龙头就会得到这个球。
 */

/**
 *  比如把signal作为local变量时，如果没有被subscribe，那么方法执行完后，该变量会被dealloc。但如果signal有被subscribe，那么subscriber会持有该signal，直到signal sendCompleted或sendError时，才会解除持有关系，signal才会被dealloc。
 */
@interface ThirdViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *myArray;
@property (strong, nonatomic) UITableView *myTableView;

@end

@implementation ThirdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myArray = [[NSMutableArray alloc] initWithObjects:@"冷信号",@"热信号",@"testSubject",@"testReplaySubject",@"将冷信号转化为热信号",@"将冷信号转化为热信号优化1",@"登录界面", @"模拟网络请求",@"testSideEffect_Signal",@"testSideEffect_ReplaySubject",@"RACCommand",@"NSObject+RACLifting",@"信号的组合使用",@"map+switchToLatest",@"rac_signalForSelector",@"官方文档-Subscription",nil];
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
        case 10:
        {
            RACCommandViewController *vc = [[RACCommandViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 11:
            [self testRACLifting];
            break;
        case 12:
            [self combineSignal];
            break;
        case 13:
            [self useSwitchToLatest];
            break;
        case 14:
            [self useSignalForSelector];
            break;
        case 15:
            [self Subscription];
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
 Subscriber何时被移除？
 当subscriber被sendCompleted,sendError时，或者手动调用[disposable dispose]时会被移除。
 
 当Subscriber被dispose后，所有该subscriber相关工作都会被停止或取消，资源也会被释放。
 
 Errors有优先权，如果有多个signals被同时监听，只要其中一个signal sendError,那么error就会立刻被传送给subscriber，并导致signal终止执行。相当于Exception.
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

#pragma mark - NSObject+RACLifting
/**
 *  RACLifting相当于对多个信号监听，只有当多个信号都至少被sendNext过一次后，才会去执行某个操作（理解为订阅者）
 */
- (void)testRACLifting
{
    NSLog(@"Start");

    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"1111"];
        return nil;
    }];

    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"2222"];
        });

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"3333"];
        });

        return nil;
    }];
    [self rac_liftSelector:@selector(doA:withB:) withSignals:signalA,signalB, nil];
}

- (void)doA:(NSString *)A withB:(NSString *)B
{
    NSLog(@"A:%@ , B:%@",A,B);
}

#pragma mark - 信号的组合使用
/**
 *  多个信号可以组成事件流
 */
- (void)combineSignal
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

        [subscriber sendNext:@"chenyufeng"];
        [subscriber sendNext:@"chenyufeng2"];
        [subscriber sendNext:@"chenyufeng3"];
        return nil;
    }];

    // 指定take,表示接收多少个sendNext;
    RACSignal *signalB = [[signalA take:1] map:^id(NSString *data) {
        return @(data.length);
    }];

    [signalB subscribeNext:^(id x) {

        NSLog(@"%@",x);
    }];
}

#pragma mark - map+switchToLatest

- (void)useSwitchToLatest
{
    RACSubject *signalOfSignals = [RACSubject subject];
    RACSubject *signal1 = [RACSubject subject];
    RACSubject *signal2 = [RACSubject subject];

    // 获取信号中最近发出信号，订阅最近发出的信号。
    // 注意switchToLatest：只能用于信号中的信号
    [signalOfSignals.switchToLatest subscribeNext:^(id x) {

        NSLog(@"%@",x);
    }];
    [signalOfSignals sendNext:signal1];
    [signalOfSignals sendNext:signal2];

    [signal1 sendNext:@1];
    [signal1 sendNext:@2];

    [signal2 sendNext:@1111];
    [signal2 sendNext:@2222];
}

#pragma mark - rac_signalForSelector

// 等callFunction被调用结束后，回调rac_signalForSelector的block；
- (void)useSignalForSelector
{
    [[self rac_signalForSelector:@selector(callFunction)] subscribeNext:^(id x) {
        NSLog(@"rac_signalForSelector");
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self callFunction];
    });
}

- (void)callFunction
{
    NSLog(@"callFunction...");
}

#pragma mark - 官方文档
- (void)Subscription
{
#if 0
    RACSignal *letters = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence.signal;
    [letters subscribeNext:^(NSString *x) {
        NSLog(@"%@\n",x);
    }];
#endif

#if 0
    __block unsigned subscriptions = 0;
    RACSignal *loggingSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        subscriptions++;
        [subscriber sendCompleted];
        return nil;
    }];

    // subscription 1
    [loggingSignal subscribeCompleted:^ {
        NSLog(@"subscription %u",subscriptions);
    }];

    // subscription 2
    [loggingSignal subscribeCompleted:^ {
        NSLog(@"subscription %u",subscriptions);
    }];
#endif

#if 0
    __block unsigned subscriptions = 0;

    RACSignal *loggingSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        subscriptions++;
        [subscriber sendCompleted];

        return nil;
    }];

    // 只会有一个订阅者
    loggingSignal = [loggingSignal doCompleted:^{
        NSLog(@"about to complete subscription:%u",subscriptions);
    }];

    [loggingSignal subscribeCompleted:^{
        NSLog(@"subscription %u",subscriptions);
    }];
#endif

#if 0
    RACSequence *letters = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence;

    RACSequence *mapped = [letters map:^id(NSString *value) {
        return [value stringByAppendingString:value];
    }];

    RACSignal *signal = [mapped signal];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
#endif

#if 0
    RACSequence *numbers = [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence;
    RACSequence *filtered = [numbers filter:^BOOL(NSString *value) {
        return ([value intValue] % 2) == 0;
    }];

    RACSignal *signal = [filtered signal];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
#endif

#if 0
    RACSequence *letters = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence;
    RACSequence *numbers = [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence;
    RACSequence *concatenated = [letters concat:numbers];

    RACSignal *signal = [concatenated signal];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
#endif

#if 0
    RACSubject *letters = [RACSubject subject];
    RACSubject *numbers = [RACSubject subject];
    RACSignal *signalOfSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

        [subscriber sendNext:letters];
        [subscriber sendNext:numbers];
        [subscriber sendCompleted];
        return nil;
    }];

    // 可以把flatten理解为降阶，原本是信号的信号，降阶后就是信号
    RACSignal *flattened = [signalOfSignal flatten];

    [flattened subscribeNext:^(NSString *x) {
        NSLog(@"%@",x);
    }];

    [letters sendNext:@"A"];
    [numbers sendNext:@"1"];
    [letters sendNext:@"B"];
    [letters sendNext:@"C"];
    [numbers sendNext:@"2"];
#endif

#if 0
    RACSequence *numbers = [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence;
    RACSequence *extended = [numbers flattenMap:^RACStream *(NSString *num) {
        return @[num, num].rac_sequence;
    }];

    RACSignal *extendedSignal = [extended signal];
    [extendedSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];

    RACSequence *edited = [numbers flattenMap:^RACStream *(NSString *num) {
        if (num.intValue % 2 == 0)
        {
            return [RACSequence empty];
        }
        else
        {
            NSString *newNum = [num stringByAppendingString:@"_"];
            return [RACSequence return:newNum];
        }
    }];

    RACSignal *editedSignal = [edited signal];
    [editedSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
#endif

#if 0
    RACSignal *letters = [@"A B C D E F G H I" componentsSeparatedByString:@" "].rac_sequence.signal;
    RACSignal *sequenced = [[letters
                             doNext:^(NSString *letter) {
                                 NSLog(@"%@",letter);// 这里打印出ABCD...
                             }]
                            then:^RACSignal *{
                                return [@"1 2 3 4 5 6 7 8 9" componentsSeparatedByString:@" "].rac_sequence.signal;
                            }];
    // 这里只返回第二个信号的值，只有在订阅后才会打印出doNext和subscribeNext中的值
    [sequenced subscribeNext:^(id x) {
        NSLog(@"%@",x);// 这里打印出1234....
    }];
#endif

#if 0
    RACSubject *letters = [RACSubject subject];
    RACSubject *numbers = [RACSubject subject];
    RACSignal *merged = [RACSignal merge:@[letters, numbers]];

    [merged subscribeNext:^(NSString *x) {
        NSLog(@"%@",x);
    }];

    [letters sendNext:@"A"];
    [numbers sendNext:@"1"];
    [letters sendNext:@"B"];
    [letters sendNext:@"C"];
    [numbers sendNext:@"2"];
#endif

}

@end

































