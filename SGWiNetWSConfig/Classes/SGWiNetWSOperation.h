//
//  SGWiNetWSOperation.h
//  SGWiNetWSConfig
//
//  Created by sungrow on 2020/3/25.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SocketRocket.h>
#import <SGWiNetWSConfig/SGWiNetWSMessage.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGWiNetWSOperation : NSOperation

- (instancetype)initWithSocket:(SRWebSocket *)socket message:(SGWiNetWSMessage *)message;

- (void)cancelSend;

@end

NS_ASSUME_NONNULL_END
