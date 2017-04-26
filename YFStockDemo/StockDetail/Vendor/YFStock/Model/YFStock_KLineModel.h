//
//  YFStock_Model.h
//  GoldfishSpot
//
//  Created by 李友富 on 2017/4/20.
//  Copyright © 2017年 中泰荣科. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class YFStock_KLineModel;

@interface YFStock_KLineModel : NSObject

#pragma mark - 后台返回
// 后台返回的字段，这些字段必须要在初始化后赋值！！！！！！(请不要修改以下任何字段，请做字段转换)
@property (nonatomic, strong) NSNumber *openPrice;
@property (nonatomic, strong) NSNumber *closePrice;
@property (nonatomic, strong) NSNumber *highPrice;
@property (nonatomic, strong) NSNumber *lowPrice;
@property (nonatomic, strong) NSNumber *volume;
@property (nonatomic, copy) NSString *dataTime;
@property (nonatomic, copy) NSString *quotationCode;

#pragma mark - 自己计算
// 自己用算法计算的（如果后台返回相同意义字段，使用后台的覆盖就好，就不会走取值的懒加载方法了）
@property (nonatomic, strong) NSArray *preAllModelArray; // 必须要赋值！！！！！！【需要用 copy，否则数组还是会跟着改变】
@property (nonatomic, strong) YFStock_KLineModel *preModel;
@property (nonatomic, strong) NSNumber *index;

// MA相关(5, 10, 20, 30)
@property (nonatomic, strong) NSNumber *MA_5;
@property (nonatomic, strong) NSNumber *MA_10;
@property (nonatomic, strong) NSNumber *MA_20;
@property (nonatomic, strong) NSNumber *MA_30;

// MACD相关(12, 26, 9)
@property (nonatomic, strong) NSNumber *MACD_DIF;
@property (nonatomic, strong) NSNumber *MACD_DEA;
@property (nonatomic, strong) NSNumber *MACD_BAR;

// KDJ(9, 3, 3)
@property (nonatomic, strong) NSNumber *KDJ_K;
@property (nonatomic, strong) NSNumber *KDJ_D;
@property (nonatomic, strong) NSNumber *KDJ_J;

// RSI(6, 12, 24)
@property (nonatomic, strong) NSNumber *RSI_6;
@property (nonatomic, strong) NSNumber *RSI_12;
@property (nonatomic, strong) NSNumber *RSI_24;

// BOLL(20, 2)
@property (nonatomic, strong) NSNumber *BOLL_UPPER;
@property (nonatomic, strong) NSNumber *BOLL_MID;
@property (nonatomic, strong) NSNumber *BOLL_LOWER;

// ARBR(26)
@property (nonatomic, strong) NSNumber *ARBR_AR;
@property (nonatomic, strong) NSNumber *ARBR_BR;

// OBV
@property (nonatomic, strong) NSNumber *OBV;

// WR(10, 6)
@property (nonatomic, strong) NSNumber *WR_1;
@property (nonatomic, strong) NSNumber *WR_2;

// CCI(14)
@property (nonatomic, strong) NSNumber *CCI;

// DMA(10, 50)
@property (nonatomic, strong) NSNumber *DDD;
@property (nonatomic, strong) NSNumber *AMA;


// =============================================================
@property (nonatomic, assign) BOOL isIncrease;

@property (nonatomic, assign) BOOL isShowTime;
@property (nonatomic, copy) NSString *showTimeStr;

@property (nonatomic, assign) CGPoint openPricePositionPoint;
@property (nonatomic, assign) CGPoint closePricePositionPoint;
@property (nonatomic, assign) CGPoint highPricePositionPoint;
@property (nonatomic, assign) CGPoint lowPricePositionPoint;

@property (nonatomic, assign) CGPoint MA_5PositionPoint;
@property (nonatomic, assign) CGPoint MA_10PositionPoint;
@property (nonatomic, assign) CGPoint MA_20PositionPoint;
@property (nonatomic, assign) CGPoint MA_30PositionPoint;

@property (nonatomic, assign) CGPoint volumeStartPositionPoint;
@property (nonatomic, assign) CGPoint volumeEndPositionPoint;

@property (nonatomic, assign) CGPoint MACD_DIFPositionPoint;
@property (nonatomic, assign) CGPoint MACD_DEAPositionPoint;
@property (nonatomic, assign) CGPoint MACD_BARStartPositionPoint;
@property (nonatomic, assign) CGPoint MACD_BAREndPositionPoint;

@property (nonatomic, assign) CGPoint KDJ_KPositionPoint;
@property (nonatomic, assign) CGPoint KDJ_DPositionPoint;
@property (nonatomic, assign) CGPoint KDJ_JPositionPoint;

@property (nonatomic, assign) CGPoint RSI_6PositionPoint;
@property (nonatomic, assign) CGPoint RSI_12PositionPoint;
@property (nonatomic, assign) CGPoint RSI_24PositionPoint;

@property (nonatomic, assign) CGPoint BOLL_UpperPositionPoint;
@property (nonatomic, assign) CGPoint BOLL_MidPositionPoint;
@property (nonatomic, assign) CGPoint BOLL_LowerPositionPoint;

@property (nonatomic, assign) CGPoint ARBR_ARPositionPoint;
@property (nonatomic, assign) CGPoint ARBR_BRPositionPoint;

@property (nonatomic, assign) CGPoint OBVPositionPoint;

@property (nonatomic, assign) CGPoint WR_1PositionPoint;
@property (nonatomic, assign) CGPoint WR_2PositionPoint;

@property (nonatomic, assign) CGPoint DDDPositionPoint;
@property (nonatomic, assign) CGPoint AMAPositionPoint;

@property (nonatomic, assign) CGPoint CCIPositionPoint;

// 必须调用，减少卡顿！！！！
- (void)initData;

@end
