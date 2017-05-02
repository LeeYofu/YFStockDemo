//
//  YFStock_Model.m
//  GoldfishSpot
//
//  Created by 李友富 on 2017/4/20.
//  Copyright © 2017年 中泰荣科. All rights reserved.
//

#import "YFStock_KLineModel.h"
#import "MJExtension.h"
#import "YFStock_Header.h"

@interface YFStock_KLineModel()


@end

@implementation YFStock_KLineModel

- (void)initData {
    
        [self preModel];
        
        [self MA_5];
        [self MA_10];
        [self MA_20];
        [self MA_30];
        
        [self MACD_DIF];
        [self MACD_DEA];
        [self MACD_BAR];
        
        [self KDJ_K];
        [self KDJ_D];
        [self KDJ_J];
        
        [self RSI_6];
        [self RSI_12];
        [self RSI_24];
        
        [self BOLL_UPPER];
        [self BOLL_MID];
        [self BOLL_LOWER];
        
        [self ARBR_AR];
        [self ARBR_BR];
        
        [self OBV];
        
        [self WR_1];
        [self WR_2];
        
        [self CCI];
        
        [self DDD];
        [self AMA];

}

//+ (NSDictionary *)mj_replacedKeyFromPropertyName {
//    
//    return @{
//             @"MA_5" : @"MA5",
//             @"MA_10" : @"MA10",
//             @"MA_20" : @"MA20",
//             @"MA_30" : @"MA30",
//             };
//}

#pragma mark - Getter
- (YFStock_KLineModel *)preModel {
    
    if (! _preModel) {
        
        _preModel = self.preAllModelArray.lastObject;
    }
    
    return _preModel;
}

- (BOOL)isIncrease {
    
    if (self.openPrice.floatValue  < self.closePrice.floatValue) {
        
        return YES;
    } else if (self.openPrice.floatValue > self.closePrice.floatValue) {
        
        return NO;
    } else {
        
        if (self.openPrice.floatValue >= self.preModel.closePrice.floatValue) {
            
            return YES;
        } else {
            
            return NO;
        }
    }
}

- (NSNumber *)index {
    
    if (! _index) {
        
        _index = [NSNumber numberWithInteger:self.preAllModelArray.count];
    }
    return _index;
}

#pragma mark MA
- (NSNumber *)MA_5 {
    
    if (! _MA_5) {
        
        _MA_5 = [NSNumber numberWithFloat:[self getMAWithN:kStock_MA_5_N]];
    }
    return _MA_5;
}

- (NSNumber *)MA_10 {
    
    if (! _MA_10) {
        
        _MA_10 = [NSNumber numberWithFloat:[self getMAWithN:kStock_MA_10_N]];
    }
    return _MA_10;
}

- (NSNumber *)MA_20 {
    
    if (! _MA_20) {
        
        _MA_20 = [NSNumber numberWithFloat:[self getMAWithN:kStock_MA_20_N]];
    }
    return _MA_20;
}

- (NSNumber *)MA_30 {
    
    if (! _MA_30) {
        
        _MA_30 = [NSNumber numberWithFloat:[self getMAWithN:kStock_MA_30_N]];
    }
    return _MA_30;
}

#pragma mark BOLL
- (NSNumber *)BOLL_UPPER {
    
    if (! _BOLL_UPPER) {
        
        _BOLL_UPPER = [NSNumber numberWithFloat:(self.BOLL_MID.floatValue + kStock_BOLL_K * [self getMDWithN:(kStock_BOLL_N - 1)])];
    }
    return _BOLL_UPPER;
}

- (NSNumber *)BOLL_MID {
    
    if (! _BOLL_MID) {
        
        _BOLL_MID = [NSNumber numberWithFloat:([self getMAWithN:(kStock_BOLL_N - 1)])];
    }
    return _BOLL_MID;
}

- (NSNumber *)BOLL_LOWER {
    
    if (! _BOLL_LOWER) {
        
        _BOLL_LOWER = [NSNumber numberWithFloat:(self.BOLL_MID.floatValue - kStock_BOLL_K * [self getMDWithN:(kStock_BOLL_N - 1)])];
    }
    return _BOLL_LOWER;
}

