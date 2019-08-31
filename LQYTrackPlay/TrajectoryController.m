//
//  TrajectoryController.m
//  YZ
//
//  Created by 李青洋 on 2019/8/20.
//  Copyright © 2019 apple. All rights reserved.
//

#import "TrajectoryController.h"
#import "API.h"
#import "SportNode.h"
#import "SportAnnotationView.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BMKLocationKit/BMKLocationManager.h>
#import <BaiduMapKit/BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import "PGDatePickManager.h"
#import <CommonCrypto/CommonDigest.h>
#import "Dialog.h"

//屏幕宽高
#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height
#define IMEI    @"868120217335055"
//复用annotationView的指定唯一标识
static NSString *annotationViewIdentifier = @"com.Baidu.BMKPointAnnotation";
@interface TrajectoryController ()<BMKLocationManagerDelegate,BMKMapViewDelegate,BMKGeoCodeSearchDelegate,PGDatePickerDelegate>
{
    NSString *timeTypeStr; //开始or结束
    NSString *timeType; //自定义 本周 昨天 今天
    
    NSDictionary *carStatusDic;
    
    NSString *currentCity;
    NSString *currentArea;
    NSString *currentAddress;
    
    NSInteger playSpeed; //5
    float playAllTime; //播放总时间
}
@property (nonatomic, strong) SportAnnotationView *sportAnnotationView;
@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *sportNodes; // 轨迹点

@property (nonatomic, strong) PGDatePickManager *datePickManager;
@property (nonatomic, strong) PGDatePickManager *yearPickManager;
@property (nonatomic, strong) PGDatePicker *datePicker;
@property (nonatomic, strong) PGDatePicker *yearPicker;
@property (nonatomic, assign) CLLocationCoordinate2D location2D;
@property (nonatomic, strong) BMKUserLocation *userLocation; //定位功能
@property (nonatomic, strong) BMKLocationManager *bmkLocationManager; //定位对象
@property (nonatomic, strong) BMKPointAnnotation *annotation; //当前界面的标注

@end

@implementation TrajectoryController
- (BMKLocationManager *)bmkLocationManager {
    if (!_bmkLocationManager) {
        _bmkLocationManager = [[BMKLocationManager alloc] init];
        _bmkLocationManager.delegate = self;
        _bmkLocationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        _bmkLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _bmkLocationManager.activityType = CLActivityTypeAutomotiveNavigation;
        _bmkLocationManager.pausesLocationUpdatesAutomatically = NO;
        _bmkLocationManager.allowsBackgroundLocationUpdates = NO;
        _bmkLocationManager.locationTimeout = 10;
    }
    return _bmkLocationManager;
}

- (BMKUserLocation *)userLocation {
    if (!_userLocation) {
        _userLocation = [[BMKUserLocation alloc] init];
    }
    return _userLocation;
}
- (BMKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
        _mapView.zoomLevel = 18;
        _mapView.showMapScaleBar = NO;
        _mapView.delegate = self;
        _mapView.rotateEnabled = NO; //是否支持旋转
//        _mapView.mapScaleBarPosition = CGPointMake(20,_mapView.frame.size.height-120);
        _mapView.mapType=BMKMapTypeStandard;
        _mapView.showsUserLocation = NO;
    }
    return _mapView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
    _bmkLocationManager.delegate = nil;
//    _sportAnnotationView = nil;
//    [self.playTimer invalidate];
//    self.playTimer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"历史轨迹";
//    self.view.backgroundColor = [UIColor whiteColor];
    playSpeed = 1;
    [self updateView];
    [self.mapBGV addSubview:self.mapView];
    [self initlocationService];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"warning");
}

#pragma mark - views

