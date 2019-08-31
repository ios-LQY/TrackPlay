//
//  SportAnnotationView.h
//  YZ
//
//  Created by 李青洋 on 2019/8/19.
//  Copyright © 2019 apple. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ Completion)(void);
typedef void(^CurrentIndex)(NSInteger idx);
typedef void(^MapCenter)(NSInteger idx);

@class SportNode;

@interface SportAnnotationView : BMKAnnotationView


/** 轨迹点数组 */
@property (nonatomic, strong) NSArray<SportNode *> *sportNodes;
/** 轨迹回放完成回调 */
@property (nonatomic, copy) Completion completion;
@property (nonatomic, copy) CurrentIndex currentIdx;
@property (nonatomic, copy) MapCenter mapCenter;
/** 播放速度 */
@property (nonatomic, assign) float speed;

/** 播放位置 */
@property (nonatomic, assign) NSInteger idx;

/** 开始 */
- (void)startWithTime:(NSInteger)time;

/** 暂停 */
- (void)pause;

/** 停止 */
- (void)stop;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
