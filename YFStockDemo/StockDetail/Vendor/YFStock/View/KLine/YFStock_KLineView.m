//
//  YFStock_KLineView.m
//  YFStockDemo
//
//  Created by 李友富 on 2017/3/30.
//  Copyright © 2017年 李友富. All rights reserved.
//

#import "YFStock_KLineView.h"
#import "YFStock_Header.h"
#import "YFKline.h"
#import "YFMA_BOLLLine.h"

@interface YFStock_KLineView()

@property (nonatomic, strong) YFStock_DataHandler *dataHandler; // data handler

@end

@implementation YFStock_KLineView


- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // clear
    CGContextClearRect(ctx, rect);
    
    if (!self.dataHandler.drawKLineModels) {
        
        return;
    }
    
    if (self.dataHandler.drawKLineModels.count > 0) {
        
        // K线
        YFKline *line = [[YFKline alloc] initWithContext:ctx drawKLineModels:self.dataHandler.drawKLineModels];
        [line draw];
        
        // MA线或布林线
        YFMA_BOLLLine *MA_BOOLLine = [[YFMA_BOLLLine alloc]initWithContext:ctx];
        [MA_BOOLLine drawWithKLineModels:self.dataHandler.drawKLineModels KLineLineType:YFStockKLineLineType_MA];
//        [MA_BOOLLine drawWithKLineModels:self.dataHandler.drawKLineModels KLineLineType:YFStockKLineLineType_BOLL];
    }
}

- (void)drawWithDataHandler:(YFStock_DataHandler *)dataHandler {
    
    self.dataHandler = dataHandler;
    
    // 不放到主线程里面，会导致卡顿！！！
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//    });
    [self setNeedsDisplay];
}

@end