#pragma mark MACD
- (NSNumber *)MACD_DIF {
    
    if (! _MACD_DIF) {
        
        _MACD_DIF = [NSNumber numberWithFloat:([self getEMAWithN:kStock_MACD_SHORT] - [self getEMAWithN:kStock_MACD_LONG])];
    }
    return _MACD_DIF;
}

- (NSNumber *)MACD_DEA {
    
    if (! _MACD_DEA) {

        _MACD_DEA = [NSNumber numberWithFloat:(self.MACD_DIF.floatValue * 2 + self.preModel.MACD_DEA.floatValue * (kStock_MACD_MID - 1)) / (kStock_MACD_MID + 1)];
    }
    return _MACD_DEA;
}

- (NSNumber *)MACD_BAR {
    
    if (! _MACD_BAR) {
        
        _MACD_BAR = [NSNumber numberWithFloat:(2 * (self.MACD_DIF.floatValue - self.MACD_DEA.floatValue))];
        
        if (_MACD_BAR.floatValue < 0.5 && _MACD_BAR.floatValue > 0) {
            
            _MACD_BAR = [NSNumber numberWithFloat:0.5];
        }
        if (_MACD_BAR.floatValue < 0 && _MACD_BAR.floatValue > -0.5) {
            
            _MACD_BAR = [NSNumber numberWithFloat:-0.5];
        }
    }
    return _MACD_BAR;
}

#pragma mark KDJ
- (NSNumber *)KDJ_K {
    
    if (! _KDJ_K) {
        
        _KDJ_K = [NSNumber numberWithFloat:(2.0 / 3.0 * self.preModel.KDJ_K.floatValue + 1.0 / 3.0 * [self getRSVWithN:kStock_KDJ_N])];
    }
    return _KDJ_K;
}

- (NSNumber *)KDJ_D {
    
    if (! _KDJ_D) {
        
        _KDJ_D = [NSNumber numberWithFloat:(2.0 / 3.0 * self.preModel.KDJ_D.floatValue + 1.0 / 3.0 * self.KDJ_K.floatValue)];
    }
    return _KDJ_D;
}

- (NSNumber *)KDJ_J {
    
    if (! _KDJ_J) {
        
        _KDJ_J = [NSNumber numberWithFloat:(3 * self.KDJ_K.floatValue - 2 * self.KDJ_D.floatValue)];
    }
    return _KDJ_J;
}

#pragma mark RSI
- (NSNumber *)RSI_6 {
    
    if (! _RSI_6) {
        
        CGFloat RSI = [self getRSIWithN:kStock_RSI_6_N];
        _RSI_6 = [NSNumber numberWithFloat:RSI];
    }
    return _RSI_6;
}

- (NSNumber *)RSI_12 {
    
    if (! _RSI_12) {
        
        CGFloat RSI = [self getRSIWithN:kStock_RSI_12_N];
        _RSI_12 = [NSNumber numberWithFloat:RSI];
    }
    return _RSI_12;
}

- (NSNumber *)RSI_24 {
    
    if (! _RSI_24) {
        
        CGFloat RSI = [self getRSIWithN:kStock_RSI_24_N];
        _RSI_24 = [NSNumber numberWithFloat:RSI];
    }
    return _RSI_24;
}

#pragma mark ARBR
- (NSNumber *)ARBR_AR {
    
    if (! _ARBR_AR) {
        
        _ARBR_AR = [NSNumber numberWithFloat:[self getARWithN:kStock_ARBR_N]];
    }
    return _ARBR_AR;
}

- (NSNumber *)ARBR_BR {
    
    if (! _ARBR_BR) {
        
        _ARBR_BR = [NSNumber numberWithFloat:[self getBRWithN:kStock_ARBR_N]];
    }
    return _ARBR_BR;
}

#pragma mark OBV
- (NSNumber *)OBV {
    
    if (! _OBV) {
        
        CGFloat VA = ((self.closePrice.floatValue - self.lowPrice.floatValue) - (self.highPrice.floatValue - self.closePrice.floatValue)) / (self.highPrice.floatValue - self.lowPrice.floatValue) * self.volume.floatValue;
        _OBV = [NSNumber numberWithFloat:VA];
    }
    return _OBV;
}

