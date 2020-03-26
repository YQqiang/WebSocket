//
//  SGWiNetWSManager.m
//  SGWiNetWSConfig
//
//  Created by sungrow on 2020/3/24.
//

#import "SGWiNetWSManager.h"
#import <SGWiNetWSConfig/SGWiNetWSNotification.h>

@interface SGWiNetWSManager ()<SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic, copy) void (^connectComplete)(NSError *error);
@property (nonatomic, copy) void (^disconnectComplete)(NSUInteger code , NSString *reason, BOOL wasClean);

@end

@implementation SGWiNetWSManager

- (SRWebSocket *)socket {
    if (!_socket) {
        _socket = [[SRWebSocket alloc] init];
    }
    return _socket;
}

//- (instancetype)init {
//    if (self = [super init]) {
//        [self reConnectToUrl:[NSURL URLWithString:@"ws://11.11.11.1/ws/home/overview"] complete:^(NSError * _Nonnull error) {
//        }];
//    }
//    return self;
//}

- (void)reConnectToUrl:(NSURL *)url complete:(void (^)(NSError *error))complete {
    [self close];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    self.connectComplete = complete;
    self.socket = [[SRWebSocket alloc] initWithURLRequest:request];
    self.socket.delegate = self;
    [self open];
}

- (void)open {
    if (self.socket.readyState != SR_OPEN) {
        [self.socket open];
    }
}

- (void)disConnectComplete:(void (^)(NSUInteger code , NSString *reason, BOOL wasClean))complete {
    [self close];
    self.disconnectComplete = complete;
}

- (void)close {
    if (self.socket.readyState == SR_OPEN) {
        [self.socket close];
    }
}

#pragma mark - SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    [self postNotification:SGWiNetWSDidReceiveMessageNotification
                    object:@{
                        @"webSocket":webSocket,
                        @"message":message
                    }];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    [self postNotification:SGWiNetWSDidOpenNotification
                    object:@{
                        @"webSocket":webSocket
                    }];
    !self.connectComplete ?: self.connectComplete(nil);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self postNotification:SGWiNetWSDidFailNotification
                    object:@{
                        @"webSocket":webSocket,
                        @"error":error
                    }];
    !self.connectComplete ?: self.connectComplete(error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [self postNotification:SGWiNetWSDidClose
                    object:@{
                        @"webSocket":webSocket,
                        @"reason":reason,
                        @"wasClean":@(wasClean)
                    }];
    !self.disconnectComplete ?: self.disconnectComplete(code, reason, wasClean);
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    [self postNotification:SGWiNetWSDidReceivePong
                    object:@{
                        @"webSocket":webSocket,
                        @"pongPayload":pongPayload
                    }];
}

- (void)postNotification:(NSString *)name object:(id)object {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:object];
}

@end
