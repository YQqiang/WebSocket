//
//  SGWiNetWSManager.h
//  SGWiNetWSConfig
//
//  Created by sungrow on 2020/3/24.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SocketRocket.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGWiNetWSManager : NSObject

@property (nonatomic, strong, readonly) SRWebSocket *socket;

- (void)reConnectToUrl:(NSURL *)url complete:(void (^)(NSError *error))complete;

- (void)disConnectComplete:(void (^)(NSUInteger code , NSString *reason, BOOL wasClean))complete;

@end

NS_ASSUME_NONNULL_END
