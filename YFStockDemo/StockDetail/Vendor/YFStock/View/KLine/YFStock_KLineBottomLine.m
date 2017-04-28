//
//  YFStock_VolumeLine.m
//  YFStockDemo
//
//  Created by 李友富 on 2017/3/31.
//  Copyright © 2017年 李友富. All rights reserved.
//

#import "YFStock_KLineBottomLine.h"
#import "YFStock_Header.h"

@interface YFStock_KLineBottomLine()

@property (nonatomic, assign) CGContextRef context;
@property (nonatomic, strong) NSArray <YFStock_KLineModel *> *drawKLineModels;
@property (nonatomic, assign) YFStockBottomBarIndex bottomBarSelectedIndex;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end

@implementation YFStock_KLineBottomLine

- (CAShapeLayer *)shapeLayer {
    
    if (_shapeLayer == nil) {
        
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.frame = self.layer.bounds;
        _shapeLayer.backgroundColor = kClearColor.CGColor;
        [self.layer addSublayer:_shapeLayer];
    }
    return _shapeLayer;
}

- (void)drawWithBottomBarSelectedIndex:(NSInteger)bottomBarSelectedIndex drawKLineModels:(NSArray<YFStock_KLineModel *> *)drawKLineModels {
    
    self.drawKLineModels = drawKLineModels;
    
    if (!self.drawKLineModels || self.drawKLineModels.count == 0) return;
    
    if (_shapeLayer) {
        
        [_shapeLayer removeFromSuperlayer];
        _shapeLayer = nil;
    }
    
    self.bottomBarSelectedIndex = bottomBarSelectedIndex;
        
    switch (self.bottomBarSelectedIndex) {
        case YFStockBottomBarIndex_MACD:
        {
            [self drawMACD];
        }
            break;
        case YFStockBottomBarIndex_KDJ:
        {
            [self drawKDJ];
        }
            break;
        case YFStockBottomBarIndex_RSI:
        {
            [self drawRSI];
        }
            break;
        case YFStockBottomBarIndex_ARBR:
        {
            [self drawARBR];
        }
            break;
        case YFStockBottomBarIndex_OBV:
        {
            [self drawOBV];
        }
            break;
        case YFStockBottomBarIndex_WR:
        {
            [self drawWR];
        }
            break;
        case YFStockBottomBarIndex_DMA:
        {
            [self drawDMA];
        }
            break;
        case YFStockBottomBarIndex_CCI:
        {
            [self drawCCI];
        }
            break;
        case YFStockBottomBarIndex_BIAS:
        {
            [self drawBIAS];
        }
            break;
            
        default:
            break;
    }
}

- (void)drawVolume {
    
    [self.drawKLineModels enumerateObjectsUsingBlock:^(YFStock_KLineModel *KLineModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIColor *strokeColor;
        CGFloat x, y, width, height;
        
        if (KLineModel.isIncrease) {
            
            strokeColor = kStockIncreaseColor;
            
        } else {
            
            strokeColor = kStockDecreaseColor;
        }
        
        x = KLineModel.volumeStartPositionPoint.x - [YFStock_Variable KLineWidth] * 0.5;
        y = KLineModel.volumeStartPositionPoint.y;
        width = [YFStock_Variable KLineWidth];
        height = ABS(KLineModel.volumeEndPositionPoint.y - KLineModel.volumeStartPositionPoint.y);
        
        CGRect rect = CGRectMake(x, y, width, height);
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
        path.lineWidth = kStockPartLineHeight;
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.fillColor = strokeColor.CGColor;
        shapeLayer.strokeColor = strokeColor.CGColor;
        shapeLayer.path = path.CGPath;
        shapeLayer.frame = self.shapeLayer.bounds;
        shapeLayer.backgroundColor = kClearColor.CGColor;
        [self.shapeLayer addSublayer:shapeLayer];

    }];
}

