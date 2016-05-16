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
 *  使用cocoapods导入ReactiveCocoa要注意，Podfile头部要用：
 use_frameworks!
 否则导入不成功

 并且要指定RAC的版本为2.0，不能使用默认的RAC版本，使用默认的RAC版本会有result包，会导致项目编译失败。Podfile文件如下：
 
 use_frameworks!

 platform:ios,'8.0'
 pod 'ReactiveCocoa', '2.0'

 */

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

@end
