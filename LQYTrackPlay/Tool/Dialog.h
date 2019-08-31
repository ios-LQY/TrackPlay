//
//  Dialog.h
//  LQYTrackPlay
//
//  Created by 李青洋 on 2019/8/31.
//  Copyright © 2019 LQY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface Dialog : NSObject

//SVProgressHUD
+ (void)loading;
+ (void)loadingWithInfo:(NSString *)info;

+ (void)toast:(NSString *)info;
+ (void)showInfo:(NSString *)info;
+ (void)showSuccessInfo:(NSString *)info;
+ (void)showErrorInfo:(NSString *)info;

+ (void)dismiss;
+ (void)popActivity;

+ (void)inverseColor;
+ (void)minimumDismissTime:(NSTimeInterval)interval;

@end

NS_ASSUME_NONNULL_END