- (void)drawMACD {
    
    // MACD
    [self.drawKLineModels enumerateObjectsUsingBlock:^(YFStock_KLineModel *KLineModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIColor *strokeColor;
        CGFloat x, y, width, height;

        if (KLineModel.MACD_BAR.floatValue > 0) {
            
            strokeColor = kStockIncreaseColor;
        } else {
            
            strokeColor = kStockDecreaseColor;
        }
        
        x = KLineModel.MACD_BARStartPositionPoint.x - 0.5 * [YFStock_Variable KLineWidth];
        y = KLineModel.MACD_BARStartPositionPoint.y;
        width = [YFStock_Variable KLineWidth];
        height = KLineModel.MACD_BAREndPositionPoint.y - KLineModel.MACD_BARStartPositionPoint.y;
        
        CGRect rect = CGRectMake(x, y, width, height);
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
        path.lineWidth = kStockPartLineHeight;
        
        [self createShapeLayerWithStrokeColor:strokeColor fillColor:strokeColor path:path frame:self.shapeLayer.bounds backgroundColor:kClearColor];

    }];
    
    // DIFF
    UIBezierPath *diffPath = [self createBezierPathWithLineWidth:kStockPartLineHeight];
    
    CGPoint DIFFFirstPoint = [self.drawKLineModels.firstObject MACD_DIFPositionPoint];
    NSAssert(!isnan(DIFFFirstPoint.x) && !isnan(DIFFFirstPoint.y), @"出现NAN值：MA画线");

    [diffPath moveToPoint:DIFFFirstPoint];
    
    for (NSInteger idx = 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] MACD_DIFPositionPoint];

        [diffPath addLineToPoint:point];
    }
    
    [self createShapeLayerWithStrokeColor:kStockDIFFLineColor fillColor:kClearColor path:diffPath frame:self.shapeLayer.bounds backgroundColor:kClearColor];

    
    // DEA
    UIBezierPath *deaPath = [self createBezierPathWithLineWidth:kStockPartLineHeight];
    
    CGPoint DEAFirstPoint = [self.drawKLineModels.firstObject MACD_DEAPositionPoint];
    NSAssert(!isnan(DEAFirstPoint.x) && !isnan(DEAFirstPoint.y), @"出现NAN值：MA画线");

    [deaPath moveToPoint:DIFFFirstPoint];

    for (NSInteger idx = 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] MACD_DEAPositionPoint];

        [deaPath addLineToPoint:point];
    }
    
    [self createShapeLayerWithStrokeColor:kStockDEALineColor fillColor:kClearColor path:deaPath frame:self.shapeLayer.bounds backgroundColor:kClearColor];

}

- (void)drawKDJ {
    
    // K
    UIBezierPath *KPath = [self createBezierPathWithLineWidth:kStockPartLineHeight];
    
    KPath.lineWidth = kStockPartLineHeight;
    CGPoint KDJ_KPoint = [self.drawKLineModels.firstObject KDJ_KPositionPoint];
    NSAssert(!isnan(KDJ_KPoint.x) && !isnan(KDJ_KPoint.y), @"出现NAN值：MA画线");

    [KPath moveToPoint:KDJ_KPoint];
    
    for (NSInteger idx = 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] KDJ_KPositionPoint];

        [KPath addLineToPoint:point];
    }
    
    [self createShapeLayerWithStrokeColor:kStockMA5LineColor fillColor:kClearColor path:KPath frame:self.shapeLayer.bounds backgroundColor:kClearColor];

    
    // D
    UIBezierPath *DPath = [self createBezierPathWithLineWidth:kStockPartLineHeight];
    
    CGPoint KDJ_DPoint = [self.drawKLineModels.firstObject KDJ_DPositionPoint];
    NSAssert(!isnan(KDJ_DPoint.x) && !isnan(KDJ_DPoint.y), @"出现NAN值：MA画线");
    
    [DPath moveToPoint:KDJ_DPoint];
    
    for (NSInteger idx = 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] KDJ_DPositionPoint];

        [DPath addLineToPoint:point];
    }
    
    [self createShapeLayerWithStrokeColor:kStockMA10LineColor fillColor:kClearColor path:DPath frame:self.shapeLayer.bounds backgroundColor:kClearColor];

    
    // J
    UIBezierPath *JPath = [self createBezierPathWithLineWidth:kStockPartLineHeight];
    
    CGPoint KDJ_JPoint = [self.drawKLineModels.firstObject KDJ_JPositionPoint];
    NSAssert(!isnan(KDJ_JPoint.x) && !isnan(KDJ_JPoint.y), @"出现NAN值：MA画线");

    [JPath moveToPoint:KDJ_JPoint];
    
    for (NSInteger idx = 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] KDJ_JPositionPoint];

        [JPath addLineToPoint:point];
    }
    
    [self createShapeLayerWithStrokeColor:kStockMA20LineColor fillColor:kClearColor path:JPath frame:self.shapeLayer.bounds backgroundColor:kClearColor];
}

