//
//  YFStock_DataHandler.m
//  YFStockDemo
//
//  Created by 李友富 on 2017/3/31.
//  Copyright © 2017年 李友富. All rights reserved.
//

#import "YFStock_DataHandler.h"

@implementation YFStock_DataHandler

#pragma mark - 初始化
+ (instancetype)dataHandler {
    
    return [self new];
}

#pragma mark - TimeLine
- (NSArray<YFStock_TimeLineModel *> *)handleAllTimeLineOriginDataArray:(NSArray *)timeLineOriginDataArray topBarIndex:(YFStockTopBarIndex)topBarIndex {
    
    return [YFStock_TimeLineModel mj_objectArrayWithKeyValuesArray:timeLineOriginDataArray];
}

- (void)handleTimeLineModelDatasWithDrawTimeLineModelArray:(NSArray *)drawTimeLineModelArray timeLineViewHeight:(CGFloat)timeLineViewHeight {
    
    self.maxTimeLineValue = [[[drawTimeLineModelArray valueForKeyPath:@"bidPrice1"] valueForKeyPath:@"@max.floatValue"] floatValue];
    self.minTimeLineValue = [[[drawTimeLineModelArray valueForKeyPath:@"bidPrice1"] valueForKeyPath:@"@min.floatValue"] floatValue];
    self.avgTimeLineValue = [[[drawTimeLineModelArray valueForKeyPath:@"bidPrice1"] valueForKeyPath:@"@avg.floatValue"] floatValue];
    
    CGFloat timeLineMinY = kStockKLineViewKlineMinY;
    CGFloat timeLineMaxY = timeLineViewHeight - 2 * kStockKLineViewKlineMinY;
    CGFloat timeLineUnitValue = (self.maxTimeLineValue - self.minTimeLineValue) / (timeLineMaxY - timeLineMinY); // 原始值 / 坐标值
    if (timeLineUnitValue == 0) timeLineUnitValue = 0.01f;
    
    NSMutableArray *tempArray = [NSMutableArray new];
    
    __block CGFloat pointStartX = 0;
    [drawTimeLineModelArray enumerateObjectsUsingBlock:^(YFStock_TimeLineModel *timeLineModel, NSUInteger idx, BOOL * _Nonnull stop) {
       
        CGFloat y = timeLineMaxY - (timeLineModel.bidPrice1 - self.minTimeLineValue) / timeLineUnitValue;
        CGPoint pricePositionPoint = CGPointMake(pointStartX, y);
        timeLineModel.pricePositionPoint = pricePositionPoint;
        [tempArray addObject:timeLineModel];
        
        pointStartX += ([YFStock_Variable timeLineWidth] + [YFStock_Variable timeLineGap]);
    }];
    
    self.drawTimeLineModels = tempArray;
    
    self.avgTimeLinePositionY = timeLineMaxY - (self.avgTimeLineValue - self.minTimeLineValue) / timeLineUnitValue;
}

- (NSInteger)timeLineTradingMinutesWithStockType:(NSString *)stockType {
    
    NSInteger totalMinutes = 0;
    
    NSString *openTimeListPath = [[NSBundle mainBundle] pathForResource:@"OpenTimeList" ofType:@"plist"];
    NSDictionary *openTimeListDic = [NSDictionary dictionaryWithContentsOfFile:openTimeListPath];
//    NSLog(@"%@", openTimeListDic);
    NSDictionary *openTimeInfoDic = openTimeListDic[stockType];
//    NSDictionary *hughPlate = openTimeInfoDic[@"hughPlate"];
    
    CGFloat tradingHours = [openTimeInfoDic[@"tradingTime"] floatValue];
    
    totalMinutes = 60 * tradingHours;
    
    return totalMinutes;
}

