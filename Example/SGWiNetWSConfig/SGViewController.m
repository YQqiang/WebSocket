//
//  SGViewController.m
//  SGWiNetWSConfig
//
//  Created by 1054572107@qq.com on 03/24/2020.
//  Copyright (c) 2020 1054572107@qq.com. All rights reserved.
//

#import "SGViewController.h"
#import <SGWiNetWSConfig/SGWiNetWSService.h>

@interface SGViewController ()

@end

@implementation SGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reConnect];
}

- (void)reConnect {
    [SGWiNetWSService.shareInstance reConnectToUrl:[NSURL URLWithString:@"ws://11.11.11.1/ws/home/overview"] complete:^(NSError * _Nonnull error) {
        if (error) {
            NSLog(@"连接失败 error = %@", error);
        } else {
            NSLog(@"连接成功");
        }
    }];
}

- (IBAction)connectAction:(UIButton *)sender {
    NSDictionary *param = @{
            @"lang": @"zh_cn",
            @"token": @"",
            @"service": @"connect"
    };
    [SGWiNetWSService.shareInstance postParam:param success:^(NSDictionary * _Nonnull result) {
        NSLog(@"result = %@", result);
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"error = %@", error);
    }];
}

@end