- (void)drawRSI {
    
    // RSI_6
    UIBezierPath *RSI_6_Path = [self createBezierPathWithLineWidth:kStockPartLineHeight];

    // start index
    NSInteger startIndex_6 = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_RSI_6_N];
    
    CGPoint RSI_6Point = [self.drawKLineModels[startIndex_6] RSI_6PositionPoint];
    NSAssert(!isnan(RSI_6Point.x) && !isnan(RSI_6Point.y), @"出现NAN值：MA画线");

    [RSI_6_Path moveToPoint:RSI_6Point];
    
    for (NSInteger idx = startIndex_6 + 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] RSI_6PositionPoint];

        [RSI_6_Path addLineToPoint:point];
    }
    [self createShapeLayerWithStrokeColor:kStockMA5LineColor fillColor:kClearColor path:RSI_6_Path frame:self.shapeLayer.bounds backgroundColor:kClearColor];
    
    // RSI_12
    UIBezierPath *RSI_12_Path = [self createBezierPathWithLineWidth:kStockPartLineHeight];
    
    // start index
    NSInteger startIndex_12 = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_RSI_12_N];
    
    CGPoint RSI_12Point = [self.drawKLineModels[startIndex_12] RSI_12PositionPoint];
    NSAssert(!isnan(RSI_12Point.x) && !isnan(RSI_12Point.y), @"出现NAN值：MA画线");

    [RSI_12_Path moveToPoint:RSI_12Point];
    
    for (NSInteger idx = startIndex_12 + 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] RSI_12PositionPoint];

        [RSI_12_Path addLineToPoint:point];
    }
    [self createShapeLayerWithStrokeColor:kStockMA10LineColor fillColor:kClearColor path:RSI_12_Path frame:self.shapeLayer.bounds backgroundColor:kClearColor];
    
    // RSI_24
    UIBezierPath *RSI_24_Path = [self createBezierPathWithLineWidth:kStockPartLineHeight];
    
    // start index
    NSInteger startIndex_24 = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_RSI_24_N];
    
    CGPoint RSI_24Point = [self.drawKLineModels[startIndex_24] RSI_24PositionPoint];
    NSAssert(!isnan(RSI_24Point.x) && !isnan(RSI_24Point.y), @"出现NAN值：MA画线");

    [RSI_24_Path moveToPoint:RSI_24Point];

    for (NSInteger idx = startIndex_24 + 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] RSI_24PositionPoint];

        [RSI_24_Path addLineToPoint:point];
    }
    [self createShapeLayerWithStrokeColor:kStockMA20LineColor fillColor:kClearColor path:RSI_24_Path frame:self.shapeLayer.bounds backgroundColor:kClearColor];

}

- (void)drawARBR {
    
    // AR
    UIBezierPath *ARBR_AR_Path = [self createBezierPathWithLineWidth:kStockPartLineHeight];
    
    // start index
    NSInteger startIndex_AR = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_ARBR_N];
    
    CGPoint ARBR_ARPoint = [self.drawKLineModels[startIndex_AR] ARBR_ARPositionPoint];
    NSAssert(!isnan(ARBR_ARPoint.x) && !isnan(ARBR_ARPoint.y), @"出现NAN值：MA画线");

    [ARBR_AR_Path moveToPoint:ARBR_ARPoint];
    
    for (NSInteger idx = startIndex_AR + 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] ARBR_ARPositionPoint];

        [ARBR_AR_Path addLineToPoint:point];
    }
    [self createShapeLayerWithStrokeColor:kStockMA5LineColor fillColor:kClearColor path:ARBR_AR_Path frame:self.shapeLayer.frame backgroundColor:kClearColor];
    
    // BR
    UIBezierPath *ARBR_BR_Path = [self createBezierPathWithLineWidth:kStockPartLineHeight];
    
    // start index
    NSInteger startIndex_BR = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_ARBR_N];
    
    CGPoint ARBR_BRPoint = [self.drawKLineModels[startIndex_BR] ARBR_BRPositionPoint];
    NSAssert(!isnan(ARBR_BRPoint.x) && !isnan(ARBR_BRPoint.y), @"出现NAN值：MA画线");

    [ARBR_BR_Path moveToPoint:ARBR_BRPoint];

    for (NSInteger idx = startIndex_BR + 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] ARBR_BRPositionPoint];

        [ARBR_BR_Path addLineToPoint:point];
    }
    [self createShapeLayerWithStrokeColor:kStockMA10LineColor fillColor:kClearColor path:ARBR_BR_Path frame:self.shapeLayer.frame backgroundColor:kClearColor];
}

