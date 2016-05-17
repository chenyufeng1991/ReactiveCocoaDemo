
//
//  ThirdViewController.m
//  ReactiveCocoaDemo
//
//  Created by chenyufeng on 16/5/17.
//  Copyright © 2016年 chenyufengweb. All rights reserved.
//

#import "ThirdViewController.h"
#import "ReactiveCocoa.h"

@interface ThirdViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *myArray;
@property (strong, nonatomic) UITableView *myTableView;

@end

@implementation ThirdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myArray = [[NSMutableArray alloc] initWithObjects:@"冷信号",@"热信号", nil];
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
        default:
            break;
    }

}

#pragma mark - Function

// 冷信号
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
- (void)hotSignal
{
    RACMulticastConnection *connection = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
            [subscriber sendNext:@1];
        }];
        [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
            [subscriber sendNext:@2];
        }];
        [[RACScheduler mainThreadScheduler] afterDelay:3 schedule:^{
            [subscriber sendNext:@3];
        }];
        [[RACScheduler mainThreadScheduler] afterDelay:4 schedule:^{
            [subscriber sendCompleted];
        }];

        return nil;
    }] publish];

    [connection connect];

    RACSignal *signal = connection.signal;
    NSLog(@"Signal was created");

    [[RACScheduler mainThreadScheduler] afterDelay:1.5 schedule:^{
        [signal subscribeNext:^(id x) {
            NSLog(@"Subscriber 1 receive:%@",x);
        }];
    }];
    [[RACScheduler mainThreadScheduler] afterDelay:2.5 schedule:^{
        [signal subscribeNext:^(id x) {
            NSLog(@"Subscriber 2 receive:%@",x);
        }];
    }];

}

@end








