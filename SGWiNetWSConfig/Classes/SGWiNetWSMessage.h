//
//  SGWiNetWSMessage.h
//  SGWiNetWSConfig
//
//  Created by sungrow on 2020/3/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    SGSendMessageTypeWebSocket,
    SGSendMessageTypeHttpGet,
    SGSendMessageTypeHttpPost,
} SGSendMessageType;

@interface SGWiNetWSMessage : NSObject

/// type = SGSendMessageTypeHttpGet  || SGSendMessageTypeHttpPost, 需要设置请求的url
@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign, readonly) SGSendMessageType type;
@property (nonatomic, strong, readonly) NSDictionary *parameters;
@property (nonatomic, assign, readonly) NSInteger timerInterval;
@property (nonatomic, copy, readonly) void (^success)(NSDictionary *result);
@property (nonatomic, copy, readonly) void (^failure)(NSError *error);
@property (nonatomic, copy, readonly) void (^timeout)(void);
@property (nonatomic, copy, readonly) void (^cancel)(void);

- (instancetype)initWithType:(SGSendMessageType)type Parameters:(NSDictionary *)parameters timerInterval:(NSInteger)timerInterval success:(void (^)(NSDictionary * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure timeout:(void (^)(void))timeout cancel:(void (^)(void))cancel;

@end

NS_ASSUME_NONNULL_END
