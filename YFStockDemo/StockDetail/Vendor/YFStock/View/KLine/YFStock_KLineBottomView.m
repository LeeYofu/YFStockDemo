//
//  YFStock_KLineVolumeView.m
//  YFStockDemo
//
//  Created by 李友富 on 2017/3/30.
//  Copyright © 2017年 李友富. All rights reserved.
//

#import "YFStock_KLineBottomView.h"
#import "YFStock_KLineBottomLine.h"

@interface YFStock_KLineBottomView()

@property (nonatomic, strong) YFStock_DataHandler *dataHandler;
@property (nonatomic, assign) YFStockBottomBarIndex bottomSelectedIndex;

@end

@implementation YFStock_KLineBottomView


- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(ctx, rect);
    
    if (!self.dataHandler.drawKLineModels) {
        
        return;
    }
    
    if (self.dataHandler.drawKLineModels.count > 0) {
     
        YFStock_KLineBottomLine *line = [[YFStock_KLineBottomLine alloc] initWithContext:ctx drawKLineModels:self.dataHandler.drawKLineModels];
        [line drawWithBottomBarSelectedIndex:self.bottomSelectedIndex];
    }
}

- (void)drawWithDataHandler:(YFStock_DataHandler *)dataHandler bottomBarSelectedIndex:(NSInteger)bottomBarSelectedIndex {
    
    self.dataHandler = dataHandler;
    self.bottomSelectedIndex = bottomBarSelectedIndex;
    
    // 不放到主线程里面，会导致卡顿！！！
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//    });
    [self setNeedsDisplay];
}

@end
