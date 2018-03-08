//
//  TestRouter.m
//  STRouterDemo
//
//  Created by EasonWang on 2018/3/8.
//  Copyright © 2018年 EasonWang. All rights reserved.
//

#import "TestRouter.h"
#import "STRouterDemo-Swift.h"

@implementation TestRouter


- (instancetype)init
{
    self = [super init];
    if (self) {
        [STRouter register:@"" handler:^(NSDictionary<NSString *,id> * _Nonnull param, void (^ bloc)(id _Nullable)) {
            
        }];
    }
    return self;
}

@end