- (void)updateView
{
    self.timeViewHeight.constant = 180;
    self.playViewHeight.constant = 130;
    self.timeView.hidden = NO;
    self.playView.hidden = YES;
    
    //time view
    self.cancelTimeBt.layer.cornerRadius = 2.5;
    self.cancelTimeBt.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.cancelTimeBt.layer.borderWidth = 0.5;
    
    self.checkBt.layer.cornerRadius = 2.5;
    self.checkBt.layer.masksToBounds = YES;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *datenow = [NSDate date];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *currentDayStr = [formatter stringFromDate:datenow];
    timeType = @"today";
    self.startTimeLabel.text = [NSString stringWithFormat:@"%@ 00:00:00",currentDayStr];
    self.endTimeLabel.text = currentTimeString;
    [self.todayBt setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    //playView
    self.slowBt.layer.cornerRadius = 2.5;
    self.slowBt.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.slowBt.layer.borderWidth = 0.5;
    
    self.addSpeedBt.layer.cornerRadius = 2.5;
    self.addSpeedBt.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.addSpeedBt.layer.borderWidth = 0.5;
    
    self.changeTimeBt.layer.cornerRadius = 2.5;
    self.changeTimeBt.layer.masksToBounds = YES;
    
    //设置滑块左边（小于部分）线条的颜色
    self.proSlider.minimumTrackTintColor = [UIColor blueColor];
    //设置滑块右边（大于部分）线条的颜色
    self.proSlider.maximumTrackTintColor = [UIColor lightGrayColor];
    //设置滑块颜色（影响已划过一端的颜色）
    self.proSlider.thumbTintColor = [UIColor blueColor];
//    [self.proSlider setThumbImage:[self OriginImage:[UIImage imageNamed:@"thumb"] scaleToSize:CGSizeMake(18, 18)] forState:UIControlStateNormal];
    [self.proSlider setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
    [self.proSlider setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateHighlighted];
    //添加点击事件
    [self.proSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    
    [self updateSpeedLabel];
}

- (UIImage*)OriginImage:(UIImage*)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);//size为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
    
}

- (void)setupDateKey:(BOOL)isYear {
    
    if (isYear) {
        self.yearPickManager = [[PGDatePickManager alloc]init];
        self.yearPicker = self.yearPickManager.datePicker;
        self.yearPicker.delegate = self;
        self.yearPicker.datePickerType = PGDatePickerTypeVertical;
        self.yearPicker.datePickerMode = PGDatePickerModeDateHourMinuteSecond;
        [self presentViewController:self.yearPickManager animated:false completion:nil];
    }else{
        self.datePickManager = [[PGDatePickManager alloc]init];
        self.datePicker = self.datePickManager.datePicker;
        self.datePicker.delegate = self;
        self.datePicker.datePickerType = PGDatePickerTypeVertical;
        self.datePicker.datePickerMode = PGDatePickerModeTimeAndSecond;
        [self presentViewController:self.datePickManager animated:false completion:nil];
    }
}


-(void)initlocationService{
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
}

#pragma mark -- BMKMapView Delegate
/** 地图加载完成 */
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView
{
    
}

/** 根据overlay生成对应的View */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
    if (![overlay isKindOfClass:[BMKPolyline class]]) return nil;
    
    BMKPolylineView *polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
    polylineView.strokeColor = [UIColor blueColor];
    polylineView.lineWidth = 2.0;
    
    return polylineView;
}

/** 根据anntation生成对应的View */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation.title isEqualToString:@"起点"]) {
        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewIdentifier];
        if (!annotationView) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewIdentifier];
            //annotationView显示的图片，默认是大头针
            annotationView.image = [UIImage imageNamed:@"start_loc"];
            
            //设置从天而降的动画效果
            annotationView.animatesDrop = YES;
            //当设为YES并实现了setCoordinate:方法时，支持将annotationView在地图上拖动
            annotationView.draggable = YES;
        }
        return annotationView;
    }else if ([annotation.title isEqualToString:@"终点"]){
        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewIdentifier];
        if (!annotationView) {
            
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewIdentifier];
            //annotationView显示的图片，默认是大头针
            annotationView.image = [UIImage imageNamed:@"end_loc"];
            
            //设置从天而降的动画效果
            annotationView.animatesDrop = YES;
            //当设为YES并实现了setCoordinate:方法时，支持将annotationView在地图上拖动
            annotationView.draggable = YES;
        }
        return annotationView;
    }else{
        __weak typeof(self) weakSelf = self;
//        _sportAnnotationView = (SportAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"SportsAnnotation"];
//        if (_sportAnnotationView == nil) {
//
//        }
        _sportAnnotationView = [[SportAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"SportsAnnotation"];
        _sportAnnotationView.sportNodes = self.sportNodes;
        _sportAnnotationView.selected = YES;
        _sportAnnotationView.draggable = YES;
        //            _sportAnnotationView.image = [UIImage imageNamed:@"map_bike"];
        _sportAnnotationView.completion = ^{
            
            [weakSelf updatePlayTimer];
        };
        _sportAnnotationView.currentIdx = ^(NSInteger idx) {
            NSString *count = [NSString stringWithFormat:@"%.2lu",(unsigned long)weakSelf.sportNodes.count];
            float progress = (idx+1)/[count floatValue];
            [weakSelf.proSlider setValue:progress animated:YES];
            
        };
        _sportAnnotationView.mapCenter = ^(NSInteger idx) {
            SportNode *node = weakSelf.sportNodes[idx];
            [weakSelf.mapView setCenterCoordinate:node.coordinate animated:YES];
        };
        return _sportAnnotationView;
    }
}


