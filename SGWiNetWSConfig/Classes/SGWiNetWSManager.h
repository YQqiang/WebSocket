//
//  SGWiNetWSManager.h
//  SGWiNetWSConfig
//
//  Created by sungrow on 2020/3/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGWiNetWSManager : NSObject

- (void)open;

- (void)close;

- (void)send:(id)data;

@end

NS_ASSUME_NONNULL_END
