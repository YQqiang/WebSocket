//
//  SGWiNetWSManager.m
//  SGWiNetWSConfig
//
//  Created by sungrow on 2020/3/24.
//

#import "SGWiNetWSManager.h"
#import <SocketRocket/SocketRocket.h>
#import <SGWiNetWSConfig/SGWiNetWSNotification.h>

@interface SGWiNetWSManager ()<SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *socket;

@end

@implementation SGWiNetWSManager

- (SRWebSocket *)socket {
    if (!_socket) {
        _socket = [[SRWebSocket alloc] init];
    }
    return _socket;
}

- (instancetype)init {
    if (self = [super init]) {
        [self reConnectToUrl:[NSURL URLWithString:@"ws://11.11.11.1/ws/home/overview"]];
    }
    return self;
}

- (void)reConnectToUrl:(NSURL *)url {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    self.socket = [[SRWebSocket alloc] initWithURLRequest:request];
    self.socket.delegate = self;
    [self open];
}

- (void)open {
    if (self.socket.readyState != SR_OPEN) {
        [self.socket open];
    }
}

- (void)close {
    [self.socket close];
}

- (void)send:(id)data {
    [self.socket send:data];
}

#pragma mark - SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    [self postNotification:SGWiNetWSDidOpenNotification
                    object:@{
                        @"webSocket":webSocket,
                        @"message":message
                    }];
    NSString *msg = @"";
    if ([message isKindOfClass:NSString.class]) {
        msg = (NSString *)message;
    } else if ([message isKindOfClass:NSData.class]) {
        msg = [[NSString alloc] initWithData:(NSData *)message encoding:NSUTF8StringEncoding];
    }
    NSLog(@"### %s message %@", __func__, msg);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    [self postNotification:SGWiNetWSDidOpenNotification
                    object:@{
                        @"webSocket":webSocket
                    }];
    NSLog(@"### %s", __func__);
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self postNotification:SGWiNetWSDidFailNotification
                    object:@{
                        @"webSocket":webSocket,
                        @"error":error
                    }];
    NSLog(@"### %s", __func__);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [self postNotification:SGWiNetWSDidClose
                    object:@{
                        @"webSocket":webSocket,
                        @"reason":reason,
                        @"wasClean":@(wasClean)
                    }];
    NSLog(@"### %s", __func__);
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    [self postNotification:SGWiNetWSDidReceivePong
                    object:@{
                        @"webSocket":webSocket,
                        @"pongPayload":pongPayload
                    }];
    NSString *message = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
    NSLog(@"### %s message = %@", __func__, message);
}

- (void)postNotification:(NSString *)name object:(id)object {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:object];
}

@end
