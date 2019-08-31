//
//  API.h
//  LQYTrackPlay
//
//  Created by 李青洋 on 2019/8/31.
//  Copyright © 2019 LQY. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^APICompletionBlock)(id data);

@interface API : NSObject

@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) APICompletionBlock completionBlock;

- (void)requestCarTest:(NSMutableDictionary *)parameters method:(NSString *)method completion:(APICompletionBlock)completion; //几米

@end

NS_ASSUME_NONNULL_END
