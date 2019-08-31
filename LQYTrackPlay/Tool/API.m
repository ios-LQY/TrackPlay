//
//  API.m
//  LQYTrackPlay
//
//  Created by 李青洋 on 2019/8/31.
//  Copyright © 2019 LQY. All rights reserved.
//

#import "API.h"
#import <AFNetworking.h>
#import <CommonCrypto/CommonDigest.h>
#import "Dialog.h"

#define kNETWORKLOG 1
@implementation API

- (void)requestCarTest:(NSMutableDictionary *)parameters method:(NSString *)method completion:(APICompletionBlock)completion {
    NSString *url = @"http://open.aichezaixian.com/route/rest";
    NSString *appSecret = @"2cc5fb36f3734b809e02856e761ff978";
    // 创建管理者对象
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json",@"charset=utf-8", nil];
    sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *app_key = @"8FB345B8693CCD007570C5F8F2E9A155";
    NSString *timestamp = [self getCurrentTimes];
    [parameters setObject:app_key forKey:@"app_key"];
    [parameters setObject:timestamp forKey:@"timestamp"];
    [parameters setObject:method forKey:@"method"];
    [parameters setObject:@"1.0" forKey:@"v"];
    [parameters setObject:@"md5" forKey:@"sign_method"];
    [parameters setObject:@"json" forKey:@"format"];
    NSString *sign = [self signToRequest:parameters secret:appSecret signMethod:@"md5"];
    [parameters setObject:sign forKey:@"sign"];
    //    NSString *checkSum = [NSString stringWithFormat:@"%@%@%@",app_key,timestamp,method];
    //    checkSum = [checkSum MD5];
    //    [sessionManager.requestSerializer setValue:appid forHTTPHeaderField:@"X-Appid"];
    ////    [sessionManager.requestSerializer setValue:curtime forHTTPHeaderField:@"X-CurTime"];
    //    [sessionManager.requestSerializer setValue:param forHTTPHeaderField:@"X-Param"];
    //    [sessionManager.requestSerializer setValue:checkSum forHTTPHeaderField:@"X-CheckSum"];
    [sessionManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    // 设置请求参数
    //    NSString *urlStr = [NSString stringWithFormat:@"%@",method];
    //    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // 需要设置 body 体
    //    sessionManager.requestSerializer.HTTPBody = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    //    [mutablerequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [sessionManager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"进度");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"请求成功");
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@\n %@",str,dic);
        //        [self parseCarData:dic completion:completion];
        completion(dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败");
        [self handleError:error];
    }];
    
}

- (void)handleError:(NSError *)error {
    NSLog(@"error -----> %@", error);
   [Dialog toast:error.localizedDescription];
}

- (NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    //现在时间,你可以输出来看下是什么格式
    
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    NSLog(@"currentTimeString =  %@",currentTimeString);
    
    return currentTimeString;
    
}

- (NSString *)signToRequest:(NSDictionary *)params
                     secret:(NSString *)secret
                 signMethod:(NSString *)signMethod
{
    
    //第一步：参数按ASCII码表排序
    NSArray *keys = params.allKeys;
    
    NSStringCompareOptions comparisonOptions =NSCaseInsensitiveSearch|NSNumericSearch|
    NSWidthInsensitiveSearch|NSForcedOrderingSearch;
    NSComparator sort = ^(NSString *obj1,NSString *obj2){
        NSRange range =NSMakeRange(0,obj1.length);
        return [obj1 compare:obj2 options:comparisonOptions range:range];
    };
    NSArray *keysSort = [keys sortedArrayUsingComparator:sort];
    
    //第二步：把所有参数名和参数串在一起
    NSMutableString *appendStr = [[NSMutableString alloc] init];
    if ([@"md5" isEqualToString:signMethod]) {
        [appendStr appendString:secret];
    }
    
    for (NSString *key in keysSort) {
        NSString *value = params[key];
        if (value) {
            [appendStr appendString:[NSString stringWithFormat:@"%@%@",key,value]];
        }
    }
    // 第三步：使用MD5加密
    [appendStr appendString:secret];
    NSString *md5Result = [self md5HexDigest:appendStr];
    
    return md5Result;
}

//MARK - md5加密
- (NSString *) md5HexDigest:(NSString *)str
{
    const char *original_str = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash uppercaseString];
}


- (void)parseDataTest:(id)data completion:(void (^)(id data))completion from:(NSString*)postOrGet{
    if (kNETWORKLOG) {
        NSLog(@"%@", data);
    }
    
    if ([data[@"code"] intValue] == 0) {
        completion(data);
    }else{
        [Dialog showInfo:data[@"data"][@"error_msg"]];
    }
}


@end