//根据经纬度返回点击的位置的名称
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSString * resultAddress = @"";
    NSString * houseName = @"";
    
    //    CLLocationCoordinate2D  coor = result.location;
    
    if(result.poiList.count > 0){
        BMKPoiInfo * info = result.poiList[0];
        if([info.name rangeOfString:@"-"].location != NSNotFound){
            houseName = [info.name componentsSeparatedByString:@"-"][0];
        }else{
            houseName = info.name;
        }
        resultAddress = [NSString stringWithFormat:@"%@%@",result.address,info.name];
    }else{
        resultAddress =result.address;
    }
    
    if(resultAddress.length == 0){
        
        //        listLocationLabel.text = @"位置解析错误，请点击定位按钮进行定位！";
        return;
    }
    
}

#pragma PGDatePickerDelegate
- (void)datePicker:(PGDatePicker *)datePicker didSelectDate:(NSDateComponents *)dateComponents {
    NSLog(@"dateComponents = %@", dateComponents);
    
    NSLog(@"%ld年%ld月%ld日%ld时%ld分%ld秒",(long)dateComponents.year ,(long)dateComponents.month,(long)dateComponents.day,(long)dateComponents.hour,(long)dateComponents.minute,(long)dateComponents.second);
    NSString *year = [NSString stringWithFormat:@"%ld",(long)dateComponents.year];
    NSString *month = [NSString stringWithFormat:@"%ld",(long)dateComponents.month];
    month = [self handleDateStr:month];
    NSString *day = [NSString stringWithFormat:@"%ld",(long)dateComponents.day];
    day = [self handleDateStr:day];
    NSString *hour = [NSString stringWithFormat:@"%ld",(long)dateComponents.hour];
    hour = [self handleDateStr:hour];
    NSString *minute = [NSString stringWithFormat:@"%ld",(long)dateComponents.minute];
    minute = [self handleDateStr:minute];
    NSString *second = [NSString stringWithFormat:@"%ld",(long)dateComponents.second];
    second = [self handleDateStr:second];
    
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",year ,month,day,hour,minute,second];
    if ([timeType isEqualToString:@"custom"]) {

    }else if ([timeType isEqualToString:@"week"]) {

    }else if ([timeType isEqualToString:@"yesterday"]) {
        NSString *yesterday = [NSString stringWithFormat:@"%ld",(long)dateComponents.day-1];
        yesterday = [self handleDateStr:yesterday];
        dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@",year ,month,yesterday,hour,minute,second];
    }else{

    }
    if ([timeTypeStr isEqualToString:@"start"]) {
        NSString *time = self.endTimeLabel.text;
        if (time.length>0) {
            NSDate* maxDate = [self nsstringConversionNSDate:time];
            datePicker.maximumDate = maxDate;
            NSTimeInterval month_day = 6*24*60*60;
            NSDate *minDate = [maxDate dateByAddingTimeInterval:-month_day];
            datePicker.minimumDate = minDate;
        }
        self.startTimeLabel.text = dateStr;
    }else{
        NSString *time = self.startTimeLabel.text;
        if (time.length>0) {
            NSDate* minDate = [self nsstringConversionNSDate:time];
            datePicker.minimumDate = minDate;
            NSTimeInterval month_day = 6*24*60*60;
            NSDate *maxDate = [minDate dateByAddingTimeInterval:month_day];
            NSDate *datenow = [NSDate date];
            if (maxDate>datenow) {
                datePicker.maximumDate = datenow;
            }else{
                datePicker.maximumDate = maxDate;
            }
        }
        self.endTimeLabel.text = dateStr;
    }
}

