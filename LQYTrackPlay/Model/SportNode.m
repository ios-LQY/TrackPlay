//
//  SportNode.m
//  YZ
//
//  Created by 李青洋 on 2019/8/19.
//  Copyright © 2019 apple. All rights reserved.
//

#import "SportNode.h"

@implementation SportNode

+ (instancetype)nodeWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        
        _coordinate = CLLocationCoordinate2DMake([dict[@"lat"] doubleValue], [dict[@"lng"] doubleValue]);
        _angle = [dict[@"direction"] floatValue]/180.00*M_PI;
//        _distance = [dict[@"distance"] doubleValue];
        _speed = [dict[@"gpsSpeed"] doubleValue];
    }
    return self;
}

@end
