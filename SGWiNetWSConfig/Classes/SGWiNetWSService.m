//
//  SGWiNetWSService.m
//  SGWiNetWSConfig
//
//  Created by sungrow on 2020/3/26.
//

#import "SGWiNetWSService.h"

@interface SGWiNetWSService ()

@property (nonatomic, strong) NSOperationQueue *messageQueue;

@end

@implementation SGWiNetWSService

- (NSOperationQueue *)messageQueue {
    if (!_messageQueue) {
        _messageQueue = [[NSOperationQueue alloc] init];
        _messageQueue.maxConcurrentOperationCount = 1;
    }
    return _messageQueue;
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

- (void)setSocket:(SRWebSocket *)socket {
    for (SGWiNetWSOperation *operation in self.messageQueue.operations) {
        [operation cancelSend];
    }
    _socket = socket;
}

@end