#pragma mark - KLine
// 处理原始K线数据转为K线模型数组
- (NSMutableArray <YFStock_KLineModel *> *)handleAllKLineOriginDataArray:(NSArray *)KLineOriginDataArray topBarIndex:(YFStockTopBarIndex)topBarIndex {
    
    NSMutableArray *allKLineModelArray = [NSMutableArray new];
    
    for (int i = 0; i < KLineOriginDataArray.count; i ++) {
        
        NSDictionary *dic = KLineOriginDataArray[i];
        YFStock_KLineModel *KLineModel = [YFStock_KLineModel mj_objectWithKeyValues:dic];
        
        KLineModel.preAllModelArray = [allKLineModelArray copy]; // 必须copy，不然还会跟着改变

        if (i > 0) {
            
            [self handleTimeShowActionWithKLineModel:KLineModel topBarIndex:topBarIndex];
        }
        
        [KLineModel initData];
        
        [allKLineModelArray addObject:KLineModel];
    }
   
    
    return allKLineModelArray;
}

- (void)handleTimeShowActionWithKLineModel:(YFStock_KLineModel *)KLineModel topBarIndex:(YFStockTopBarIndex)topBarIndex {
    
    switch (topBarIndex) {
        case YFStockTopBarIndex_DayK:
        {
            NSInteger currentModelMonth = [[[KLineModel.dataTime substringFromIndex:5] substringToIndex:2] integerValue];
            NSInteger preModelMonth = [[[KLineModel.preModel.dataTime substringFromIndex:5] substringToIndex:2] integerValue];
            if (currentModelMonth != preModelMonth) {
                
                KLineModel.isShowTime = YES;
                KLineModel.showTimeStr = [KLineModel.dataTime substringToIndex:7];
            } else {
                
                KLineModel.isShowTime = NO;
            }
        }
            break;
        case YFStockTopBarIndex_WeekK:
        {
            NSInteger currentModelMonth = [[[KLineModel.dataTime substringFromIndex:5] substringToIndex:2] integerValue];
            NSInteger preModelMonth = [[[KLineModel.preModel.dataTime substringFromIndex:5] substringToIndex:2] integerValue];
            if ((currentModelMonth == 3 || currentModelMonth == 9 ) &&
                (currentModelMonth != preModelMonth)) { // 3月、9月？？？
                
                KLineModel.isShowTime = YES;
                KLineModel.showTimeStr = [KLineModel.dataTime substringToIndex:7];
            } else {
                
                KLineModel.isShowTime = NO;
            }
        }
            break;
        case YFStockTopBarIndex_MonthK:
        {
            NSInteger currentModelMonth = [[[KLineModel.dataTime substringFromIndex:5] substringToIndex:2] integerValue];
            NSInteger preModelMonth = [[[KLineModel.preModel.dataTime substringFromIndex:5] substringToIndex:2] integerValue];
            if ((currentModelMonth == 3 ) &&
                (currentModelMonth != preModelMonth)) { // 3月、9月？？？
                
                KLineModel.isShowTime = YES;
                KLineModel.showTimeStr = [KLineModel.dataTime substringToIndex:7];
            } else {
                
                KLineModel.isShowTime = NO;
            }
        }
            break;
        default:
        {
            KLineModel.isShowTime = NO;
        }
            break;
    }
}

// 处理需要绘制的K线模型数组(主要是处理position)
- (void)handleKLineModelDatasWithDrawKlineModelArray:(NSArray *)drawKLineModelArray pointStartX:(CGFloat)pointStartX KLineViewHeight:(CGFloat)KLineViewHeight volumeViewHeight:(CGFloat)volumeViewHeight {
    
    [self getMaxValueMinValueWithDrawKlineModelArray:drawKLineModelArray pointStartX:pointStartX KLineViewHeight:KLineViewHeight volumeViewHeight:volumeViewHeight];

    [self getPositionWithDrawKlineModelArray:drawKLineModelArray pointStartX:pointStartX KLineViewHeight:KLineViewHeight volumeViewHeight:volumeViewHeight];
    
}

