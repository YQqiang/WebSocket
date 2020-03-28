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
@property (weak, nonatomic) IBOutlet UIButton *wsBtn;
@property (weak, nonatomic) IBOutlet UIButton *getBtn;
@property (weak, nonatomic) IBOutlet UIButton *postBtn;
@property (weak, nonatomic) IBOutlet UIStackView *urlStack;
@property (weak, nonatomic) IBOutlet UITextView *urlTextView;

@end

@implementation SGDetailViewController

+ (instancetype)detailViewController {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SGDetailViewController *vc = [board instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    void (^success)(NSDictionary * _Nonnull result) = ^void(NSDictionary * _Nonnull result) {
        [self showResponse:[NSString stringWithFormat:@"%@", result]];
    };
    void (^failure)(NSError * _Nonnull error) = ^void(NSError * _Nonnull error) {
        [self showResponse:[NSString stringWithFormat:@"%@", error]];
    };
    NSString *url = self.urlTextView.text;
    if (self.wsBtn.selected) {
        [SGWiNetWSService.shareInstance webSocketSend:dic success:success failure:failure];
    } else if (self.getBtn.selected) {
        [SGWiNetWSService.shareInstance httpGetSend:url param:dic success:success failure:failure];
    } else if (self.postBtn.selected) {
        [SGWiNetWSService.shareInstance httpPostSend:url param:dic success:success failure:failure];
    }
}

- (IBAction)dismissKeyboard:(UIButton *)sender {
    [self.view endEditing:YES];
}

- (IBAction)wsBtnAction:(UIButton *)sender {
    [self selectedButton:sender];
}

- (IBAction)getBtnAction:(UIButton *)sender {
    [self selectedButton:sender];
}

- (IBAction)postBtnAction:(UIButton *)sender {
    [self selectedButton:sender];
}

- (void)selectedButton:(UIButton *)sender {
    self.wsBtn.selected = sender == self.wsBtn;
    self.getBtn.selected = sender == self.getBtn;
    self.postBtn.selected = sender == self.postBtn;
    self.urlStack.hidden = self.wsBtn.selected;
}

- (IBAction)clearRequest:(UIButton *)sender {
    self.requestTextView.text = @"";
    self.responseTextView.text = @"";
}

@end