#pragma mark WR
- (NSNumber *)WR_1 {
    
    if (! _WR_1) {
        
        CGFloat value = 100 * ([self getMaxHighPriceWithN:kStock_WR_1_N] - self.closePrice.floatValue) / ([self getMaxHighPriceWithN:kStock_WR_1_N] - [self getMinLowPriceWithN:kStock_WR_1_N]);
        _WR_1 = [NSNumber numberWithFloat:value];
    }
    return _WR_1;
}

- (NSNumber *)WR_2 {
    
    if (! _WR_2) {
        
        CGFloat value = 100 * ([self getMaxHighPriceWithN:kStock_WR_2_N] - self.closePrice.floatValue) / ([self getMaxHighPriceWithN:kStock_WR_2_N] - [self getMinLowPriceWithN:kStock_WR_2_N]);
        _WR_2 = [NSNumber numberWithFloat:value];
    }
    return _WR_2;
}

#pragma mark DMA
- (NSNumber *)DDD {
    
    if (! _DDD) {
        
        CGFloat DDD = [self getMAWithN:kStock_DMA_SHORT] - [self getMAWithN:kStock_DMA_LONG];
        _DDD = [NSNumber numberWithFloat:DDD];
    }
    return _DDD;
}

- (NSNumber *)AMA {
    
    if (! _AMA) {
        
        CGFloat DDD_MA = [self getDDD_MAWithN:kStock_DMA_SHORT];
        _AMA = [NSNumber numberWithFloat:DDD_MA];
    }
    return _AMA;
}


#pragma mark CCI
- (NSNumber *)CCI {
    
    if (! _CCI) {
        
        CGFloat TYP = [self getTYP];
        CGFloat MA_TYP_N = [self getTYP_MAWithN:kStock_CCI_N];
        CGFloat AVEDEV = [self getAVEDEVWithN:kStock_CCI_N];
        CGFloat CCI = (TYP - MA_TYP_N)/ AVEDEV / 0.015;
        _CCI = [NSNumber numberWithFloat:CCI];
    }
    return _CCI;
}

#pragma mark BIAS
- (NSNumber *)BIAS_1 {
    
    if (! _BIAS_1) {
        
        CGFloat BIAS = (self.closePrice.floatValue - [self getMAWithN:kStock_BIAS_1_N]) / [self getMAWithN:kStock_BIAS_1_N] * 100.0f;
        _BIAS_1 = [NSNumber numberWithFloat:BIAS];
    }
    return _BIAS_1;
}

- (NSNumber *)BIAS_2 {
    
    if (! _BIAS_2) {
        
        CGFloat BIAS = (self.closePrice.floatValue - [self getMAWithN:kStock_BIAS_2_N]) / [self getMAWithN:kStock_BIAS_2_N] * 100.0f;
        _BIAS_2 = [NSNumber numberWithFloat:BIAS];
    }
    return _BIAS_2;
}

- (NSNumber *)BIAS_3 {
    
    if (! _BIAS_3) {
        
        CGFloat BIAS = (self.closePrice.floatValue - [self getMAWithN:kStock_BIAS_3_N]) / [self getMAWithN:kStock_BIAS_3_N] * 100.0f;
        _BIAS_3 = [NSNumber numberWithFloat:BIAS];
    }
    return _BIAS_3;
}

#pragma mark ROC
- (NSNumber *)ROC {
    
    if (! _ROC) {
        
        CGFloat previousNDayClosePrice = [self getPreviousClosePriceWithN:kStock_ROC_N];
        CGFloat ROC = (self.closePrice.floatValue - previousNDayClosePrice) / previousNDayClosePrice * 100;
        _ROC = [NSNumber numberWithFloat:ROC];
    }
    return _ROC;
}

- (NSNumber *)ROC_MA {
    
    if (! _ROC_MA) {
        
        CGFloat ROC_MA = [self getROC_MAWithN:kStock_ROC_MA_N];
        _ROC_MA = [NSNumber numberWithFloat:ROC_MA];
    }
    return _ROC_MA;
}

#pragma mark MTM
- (NSNumber *)MTM {
    
    if (! _MTM) {
        
        CGFloat MTM = self.closePrice.floatValue - [self getPreviousClosePriceWithN:kStock_MTM_N];
        _MTM = [NSNumber numberWithFloat:MTM];
    }
    return _MTM;
}

- (NSNumber *)MTM_MA {
    
    if (! _MTM_MA) {
        
        _MTM_MA = [NSNumber numberWithFloat:[self getMTM_MAWithN:kStock_MTM_MA_N]];
    }
    return _MTM_MA;
}

