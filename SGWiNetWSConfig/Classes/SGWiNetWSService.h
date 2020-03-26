//
//  SGWiNetWSService.h
//  SGWiNetWSConfig
//
//  Created by sungrow on 2020/3/26.
//

#import <Foundation/Foundation.h>
#import <SGWiNetWSConfig/SGWiNetWSOperation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGWiNetWSService : NSObject

@property (nonatomic, strong) SRWebSocket *socket;

@end

NS_ASSUME_NONNULL_END