- (void)drawOBV {
    
    [self drawVolume];
    
    // OBV
    UIBezierPath *path = [self createBezierPathWithLineWidth:kStockPartLineHeight];
    
    CGPoint OBVPoint = [self.drawKLineModels[0] OBVPositionPoint];
    NSAssert(!isnan(OBVPoint.x) && !isnan(OBVPoint.y), @"出现NAN值：MA画线");

    [path moveToPoint:OBVPoint];
    
    for (NSInteger idx = 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] OBVPositionPoint];

        [path addLineToPoint:point];
    }
    [self createShapeLayerWithStrokeColor:kStockMA5LineColor fillColor:kClearColor path:path frame:self.shapeLayer.frame backgroundColor:kClearColor];
}

- (void)drawWR {
    
    // WR_1
    UIBezierPath *WR_1_Path = [self createBezierPathWithLineWidth:kStockPartLineHeight];
    
    // start index
    NSInteger startIndex_WR_1 = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_WR_1_N];
    
    CGPoint WR_1Point = [self.drawKLineModels[startIndex_WR_1] WR_1PositionPoint];
    NSAssert(!isnan(WR_1Point.x) && !isnan(WR_1Point.y), @"出现NAN值：MA画线");

    [WR_1_Path moveToPoint:WR_1Point];
    
    for (NSInteger idx = startIndex_WR_1 + 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] WR_1PositionPoint];

        [WR_1_Path addLineToPoint:point];
    }
    [self createShapeLayerWithStrokeColor:kStockMA5LineColor fillColor:kClearColor path:WR_1_Path frame:self.shapeLayer.frame backgroundColor:kClearColor];
    
    
    // WR_2
    UIBezierPath *WR_2_Path = [self createBezierPathWithLineWidth:kStockPartLineHeight];
    
    // start index
    NSInteger startIndex_WR_2 = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_WR_2_N];
    
    CGPoint WR_2Point = [self.drawKLineModels[startIndex_WR_2] WR_2PositionPoint];
    NSAssert(!isnan(WR_2Point.x) && !isnan(WR_2Point.y), @"出现NAN值：MA画线");

    [WR_2_Path moveToPoint:WR_2Point];

    for (NSInteger idx = startIndex_WR_2 + 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] WR_2PositionPoint];

        [WR_2_Path addLineToPoint:point];
    }
    [self createShapeLayerWithStrokeColor:kStockMA10LineColor fillColor:kClearColor path:WR_2_Path frame:self.shapeLayer.frame backgroundColor:kClearColor];

}

- (void)drawDMA {
    
    // DDD
    UIBezierPath *DDDPath = [self createBezierPathWithLineWidth:kStockPartLineHeight];
    
    // start index
    NSInteger startIndex_DDD = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_DMA_LONG];
    
    CGPoint DDD_Point = [self.drawKLineModels[startIndex_DDD] DDDPositionPoint];
    NSAssert(!isnan(DDD_Point.x) && !isnan(DDD_Point.y), @"出现NAN值：MA画线");

    [DDDPath moveToPoint:DDD_Point];
    
    for (NSInteger idx = startIndex_DDD + 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] DDDPositionPoint];

        [DDDPath addLineToPoint:point];
    }
    [self createShapeLayerWithStrokeColor:kStockMA5LineColor fillColor:kClearColor path:DDDPath frame:self.shapeLayer.frame backgroundColor:kClearColor];
    
    
    // AMA
    UIBezierPath *AMAPath = [self createBezierPathWithLineWidth:kStockPartLineHeight];
    
    // start index
    NSInteger startIndex_AMA = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_DMA_LONG];
    
    CGPoint AMAPoint = [self.drawKLineModels[startIndex_AMA] AMAPositionPoint];
    NSAssert(!isnan(AMAPoint.x) && !isnan(AMAPoint.y), @"出现NAN值：MA画线");

    [AMAPath moveToPoint:AMAPoint];
    
    for (NSInteger idx = startIndex_AMA + 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] AMAPositionPoint];

        [AMAPath addLineToPoint:point];
    }
    [self createShapeLayerWithStrokeColor:kStockMA10LineColor fillColor:kClearColor path:AMAPath frame:self.shapeLayer.frame backgroundColor:kClearColor];

}

