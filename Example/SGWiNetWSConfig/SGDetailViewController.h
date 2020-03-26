//
//  SGDetailViewController.h
//  SGWiNetWSConfig_Example
//
//  Created by sungrow on 2020/3/26.
//  Copyright © 2020 1054572107@qq.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SGDetailViewController : UIViewController

@property (nonatomic, copy) NSString *token;

+ (instancetype)detailViewController;

@end

NS_ASSUME_NONNULL_END
