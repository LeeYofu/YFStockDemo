

#import "YFMA_BOLLLine.h"

@interface YFMA_BOLLLine()
/**
 绘制上下文
 */
@property (nonatomic, assign) CGContextRef context;

@property (nonatomic, strong) NSArray *drawKLineModels;

@end

@implementation YFMA_BOLLLine

#pragma mark - 初始化
- (instancetype)initWithContext:(CGContextRef)context {
    
    self = [super init];
    if(self)
    {
        self.context = context;
    }
    return self;
}

#pragma mark - draw
- (void)drawWithKLineModels:(NSArray<YFStock_KLineModel *> *)drawKLineModels KLineLineType:(YFStockKLineLineType)KLineLineType {
    
    if(!self.context || !drawKLineModels) {
        
        return;
    }
    
    self.drawKLineModels = drawKLineModels;
    
    switch (KLineLineType) {
        case YFStockKLineLineType_MA:
        {
            [self drawMA];
        }
            break;
        case YFStockKLineLineType_BOLL:
        {
            [self drawBOLL];
        }
            break;
            
        default:
            break;
    }

}

#pragma mark - MA
- (void)drawMA {
    
    [self drawMA_5];
    [self drawMA_10];
    [self drawMA_20];
}

- (void)drawMA_5 {
    
    CGContextSetStrokeColorWithColor(self.context, kStockMA5LineColor.CGColor);
    
    CGContextSetLineWidth(self.context, kStockMALineWidth);
    
    // start index
    NSInteger startIndex = 0;
    if ([self.drawKLineModels.firstObject index].integerValue <= kStock_MA_5_N - 1) {
        
        startIndex = kStock_MA_5_N - 1 - [self.drawKLineModels.firstObject index].integerValue;
    }
    
    CGPoint firstPoint = [self.drawKLineModels[startIndex] MA_5PositionPoint];
    NSAssert(!isnan(firstPoint.x) && !isnan(firstPoint.y), @"出现NAN值：MA画线");
    CGContextMoveToPoint(self.context, firstPoint.x, firstPoint.y);
    
    for (NSInteger idx = startIndex + 1; idx < self.drawKLineModels.count ; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] MA_5PositionPoint];
        CGContextAddLineToPoint(self.context, point.x, point.y);
    }
    
    CGContextStrokePath(self.context);
}

- (void)drawMA_10 {
    
    CGContextSetStrokeColorWithColor(self.context, kStockMA10LineColor.CGColor);
    
    CGContextSetLineWidth(self.context, kStockMALineWidth);
    
    // start index
    NSInteger startIndex = 0;
    if ([self.drawKLineModels.firstObject index].integerValue <= kStock_MA_10_N - 1) {
        
        startIndex = kStock_MA_10_N - 1 - [self.drawKLineModels.firstObject index].integerValue;
    }
    
    CGPoint firstPoint = [self.drawKLineModels[startIndex] MA_10PositionPoint];
    NSAssert(!isnan(firstPoint.x) && !isnan(firstPoint.y), @"出现NAN值：MA画线");
    CGContextMoveToPoint(self.context, firstPoint.x, firstPoint.y);
    
    for (NSInteger idx = startIndex + 1; idx < self.drawKLineModels.count ; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] MA_10PositionPoint];
        CGContextAddLineToPoint(self.context, point.x, point.y);
    }
    
    CGContextStrokePath(self.context);
}

- (void)drawMA_20 {
    
    CGContextSetStrokeColorWithColor(self.context, kStockMA20LineColor.CGColor);
    
    CGContextSetLineWidth(self.context, kStockMALineWidth);
    
    // start index
    NSInteger startIndex = 0;
    if ([self.drawKLineModels.firstObject index].integerValue <= kStock_MA_20_N - 1) {
        
        startIndex = kStock_MA_20_N - 1 - [self.drawKLineModels.firstObject index].integerValue;
    }
    
    CGPoint firstPoint = [self.drawKLineModels[startIndex] MA_20PositionPoint];
    NSAssert(!isnan(firstPoint.x) && !isnan(firstPoint.y), @"出现NAN值：MA画线");
    CGContextMoveToPoint(self.context, firstPoint.x, firstPoint.y);
    
    for (NSInteger idx = startIndex + 1; idx < self.drawKLineModels.count ; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] MA_20PositionPoint];
        CGContextAddLineToPoint(self.context, point.x, point.y);
    }
    
    CGContextStrokePath(self.context);
}

#pragma mark - BOLL
- (void)drawBOLL {
    
    [self drawBOLL_UPPER];
    [self drawBOLL_MID];
    [self drawBOLL_LOWER];
}

- (void)drawBOLL_UPPER {
    
    CGContextSetStrokeColorWithColor(self.context, kStockBOOLUpperLineColor.CGColor);
    
    CGContextSetLineWidth(self.context, kStockMALineWidth);
    
    CGPoint firstPoint = [self.drawKLineModels.firstObject BOLL_UpperPositionPoint];
    NSAssert(!isnan(firstPoint.x) && !isnan(firstPoint.y), @"出现NAN值：MA画线");
    CGContextMoveToPoint(self.context, firstPoint.x, firstPoint.y);
    
    for (NSInteger idx = 1; idx < self.drawKLineModels.count ; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] BOLL_UpperPositionPoint];
        CGContextAddLineToPoint(self.context, point.x, point.y);
    }
    
    CGContextStrokePath(self.context);
}

- (void)drawBOLL_MID {
    
    CGContextSetStrokeColorWithColor(self.context, kStockBOOLMidLineColor.CGColor);
    
    CGContextSetLineWidth(self.context, kStockMALineWidth);
    
    CGPoint firstPoint = [self.drawKLineModels.firstObject BOLL_MidPositionPoint];
    NSAssert(!isnan(firstPoint.x) && !isnan(firstPoint.y), @"出现NAN值：MA画线");
    CGContextMoveToPoint(self.context, firstPoint.x, firstPoint.y);
    
    for (NSInteger idx = 1; idx < self.drawKLineModels.count ; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] BOLL_MidPositionPoint];
        CGContextAddLineToPoint(self.context, point.x, point.y);
    }
    
    CGContextStrokePath(self.context);
}

- (void)drawBOLL_LOWER {
    
    CGContextSetStrokeColorWithColor(self.context, kStockBOOLLowerLineColor.CGColor);
    
    CGContextSetLineWidth(self.context, kStockMALineWidth);
    
    CGPoint firstPoint = [self.drawKLineModels.firstObject BOLL_LowerPositionPoint];
    NSAssert(!isnan(firstPoint.x) && !isnan(firstPoint.y), @"出现NAN值：MA画线");
    CGContextMoveToPoint(self.context, firstPoint.x, firstPoint.y);
    
    for (NSInteger idx = 1; idx < self.drawKLineModels.count ; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] BOLL_LowerPositionPoint];
        CGContextAddLineToPoint(self.context, point.x, point.y);
    }
    
    CGContextStrokePath(self.context);
}

@end
