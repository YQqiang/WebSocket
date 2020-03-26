//
//  SGWiNetWSService.h
//  SGWiNetWSConfig
//
//  Created by sungrow on 2020/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGWiNetWSService : NSObject

+ (instancetype)shareInstance;

- (void)reConnectToUrl:(NSURL *)url complete:(void (^)(NSError *error))complete;

- (void)disConnectComplete:(void (^)(NSUInteger code , NSString *reason, BOOL wasClean))complete;

- (void)postParam:(NSDictionary *)param success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
