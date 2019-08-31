//
//  TrajectoryController.h
//  YZ
//
//  Created by 李青洋 on 2019/8/20.
//  Copyright © 2019 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TrajectoryController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *mapBGV;

//time view
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeViewHeight;
- (IBAction)customAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *customTimeBt;
- (IBAction)weekTimeAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *weekTimeBt;
- (IBAction)yesterdayAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *yesterdayBt;
- (IBAction)todayAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *todayBt;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
- (IBAction)startTimeAction:(id)sender;
- (IBAction)endTimeAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelTimeBt;
- (IBAction)cancelTimeAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *checkBt;
- (IBAction)checkAction:(id)sender;
//播放view
@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *playViewHeight;

@property (weak, nonatomic) IBOutlet UIButton *playImgBt;
- (IBAction)playAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UIButton *slowBt;

- (IBAction)slowAction:(id)sender;
- (IBAction)addSpeedAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *addSpeedBt;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UISlider *proSlider;
@property (weak, nonatomic) IBOutlet UILabel *startTimeShowLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeShowLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeTimeBt;
- (IBAction)changeTimeAction:(id)sender;




@property (nonatomic, strong)NSString *product_sn;
@property (nonatomic, strong)NSString *gps_code;
@property (nonatomic, strong)NSString *meter_code;
@property (nonatomic, strong)NSString *overdue;
@end

NS_ASSUME_NONNULL_END
