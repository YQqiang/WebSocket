//
//  SGWiNetWSService.h
//  SGWiNetWSConfig
//
//  Created by sungrow on 2020/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGWiNetWSService : NSObject

@property (nonatomic, strong, readonly) NSOperationQueue *messageQueue;;

+ (instancetype)shareInstance;

- (void)reConnectToUrl:(NSURL *)url complete:(void (^)(NSError *error))complete;

- (void)disConnectComplete:(void (^)(NSUInteger code , NSString *reason, BOOL wasClean))complete;

- (void)webSocketSend:(NSDictionary *)param success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

- (void)httpGetSend:(NSString *)url param:(NSDictionary *)param success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

- (void)httpPostSend:(NSString *)url param:(NSDictionary *)param success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

- (void)httpUpload:(NSString *)url fileData:(NSData *)fileData progress:(void (^)(NSProgress *progress))progress success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

- (void)httpDownload:(NSString *)url progress:(void (^)(NSProgress *progress))progress complete:(void (^)(NSURLResponse * response, NSURL * filePath, NSError * error))complete;

- (void)cancelTransferQueue;

@end

NS_ASSUME_NONNULL_END