#pragma mark CR
- (NSNumber *)CR {
    
    if (! _CR) {
        
        CGFloat CR = [self getP_1WithN:kStock_CR_N] / [self getP_2WithN:kStock_CR_N] * 100;
        _CR = [NSNumber numberWithFloat:CR];
    }
    return _CR;
}

- (NSNumber *)CR_MA_1 {
    
    if (! _CR_MA_1) {
        
        _CR_MA_1 = [NSNumber numberWithFloat:[self getCR_MAWithN:kStock_CR_MA_1_N]];
    }
    return _CR_MA_1;
}

- (NSNumber *)CR_MA_2 {
    
    if (! _CR_MA_2) {
        
        _CR_MA_2 = [NSNumber numberWithFloat:[self getCR_MAWithN:kStock_CR_MA_2_N]];
    }
    return _CR_MA_2;
}

#pragma mark DMI
- (NSNumber *)DMI_PDI {
    
    if (! _DMI_PDI) {
        
        _DMI_PDI = [NSNumber numberWithFloat:[self getDIPlusWithN:14]];
    }
    return _DMI_PDI;
}

- (NSNumber *)DMI_MDI {
    
    if (! _DMI_MDI) {
        
        _DMI_MDI = [NSNumber numberWithFloat:[self getDIMinusWithN:14]];
    }
    return _DMI_MDI;
}

- (NSNumber *)DMI_ADX {
    
    if (! _DMI_ADX) {
        
        _DMI_ADX = [NSNumber numberWithFloat:[self getADXWithN:14]];
    }
    return _DMI_ADX;
}

- (NSNumber *)DMI_ADXR {
    
    if (! _DMI_ADXR) {
        
        CGFloat ADXR = (self.DMI_ADX.floatValue - [self getPreviousADXWithN:6]) * 0.5;
        _DMI_ADXR = [NSNumber numberWithFloat:ADXR];
    }
    return _DMI_ADXR;
}

#pragma mark TRIX
- (NSNumber *)TRIX {
    
    if (! _TRIX) {
        
        CGFloat todayTR = [self getTRWithN:kStock_TRIX_N];
        CGFloat yesterdayTR = [self.preModel getTRWithN:kStock_TRIX_N];
        
        _TRIX = [NSNumber numberWithFloat:(todayTR - yesterdayTR) / yesterdayTR * 100];
    }
    return _TRIX;
}

- (NSNumber *)TRIX_MA {
    
    if (! _TRIX_MA) {
        
        CGFloat TRIX_MA = [self getTRIX_MAWithN:kStock_TRIX_MA_N];
        _TRIX_MA = [NSNumber numberWithFloat:TRIX_MA];
    }
    return _TRIX_MA;
}


#pragma mark - 计算相关
#pragma mark MA/EMA
// MA
// 最近N日收盘价C的平均值  MA(C, N) = (C1 + C2 + …… +CN) / N
- (CGFloat)getMAWithN:(NSInteger)N {
    
    CGFloat MA = 0;
    
    NSMutableArray *tempArray = [self getPreviousArrayContainsSelfWithN:N];
    
    MA = [[[tempArray valueForKeyPath:@"closePrice"] valueForKeyPath:@"@avg.floatValue"] floatValue];
    
    tempArray = nil;
    
//    if (self.index.integerValue <= N - 1 - 1) {
//
//        MA = 0;
//    }
    
    return MA;
}

// EMA
// 当日EMA(C, N) = 2 / (N + 1) * (当日C – 前1日EMA) + 前1日EMA
- (CGFloat)getEMAWithN:(NSInteger)N {
    
    CGFloat EMA = 0;

    EMA = (self.closePrice.floatValue * 2 + [self.preModel getEMAWithN:N] * (N - 1)) / (N + 1);
    
    return EMA;
}

#pragma mark KDJ
// RSV
- (CGFloat)getRSVWithN:(NSInteger)N {
    
    CGFloat RSV = 0;
    
    if([self getMaxHighPriceWithN:N] == [self getMinLowPriceWithN:N]) {
        
        RSV = 100;
    } else {
        
        RSV = (self.closePrice.floatValue - [self getMinLowPriceWithN:N]) * 100 / ([self getMaxHighPriceWithN:N] - [self getMinLowPriceWithN:N]);
    }
    
    return RSV;
}

