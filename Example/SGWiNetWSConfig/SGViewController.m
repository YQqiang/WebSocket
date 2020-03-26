//
//  SGViewController.m
//  SGWiNetWSConfig
//
//  Created by 1054572107@qq.com on 03/24/2020.
//  Copyright (c) 2020 1054572107@qq.com. All rights reserved.
//

#import "SGViewController.h"
#import <SGWiNetWSConfig/SGWiNetWSManager.h>

@interface SGViewController ()

@property (nonatomic, strong) SGWiNetWSManager *wsManager;

@end

@implementation SGViewController

- (SGWiNetWSManager *)wsManager {
    if (!_wsManager) {
        _wsManager = [[SGWiNetWSManager alloc] init];
    }
    return _wsManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self wsManager];
	
}

- (IBAction)connectAction:(UIButton *)sender {
    [self.wsManager send:@"{\"lang\":\"zh_cn\",\"token\":\"\",\"service\":\"connect\"}"];
}

- (void)staList {
    NSString *msg = @"\"lang\":\"zh_cn\",\"token\":\"1193_36c55764-8e88-477d-94aa-6601da7e4d0f\",\"service\":\"stalist\"";
    [self.wsManager send:msg];
}

@end
