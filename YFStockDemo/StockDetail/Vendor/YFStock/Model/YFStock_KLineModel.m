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
        
        CGFloat RS = [self getRSWithN:kStock_RSI_6_N];
        _RSI_6 = [NSNumber numberWithFloat:(100 * RS / (1 + RS))];
    }
    return _RSI_6;
}

- (NSNumber *)RSI_12 {
    
    if (! _RSI_12) {
        
        CGFloat RS = [self getRSWithN:kStock_RSI_12_N];
        _RSI_12 = [NSNumber numberWithFloat:(100 * RS / (1 + RS))];
    }
    return _RSI_12;
}

- (NSNumber *)RSI_24 {
    
    if (! _RSI_24) {
        
        CGFloat RS = [self getRSWithN:kStock_RSI_24_N];
        _RSI_24 = [NSNumber numberWithFloat:(100 * RS / (1 + RS))];
    }
    return _RSI_24;
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

#pragma mark - 计算相关
// MA
// 最近N日收盘价C的平均值  MA(C, N) = (C1 + C2 + …… +CN) / N
- (CGFloat)getMAWithN:(NSInteger)N {
    
    CGFloat MA = 0;
    
    NSInteger startIndex = self.preAllModelArray.count - (N - 1);
    if (startIndex < 0) {
        
        startIndex = 0;
    }
    if (startIndex > self.preAllModelArray.count - 1) {
        
        startIndex = self.preAllModelArray.count - 1;
    }
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[self.preAllModelArray subarrayWithRange:NSMakeRange(startIndex, self.preAllModelArray.count - startIndex)]];
    
    [tempArray addObject:self];
    
    MA = [[[tempArray valueForKeyPath:@"closePrice"] valueForKeyPath:@"@avg.floatValue"] floatValue];
    
    tempArray = nil;
    
    //
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
    
    CGFloat value = 10000000;
    
    if (self.preAllModelArray.count >= (N - 1)) {
        
        NSArray *tempKLineModelArray = [self.preAllModelArray subarrayWithRange:NSMakeRange(self.preAllModelArray.count - (N - 1), (N - 1))];
        CGFloat minPrice =  [[[tempKLineModelArray valueForKeyPath:@"lowPrice"] valueForKeyPath:@"@min.floatValue"] floatValue];
        
        value = minPrice < self.lowPrice.floatValue ? minPrice : self.lowPrice.floatValue;
        
    } else {
        
        value = 0;
    }
    
    return value;
}

// RS
/*
 A = N个数字中正数之和 —— N日内收盘涨幅之和
 B = N个数字中负数之和 * (-1) —— N日内收盘跌幅之和（取正值）
 RS = A / B —— 相对强度
 */
- (CGFloat)getRSWithN:(NSInteger)N {
    
    CGFloat RS = 0;
    
    NSInteger startIndex = self.preAllModelArray.count - (N - 1);
    if (startIndex < 0) {
        
        startIndex = 0;
    }
    if (startIndex > self.preAllModelArray.count - 1) {
        
        startIndex = self.preAllModelArray.count - 1;
    }
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[self.preAllModelArray subarrayWithRange:NSMakeRange(startIndex, self.preAllModelArray.count - startIndex)]];
    
    [tempArray addObject:self];

    CGFloat A = 0, B = 0;
    
    for (YFStock_KLineModel *model in tempArray) {
        
        CGFloat closePricePadding = model.closePrice.floatValue - model.preModel.closePrice.floatValue;
        
        if (closePricePadding >= 0) {
            
            A += closePricePadding;
        } else {
            
            B += closePricePadding;
        }
    }
    
    if (B == 0) {
        
        B = MAXFLOAT;
    }
    
    RS = ABS(A / B);
    
    return RS;
}

- (CGFloat)getMDWithN:(NSInteger)N {
    
    CGFloat MD = 0;
    
    NSInteger startIndex = self.preAllModelArray.count - (N - 1);
    if (startIndex < 0) {
        
        startIndex = 0;
    }
    if (startIndex > self.preAllModelArray.count - 1) {
        
        startIndex = self.preAllModelArray.count - 1;
    }
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[self.preAllModelArray subarrayWithRange:NSMakeRange(startIndex, self.preAllModelArray.count - startIndex)]];
    
    [tempArray addObject:self];
        
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


@end