// 获取N周期内收盘价最小值和最大值
- (CGFloat)getMaxHighPriceWithN:(NSInteger)N {
    
    CGFloat value = 0;
    
    if (self.preAllModelArray.count >= (N - 1)) {
        
        NSArray *tempKLineModelArray = [self.preAllModelArray subarrayWithRange:NSMakeRange(self.preAllModelArray.count - (N - 1), (N - 1))];
        CGFloat maxPrice =  [[[tempKLineModelArray valueForKeyPath:@"highPrice"] valueForKeyPath:@"@max.floatValue"] floatValue];
        
        value = maxPrice > self.highPrice.floatValue ? maxPrice : self.highPrice.floatValue;
        
    } else {
        
        value = 0;
    }
    
    return value;
}

- (CGFloat)getMinLowPriceWithN:(NSInteger)N {
    
    CGFloat value = MAXFLOAT;
    
    if (self.preAllModelArray.count >= (N - 1)) {
        
        NSArray *tempKLineModelArray = [self.preAllModelArray subarrayWithRange:NSMakeRange(self.preAllModelArray.count - (N - 1), (N - 1))];
        CGFloat minPrice =  [[[tempKLineModelArray valueForKeyPath:@"lowPrice"] valueForKeyPath:@"@min.floatValue"] floatValue];
        
        value = minPrice < self.lowPrice.floatValue ? minPrice : self.lowPrice.floatValue;
        
    } else {
        
        value = MAXFLOAT;
    }
    
    return value;
}

#pragma mark RSI
// RSI
- (CGFloat)getRSIWithN:(NSInteger)N {
    
    CGFloat RSI = 0;
    
    CGFloat increaseValue = [self getIncreaseAvgWithN:N];
    CGFloat decreaseValue = [self getDecreaseAvgWithN:N];
    
    // security
    if (decreaseValue == 0) {
        
        decreaseValue = MAXFLOAT;
    }
    
    CGFloat RS = increaseValue / decreaseValue;
    
    RSI = 100 * RS / (1 + RS);
    
    return RSI;
}

- (CGFloat)getIncreaseAvgWithN:(NSInteger)N {
    
    CGFloat increaseAvg = 0;
    
    CGFloat minusValue = self.closePrice.floatValue - self.preModel.closePrice.floatValue;
    CGFloat increaseValue = minusValue < 0 ? 0 : minusValue; // 当日下跌，记涨幅数为0
    
    increaseAvg = ((N - 1) * [self.preModel getIncreaseAvgWithN:N] + increaseValue) / N;
    
    return increaseAvg;
}

- (CGFloat)getDecreaseAvgWithN:(NSInteger)N {
    
    CGFloat decreaseAvg = 0;
    
    CGFloat minusValue = self.closePrice.floatValue - self.preModel.closePrice.floatValue;
    CGFloat decreaseValue = minusValue > 0 ? 0 : ABS(minusValue); // 当日上涨，记跌幅数为0
    
    decreaseAvg = ((N - 1) * [self.preModel getDecreaseAvgWithN:N] + decreaseValue) / N;
    
    return decreaseAvg;
}

#pragma mark BOLL
- (CGFloat)getMDWithN:(NSInteger)N {
    
    CGFloat MD = 0;
    
    NSMutableArray *tempArray = [self getPreviousArrayContainsSelfWithN:N];
    
    CGFloat sum = 0;
    for (YFStock_KLineModel *model in tempArray) {
        
        CGFloat a = model.closePrice.floatValue - [self getMAWithN:N];
        a *= a;
        
        sum += a;
    }
    
    sum /= (N * 1.0);
    
    MD = sqrt(sum);
    
    return MD;
}

#pragma mark ARBR
- (CGFloat)getARWithN:(NSInteger)N {
    
    CGFloat AR = 0;
    
    NSMutableArray *tempArray = [self getPreviousArrayContainsSelfWithN:N];
    
    CGFloat sum_HMinusO = 0;
    CGFloat sum_OMinusL = 0;
    for (YFStock_KLineModel *model in tempArray) {
        
        CGFloat HMinusO = model.highPrice.floatValue - model.openPrice.floatValue;
        CGFloat OMinusL = model.openPrice.floatValue - model.lowPrice.floatValue;
        
        sum_HMinusO += HMinusO;
        sum_OMinusL += OMinusL;
    }
    
    AR = (sum_HMinusO / sum_OMinusL) * 100;
    
    return AR;
}

