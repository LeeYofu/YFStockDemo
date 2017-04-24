//
//  StockDetailViewController.m
//  GoldfishSpot
//
//  Created by 李友富 on 2017/4/18.
//  Copyright © 2017年 中泰荣科. All rights reserved.
//

#import "StockDetailViewController.h"
#import "YFStock.h"
#import "YFNetworkRequest.h"
#import "StockDetailFullScreenViewController.h"

#define kTimeLineUrl @"https://goldfishspot.qdztrk.com/goldfishfinance/quotation/quotationAllPrices?quotation=SH0001"
#define kDayKlineUrl @"https://goldfishspot.qdztrk.com/goldfishfinance/quotation/echartData?bCode=SH0001&dType=DAY&count=500&quota=MA"
#define kWeekKlineUrl @"https://goldfishspot.qdztrk.com/goldfishfinance/quotation/echartData?bCode=SH0001&dType=WEEK&count=500&quota=MA"
#define kMonthKlineUrl @"https://goldfishspot.qdztrk.com/goldfishfinance/quotation/echartData?bCode=SH0001&dType=MONTH&count=500&quota=MA"


@interface StockDetailViewController () <YFStockDataSource, StockDetailFullScreenViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *timeLineDatas;
@property (nonatomic, strong) NSMutableArray *dayDatas;
@property (nonatomic, strong) NSMutableArray *weekDatas;
@property (nonatomic, strong) NSMutableArray *monthDatas;
@property (nonatomic, assign) BOOL canAutoRotate;

@property (nonatomic, strong) YFStock *stock;
@property (nonatomic, strong) StockDetailFullScreenViewController *fullScreenVC;
@property (nonatomic, strong) UIView *fullScreenView;

@end

@implementation StockDetailViewController

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self config];
    
    [self createSubviews];
}

- (void)config {
    
    self.view.backgroundColor = kWhiteColor;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [YFStock_Variable setSelectedIndex:0];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    self.canAutoRotate = NO;
}

- (void)createSubviews {
    
    // top view
    UIView *topBgView = [UIView new];
    topBgView.frame = CGRectMake(0, 0, kScreenWidth, 156);
    topBgView.backgroundColor = kCustomRGBColor(26, 181, 70, 1.0f);
    [self.view addSubview:topBgView];
    
    self.stock = [YFStock stockWithFrame:CGRectMake(0, topBgView.maxY, kScreenWidth, self.view.height - 45 - topBgView.height) superView:self.view dataSource:self];
    
    UIButton *fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    fullScreenButton.frame = CGRectMake(self.view.width - 45, self.stock.view.maxY, 45, kScreenHeight - self.stock.view.maxY);
    fullScreenButton.backgroundColor = kBlueColor;
    [fullScreenButton addTarget:self action:@selector(enterFullScreen) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fullScreenButton];
    
}

#pragma mark - 网络请求
- (void)requestTimeLine {
    
    [YFNetworkRequest getWithSubUrl:kTimeLineUrl parameters:nil sucess:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *resultBeanArray = responseObject[@"resultBean"];
        self.timeLineDatas = (NSMutableArray *)resultBeanArray;
        
        [self.stock draw];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"error = %@", error);
    }];
}

- (void)requestDayK {
    
    [YFNetworkRequest getWithSubUrl:kDayKlineUrl parameters:nil sucess:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *resultBeanArray = responseObject[@"resultBean"];
        self.dayDatas = (NSMutableArray *)resultBeanArray;
        
        [self.stock draw];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"error = %@", error);
    }];
}

- (void)requestWeekK {
    
    [YFNetworkRequest getWithSubUrl:kWeekKlineUrl parameters:nil sucess:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *resultBeanArray = responseObject[@"resultBean"];
        self.weekDatas = (NSMutableArray *)resultBeanArray;
        
        [self.stock draw];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"error = %@", error);
    }];
}

- (void)requestMonthK {
    
    [YFNetworkRequest getWithSubUrl:kMonthKlineUrl parameters:nil sucess:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *resultBeanArray = responseObject[@"resultBean"];
        self.monthDatas = (NSMutableArray *)resultBeanArray;
        
        [self.stock draw];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"error = %@", error);
    }];
}

