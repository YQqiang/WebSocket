//
//  SGViewController.m
//  SGWiNetWSConfig
//
//  Created by 1054572107@qq.com on 03/24/2020.
//  Copyright (c) 2020 1054572107@qq.com. All rights reserved.
//

#import "SGViewController.h"
#import <SGWiNetWSConfig/SGWiNetWSService.h>
#import "SGDetailViewController.h"

@interface SGViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

@property (nonatomic, copy) NSString *token;

@end

@implementation SGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.text = @"ws://11.11.11.1/ws/home/overview";
    [self reConnect];
}

- (void)reConnect {
    NSString *text = self.textView.text;
    [SGWiNetWSService.shareInstance reConnectToUrl:[NSURL URLWithString:text] complete:^(NSError * _Nonnull error) {
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
        [self showMessage:[NSString stringWithFormat:@"%@", result]];
        self.token = result[@"result_data"][@"token"];
        [self goToDetailViewController];
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"error = %@", error);
        [self showMessage:[NSString stringWithFormat:@"%@", error]];
    }];
}

- (void)goToDetailViewController {
    SGDetailViewController *vc = [SGDetailViewController detailViewController];
    vc.token = self.token;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showMessage:(NSString *)msg {
    self.msgLabel.text = msg;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView endEditing:YES];
        return NO;
    }
    return YES;
}

@end