- (CGFloat)getBRWithN:(NSInteger)N {
    
    CGFloat BR = 0;
    
    NSMutableArray *tempArray = [self getPreviousArrayContainsSelfWithN:N];
    
    CGFloat sum_HMinusPC = 0;
    CGFloat sum_PCMinusL = 0;
    for (YFStock_KLineModel *model in tempArray) {
        
        CGFloat HMinusPC = model.highPrice.floatValue - model.preModel.closePrice.floatValue;
        CGFloat PCMinusL = model.preModel.closePrice.floatValue - model.lowPrice.floatValue;
        
        sum_HMinusPC += HMinusPC;
        sum_PCMinusL += PCMinusL;
    }
    
    BR = (sum_HMinusPC / sum_PCMinusL) * 100;
    
    return BR;
}

#pragma mark CCI
- (CGFloat)getTYP {
    
    CGFloat TYP = 0;
    
    TYP = (self.highPrice.floatValue + self.lowPrice.floatValue + self.closePrice.floatValue) / 3.0;
    
    return TYP;
}

- (CGFloat)getTYP_MAWithN:(NSInteger)N {
    
    CGFloat MA = 0;
    
    NSMutableArray *tempArray = [self getPreviousArrayContainsSelfWithN:N];
    
    CGFloat sumTYP = 0;
    for (YFStock_KLineModel *model in tempArray) {
        
        sumTYP += [model getTYP];
    }
    
    //    if (self.index.integerValue <= N - 1 - 1) {
    //
    //        MA = 0;
    //    }
    
    MA = sumTYP / (N * 1.0);
    
    return MA;
}

- (CGFloat)getAVEDEVWithN:(NSInteger)N {
    
    CGFloat AVEDEV = 0;
    
    NSMutableArray *tempArray = [self getPreviousArrayContainsSelfWithN:N];

    CGFloat sum = 0;
    for (YFStock_KLineModel *model in tempArray) {
        
        sum += ABS([model getTYP] - [model getTYP_MAWithN:N]);
    }
    
    AVEDEV = sum / (N * 1.0);
    
    return AVEDEV;
}

#pragma mark DMA
- (CGFloat)getDDD_MAWithN:(NSInteger)N {
    
    CGFloat MA = 0;

    NSMutableArray *tempArray = [self getPreviousArrayContainsSelfWithN:N];
    
    CGFloat sumDDD = 0;
    for (YFStock_KLineModel *model in tempArray) {
        
        sumDDD += model.DDD.floatValue;
    }
    
    //    if (self.index.integerValue <= N - 1 - 1) {
    //
    //        MA = 0;
    //    }
    
    MA = sumDDD / (N * 1.0);
    
    return MA;
}

#pragma mark ROC
// 获取N天前的收盘价
- (CGFloat)getPreviousClosePriceWithN:(NSInteger)N {
    
    CGFloat closePrice = 0;
    
    NSInteger index = self.preAllModelArray.count - 1 - (N - 1);
    if (index < 0) {
        
        index = 0;
    }
    
    if (self.preAllModelArray.count) {
        
        YFStock_KLineModel *model = self.preAllModelArray[index];
        
        closePrice = model.closePrice.floatValue;
    } else {
        
        closePrice = 99999.0;
    }
    
    
    return closePrice;
}

- (CGFloat)getROC_MAWithN:(NSInteger)N {

    CGFloat ROC_MA = 0;
    
    CGFloat sum = 0;
    NSMutableArray *tempArray = [self getPreviousArrayContainsSelfWithN:N];
    
    for (YFStock_KLineModel *model in tempArray) {
        
        sum += model.ROC.floatValue;
    }
    
    ROC_MA = sum / (N * 1.0);
    
    return ROC_MA;
}

#pragma mark MTM
- (CGFloat)getMTM_MAWithN:(NSInteger)N {
    
    CGFloat MTM_MA = 0;
    
    CGFloat sum = 0;
    NSMutableArray *tempArray = [self getPreviousArrayContainsSelfWithN:N];
    
    for (YFStock_KLineModel *model in tempArray) {
        
        sum += model.MTM.floatValue;
    }
    
    MTM_MA = sum / (N * 1.0);
    
    return MTM_MA;
}