#pragma mark - dataSource
- (void)YFStock:(YFStock *)stock didSelectedStockLineTypeAtIndex:(YFStockTopBarIndex)index {
    
    if (index == YFStockTopBarIndex_MinuteHour) { // 分时
        
        [self requestTimeLine];
    } else if (index == YFStockTopBarIndex_DayK) { // day
        
        [self requestDayK];
    } else if (index == YFStockTopBarIndex_WeekK) { // week
        
        [self requestWeekK];
    } else if (index == YFStockTopBarIndex_MonthK) { // month
        
        [self requestMonthK];
    } else { // other
        
    }
}

- (NSArray *)YFStock:(YFStock *)stock stockDatasOfIndex:(YFStockTopBarIndex)index {
    
    if (index == YFStockTopBarIndex_MinuteHour) { // 分时
        
        return self.timeLineDatas;
    } else if (index == YFStockTopBarIndex_DayK) { // day
        
        return self.dayDatas;
    } else if (index == YFStockTopBarIndex_WeekK) { // week
        
        return self.weekDatas;
    } else if (index == YFStockTopBarIndex_MonthK) { // month
        
        return self.monthDatas;
    } else { // other
        
        return @[];
    }
};

- (YFStockLineType)YFStock:(YFStock *)stock stockLineTypeOfIndex:(YFStockTopBarIndex)index {
    
    if (index == YFStockTopBarIndex_MinuteHour) {
        
        return YFStockLineTypeTimeLine;
    }
    return YFStockLineTypeKLine;
}

- (NSArray<NSString *> *)titleItemsOfStock:(YFStock *)stock {
    
    return @[ @"分时", @"日K", @"周K", @"月K", @"5分", @"30分", @"60分", @"年K" ];
}

#pragma mark - 全屏/竖屏相关
- (void)enterFullScreen {
    
    [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
}

- (void)exitFullScreen {
    
    [self interfaceOrientation:UIInterfaceOrientationPortrait];
}

- (BOOL)shouldAutorotate {
    
    return self.canAutoRotate;
//    return YES;
}

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    
    self.canAutoRotate = YES;
    
    // 1
    //    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
    //        SEL selector             = NSSelectorFromString(@"setOrientation:");
    //        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    //        [invocation setSelector:selector];
    //        [invocation setTarget:[UIDevice currentDevice]];
    //        int val                  = orientation;
    //        // 从2开始是因为0 1 两个参数已经被selector和target占用
    //        [invocation setArgument:&val atIndex:2];
    //        [invocation invoke];
    //    }
    
    // 2
    NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
    NSNumber *orientationTarget = [NSNumber numberWithInt:orientation];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    
    self.canAutoRotate = NO;
}

- (void)deviceOrientationDidChange {
    
    if (self.canAutoRotate == NO) {
        
        return;
    }
    NSLog(@"NAV deviceOrientationDidChange:%ld",(long)[UIDevice currentDevice].orientation);
    
    if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) { // portrait
        
        [self removeFullScreenView];
    } else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft ||
               [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) { // left/right
        
        [self addFullScreenView];
    }
}

- (void)addFullScreenView {
    
    if (self.fullScreenView == nil) {
        
        StockDetailFullScreenViewController *fullScreenVC = [StockDetailFullScreenViewController new];
        fullScreenVC.delegate = self;
        self.fullScreenVC = fullScreenVC;
        self.fullScreenView = fullScreenVC.view;
        [self.view addSubview:self.fullScreenView];
    }
}

- (void)removeFullScreenView {
    
    if (self.fullScreenView) {
        
        [self.fullScreenView removeFromSuperview];
        self.fullScreenView = nil;
    }
}

- (void)stockDetailFullScreenViewControllerExitButtonDidClicked {
    
    [self exitFullScreen];
}


#pragma mark - lazy loading
- (NSMutableArray *)timeLineDatas {
    
    if (_timeLineDatas == nil) {
        
        _timeLineDatas = [NSMutableArray new];
    }
    return _timeLineDatas;
}

- (NSMutableArray *)dayDatas {
    
    if (_dayDatas == nil) {
        
        _dayDatas = [NSMutableArray new];
    }
    return _dayDatas;
}

- (NSMutableArray *)weekDatas {
    
    if (_weekDatas == nil) {
        
        _weekDatas = [NSMutableArray new];
    }
    return _weekDatas;
}

- (NSMutableArray *)monthDatas {
    
    if (_monthDatas == nil) {
        
        _monthDatas = [NSMutableArray new];
    }
    return _monthDatas;
}


@end
