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
        _messageQueue.maxConcurrentOperationCount = 10;
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

- (void)webSocketSend:(NSDictionary *)param success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    SGWiNetWSMessage *message = [[SGWiNetWSMessage alloc] initWithType:SGSendMessageTypeWebSocket Parameters:param timerInterval:3 success:success failure:failure timeout:^{
        NSError *error = [[NSError alloc] initWithDomain:@"SGWiNetWSOperation.timeout" code:2020032503 userInfo:@{}];
        !failure ?: failure(error);
    } cancel:^{
        NSError *error = [[NSError alloc] initWithDomain:@"SGWiNetWSOperation.cancel" code:2020032504 userInfo:@{}];
        !failure ?: failure(error);
    }];
    [self sendMessage:message];
}

- (void)httpGetSend:(NSString *)url param:(NSDictionary *)param success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    [self httpSendType:SGSendMessageTypeHttpGet url:url param:param success:success failure:failure];
}

- (void)httpPostSend:(NSString *)url param:(NSDictionary *)param success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    [self httpSendType:SGSendMessageTypeHttpPost url:url param:param success:success failure:failure];
}

- (void)httpUpload:(NSString *)url fileData:(NSData *)fileData progress:(void (^)(NSProgress *progress))progress success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    SGWiNetWSMessage *message = [[SGWiNetWSMessage alloc] initWithType:SGSendMessageTypeHttpUpload Parameters:@{} timerInterval:30 * 60 success:success failure:failure timeout:^{
        NSError *error = [[NSError alloc] initWithDomain:@"SGWiNetWSOperation.timeout" code:2020052201 userInfo:@{}];
        !failure ?: failure(error);
    } cancel:^{
        NSError *error = [[NSError alloc] initWithDomain:@"SGWiNetWSOperation.cancel" code:2020052202 userInfo:@{}];
        !failure ?: failure(error);
    }];
    message.url = url;
    message.fileData = fileData;
    message.uploadProgress = progress;
    [self sendMessage:message];
}

- (void)httpDownload:(NSString *)url progress:(void (^)(NSProgress *progress))progress complete:(void (^)(NSURLResponse * response, NSURL * filePath, NSError * error))complete {
    SGWiNetWSMessage *message = [[SGWiNetWSMessage alloc] initWithType:SGSendMessageTypeHttpDownload Parameters:@{} timerInterval:30 * 60 success:^(NSDictionary * _Nonnull result) {
    } failure:^(NSError * _Nonnull error) {
    } timeout:^{
        NSError *error = [[NSError alloc] initWithDomain:@"SGWiNetWSOperation.timeout" code:2020053001 userInfo:@{}];
        !complete ?: complete(nil, nil, error);
    } cancel:^{
        NSError *error = [[NSError alloc] initWithDomain:@"SGWiNetWSOperation.cancel" code:2020053002 userInfo:@{}];
        !complete ?: complete(nil, nil, error);
    }];
    message.url = url;
    message.downloadProgress = progress;
    message.downloadComplete = complete;
    [self sendMessage:message];
}

- (void)httpSendType:(SGSendMessageType)type url:(NSString *)url param:(NSDictionary *)param success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    SGWiNetWSMessage *message = [[SGWiNetWSMessage alloc] initWithType:type Parameters:param timerInterval:10 success:success failure:failure timeout:^{
        NSError *error = [[NSError alloc] initWithDomain:@"SGWiNetWSOperation.timeout" code:2020032503 userInfo:@{}];
        !failure ?: failure(error);
    } cancel:^{
        NSError *error = [[NSError alloc] initWithDomain:@"SGWiNetWSOperation.cancel" code:2020032504 userInfo:@{}];
        !failure ?: failure(error);
    }];
    message.url = url;
    [self sendMessage:message];
}

- (void)sendMessage:(SGWiNetWSMessage *)message {
    SGWiNetWSOperation *operation = [[SGWiNetWSOperation alloc] initWithSocket:self.socket message:message];
    [self addOperation:operation];
}

- (void)addOperation:(SGWiNetWSOperation *)operation {
    [self.messageQueue addOperation:operation];
}

- (SRWebSocket *)socket {
    return self.wsManager.socket;
}

- (void)cancelTransferQueue {
    for (SGWiNetWSOperation *operation in self.messageQueue.operations) {
        [operation cancelSend];
    }
}

@end