#pragma mark CR
- (CGFloat)getMiddlePrice {
    
    CGFloat middlePrice = 0;
    
    /*
     四种计算方法
     1、M=（2C+H+L）÷4
     2、M=（C+H+L+O）÷4
     3、M=（C+H+L）÷3
     4、M=（H+L）÷2
     */
    
    middlePrice = (self.highPrice.floatValue + self.lowPrice.floatValue) * 0.5;
    
    return middlePrice;
}

- (CGFloat)getP_1WithN:(NSInteger)N {
    
    CGFloat P = 0;
    
    NSMutableArray *tempArray = [self getPreviousArrayContainsSelfWithN:N];
    
    for (YFStock_KLineModel *model in tempArray) {
        
        P += (model.highPrice.floatValue - [model.preModel getMiddlePrice]);
    }
    
    return P;
}

- (CGFloat)getP_2WithN:(NSInteger)N {
    
    CGFloat P = 0;
    
    NSMutableArray *tempArray = [self getPreviousArrayContainsSelfWithN:N];
    
    for (YFStock_KLineModel *model in tempArray) {
        
        P += ([model.preModel getMiddlePrice] - model.lowPrice.floatValue);
    }
    
    return P;
}

- (CGFloat)getCR_MAWithN:(NSInteger)N {
    
    CGFloat CR_MA = 0;
    
    CGFloat sum = 0;
    NSMutableArray *tempArray = [self getPreviousArrayContainsSelfWithN:N];
    
    for (YFStock_KLineModel *model in tempArray) {
        
        sum += model.CR.floatValue;
    }
    
    CR_MA = sum / (N * 1.0);
    
    return CR_MA;
}

#pragma mark DMI
- (CGFloat)getDMPlus {
    
    CGFloat DMPlus = 0;
    
    DMPlus = self.highPrice.floatValue - self.preModel.highPrice.floatValue;
    if (DMPlus <= 0) {
        
        DMPlus = 0;
    }
    
    return DMPlus;
}

- (CGFloat)getDMMinus {
    
    CGFloat DMMinus = 0;
    
    DMMinus = self.preModel.lowPrice.floatValue - self.lowPrice.floatValue;
    if (DMMinus <= 0) {
        
        DMMinus = 0;
    }
    
    return DMMinus;
}

- (CGFloat)getTR {
    
    CGFloat TR = 0;
    
    CGFloat A = ABS(self.highPrice.floatValue - self.lowPrice.floatValue);
    CGFloat B = ABS(self.highPrice.floatValue - self.preModel.closePrice.floatValue);
    CGFloat C = ABS(self.lowPrice.floatValue - self.preModel.closePrice.floatValue);
    
    TR = MAX(A, MAX(B, C));
    
    return TR;
}

- (CGFloat)getDIPlusWithN:(NSInteger)N {
    
    CGFloat DIPlus = 0;
    
    NSArray *tempArray = [self getPreviousArrayContainsSelfWithN:N];
    CGFloat sumDMPlus = 0;
    CGFloat sumTR = 0;
    for (YFStock_KLineModel *model in tempArray) {
        
        CGFloat DMPlus = [model getDMPlus];
        CGFloat DMMinus = [model getDMMinus];
        
        if (DMPlus > DMMinus) {
            
            DMMinus = 0;
        } else if (DMPlus < DMMinus) {
            
            DMPlus = 0;
        } else {
            
            DMPlus = 0;
            DMMinus = 0;
        }

        sumDMPlus += DMPlus;
        sumTR += [model getTR];
        
//        CGFloat DMPlus = model.highPrice.floatValue - model.preModel.lowPrice.floatValue;
//        if (DMPlus <= ABS(model.lowPrice.floatValue - model.preModel.lowPrice.floatValue)) {
//            
//            DMPlus = 0;
//        }
//        
//        CGFloat DMMinus = model.lowPrice.floatValue - model.preModel.lowPrice.floatValue;
//        if (DMMinus <= ABS(model.highPrice.floatValue - model.preModel.lowPrice.floatValue)) {
//            
//            DMMinus = 0;
//        }
//        
//        sumDMPlus += DMPlus;
//        sumTR += [model getTR];
    }
    
    DIPlus = sumDMPlus / sumTR * 100;
    
    if (DIPlus < 0) {
        
        DIPlus = 0;
    }
    if (DIPlus > 100) {
        
        DIPlus = 100;
    }
    
    return DIPlus;
}

