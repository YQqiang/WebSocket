//
//  SGWiNetWSOperation.m
//  SGWiNetWSConfig
//
//  Created by sungrow on 2020/3/25.
//

#import "SGWiNetWSOperation.h"
#import <SGWiNetWSConfig/SGWiNetWSNotification.h>

@interface SGWiNetWSOperation ()

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
    if (self.socket.readyState != SR_OPEN) {
        NSError *error = [[NSError alloc] initWithDomain:@"SGWiNetWSOperation.notOpen" code:2020032501 userInfo:@{}];
        [self executeFailure:error];
        return;
    }
    [self addNotification];
    [self sendMessage];
}

- (void)sendMessage {
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

@end
