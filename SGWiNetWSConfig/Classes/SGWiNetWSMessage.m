//
//  SGWiNetWSMessage.m
//  SGWiNetWSConfig
//
//  Created by sungrow on 2020/3/25.
//

#import "SGWiNetWSMessage.h"

@interface SGWiNetWSMessage ()

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, assign) SGSendMessageType type;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, assign) NSInteger timerInterval;
@property (nonatomic, copy) void (^success)(NSDictionary *result);
@property (nonatomic, copy) void (^failure)(NSError *error);
@property (nonatomic, copy) void (^timeout)(void);
@property (nonatomic, copy) void (^cancel)(void);
@property (nonatomic, strong) NSProgress *uploadProgressValue;
@property (nonatomic, strong) NSProgress *downloadProgressValue;

@end

@implementation SGWiNetWSMessage

#pragma mark - lazy
- (NSProgress *)uploadProgressValue {
    if (!_uploadProgressValue) {
        _uploadProgressValue = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    }
    return _uploadProgressValue;
}

- (NSProgress *)downloadProgressValue {
    if (!_downloadProgressValue) {
        _downloadProgressValue = [[NSProgress alloc] initWithParent:nil userInfo:nil];
    }
    return _downloadProgressValue;
}

- (instancetype)init {
    NSAssert(NO, @"use initWithParameters: timerInterval: success: failure: timeout: cancel:");
    return nil;
}

- (instancetype)initWithType:(SGSendMessageType)type Parameters:(NSDictionary *)parameters timerInterval:(NSInteger)timerInterval success:(void (^)(NSDictionary * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure timeout:(void (^)(void))timeout cancel:(void (^)(void))cancel {
    if (self = [super init]) {
        self.type = type;
        self.parameters = parameters;
        self.timerInterval = timerInterval;
        self.success = success;
        self.failure = failure;
        self.timeout = timeout;
        self.cancel = cancel;
        self.uuid = [[NSUUID alloc] init].UUIDString;
    }
    return self;
}

@end
