//
//  SGWiNetWSService.m
//  SGWiNetWSConfig
//
//  Created by sungrow on 2020/3/26.
//

#import "SGWiNetWSService.h"
#import <SGWiNetWSConfig/SGWiNetWSOperation.h>
#import <SGWiNetWSConfig/SGWiNetWSManager.h>

@interface SGWiNetWSService ()

@property (nonatomic, strong) NSOperationQueue *messageQueue;
@property (nonatomic, strong) SGWiNetWSManager *wsManager;

@end

@implementation SGWiNetWSService

- (NSOperationQueue *)messageQueue {
    if (!_messageQueue) {
        _messageQueue = [[NSOperationQueue alloc] init];
        _messageQueue.maxConcurrentOperationCount = 1;
    }
    return _messageQueue;
}

- (SGWiNetWSManager *)wsManager {
    if (!_wsManager) {
        _wsManager = [[SGWiNetWSManager alloc] init];
    }
    return _wsManager;
}

+ (instancetype)shareInstance {
    static SGWiNetWSService *this = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!this) {
            this = [[SGWiNetWSService alloc] init];
        }
    });
    return this;
}

- (void)reConnectToUrl:(NSURL *)url complete:(void (^)(NSError *error))complete {
    [self.wsManager reConnectToUrl:url complete:complete];
}

- (void)disConnectComplete:(void (^)(NSUInteger code , NSString *reason, BOOL wasClean))complete {
    [self.wsManager disConnectComplete:complete];
}

- (void)postParam:(NSDictionary *)param success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    SGWiNetWSMessage *message = [[SGWiNetWSMessage alloc] initWithParameters:param timerInterval:3 success:success failure:failure timeout:^{
        NSError *error = [[NSError alloc] initWithDomain:@"SGWiNetWSOperation.timeout" code:2020032503 userInfo:@{}];
        !failure ?: failure(error);
    } cancel:^{
        NSError *error = [[NSError alloc] initWithDomain:@"SGWiNetWSOperation.cancel" code:2020032504 userInfo:@{}];
        !failure ?: failure(error);
    }];
    [self postMessage:message];
}

- (void)postMessage:(SGWiNetWSMessage *)message {
    SGWiNetWSOperation *operation = [[SGWiNetWSOperation alloc] initWithSocket:self.socket message:message];
    [self addOperation:operation];
}

- (void)addOperation:(SGWiNetWSOperation *)operation {
    [self.messageQueue addOperation:operation];
}

- (SRWebSocket *)socket {
    return self.wsManager.socket;
}

@end