// 获取K线的以及成交量线的maxValue、minValue
- (void)getMaxValueMinValueWithDrawKlineModelArray:(NSArray *)drawKLineModelArray pointStartX:(CGFloat)pointStartX KLineViewHeight:(CGFloat)KLineViewHeight volumeViewHeight:(CGFloat)volumeViewHeight {
    
    // K线
    CGFloat max =  [[[drawKLineModelArray valueForKeyPath:@"highPrice"] valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat MA5max =  [[[drawKLineModelArray valueForKeyPath:@"MA_5"] valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat MA10max =  [[[drawKLineModelArray valueForKeyPath:@"MA_10"] valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat MA20max =  [[[drawKLineModelArray valueForKeyPath:@"MA_20"] valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat MA30max =  [[[drawKLineModelArray valueForKeyPath:@"MA_30"] valueForKeyPath:@"@max.floatValue"] floatValue];
    
    // 取 highPrice、所有MA值的最大值为K线的最大值
    max = MAX(MAX(MAX(MAX(MA5max, MA10max), MA20max), MA30max), max);
    
    __block CGFloat min = [[[drawKLineModelArray valueForKeyPath:@"lowPrice"] valueForKeyPath:@"@min.floatValue"] floatValue];
    
    // 取 lowPrice、所有【有效】MA值的最小值为K线的最小值
    [drawKLineModelArray enumerateObjectsUsingBlock:^(YFStock_KLineModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat MA5 = obj.MA_5.floatValue;
        CGFloat MA10 = obj.MA_10.floatValue;
        CGFloat MA20 = obj.MA_20.floatValue;
        CGFloat MA30 = obj.MA_30.floatValue;
        
        if (MA5 > 0 && MA5 < min) {
            
            min = MA5;
        }
        if (MA10 > 0 && MA10 < min) {
            
            min = MA10;
        }
        if (MA20 > 0 && MA20 < min) {
            
            min = MA20;
        }
        if (MA30 > 0 && MA30 < min) {
            
            min = MA30;
        }
    }];
    
//    CGFloat BOLL_UPPERmax =  [[[drawKLineModelArray valueForKeyPath:@"BOLL_UPPER"] valueForKeyPath:@"@max.floatValue"] floatValue];
//    CGFloat BOLL_MIDmax =  [[[drawKLineModelArray valueForKeyPath:@"BOLL_MID"] valueForKeyPath:@"@max.floatValue"] floatValue];
//    CGFloat BOLL_LOWERmax =  [[[drawKLineModelArray valueForKeyPath:@"BOLL_LOWER"] valueForKeyPath:@"@max.floatValue"] floatValue];
//
//    CGFloat BOLL_UPPERmin =  [[[drawKLineModelArray valueForKeyPath:@"BOLL_UPPER"] valueForKeyPath:@"@min.floatValue"] floatValue];
//    CGFloat BOLL_MIDmin =  [[[drawKLineModelArray valueForKeyPath:@"BOLL_MID"] valueForKeyPath:@"@min.floatValue"] floatValue];
//    CGFloat BOLL_LOWERmin =  [[[drawKLineModelArray valueForKeyPath:@"BOLL_LOWER"] valueForKeyPath:@"@min.floatValue"] floatValue];
//    
//    max = MAX(max, MAX(BOLL_UPPERmax, MAX(BOLL_MIDmax, BOLL_LOWERmax)));
//    min = MIN(min, MIN(BOLL_UPPERmin, MIN(BOLL_MIDmin, BOLL_LOWERmin)));

    self.maxKLineValue = max;
    self.minKLineValue = min;

    // volume线
    self.minVolumeLineValue =  0;
    self.maxVolumeLineValue =  [[[drawKLineModelArray valueForKeyPath:@"volume"] valueForKeyPath:@"@max.floatValue"] floatValue];
    
    // MACD
    CGFloat maxDIFF = [[[drawKLineModelArray valueForKeyPath:@"MACD_DIF"] valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat maxDEA = [[[drawKLineModelArray valueForKeyPath:@"MACD_DEA"] valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat maxMACD = [[[drawKLineModelArray valueForKeyPath:@"MACD_BAR"] valueForKeyPath:@"@max.floatValue"] floatValue];
    
    CGFloat minDIFF = [[[drawKLineModelArray valueForKeyPath:@"MACD_DIF"] valueForKeyPath:@"@min.floatValue"] floatValue];
    CGFloat minDEA = [[[drawKLineModelArray valueForKeyPath:@"MACD_DEA"] valueForKeyPath:@"@min.floatValue"] floatValue];
    CGFloat minMACD = [[[drawKLineModelArray valueForKeyPath:@"MACD_BAR"] valueForKeyPath:@"@min.floatValue"] floatValue];
    
    self.MACDMaxValue = MAX(MAX(maxDIFF, maxDEA), maxMACD);
    self.MACDMinValue = MIN(MIN(minDIFF, minDEA), minMACD);
    
    self.MACDMaxValue = ABS(self.MACDMaxValue) > ABS(self.MACDMinValue) ? ABS(self.MACDMaxValue) : ABS(self.MACDMinValue);
    self.MACDMinValue = -self.MACDMaxValue;
    
    // KDJ
    CGFloat maxK = [[[drawKLineModelArray valueForKeyPath:@"KDJ_K"] valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat maxD = [[[drawKLineModelArray valueForKeyPath:@"KDJ_D"] valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat maxJ = [[[drawKLineModelArray valueForKeyPath:@"KDJ_J"] valueForKeyPath:@"@max.floatValue"] floatValue];

    CGFloat minK = [[[drawKLineModelArray valueForKeyPath:@"KDJ_K"] valueForKeyPath:@"@min.floatValue"] floatValue];
    CGFloat minD = [[[drawKLineModelArray valueForKeyPath:@"KDJ_D"] valueForKeyPath:@"@min.floatValue"] floatValue];
    CGFloat minJ = [[[drawKLineModelArray valueForKeyPath:@"KDJ_J"] valueForKeyPath:@"@min.floatValue"] floatValue];

    self.KDJMaxValue = MAX(MAX(maxK, maxD), maxJ);
    self.KDJMinValue = MIN(MIN(minK, minD), minJ);
    
    // RSI
    CGFloat maxRSI_6 = [[[drawKLineModelArray valueForKeyPath:@"RSI_6"] valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat maxRSI_12 = [[[drawKLineModelArray valueForKeyPath:@"RSI_12"] valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat maxRSI_24 = [[[drawKLineModelArray valueForKeyPath:@"RSI_24"] valueForKeyPath:@"@max.floatValue"] floatValue];
    
    CGFloat minRSI_6 = [[[drawKLineModelArray valueForKeyPath:@"RSI_6"] valueForKeyPath:@"@min.floatValue"] floatValue];
    CGFloat minRSI_12 = [[[drawKLineModelArray valueForKeyPath:@"RSI_12"] valueForKeyPath:@"@min.floatValue"] floatValue];
    CGFloat minRSI_24 = [[[drawKLineModelArray valueForKeyPath:@"RSI_24"] valueForKeyPath:@"@min.floatValue"] floatValue];
    
    self.RSIMaxValue = MAX(MAX(maxRSI_6, maxRSI_12), maxRSI_24);
    self.RSIMinValue = MIN(MIN(minRSI_6, minRSI_12), minRSI_24);
    
    // ARBR
    CGFloat maxAR = [[[drawKLineModelArray valueForKeyPath:@"ARBR_AR"] valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat maxBR = [[[drawKLineModelArray valueForKeyPath:@"ARBR_BR"] valueForKeyPath:@"@max.floatValue"] floatValue];
    
    CGFloat minAR = [[[drawKLineModelArray valueForKeyPath:@"ARBR_AR"] valueForKeyPath:@"@min.floatValue"] floatValue];
    CGFloat minBR = [[[drawKLineModelArray valueForKeyPath:@"ARBR_BR"] valueForKeyPath:@"@min.floatValue"] floatValue];
    
    self.ARBRMaxValue = MAX(maxAR, maxBR);
    self.ARBRMinValue = MIN(minAR, minBR);
    
    // OBV
    CGFloat maxOBV = [[[drawKLineModelArray valueForKeyPath:@"OBV"] valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat minOBV = [[[drawKLineModelArray valueForKeyPath:@"OBV"] valueForKeyPath:@"@min.floatValue"] floatValue];

    self.OBVMaxValue = maxOBV;
    self.OBVMinValue = minOBV;
    
    // WR
    CGFloat maxWR_1 = [[[drawKLineModelArray valueForKeyPath:@"WR_1"] valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat maxWR_2 = [[[drawKLineModelArray valueForKeyPath:@"WR_2"] valueForKeyPath:@"@max.floatValue"] floatValue];
    
    CGFloat minWR_1 = [[[drawKLineModelArray valueForKeyPath:@"WR_1"] valueForKeyPath:@"@min.floatValue"] floatValue];
    CGFloat minWR_2 = [[[drawKLineModelArray valueForKeyPath:@"WR_2"] valueForKeyPath:@"@min.floatValue"] floatValue];
    
    self.WRMaxValue = MAX(maxWR_1, maxWR_2);
    self.WRMinValue = MIN(minWR_1, minWR_2);
    
    // DMA
    CGFloat maxDDD = [[[drawKLineModelArray valueForKeyPath:@"DDD"] valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat maxAMA = [[[drawKLineModelArray valueForKeyPath:@"AMA"] valueForKeyPath:@"@max.floatValue"] floatValue];
    
    CGFloat minDDD = [[[drawKLineModelArray valueForKeyPath:@"DDD"] valueForKeyPath:@"@min.floatValue"] floatValue];
    CGFloat minAMA= [[[drawKLineModelArray valueForKeyPath:@"AMA"] valueForKeyPath:@"@min.floatValue"] floatValue];
    
    self.DMAMaxValue = MAX(maxDDD, maxAMA);
    self.DMAMinValue = MIN(minDDD, minAMA);

    // CCI
    CGFloat maxCCI = [[[drawKLineModelArray valueForKeyPath:@"CCI"] valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat minCCI = [[[drawKLineModelArray valueForKeyPath:@"CCI"] valueForKeyPath:@"@min.floatValue"] floatValue];
    
    self.CCIMaxValue = maxCCI;
    self.CCIMinValue = minCCI;
    
    // BIAS
    CGFloat maxBIAS1 = [[[drawKLineModelArray valueForKeyPath:@"BIAS_1"] valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat maxBIAS2 = [[[drawKLineModelArray valueForKeyPath:@"BIAS_2"] valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat maxBIAS3 = [[[drawKLineModelArray valueForKeyPath:@"BIAS_3"] valueForKeyPath:@"@max.floatValue"] floatValue];

    CGFloat minBIAS1 = [[[drawKLineModelArray valueForKeyPath:@"BIAS_1"] valueForKeyPath:@"@min.floatValue"] floatValue];
    CGFloat minBIAS2 = [[[drawKLineModelArray valueForKeyPath:@"BIAS_2"] valueForKeyPath:@"@min.floatValue"] floatValue];
    CGFloat minBIAS3 = [[[drawKLineModelArray valueForKeyPath:@"BIAS_3"] valueForKeyPath:@"@min.floatValue"] floatValue];

    self.BIASMaxValue = MAX(maxBIAS1, MAX(maxBIAS2, maxBIAS3));
    self.BIASMinValue = MIN(minBIAS1, MIN(minBIAS2, minBIAS3));
}

// 获取 K线 的以及 volume线 的坐标转换 macd kdj 等
- (void)getPositionWithDrawKlineModelArray:(NSArray *)drawKLineModelArray pointStartX:(CGFloat)pointStartX KLineViewHeight:(CGFloat)KLineViewHeight volumeViewHeight:(CGFloat)volumeViewHeight {
    
    NSMutableArray *tempDrawKLineModels = [NSMutableArray new];
    
    // k line
    CGFloat KLineMinY = kStockKLineViewKlineMinY;
    CGFloat KLineMaxY = KLineViewHeight - 2 * kStockKLineViewKlineMinY;
    CGFloat KLineUnitValue = (self.maxKLineValue - self.minKLineValue) / (KLineMaxY - KLineMinY); // 原始值 / 坐标值
    if (KLineUnitValue == 0) KLineUnitValue = 0.01f;
    
    // volume line
    CGFloat volumeLineMinY = kStockVolumeLineViewVolumeLineMinY;
    CGFloat volumeLineMaxY = volumeViewHeight; // 到底部
    CGFloat volumeLineUnitValue = (self.maxVolumeLineValue - self.minVolumeLineValue) / (volumeLineMaxY - volumeLineMinY); // 原始值 / 坐标值
    if (volumeLineUnitValue == 0) volumeLineUnitValue = 0.01f;
    
    // MACD line
    CGFloat MACDLineMinY = kStockVolumeLineViewVolumeLineMinY;
    CGFloat MACDLineMaxY = volumeViewHeight - 2 * kStockVolumeLineViewVolumeLineMinY;
    CGFloat MACDLineUnitValue = (self.MACDMaxValue - self.MACDMinValue) / (MACDLineMinY - MACDLineMaxY);
    if (MACDLineUnitValue == 0) MACDLineUnitValue = 0.01f;
    
    // KDJ line
    CGFloat KDJLineMinY = kStockVolumeLineViewVolumeLineMinY;
    CGFloat KDJLineMaxY = volumeViewHeight - 2 * kStockVolumeLineViewVolumeLineMinY;
    CGFloat KDJLineUnitValue = (self.KDJMaxValue - self.KDJMinValue) / (KDJLineMaxY - KDJLineMinY);
    if (KDJLineUnitValue == 0) KDJLineUnitValue = 0.01f;
    
    // RSI
    CGFloat RSILineMinY = kStockVolumeLineViewVolumeLineMinY;
    CGFloat RSILineMaxY = volumeViewHeight - 2 * kStockVolumeLineViewVolumeLineMinY;
    CGFloat RSILineUnitValue = (self.RSIMaxValue - self.RSIMinValue) / (RSILineMaxY - RSILineMinY);
    if (RSILineUnitValue == 0) RSILineUnitValue = 0.01f;
    
    // ARBR
    CGFloat ARBRLineMinY = kStockVolumeLineViewVolumeLineMinY;
    CGFloat ARBRLineMaxY = volumeViewHeight - 2 * kStockVolumeLineViewVolumeLineMinY;
    CGFloat ARBRLineUnitValue = (self.ARBRMaxValue - self.ARBRMinValue) / (ARBRLineMaxY - ARBRLineMinY);
    if (ARBRLineUnitValue == 0) ARBRLineUnitValue = 0.01f;
    
    // OBV
    CGFloat OBVLineMinY = kStockVolumeLineViewVolumeLineMinY;
    CGFloat OBVLineMaxY = volumeViewHeight - 2 * kStockVolumeLineViewVolumeLineMinY;
    CGFloat OBVLineUnitValue = (self.OBVMaxValue - self.OBVMinValue) / (OBVLineMaxY - OBVLineMinY); // 原始值 / 坐标值
    if (OBVLineUnitValue == 0) OBVLineUnitValue = 0.01f;
    
    // WR
    CGFloat WRLineMinY = kStockVolumeLineViewVolumeLineMinY;
    CGFloat WRLineMaxY = volumeViewHeight - 2 * kStockVolumeLineViewVolumeLineMinY;
    CGFloat WRLineUnitValue = (self.WRMaxValue - self.WRMinValue) / (WRLineMaxY - WRLineMinY); // 原始值 / 坐标值
    if (WRLineUnitValue == 0) WRLineUnitValue = 0.01f;
    
    // DMA
    CGFloat DMALineMinY = kStockVolumeLineViewVolumeLineMinY;
    CGFloat DMALineMaxY = volumeViewHeight - 2 * kStockVolumeLineViewVolumeLineMinY;
    CGFloat DMALineUnitValue = (self.DMAMaxValue - self.DMAMinValue) / (DMALineMaxY - DMALineMinY); // 原始值 / 坐标值
    if (DMALineUnitValue == 0) DMALineUnitValue = 0.01f;
    
    // CCI
    CGFloat CCILineMinY = kStockVolumeLineViewVolumeLineMinY;
    CGFloat CCILineMaxY = volumeViewHeight - 2 * kStockVolumeLineViewVolumeLineMinY; 
    CGFloat CCILineUnitValue = (self.CCIMaxValue - self.CCIMinValue) / (CCILineMaxY - CCILineMinY); // 原始值 / 坐标值
    if (CCILineUnitValue == 0) CCILineUnitValue = 0.01f;
    
    
    // 便利
    [drawKLineModelArray enumerateObjectsUsingBlock:^(YFStock_KLineModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        
#pragma mark - K线
        CGFloat xPosition = pointStartX + idx * ([YFStock_Variable KLineWidth] + [YFStock_Variable KLineGap]);
        
        CGPoint highPoint = CGPointMake(xPosition, ABS(KLineMaxY - (model.highPrice.floatValue - self.minKLineValue) / KLineUnitValue));
        CGPoint lowPoint = CGPointMake(xPosition, ABS(KLineMaxY - (model.lowPrice.floatValue - self.minKLineValue) / KLineUnitValue));
        CGPoint openPoint = CGPointMake(xPosition, ABS(KLineMaxY - (model.openPrice.floatValue - self.minKLineValue) / KLineUnitValue));
        CGFloat closePointY = ABS(KLineMaxY - (model.closePrice.floatValue - self.minKLineValue) / KLineUnitValue);
        
        //格式化openPoint和closePointY
        if(ABS(closePointY - openPoint.y) < kStockKLineKlineMinThick) { // open 跟 close 的 y 非常相近
            
            if(openPoint.y > closePointY) { // 小者不变，大者更大
                
                openPoint.y = closePointY + kStockKLineKlineMinThick;
                
            } else if(openPoint.y < closePointY) {
                
                closePointY = openPoint.y + kStockKLineKlineMinThick;
            } else { // openPointY == closePointY
                
                if(idx > 0) {

                    if(model.openPrice > model.preModel.closePrice) {

                        openPoint.y = closePointY + kStockKLineKlineMinThick;
                    } else {

                        closePointY = openPoint.y + kStockKLineKlineMinThick;
                    }
                } else if(idx + 1 < drawKLineModelArray.count) {
                    
                    // idx == 0 即第一个时
//                    id<YYLineDataModelProtocol> subKLineModel = drawKLineModels[idx+1];
//                    if(model.Close.floatValue < subKLineModel.Open.floatValue) {
//                        openPoint.y = closePointY + YYStockLineMinThick;
//                    } else {
//                        closePointY = openPoint.y + kStockKLineKlineMinThick;
//                    }
                } else {
                    
                    openPoint.y = closePointY - kStockKLineKlineMinThick;
                }
            }
        }
        
        CGPoint closePoint = CGPointMake(xPosition, closePointY);
        
        model.openPricePositionPoint = openPoint;
        model.closePricePositionPoint = closePoint;
        model.highPricePositionPoint = highPoint;
        model.lowPricePositionPoint = lowPoint;
        
#pragma mark - volume线
        CGFloat yPosition = ABS(volumeLineMaxY - (model.volume.integerValue - self.minVolumeLineValue) / volumeLineUnitValue); // start 的 y
        CGPoint startPoint = CGPointMake(xPosition, (ABS(yPosition - volumeLineMaxY) > 0 && ABS(yPosition - volumeLineMaxY) < 0.5) ? volumeLineMaxY - 0.5 : yPosition);
        CGPoint endPoint = CGPointMake(xPosition, volumeLineMaxY);

        model.volumeStartPositionPoint = startPoint; // 上↑
        model.volumeEndPositionPoint = endPoint; // 下↓
        
#pragma mark - MA线
        model.MA_5PositionPoint = CGPointMake(xPosition, ABS(KLineMaxY - (model.MA_5.floatValue - self.minKLineValue) / KLineUnitValue));
        model.MA_10PositionPoint = CGPointMake(xPosition, ABS(KLineMaxY - (model.MA_10.floatValue - self.minKLineValue) / KLineUnitValue));
        model.MA_20PositionPoint = CGPointMake(xPosition, ABS(KLineMaxY - (model.MA_20.floatValue - self.minKLineValue) / KLineUnitValue));
        model.MA_30PositionPoint = CGPointMake(xPosition, ABS(KLineMaxY - (model.MA_30.floatValue - self.minKLineValue) / KLineUnitValue));

#pragma mark - MACD
        model.MACD_DIFPositionPoint = CGPointMake(xPosition, model.MACD_DIF.floatValue / MACDLineUnitValue + volumeViewHeight * 0.5);
        model.MACD_DEAPositionPoint = CGPointMake(xPosition, model.MACD_DEA.floatValue / MACDLineUnitValue + volumeViewHeight * 0.5);
        model.MACD_BARStartPositionPoint = CGPointMake(xPosition, volumeViewHeight * 0.5);
        model.MACD_BAREndPositionPoint = CGPointMake(xPosition, model.MACD_BAR.floatValue / MACDLineUnitValue + volumeViewHeight * 0.5);
        
#pragma mark - KDJ
        model.KDJ_KPositionPoint = CGPointMake(xPosition, KDJLineMaxY - (model.KDJ_K.floatValue - self.KDJMinValue) / KDJLineUnitValue);
        model.KDJ_DPositionPoint = CGPointMake(xPosition, KDJLineMaxY - (model.KDJ_D.floatValue - self.KDJMinValue) / KDJLineUnitValue);
        model.KDJ_JPositionPoint = CGPointMake(xPosition, KDJLineMaxY - (model.KDJ_J.floatValue - self.KDJMinValue) / KDJLineUnitValue);
        
#pragma mark - RSI
        model.RSI_6PositionPoint = CGPointMake(xPosition, ABS(RSILineMaxY - (model.RSI_6.floatValue - self.RSIMinValue) / RSILineUnitValue));
        model.RSI_12PositionPoint = CGPointMake(xPosition, ABS(RSILineMaxY - (model.RSI_12.floatValue - self.RSIMinValue) / RSILineUnitValue));
        model.RSI_24PositionPoint = CGPointMake(xPosition, ABS(RSILineMaxY - (model.RSI_24.floatValue - self.RSIMinValue) / RSILineUnitValue));
        
#pragma mark - BOLL
        model.BOLL_UpperPositionPoint = CGPointMake(xPosition, ABS(KLineMaxY - (model.BOLL_UPPER.floatValue - self.minKLineValue) / KLineUnitValue));
        model.BOLL_MidPositionPoint = CGPointMake(xPosition, ABS(KLineMaxY - (model.BOLL_MID.floatValue - self.minKLineValue) / KLineUnitValue));
        model.BOLL_LowerPositionPoint = CGPointMake(xPosition, ABS(KLineMaxY - (model.BOLL_LOWER.floatValue - self.minKLineValue) / KLineUnitValue));
        
#pragma mark - ARBR
        model.ARBR_ARPositionPoint = CGPointMake(xPosition, ABS(ARBRLineMaxY - (model.ARBR_AR.floatValue - self.ARBRMinValue) / ARBRLineUnitValue));
        model.ARBR_BRPositionPoint = CGPointMake(xPosition, ABS(ARBRLineMaxY - (model.ARBR_BR.floatValue - self.ARBRMinValue) / ARBRLineUnitValue));
        
#pragma mark - OBV
        model.OBVPositionPoint = CGPointMake(xPosition, ABS(OBVLineMaxY - (model.OBV.floatValue - self.OBVMinValue) / OBVLineUnitValue));

#pragma mark - WR
        model.WR_1PositionPoint = CGPointMake(xPosition, ABS(WRLineMaxY - (model.WR_1.floatValue - self.WRMinValue) / WRLineUnitValue));
        model.WR_2PositionPoint = CGPointMake(xPosition, ABS(WRLineMaxY - (model.WR_2.floatValue - self.WRMinValue) / WRLineUnitValue));
        
#pragma mark - DMA
        model.DDDPositionPoint = CGPointMake(xPosition, ABS(DMALineMaxY - (model.DDD.floatValue - self.DMAMinValue) / DMALineUnitValue));
        model.AMAPositionPoint = CGPointMake(xPosition, ABS(DMALineMaxY - (model.AMA.floatValue - self.DMAMinValue) / DMALineUnitValue));

#pragma mark - CCI
        model.CCIPositionPoint = CGPointMake(xPosition, ABS(CCILineMaxY - (model.CCI.floatValue - self.CCIMinValue) / CCILineUnitValue));
        
        
        
        
        
        
        [tempDrawKLineModels addObject:model];
    }];
    
    self.drawKLineModels = tempDrawKLineModels;
}


#pragma mark - lazy loading
- (NSArray<YFStock_KLineModel *> *)drawKLineModels {
    
    if (_drawKLineModels == nil) {
        
        _drawKLineModels = [NSArray new];
    }
    return _drawKLineModels;
}


@end
