

#import "YFKline.h"
#import "YFStock_Header.h"

@interface YFKline()

@property (nonatomic, assign) CGContextRef context; // 父视图的上下文
@property (nonatomic, strong) NSArray <YFStock_KLineModel *>  *drawKLineModels; // 要绘制的K线模型数组

@end

@implementation YFKline

#pragma mark - 初始化
- (instancetype)initWithContext:(CGContextRef)context drawKLineModels:(NSArray <YFStock_KLineModel *>*)drawKLineModels {
    
    self = [super init];
    
    if (self) {
        
        _context = context;
        _drawKLineModels = drawKLineModels;
    }
    return self;
}

#pragma mark - 绘制
- (void)draw {
    
    // security
    if (!self.drawKLineModels || !self.context) return;
    
    CGContextRef ctx = self.context;
    
    // 父视图已经clear
    
    [self.drawKLineModels enumerateObjectsUsingBlock:^(YFStock_KLineModel *KLineModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIColor *strokeColor;
        if (KLineModel.isIncrease) {
            
            strokeColor = kStockIncreaseColor;
        } else {
            
            strokeColor = kStockDecreaseColor;
        }
                
        CGContextSetStrokeColorWithColor(ctx, strokeColor.CGColor);
        
        // 蜡烛
        CGContextSetLineWidth(ctx, [YFStock_Variable KLineWidth]);
        const CGPoint solidPoints[] = { KLineModel.openPricePositionPoint, KLineModel.closePricePositionPoint };
        CGContextStrokeLineSegments(ctx, solidPoints, 2);
        
        // 竖线
        CGContextSetLineWidth(ctx, kStockShadowLineWidth);
        const CGPoint shadowPoints[] = { KLineModel.highPricePositionPoint, KLineModel.lowPricePositionPoint };
        CGContextStrokeLineSegments(ctx, shadowPoints, 2);
        
        // 绘制绿色空心线 - 必须放后面，这样能盖住竖线 - 本质绘制主题色的小一点的蜡烛
        CGFloat gap = 2.0f;
        if ([KLineModel openPrice].floatValue <= [KLineModel closePrice].floatValue && ABS(KLineModel.openPricePositionPoint.y - KLineModel.closePricePositionPoint.y) > gap) { // 涨-红色
            
            CGContextSetStrokeColorWithColor(ctx, kStockThemeColor.CGColor);
            CGContextSetLineWidth(ctx, [YFStock_Variable KLineWidth] - gap);
            const CGPoint solidPoints[] = { CGPointMake(KLineModel.openPricePositionPoint.x, KLineModel.openPricePositionPoint.y - gap * 0.5f), CGPointMake(KLineModel.openPricePositionPoint.x, KLineModel.closePricePositionPoint.y + gap * 0.5f)};
            CGContextStrokeLineSegments(ctx, solidPoints, 2);
        }
    }];
}

@end
