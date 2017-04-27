

#import "YFMA_BOLLLine.h"

@interface YFMA_BOLLLine()

@property (nonatomic, strong) NSArray *drawKLineModels;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;


@end

@implementation YFMA_BOLLLine

- (CAShapeLayer *)shapeLayer {
    
    if (_shapeLayer == nil) {
        
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.frame = self.layer.bounds;
        _shapeLayer.backgroundColor = kClearColor.CGColor;
        [self.layer addSublayer:_shapeLayer];
    }
    return _shapeLayer;
}

#pragma mark - draw
- (void)drawWithKLineModels:(NSArray<YFStock_KLineModel *> *)drawKLineModels KLineLineType:(YFStockKLineLineType)KLineLineType {

    if(!drawKLineModels || drawKLineModels.count == 0) {

        return;
    }
    
    if (_shapeLayer) {
        
        [_shapeLayer removeFromSuperlayer];
        _shapeLayer = nil;
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
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = kStockPartLineHeight;
    
    // start index
    NSInteger startIndex = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_MA_5_N];
    CGPoint firstPoint = [self.drawKLineModels[startIndex] MA_5PositionPoint];
    NSAssert(!isnan(firstPoint.x) && !isnan(firstPoint.y), @"出现NAN值：MA画线");
    
    [path moveToPoint:firstPoint];
    
    for (NSInteger idx = startIndex + 1; idx < self.drawKLineModels.count ; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] MA_5PositionPoint];
        [path addLineToPoint:point];
    }

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = kStockMA5LineColor.CGColor;
    shapeLayer.fillColor = kClearColor.CGColor;
    shapeLayer.path = path.CGPath;
    shapeLayer.frame = self.shapeLayer.bounds;
    shapeLayer.backgroundColor = kClearColor.CGColor;
    [self.shapeLayer addSublayer:shapeLayer];
}

- (void)drawMA_10 {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = kStockPartLineHeight;
    
    // start index
    NSInteger startIndex = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_MA_10_N];
    
    CGPoint firstPoint = [self.drawKLineModels[startIndex] MA_10PositionPoint];
    NSAssert(!isnan(firstPoint.x) && !isnan(firstPoint.y), @"出现NAN值：MA画线");
    
    [path moveToPoint:firstPoint];
        
    for (NSInteger idx = startIndex + 1; idx < self.drawKLineModels.count ; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] MA_10PositionPoint];
        [path addLineToPoint:point];
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = kStockMA10LineColor.CGColor;
    shapeLayer.fillColor = kClearColor.CGColor;
    shapeLayer.path = path.CGPath;
    shapeLayer.frame = self.shapeLayer.bounds;
    shapeLayer.backgroundColor = kClearColor.CGColor;
    [self.shapeLayer addSublayer:shapeLayer];
}

- (void)drawMA_20 {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = kStockPartLineHeight;
    
    // start index
    NSInteger startIndex = [self getStartIndexWithDrawKLineModels:self.drawKLineModels N:kStock_MA_20_N];
    
    CGPoint firstPoint = [self.drawKLineModels[startIndex] MA_20PositionPoint];
    NSAssert(!isnan(firstPoint.x) && !isnan(firstPoint.y), @"出现NAN值：MA画线");
    
    [path moveToPoint:firstPoint];
    
    for (NSInteger idx = startIndex + 1; idx < self.drawKLineModels.count ; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] MA_20PositionPoint];
        [path addLineToPoint:point];
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = kStockMA20LineColor.CGColor;
    shapeLayer.fillColor = kClearColor.CGColor;
    shapeLayer.path = path.CGPath;
    shapeLayer.frame = self.shapeLayer.bounds;
    shapeLayer.backgroundColor = kClearColor.CGColor;
    [self.shapeLayer addSublayer:shapeLayer];
}

#pragma mark - BOLL
- (void)drawBOLL {
    
    [self drawBOLL_UPPER];
    [self drawBOLL_MID];
    [self drawBOLL_LOWER];
}

- (void)drawBOLL_UPPER {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = kStockPartLineHeight;
    
    CGPoint firstPoint = [self.drawKLineModels.firstObject BOLL_UpperPositionPoint];
    NSAssert(!isnan(firstPoint.x) && !isnan(firstPoint.y), @"出现NAN值：MA画线");
    
    [path moveToPoint:firstPoint];
    
    for (NSInteger idx = 1; idx < self.drawKLineModels.count ; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] BOLL_UpperPositionPoint];
        [path addLineToPoint:point];
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = kStockMA5LineColor.CGColor;
    shapeLayer.fillColor = kClearColor.CGColor;
    shapeLayer.path = path.CGPath;
    shapeLayer.frame = self.shapeLayer.bounds;
    shapeLayer.backgroundColor = kClearColor.CGColor;
    [self.shapeLayer addSublayer:shapeLayer];
}

- (void)drawBOLL_MID {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = kStockPartLineHeight;
    
    CGPoint firstPoint = [self.drawKLineModels.firstObject BOLL_MidPositionPoint];
    NSAssert(!isnan(firstPoint.x) && !isnan(firstPoint.y), @"出现NAN值：MA画线");
    
    [path moveToPoint:firstPoint];
    
    for (NSInteger idx = 1; idx < self.drawKLineModels.count ; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] BOLL_MidPositionPoint];
        [path addLineToPoint:point];
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = kStockMA10LineColor.CGColor;
    shapeLayer.fillColor = kClearColor.CGColor;
    shapeLayer.path = path.CGPath;
    shapeLayer.frame = self.shapeLayer.bounds;
    shapeLayer.backgroundColor = kClearColor.CGColor;
    [self.shapeLayer addSublayer:shapeLayer];
}

- (void)drawBOLL_LOWER {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = kStockPartLineHeight;
    
    CGPoint firstPoint = [self.drawKLineModels.firstObject BOLL_LowerPositionPoint];
    NSAssert(!isnan(firstPoint.x) && !isnan(firstPoint.y), @"出现NAN值：MA画线");
    
    [path moveToPoint:firstPoint];
    
    for (NSInteger idx = 1; idx < self.drawKLineModels.count ; idx++) {
        
        CGPoint point = [self.drawKLineModels[idx] BOLL_LowerPositionPoint];
        [path addLineToPoint:point];
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = kStockMA20LineColor.CGColor;
    shapeLayer.fillColor = kClearColor.CGColor;
    shapeLayer.path = path.CGPath;
    shapeLayer.frame = self.shapeLayer.bounds;
    shapeLayer.backgroundColor = kClearColor.CGColor;
    [self.shapeLayer addSublayer:shapeLayer];
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
