
// KLine

#import <UIKit/UIKit.h>
#import "YFStock_KLineModel.h"

@interface YFKline : UIView

// 初始化
- (instancetype)initWithContext:(CGContextRef)context drawKLineModels:(NSArray <YFStock_KLineModel *>*)drawKLineModels;
// 绘制
- (void)draw;

@end