- (void)drawCCI {
    
    // CCI
    UIBezierPath *path = [self createBezierPathWithLineWidth:kStockPartLineHeight];
    
    // start index
    NSInteger startIndex_CCI = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_CCI_N];
    
    CGPoint CCI_Point = [self.drawKLineModels[startIndex_CCI] CCIPositionPoint];
    NSAssert(!isnan(CCI_Point.x) && !isnan(CCI_Point.y), @"出现NAN值：MA画线");

    [path moveToPoint:CCI_Point];
    
    for (NSInteger idx = startIndex_CCI + 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] CCIPositionPoint];

        [path addLineToPoint:point];
    }
    [self createShapeLayerWithStrokeColor:kStockMA5LineColor fillColor:kClearColor path:path frame:self.shapeLayer.frame backgroundColor:kClearColor];
}

- (void)drawBIAS {
    
    // BIAS_1
    UIBezierPath *path1 = [self createBezierPathWithLineWidth:kStockPartLineHeight];
    
    NSInteger startIndex1 = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_BIAS_1_N];
    
    CGPoint BIAS_1_Point = [self.drawKLineModels[startIndex1] BIAS_1PositionPoint];
    NSAssert(!isnan(BIAS_1_Point.x) && !isnan(BIAS_1_Point.y), @"出现NAN值：MA画线");
    
    [path1 moveToPoint:BIAS_1_Point];
    
    for (NSInteger idx = startIndex1 + 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] BIAS_1PositionPoint];
        
        [path1 addLineToPoint:point];
    }
    [self createShapeLayerWithStrokeColor:kStockMA5LineColor fillColor:kClearColor path:path1 frame:self.shapeLayer.frame backgroundColor:kClearColor];
    
    // BIAS_2
    UIBezierPath *path2 = [self createBezierPathWithLineWidth:kStockPartLineHeight];
    
    NSInteger startIndex2 = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_BIAS_2_N];
    
    CGPoint BIAS_2_Point = [self.drawKLineModels[startIndex2] BIAS_2PositionPoint];
    NSAssert(!isnan(BIAS_2_Point.x) && !isnan(BIAS_2_Point.y), @"出现NAN值：MA画线");
    
    [path2 moveToPoint:BIAS_2_Point];
    
    for (NSInteger idx = startIndex2 + 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] BIAS_2PositionPoint];
        
        [path2 addLineToPoint:point];
    }
    [self createShapeLayerWithStrokeColor:kStockMA10LineColor fillColor:kClearColor path:path2 frame:self.shapeLayer.frame backgroundColor:kClearColor];
    
    // BIAS_3
    UIBezierPath *path3 = [self createBezierPathWithLineWidth:kStockPartLineHeight];
    
    NSInteger startIndex3 = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_BIAS_3_N];
    
    CGPoint BIAS_3_Point = [self.drawKLineModels[startIndex3] BIAS_3PositionPoint];
    NSAssert(!isnan(BIAS_3_Point.x) && !isnan(BIAS_3_Point.y), @"出现NAN值：MA画线");
    
    [path3 moveToPoint:BIAS_3_Point];
    
    for (NSInteger idx = startIndex3 + 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] BIAS_3PositionPoint];
        
        [path3 addLineToPoint:point];
    }
    [self createShapeLayerWithStrokeColor:kStockMA20LineColor fillColor:kClearColor path:path3 frame:self.shapeLayer.frame backgroundColor:kClearColor];
}

- (UIBezierPath *)createBezierPathWithLineWidth:(CGFloat)lineWidth {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = lineWidth;
    return path;
}

- (void)createShapeLayerWithStrokeColor:(UIColor *)strokeColor fillColor:(UIColor *)fillColor path:(UIBezierPath *)path frame:(CGRect)frame backgroundColor:(UIColor *)backGroundColor {
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = fillColor.CGColor;
    layer.strokeColor = strokeColor.CGColor;
    layer.path = path.CGPath;
    layer.frame = frame;
    layer.backgroundColor = backGroundColor.CGColor;
    [self.shapeLayer addSublayer:layer];
}

- (NSInteger)getStartIndexWithDrawKLineModels:(NSArray <YFStock_KLineModel *> *)drawKLineModels N:(NSInteger)N {
    
    NSInteger startIndex = 0;
    
    if ([drawKLineModels.firstObject index].integerValue <= N - 1) {
        
        startIndex = N - 1 - [drawKLineModels.firstObject index].integerValue;
    }
    if (startIndex > drawKLineModels.count - 1) {
        
        startIndex = drawKLineModels.count - 1;
    }
    
    return startIndex;
}

@end
