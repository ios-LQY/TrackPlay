//
//  SportNode.h
//  YZ
//
//  Created by 李青洋 on 2019/8/19.
//  Copyright © 2019 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface SportNode : NSObject

/** 经纬度 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

/** 方向（角度）*/
@property (nonatomic, assign) CGFloat angle;

/** 距离 */
@property (nonatomic, assign) CGFloat distance;

/** 速度 */
@property (nonatomic, assign) CGFloat speed;

+ (instancetype)nodeWithDictionary:(NSDictionary *)dict;


@end

NS_ASSUME_NONNULL_END
