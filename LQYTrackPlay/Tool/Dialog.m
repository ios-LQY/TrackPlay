//
//  Dialog.m
//  LQYTrackPlay
//
//  Created by 李青洋 on 2019/8/31.
//  Copyright © 2019 LQY. All rights reserved.
//

#import "Dialog.h"
#import "SVProgressHUD.h"

@implementation Dialog

+ (void)loading {
    [SVProgressHUD show];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
}

+ (void)loadingWithInfo:(NSString *)info {
    [SVProgressHUD showWithStatus:info];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
}

+ (void)toast:(NSString *)info {
    if (info.length) {
        [SVProgressHUD setMinimumSize:CGSizeZero];
        [SVProgressHUD showImage:nil status:info];
    } else {
        [SVProgressHUD dismiss];
    }
}

+ (void)showInfo:(NSString *)info {
    [SVProgressHUD showInfoWithStatus:info];
}

+ (void)showSuccessInfo:(NSString *)info {
    [SVProgressHUD showSuccessWithStatus:info];
}

+ (void)showErrorInfo:(NSString *)info {
    [SVProgressHUD showErrorWithStatus:info];
}

+ (void)dismiss {
    [SVProgressHUD dismiss];
}

+ (void)popActivity {
    [SVProgressHUD popActivity];
}

+ (void)inverseColor {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.2f alpha:0.8f]];
}

+ (void)minimumDismissTime:(NSTimeInterval)interval {
    [SVProgressHUD setMinimumDismissTimeInterval:interval];
}

@end