- (NSString *)handleDateStr:(NSString *)timeStr
{
    if ([timeStr intValue]<10) {
        timeStr = [NSString stringWithFormat:@"0%@",timeStr];
    }
    return timeStr;
}


#pragma mark - load data
- (void)getToken
{
    [Dialog loading];
    NSString *user_pwd_md5 = [self md5HexDigest:@"a123456"];
    NSDictionary *dic = @{@"user_id":@"zjymwl",
                          @"user_pwd_md5":user_pwd_md5,
                          @"expires_in":@"60"
                          };
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    //url处理
    //    NSString *url = @"http://open.aichezaixian.com/route/rest";
    NSString *method = @"jimi.oauth.token.get";
    API *api = [API new];
    [api requestCarTest:mutDic method:method completion:^(id data) {
        if ([data[@"code"] intValue] == 0) {

            [self loadSportNodes:data[@"result"][@"accessToken"]];
        }else{
            [Dialog showInfo:data[@"message"]];
        }
    }];

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

- (void)loadSportNodes:(NSString *)token
{
    self.sportNodes = [NSMutableArray array];
    
    NSDictionary *dic = @{@"access_token":token,
                          @"imei":IMEI,
                          @"begin_time":self.startTimeLabel.text,
                          @"end_time":self.endTimeLabel.text,
                          @"map_type":@"BAIDU"
                          };
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    //url处理
    NSString *method = @"jimi.device.track.list";
    API *api = [API new];
    [api requestCarTest:mutDic method:method completion:^(id data) {
        [Dialog dismiss];
        if ([data[@"code"] intValue] == 0) {
            NSArray *dataArray = data[@"result"];
            if (dataArray.count > 0) {
                CLLocationCoordinate2D coords = CLLocationCoordinate2DMake([dataArray[0][@"lat"] floatValue],[dataArray[0][@"lng"] floatValue]);//纬度，经度
                self.mapView.centerCoordinate = coords;
                [self createAnnotation:dataArray];
                self->playAllTime = dataArray.count/5.00;
            }
            
        }else{
            [Dialog showInfo:data[@"message"]];
        }
    }];
    
}

- (void)createAnnotation:(NSArray*)dataArray
{
    for (NSDictionary *dict in dataArray) {
        SportNode *node = [SportNode nodeWithDictionary:dict];
        [self.sportNodes addObject:node];
    }
    
    CLLocationCoordinate2D coors[self.sportNodes.count];
    for (NSInteger i = 0; i < self.sportNodes.count; i++) {
        SportNode *node = self.sportNodes[i];
        coors[i] = node.coordinate;
    }
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView removeOverlays:_mapView.overlays];
    
    BMKPolyline *polyline = [BMKPolyline polylineWithCoordinates:coors count:self.sportNodes.count];
    [_mapView addOverlay:polyline];
    
    BMKPointAnnotation *startAnnotation = [[BMKPointAnnotation alloc]init];
    startAnnotation.coordinate = coors[0];
    startAnnotation.title = @"起点";
    [_mapView addAnnotation:startAnnotation];
    
    BMKPointAnnotation *endAnnotation = [[BMKPointAnnotation alloc]init];
    endAnnotation.coordinate = coors[self.sportNodes.count-1];
    endAnnotation.title = @"终点";
    [_mapView addAnnotation:endAnnotation];
    
    BMKPointAnnotation *sportAnnotation = [[BMKPointAnnotation alloc]init];
    sportAnnotation.coordinate = coors[0];
    sportAnnotation.title = @"轨迹回放";
    [_mapView addAnnotation:sportAnnotation];
}

- (NSDate *)timeStrToDateStr:(NSString*)timeStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//解决8小时时间差问题
    NSDate *date = [dateFormatter dateFromString:timeStr];
    return date;
}

