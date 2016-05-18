//
//  LoginManager.h
//  ReactiveCocoaDemo
//
//  Created by chenyufeng on 16/5/17.
//  Copyright © 2016年 chenyufengweb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"

@interface LoginManager : NSObject

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) BOOL isLogined;

@end
