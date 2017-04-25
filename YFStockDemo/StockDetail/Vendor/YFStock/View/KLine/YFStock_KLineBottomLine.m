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

@end

@implementation YFStock_KLineBottomLine

#pragma mark - 初始化
- (instancetype)initWithContext:(CGContextRef)context drawKLineModels:(NSArray <YFStock_KLineModel *>*)drawKLineModels {
    
    self = [super init];
    
    if (self) {
        
        _context = context;
        _drawKLineModels = drawKLineModels;
    }
    return self;
}

// draw
- (void)drawWithBottomBarSelectedIndex:(NSInteger)bottomBarSelectedIndex {
    
    if (!self.drawKLineModels || !self.context) return;
    
    self.bottomBarSelectedIndex = bottomBarSelectedIndex;
    
    // 注：已经提前clear
    
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
            
        default:
            break;
    }
}

- (void)drawVolume {
    
    [self.drawKLineModels enumerateObjectsUsingBlock:^(YFStock_KLineModel *KLineModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIColor *strokeColor;
        if (KLineModel.isIncrease) {
            
            strokeColor = kStockIncreaseColor;
        } else {
            
            strokeColor = kStockDecreaseColor;
        }
        
        CGContextSetStrokeColorWithColor(self.context, strokeColor.CGColor);
        CGContextSetLineWidth(self.context, [YFStock_Variable KLineWidth]);
        const CGPoint solidPoints[] = { KLineModel.volumeStartPositionPoint, KLineModel.volumeEndPositionPoint };
        CGContextStrokeLineSegments(self.context, solidPoints, 2);
        
        // 绘制绿色空心线
        //        CGFloat gap = 2.0f;
        //
        //        if ([strokeColor isEqual:kStockDecreaseColor] && ABS(KLineModel.volumeStartPositionPoint.y - KLineModel.volumeEndPositionPoint.y) > gap) {
        //
        //            CGContextSetStrokeColorWithColor(ctx, kStockThemeColor.CGColor);
        //            CGContextSetLineWidth(ctx, [YFStock_Variable KLineWidth] - gap);
        //            const CGPoint solidPoints[] = {CGPointMake(KLineModel.volumeStartPositionPoint.x, KLineModel.volumeStartPositionPoint.y + gap * 0.5),CGPointMake(KLineModel.volumeStartPositionPoint.x, KLineModel.volumeEndPositionPoint.y - gap * 0.5)};
        //            CGContextStrokeLineSegments(ctx, solidPoints, 2);
        //        }
    }];
}

- (void)drawMACD {
    
    // MACD
    [self.drawKLineModels enumerateObjectsUsingBlock:^(YFStock_KLineModel *KLineModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIColor *strokeColor;
        if (KLineModel.MACD_BAR.floatValue > 0) {
            
            strokeColor = kStockIncreaseColor;
        } else {
            
            strokeColor = kStockDecreaseColor;
        }
        
        CGContextSetStrokeColorWithColor(self.context, strokeColor.CGColor);
        CGContextSetLineWidth(self.context, [YFStock_Variable KLineWidth]);
        const CGPoint solidPoints[] = { KLineModel.MACD_BARStartPositionPoint, KLineModel.MACD_BAREndPositionPoint };
        CGContextStrokeLineSegments(self.context, solidPoints, 2);
        
        // 绘制绿色空心线
        //        CGFloat gap = 2.0f;
        //
        //        if ([strokeColor isEqual:kStockDecreaseColor] && ABS(KLineModel.volumeStartPositionPoint.y - KLineModel.volumeEndPositionPoint.y) > gap) {
        //
        //            CGContextSetStrokeColorWithColor(ctx, kStockThemeColor.CGColor);
        //            CGContextSetLineWidth(ctx, [YFStock_Variable KLineWidth] - gap);
        //            const CGPoint solidPoints[] = {CGPointMake(KLineModel.volumeStartPositionPoint.x, KLineModel.volumeStartPositionPoint.y + gap * 0.5),CGPointMake(KLineModel.volumeStartPositionPoint.x, KLineModel.volumeEndPositionPoint.y - gap * 0.5)};
        //            CGContextStrokeLineSegments(ctx, solidPoints, 2);
        //        }
    }];
    
    // DIFF
    CGContextSetStrokeColorWithColor(self.context, kStockDIFFLineColor.CGColor);
    CGContextSetLineWidth(self.context, kStockMALineWidth);
    CGPoint DIFFFirstPoint = [self.drawKLineModels.firstObject MACD_DIFPositionPoint];
    NSAssert(!isnan(DIFFFirstPoint.x) && !isnan(DIFFFirstPoint.y), @"出现NAN值：MA画线");
    CGContextMoveToPoint(self.context, DIFFFirstPoint.x, DIFFFirstPoint.y);
    
    for (NSInteger idx = 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] MACD_DIFPositionPoint];
        CGContextAddLineToPoint(self.context, point.x, point.y);
    }
    CGContextStrokePath(self.context);
    
    // DEA
    CGContextSetStrokeColorWithColor(self.context, kStockDEALineColor.CGColor);
    CGContextSetLineWidth(self.context, kStockMALineWidth);
    CGPoint DEAFirstPoint = [self.drawKLineModels.firstObject MACD_DEAPositionPoint];
    NSAssert(!isnan(DEAFirstPoint.x) && !isnan(DEAFirstPoint.y), @"出现NAN值：MA画线");
    CGContextMoveToPoint(self.context, DEAFirstPoint.x, DEAFirstPoint.y);
    
    for (NSInteger idx = 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] MACD_DEAPositionPoint];
        CGContextAddLineToPoint(self.context, point.x, point.y);
    }
    CGContextStrokePath(self.context);
}