- (CGFloat)getDIMinusWithN:(NSInteger)N {
    
    CGFloat DIMinus = 0;
    
    NSArray *tempArray = [self getPreviousArrayContainsSelfWithN:N];
    CGFloat sumDMMinus = 0;
    CGFloat sumTR = 0;
    for (YFStock_KLineModel *model in tempArray) {
        
        CGFloat DMPlus = [model getDMPlus];
        CGFloat DMMinus = [model getDMMinus];
        
        if (DMPlus > DMMinus) {
            
            DMMinus = 0;
        } else if (DMPlus < DMMinus) {
            
            DMPlus = 0;
        } else {
            
            DMPlus = 0;
            DMMinus = 0;
        }
        
        sumDMMinus += DMMinus;
        sumTR += [model getTR];
    }
    
    DIMinus = sumDMMinus / sumTR * 100;
    
    if (DIMinus < 0) {
        
        DIMinus = 0;
    }
    if (DIMinus > 100) {
        
        DIMinus = 100;
    }
    
    return DIMinus;
}

- (CGFloat)getADXWithN:(NSInteger)N {
    
    CGFloat ADX = 0;
    
    NSArray *tempArray = [self getPreviousArrayContainsSelfWithN:N];
    CGFloat sum = 0;
    for (YFStock_KLineModel *model in tempArray) {
        
        CGFloat DX = (ABS(model.DMI_PDI.floatValue - model.DMI_MDI.floatValue) / (model.DMI_PDI.floatValue + model.DMI_MDI.floatValue)) * 100;
        sum += DX;
    }
    
    ADX = sum / (N * 1.0);
    
    return ADX;
}

- (CGFloat)getPreviousADXWithN:(NSInteger)N {
    
    CGFloat ADX = 0;
    
    NSInteger index = self.preAllModelArray.count - 1 - (N - 1);
    if (index < 0) {
        
        index = 0;
    }
    
    if (self.preAllModelArray.count) {
        
        YFStock_KLineModel *model = self.preAllModelArray[index];
        
        ADX = model.DMI_ADX.floatValue;
    } else {
        
        ADX = 0;
    }
    
    return ADX;
}

#pragma mark TRIX 
- (CGFloat)getAXWithN:(NSInteger)N {

    CGFloat AX = 0;
    
    AX = (self.closePrice.floatValue * 2 + [self.preModel getAXWithN:N] * (N - 1)) / (N + 1);
    
    return AX;
}

- (CGFloat)getBXWithN:(NSInteger)N {
    
    CGFloat BX = 0;
    
    BX = ([self getAXWithN:N] * 2 + [self.preModel getBXWithN:N] * (N - 1)) / (N + 1);
    
    return BX;
}

- (CGFloat)getTRWithN:(NSInteger)N {
    
    CGFloat TRIX = 0;
    
    TRIX = ([self getBXWithN:N] * 2 + [self.preModel getTRWithN:N] * (N - 1)) / (N + 1);
    
    return TRIX;
}

- (CGFloat)getTRIX_MAWithN:(NSInteger)N {
    
    CGFloat TRIX_MA = 0;
    
    CGFloat sum = 0;
    NSMutableArray *tempArray = [self getPreviousArrayContainsSelfWithN:N];
    
    for (YFStock_KLineModel *model in tempArray) {
        
        sum += model.TRIX.floatValue;
    }
    
    TRIX_MA = sum / (N * 1.0);
    
    return TRIX_MA;
}

#pragma mark Other
- (NSMutableArray *)getPreviousArrayContainsSelfWithN:(NSInteger)N {
    
    NSInteger startIndex = self.preAllModelArray.count - (N - 1);
    if (startIndex < 0) {
        
        startIndex = 0;
    }
    if (startIndex > self.preAllModelArray.count - 1) {
        
        startIndex = self.preAllModelArray.count - 1;
    }
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[self.preAllModelArray subarrayWithRange:NSMakeRange(startIndex, self.preAllModelArray.count - startIndex)]];
    
    [tempArray addObject:self];
    
    return tempArray;
}

@end