- (NSString *)timeIntervalWithStartDate:(NSDate *)start endDate:(NSDate *)end {
    
    NSTimeInterval time=[end timeIntervalSinceDate:start];
    
    //    int days=((int)time)/(3600*24);
    //    int hours=((int)time)%(3600*24)/3600;
    
    return [[NSString alloc] initWithFormat:@"%f",time];
}


#pragma mark - action
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sliderAction:(UISlider*)slider
{
    NSLog(@"%f",slider.value);
    if (self.sportNodes.count > 0) {
        NSInteger sports = self.sportNodes.count-1;
        sports = sports * slider.value;
        _sportAnnotationView.idx = sports;
        SportNode *node = self.sportNodes[sports];
        _sportAnnotationView.annotation.coordinate = node.coordinate;
    }
}

- (NSDate *)nsstringConversionNSDate:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:MM:ss"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    return date;
}

- (IBAction)customAction:(id)sender {
    //自定义时间
    self.startTimeLabel.text = @"请选择开始时间";
    self.endTimeLabel.text = @"请选择结束时间";
    timeType = @"custom";
    [self.customTimeBt setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.weekTimeBt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.yesterdayBt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.todayBt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}
- (IBAction)weekTimeAction:(id)sender {
    timeType = @"week";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *datenow = [NSDate date];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    NSTimeInterval week_day = 6*24*60*60;
    NSDate *weekDate = [datenow dateByAddingTimeInterval:-week_day];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *weekStr = [formatter stringFromDate:weekDate];
    self.startTimeLabel.text = [NSString stringWithFormat:@"%@ 00:00:00",weekStr];
    self.endTimeLabel.text = currentTimeString;
    [self.customTimeBt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.weekTimeBt setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.yesterdayBt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.todayBt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}
- (IBAction)yesterdayAction:(id)sender {
    timeType = @"yesterday";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *datenow = [NSDate date];
    NSTimeInterval one_day = 24*60*60;
    NSDate *yesterdayDate = [datenow dateByAddingTimeInterval:-one_day];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *yesterdayStr = [formatter stringFromDate:yesterdayDate];
    self.startTimeLabel.text = [NSString stringWithFormat:@"%@ 00:00:00",yesterdayStr];
    self.endTimeLabel.text = [NSString stringWithFormat:@"%@ 23:59:59",yesterdayStr];
    [self.customTimeBt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.weekTimeBt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.yesterdayBt setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.todayBt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}
- (IBAction)todayAction:(id)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *datenow = [NSDate date];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *currentDayStr = [formatter stringFromDate:datenow];
    timeType = @"today";
    self.startTimeLabel.text = [NSString stringWithFormat:@"%@ 00:00:00",currentDayStr];
    self.endTimeLabel.text = currentTimeString;
    [self.customTimeBt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.weekTimeBt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.yesterdayBt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.todayBt setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
}
- (IBAction)startTimeAction:(id)sender {
    timeTypeStr = @"start";
    if ([timeType isEqualToString:@"custom"] || [timeType isEqualToString:@"week"]) {
        [self setupDateKey:YES];
    }else{
        [self setupDateKey:NO];
    }
    if (self.startTimeLabel.text.length==0 && self.endTimeLabel.text.length==0) {
        if ([timeType isEqualToString:@"custom"]) {
//            self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        }else if ([timeType isEqualToString:@"week"]) {
            self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;

        }else{

        }
    }else if (self.startTimeLabel.text.length==0 && self.endTimeLabel.text.length>0){
        self.startTimeLabel.text = self.endTimeLabel.text;
        NSDate* maxDate = [self nsstringConversionNSDate:self.endTimeLabel.text];
        
        if ([timeType isEqualToString:@"custom"]) {
            self.yearPicker.maximumDate = maxDate;
            NSTimeInterval month_day = 6*24*60*60;
            NSDate *minDate = [maxDate dateByAddingTimeInterval:-month_day];
            self.yearPicker.minimumDate = minDate;
//            self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        }else if ([timeType isEqualToString:@"week"]) {
            self.yearPicker.maximumDate = maxDate;
            NSTimeInterval month_day = 6*24*60*60;
            NSDate *minDate = [maxDate dateByAddingTimeInterval:-month_day];
            self.yearPicker.minimumDate = minDate;
//            self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        }else if ([timeType isEqualToString:@"yesterday"]) {
            self.datePicker.maximumDate = maxDate;
        }else{
            self.datePicker.maximumDate = maxDate;
        }
    }
}

- (IBAction)endTimeAction:(id)sender {
    timeTypeStr = @"end";
    if ([timeType isEqualToString:@"custom"] || [timeType isEqualToString:@"week"]) {
        [self setupDateKey:YES];
    }else{
        [self setupDateKey:NO];
    }
    if (self.startTimeLabel.text.length==0 && self.endTimeLabel.text.length==0) {

    }else if (self.startTimeLabel.text.length>0 && self.endTimeLabel.text.length==0){
        self.endTimeLabel.text = self.startTimeLabel.text;
        NSDate* minDate = [self nsstringConversionNSDate:self.startTimeLabel.text];
        
        if ([timeType isEqualToString:@"custom"]) {
            self.yearPicker.minimumDate = minDate;
            NSTimeInterval month_day = 6*24*60*60;
            NSDate *maxDate = [minDate dateByAddingTimeInterval:month_day];
            NSDate *datenow = [NSDate date];
            if (maxDate>datenow) {
                self.yearPicker.maximumDate = datenow;
            }else{
                self.yearPicker.maximumDate = maxDate;
            }
//            self.yearPicker.datePickerMode = UIDatePickerModeDateAndTime;
        }else if ([timeType isEqualToString:@"week"]) {
            self.yearPicker.minimumDate = minDate;
            NSTimeInterval month_day = 6*24*60*60;
            NSDate *maxDate = [minDate dateByAddingTimeInterval:month_day];
            NSDate *datenow = [NSDate date];
            if (maxDate>datenow) {
                self.yearPicker.maximumDate = datenow;
            }else{
                self.yearPicker.maximumDate = maxDate;
            }
//            self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        }else if ([timeType isEqualToString:@"yesterday"]) {
            self.datePicker.minimumDate = minDate;
//            self.datePicker.datePickerMode = UIDatePickerModeTime;
        }else{
            self.datePicker.minimumDate = minDate;
//            self.datePicker.datePickerMode = UIDatePickerModeTime;
            
        }
        
        
    }
}
- (IBAction)cancelTimeAction:(id)sender {
    [self backAction];
}
- (IBAction)checkAction:(id)sender {
    [self.proSlider setValue:0];
    [self getToken];
    self.timeView.hidden = YES;
    self.playView.hidden = NO;
    self.startTimeShowLabel.text = self.startTimeLabel.text;
    self.endTimeShowLabel.text = self.endTimeLabel.text;
}

- (IBAction)playAction:(id)sender {
    _sportAnnotationView.speed = playSpeed;
    if (self.playImgBt.selected) {
        [self.playImgBt setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        self.playImgBt.selected = NO;
        [_sportAnnotationView pause];
    }else{
        [self.playImgBt setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        self.playImgBt.selected = YES;
        
        [_sportAnnotationView startWithTime:playAllTime];

    }
    
}
- (IBAction)slowAction:(id)sender {
    if (playSpeed > 1) {
        playSpeed --;
    }
    _sportAnnotationView.speed = playSpeed;
    [self updateSpeedLabel];
}

- (IBAction)addSpeedAction:(id)sender {
    if (playSpeed < 3) {
        playSpeed ++;
    }
    _sportAnnotationView.speed = playSpeed;
    [self updateSpeedLabel];
}
- (IBAction)changeTimeAction:(id)sender {
    [_sportAnnotationView reset];
    playSpeed = 1;
    [self updateSpeedLabel];
    self.timeView.hidden = NO;
    self.playView.hidden = YES;
    [self updatePlayTimer];
}

- (void)updateSpeedLabel
{
    self.speedLabel.text = [NSString stringWithFormat:@"速度:%ld",(long)playSpeed];
}

- (void)updatePlayTimer
{
    [self.playImgBt setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    self.playImgBt.selected = NO;
    [self.proSlider setValue:0];
}
@end
