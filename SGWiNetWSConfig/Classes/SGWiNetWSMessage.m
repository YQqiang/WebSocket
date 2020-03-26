//
//  SGWiNetWSMessage.m
//  SGWiNetWSConfig
//
//  Created by sungrow on 2020/3/25.
//

#import "SGWiNetWSMessage.h"

@interface SGWiNetWSMessage ()

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, assign) NSInteger timerInterval;
@property (nonatomic, copy) void (^success)(NSDictionary *result);
@property (nonatomic, copy) void (^failure)(NSError *error);
@property (nonatomic, copy) void (^timeout)(void);
@property (nonatomic, copy) void (^cancel)(void);

@end

@implementation SGWiNetWSMessage

- (instancetype)init {
    NSAssert(NO, @"use initWithParameters: timerInterval: success: failure: timeout: cancel:");
    return nil;
}

- (instancetype)initWithParameters:(NSDictionary *)parameters timerInterval:(NSInteger)timerInterval success:(void (^)(NSDictionary * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure timeout:(void (^)(void))timeout cancel:(void (^)(void))cancel {
    if (self = [super init]) {
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
