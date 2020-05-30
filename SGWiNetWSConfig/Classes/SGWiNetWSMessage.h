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
    SGSendMessageTypeHttpUpload,
    SGSendMessageTypeHttpDownload,
} SGSendMessageType;

@interface SGWiNetWSMessage : NSObject

/// type = SGSendMessageTypeHttpGet  || SGSendMessageTypeHttpPost || SGSendMessageTypeHttpUpload, 需要设置请求的url
@property (nonatomic, copy) NSString *url;

/// SGSendMessageTypeHttpUpload
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, copy) void (^uploadProgress)(NSProgress *progress);
@property (nonatomic, strong, readonly) NSProgress *uploadProgressValue;

/// SGSendMessageTypeHttpDownload
@property (nonatomic, copy) void (^downloadComplete)(NSURLResponse * response, NSURL * filePath, NSError * error);
@property (nonatomic, copy) void (^downloadProgress)(NSProgress *progress);
@property (nonatomic, strong, readonly) NSProgress *downloadProgressValue;

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
