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

@property (nonatomic, strong) YFKline *KLine;

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

        // MA线或布林线
        YFMA_BOLLLine *MA_BOOLLine = [[YFMA_BOLLLine alloc]initWithContext:ctx];
        [MA_BOOLLine drawWithKLineModels:self.dataHandler.drawKLineModels KLineLineType:YFStockKLineLineType_MA];
//        [MA_BOOLLine drawWithKLineModels:self.dataHandler.drawKLineModels KLineLineType:YFStockKLineLineType_BOLL];
    }
}

- (void)drawWithDataHandler:(YFStock_DataHandler *)dataHandler {
    
    self.dataHandler = dataHandler;
    
    [self setNeedsDisplay];
    [self.KLine drawWithDrawKLineModels:self.dataHandler.drawKLineModels];
}

- (YFKline *)KLine {
    
    if (_KLine == nil) {
       
        _KLine = [[YFKline alloc] initWithFrame:self.bounds];
        [self addSubview:_KLine];
    }
    
    return _KLine;
}

@end
