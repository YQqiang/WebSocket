//
//  SGDetailViewController.m
//  SGWiNetWSConfig_Example
//
//  Created by sungrow on 2020/3/26.
//  Copyright © 2020 1054572107@qq.com. All rights reserved.
//

#import "SGDetailViewController.h"
#import <SGWiNetWSConfig/SGWiNetWSService.h>

@interface SGDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextView *requestTextView;
@property (weak, nonatomic) IBOutlet UITextView *responseTextView;

@end

@implementation SGDetailViewController

+ (instancetype)detailViewController {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SGDetailViewController *vc = [board instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.requestTextView.text = @"service,stalist";
}

- (void)showResponse:(NSString *)msg {
    self.responseTextView.text = msg;
}

- (IBAction)sendAction:(UIButton *)sender {
    [self dismissKeyboard:sender];
    NSString *text = self.requestTextView.text;
    NSArray *keyValues = [text componentsSeparatedByString:@"\n"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.token forKey:@"token"];
    [dic setValue:@"zh_cn" forKey:@"lang"];
    for (NSString *keyValue in keyValues) {
        NSArray *kv = [keyValue componentsSeparatedByString:@","];
        if (kv.count == 2) {
            [dic setValue:kv.lastObject forKey:kv.firstObject];
        }
    }
    [SGWiNetWSService.shareInstance postParam:dic success:^(NSDictionary * _Nonnull result) {
        [self showResponse:[NSString stringWithFormat:@"%@", result]];
    } failure:^(NSError * _Nonnull error) {
        [self showResponse:[NSString stringWithFormat:@"%@", error]];
    }];
}

- (IBAction)dismissKeyboard:(UIButton *)sender {
    [self.view endEditing:YES];
}

- (IBAction)clearRequest:(UIButton *)sender {
    self.requestTextView.text = @"";
    self.responseTextView.text = @"";
}

@end
