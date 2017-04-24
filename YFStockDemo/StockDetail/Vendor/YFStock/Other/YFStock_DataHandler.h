//
//  YFStock_DataHandler.h
//  YFStockDemo
//
//  Created by 李友富 on 2017/3/31.
//  Copyright © 2017年 李友富. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YFStock_Header.h"
#import "YFStock_KLineModel.h"
#import "YFStock_TimeLineModel.h"

@interface YFStock_DataHandler : NSObject

#pragma mark - property
// KLine
@property (nonatomic, assign) CGFloat maxKLineValue; // 都是实际原始值，不是坐标值
@property (nonatomic, assign) CGFloat minKLineValue;
@property (nonatomic, assign) CGFloat maxVolumeLineValue;
@property (nonatomic, assign) CGFloat minVolumeLineValue;
@property (nonatomic, strong) NSArray <YFStock_KLineModel *> *drawKLineModels;


// TimeLine
@property (nonatomic, assign) CGFloat maxTimeLineValue; 
@property (nonatomic, assign) CGFloat minTimeLineValue;
@property (nonatomic, assign) CGFloat avgTimeLineValue;
@property (nonatomic, assign) CGFloat avgTimeLinePositionY;
@property (nonatomic, strong) NSArray <YFStock_TimeLineModel *> *drawTimeLineModels;

// MACD
@property (nonatomic, assign) CGFloat MACDMaxValue;
@property (nonatomic, assign) CGFloat MACDMinValue;

// KDJ
@property (nonatomic, assign) CGFloat KDJMaxValue;
@property (nonatomic, assign) CGFloat KDJMinValue;

// RSI
@property (nonatomic, assign) CGFloat RSIMaxValue;
@property (nonatomic, assign) CGFloat RSIMinValue;


#pragma mark - method
// 初始化
+ (instancetype)dataHandler;

// K线
// 处理原始K线相关数据，处理成为K线模型数组
- (NSArray <YFStock_KLineModel *> *)handleAllKLineOriginDataArray:(NSArray *)KLineOriginDataArray topBarIndex:(YFStockTopBarIndex)topBarIndex;
// k线模型数据处理(当前绘制部分 drawKLineModels)
- (void)handleKLineModelDatasWithDrawKlineModelArray:(NSArray *)drawKLineModelArray pointStartX:(CGFloat)pointStartX KLineViewHeight:(CGFloat)KLineViewHeight volumeViewHeight:(CGFloat)volumeViewHeight;

// 分时线
// 处理原始分时线相关数据，处理成为分时线模型数组
- (NSArray <YFStock_TimeLineModel *> *)handleAllTimeLineOriginDataArray:(NSArray *)timeLineOriginDataArray topBarIndex:(YFStockTopBarIndex)topBarIndex;
// 分时线模型数据处理（当前绘制部分，实际是所有，因为无缩放功能）
- (void)handleTimeLineModelDatasWithDrawTimeLineModelArray:(NSArray *)drawTimeLineModelArray timeLineViewHeight:(CGFloat)timeLineViewHeight;
// 获取分时分钟总数
- (NSInteger)timeLineTradingMinutesWithStockType:(NSString *)stockType;

@end