- (void)drawKDJ {
    
    // K
    CGContextSetStrokeColorWithColor(self.context, kStockMA5LineColor.CGColor);
    CGContextSetLineWidth(self.context, kStockMALineWidth);
    CGPoint KDJ_KPoint = [self.drawKLineModels.firstObject KDJ_KPositionPoint];
    NSAssert(!isnan(KDJ_KPoint.x) && !isnan(KDJ_KPoint.y), @"出现NAN值：MA画线");
    CGContextMoveToPoint(self.context, KDJ_KPoint.x, KDJ_KPoint.y);
    
    for (NSInteger idx = 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] KDJ_KPositionPoint];
        CGContextAddLineToPoint(self.context, point.x, point.y);
    }
    CGContextStrokePath(self.context);
    
    // D
    CGContextSetStrokeColorWithColor(self.context, kStockMA10LineColor.CGColor);
    CGContextSetLineWidth(self.context, kStockMALineWidth);
    CGPoint KDJ_DPoint = [self.drawKLineModels.firstObject KDJ_DPositionPoint];
    NSAssert(!isnan(KDJ_DPoint.x) && !isnan(KDJ_DPoint.y), @"出现NAN值：MA画线");
    CGContextMoveToPoint(self.context, KDJ_DPoint.x, KDJ_DPoint.y);
    
    for (NSInteger idx = 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] KDJ_DPositionPoint];
        CGContextAddLineToPoint(self.context, point.x, point.y);
    }
    CGContextStrokePath(self.context);
    
    // J
    CGContextSetStrokeColorWithColor(self.context, kStockMA20LineColor.CGColor);
    CGContextSetLineWidth(self.context, kStockMALineWidth);
    CGPoint KDJ_JPoint = [self.drawKLineModels.firstObject KDJ_JPositionPoint];
    NSAssert(!isnan(KDJ_JPoint.x) && !isnan(KDJ_JPoint.y), @"出现NAN值：MA画线");
    CGContextMoveToPoint(self.context, KDJ_JPoint.x, KDJ_JPoint.y);
    
    for (NSInteger idx = 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] KDJ_JPositionPoint];
        CGContextAddLineToPoint(self.context, point.x, point.y);
    }
    CGContextStrokePath(self.context);
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

- (void)drawRSI {
    
    // RSI_6
    CGContextSetStrokeColorWithColor(self.context, kStockMA5LineColor.CGColor);
    CGContextSetLineWidth(self.context, kStockMALineWidth);

    // start index
    NSInteger startIndex_6 = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_RSI_6_N];
    
    CGPoint RSI_6Point = [self.drawKLineModels[startIndex_6] RSI_6PositionPoint];
    NSAssert(!isnan(RSI_6Point.x) && !isnan(RSI_6Point.y), @"出现NAN值：MA画线");
    CGContextMoveToPoint(self.context, RSI_6Point.x, RSI_6Point.y);
    
    for (NSInteger idx = startIndex_6 + 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] RSI_6PositionPoint];
        CGContextAddLineToPoint(self.context, point.x, point.y);
    }
    CGContextStrokePath(self.context);
    
    // RSI_12
    CGContextSetStrokeColorWithColor(self.context, kStockMA10LineColor.CGColor);
    CGContextSetLineWidth(self.context, kStockMALineWidth);
    
    // start index
    NSInteger startIndex_12 = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_RSI_12_N];
    
    CGPoint RSI_12Point = [self.drawKLineModels[startIndex_12] RSI_12PositionPoint];
    NSAssert(!isnan(RSI_12Point.x) && !isnan(RSI_12Point.y), @"出现NAN值：MA画线");
    CGContextMoveToPoint(self.context, RSI_12Point.x, RSI_12Point.y);
    
    for (NSInteger idx = startIndex_12 + 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] RSI_12PositionPoint];
        CGContextAddLineToPoint(self.context, point.x, point.y);
    }
    CGContextStrokePath(self.context);
    
    // RSI_24
    CGContextSetStrokeColorWithColor(self.context, kStockMA20LineColor.CGColor);
    CGContextSetLineWidth(self.context, kStockMALineWidth);
    
    // start index
    NSInteger startIndex_24 = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_RSI_24_N];
    
    CGPoint RSI_24Point = [self.drawKLineModels[startIndex_24] RSI_24PositionPoint];
    NSAssert(!isnan(RSI_24Point.x) && !isnan(RSI_24Point.y), @"出现NAN值：MA画线");
    CGContextMoveToPoint(self.context, RSI_24Point.x, RSI_24Point.y);
    
    for (NSInteger idx = startIndex_24 + 1; idx < self.drawKLineModels.count; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] RSI_24PositionPoint];
        CGContextAddLineToPoint(self.context, point.x, point.y);
    }
    CGContextStrokePath(self.context);

}

@end
