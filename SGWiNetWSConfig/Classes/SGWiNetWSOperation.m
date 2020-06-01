//
//  SGWiNetWSOperation.m
//  SGWiNetWSConfig
//
//  Created by sungrow on 2020/3/25.
//

#import "SGWiNetWSOperation.h"
#import <SGWiNetWSConfig/SGWiNetWSNotification.h>

@interface SGWiNetWSOperation ()<NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic, strong) SGWiNetWSMessage *message;
@property (nonatomic, assign) BOOL willCancel;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation SGWiNetWSOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithSocket:(SRWebSocket *)socket message:(SGWiNetWSMessage *)message {
    if (self = [super init]) {
        self.socket = socket;
        self.message = message;
    }
    return self;
}

- (void)startTimer {
    if (!self.timer) {
        self.timer = [NSTimer timerWithTimeInterval:self.message.timerInterval target:self selector:@selector(executeTimeout) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)start {
    if (![self isReady]){
        return;
    }
    if (self.isCancelled) {
        return;
    }
    if (self.willCancel) {
        [self executeCancel];
        return;
    }
    if (self.message.type == SGSendMessageTypeWebSocket) {
        if (self.socket.readyState != SR_OPEN) {
            NSError *error = [[NSError alloc] initWithDomain:@"SGWiNetWSOperation.notOpen" code:2020032501 userInfo:@{}];
            [self executeFailure:error];
            return;
        }
        [self addNotification];
        [self webSocketSend];
    } else {
        [self httpSend];
    }
}

- (void)webSocketSend {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.message.parameters options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        [self executeFailure:error];
    } else {
        [self.socket send:data];
        [self startTimer];
    }
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessageNoti:) name:SGWiNetWSDidReceiveMessageNotification object:nil];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMessageNoti:(NSNotification *)noti {
    SRWebSocket *webSocket = noti.object[@"webSocket"];
    if (self.socket != webSocket) return;
    id message = noti.object[@"message"];
    NSData *data;
    if ([message isKindOfClass:NSData.class]) {
        data = (NSData *)message;
    } else if ([message isKindOfClass:NSString.class]) {
        data = [message dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        NSError *error = [[NSError alloc] initWithDomain:@"SGWiNetWSOperation.dataType.error" code:2020032502 userInfo:@{}];
        [self executeFailure:error];
        return;
    }
    NSError *error;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingFragmentsAllowed error:&error];
    if (error) {
        [self executeFailure:error];
    } else {
        [self executeSucces:result];
    }
}

- (void)finish {
    [self stopTimer];
    [self removeNotification];
    [self changeExecuting:NO];
    [self changeFinished:YES];
}

- (void)changeExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)changeFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isAsynchronous {
    return YES;
}

- (void)cancelSend {
    self.willCancel = YES;
}

#pragma mark - http
- (void)httpSend {
    if (self.message.url.length <= 0) {
        NSError *error = [[NSError alloc] initWithDomain:@"SGWiNetWSOperation.url.notset" code:2020032701 userInfo:@{}];
        [self executeFailure:error];
        return;
    }
    NSURL *url = [NSURL URLWithString:self.message.url];
    if (!url) {
        NSError *error = [[NSError alloc] initWithDomain:@"SGWiNetWSOperation.url.error" code:2020032702 userInfo:@{}];
        [self executeFailure:error];
        return;
    }
    void (^complete)(NSData *data, NSURLResponse *response, NSError *error) = ^void(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            [self executeFailure:error];
        } else {
            NSError *error;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingFragmentsAllowed error:&error];
            if (error) {
                [self executeFailure:error];
            } else {
                [self executeSucces:result];
            }
        }
    };
    if (self.message.type == SGSendMessageTypeHttpGet) {
        [self httpGet:url complete:complete];
    } else if (self.message.type == SGSendMessageTypeHttpPost) {
        [self httpPost:url complete:complete];
    } else if (self.message.type == SGSendMessageTypeHttpUpload) {
        [self httpUpload:url complete:complete];
    } else if (self.message.type == SGSendMessageTypeHttpDownload) {
        [self httpDownload:url complete:nil];
    }
}

- (void)httpPost:(NSURL *)url complete:(void (^)(NSData * data, NSURLResponse *response, NSError * error))complete {
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.message.parameters options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        jsonData = [[self parametersJoined] dataUsingEncoding:NSUTF8StringEncoding];
    }
    request.HTTPBody = jsonData;
    request.timeoutInterval = self.message.timerInterval;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:complete];
    [dataTask resume];
}

- (void)httpGet:(NSURL *)url complete:(void (^)(NSData * data, NSURLResponse *response, NSError * error))complete {
    NSString *params = [self parametersJoined];
    if (params.length > 0) {
        NSString *finalUrlStr = [NSString stringWithFormat:@"%@?%@", url.absoluteString, params];
        url = [NSURL URLWithString:finalUrlStr];
    }
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = self.message.timerInterval;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:complete];
    [dataTask resume];
}

- (NSURLSessionDataTask *)httpUpload:(NSURL *)url complete:(void (^)(NSData * data, NSURLResponse *response, NSError * error))complete {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:self.message.fileData completionHandler:complete];
    [uploadTask resume];
    return uploadTask;
}

- (NSURLSessionDownloadTask *)httpDownload:(NSURL *)url complete:(void (^)(NSData * data, NSURLResponse *response, NSError * error))complete {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
    [downloadTask resume];
    return downloadTask;
}

- (NSString *)parametersJoined {
    NSMutableArray <NSString *>*keyValues = [NSMutableArray array];
    for (NSString *key in self.message.parameters.allKeys) {
        [keyValues addObject:[NSString stringWithFormat:@"%@=%@", key, self.message.parameters[key]]];
    }
    return [keyValues componentsJoinedByString:@"&"];
}

#pragma mark - excute block
- (void)executeCancel {
    [self finish];
    if (self.message.cancel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.message.cancel();
        });
    }
}

- (void)executeTimeout {
    [self finish];
    if (self.message.timeout) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.message.timeout();
        });
    }
}

- (void)executeSucces:(NSDictionary *)result {
    [self finish];
    if (self.message.success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.message.success(result);
        });
    }
}

- (void)executeFailure:(NSError *)error {
    [self finish];
    if (self.message.failure) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.message.failure(error);
        });
    }
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
         didSendBodyData:(int64_t)bytesSent
          totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    self.message.uploadProgressValue.totalUnitCount = task.countOfBytesExpectedToSend;
    self.message.uploadProgressValue.completedUnitCount = task.countOfBytesSent;
    !self.message.uploadProgress ?: self.message.uploadProgress(self.message.uploadProgressValue);
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    [self finish];
    if (self.message.downloadComplete) {
        self.message.downloadComplete(downloadTask.response, location, nil);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [self finish];
    if (self.message.downloadComplete) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.message.downloadComplete(task.response, nil, error);
        });
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    self.message.downloadProgressValue.totalUnitCount = downloadTask.countOfBytesExpectedToSend;
    self.message.downloadProgressValue.completedUnitCount = downloadTask.countOfBytesSent;
    !self.message.downloadProgress ?: self.message.downloadProgress(self.message.downloadProgressValue);
}

@end
