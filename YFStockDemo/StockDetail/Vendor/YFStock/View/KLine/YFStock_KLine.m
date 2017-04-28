//
//  YFStock_KLineView.m
//  YFStockDemo
//
//  Created by 李友富 on 2017/3/30.
//  Copyright © 2017年 李友富. All rights reserved.
//

#import "YFStock_KLine.h"
#import "YFStock_ScrollView.h"
#import "YFStock_KLineView.h"
#import "YFStock_KLineBottomView.h"
#import "YFStock_TimeView.h"
#import "YFStock_KLineMaskView.h"
#import "YFStock_DataHandler.h"
#import "YFStock_TopBar.h"

@interface YFStock_KLine() <UIScrollViewDelegate, YFStock_TopBarDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *allKLineModels; // 所有的K线模型
@property (nonatomic, assign) CGFloat lastContentOffsetX; // 上一次scrollView滚动的contentOffsetX（滚动量大于K线的宽度加空隙才记录）
@property (nonatomic, strong) NSMutableArray *KLineRightValueLabels; // 左侧的数值label数组
@property (nonatomic, strong) NSMutableArray *bottomRightValueLabels;
@property (nonatomic, strong) YFStock_DataHandler *dataHandler; // dataHandler
@property (nonatomic, assign) YFStockBottomBarIndex bottomBarIndex;
@property (nonatomic, assign) CGFloat lastPinchScale;
@property (nonatomic, assign) CGFloat lastTowTouchDistance;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;

@property (nonatomic, strong) YFStock_ScrollView *scrollView; // scrollView
@property (nonatomic, strong) YFStock_KLineView *KLineView; // 真正的K线view
@property (nonatomic, strong) YFStock_KLineBottomView *bottomView; // 真正的bottomView
@property (nonatomic, strong) YFStock_TimeView *timeView; // 真正的时间view
@property (nonatomic, strong) YFStock_KLineMaskView *maskView; // 长按手势遮罩view（十字线）
@property (nonatomic, strong) UILabel *showMALabel; // showMALabel
@property (nonatomic, strong) YFStock_TopBar *bottomBar; // bottomBar

@end

@implementation YFStock_KLine

#pragma mark - 初始化
- (YFStock_KLine *)initWithFrame:(CGRect)frame allKLineModels:(NSArray<YFStock_KLineModel *> *)allKLineModels {
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = kClearColor;
        
        self.allKLineModels = allKLineModels;
        
        [self createSubviews];
    }
    return self;
}

#pragma mark - 布局子视图
- (void)createSubviews {
    
    [self createScrollView];
    [self createKLineView_VolumeView];
    [self createTimeView];
    [self createBottomBar];
    [self createRightValueLabels];
    [self createShowMALabel];
}

- (void)createScrollView {
    
    // scrollView 跟 self视图 是有上线左右 间距 的
    self.scrollView = [[YFStock_ScrollView alloc] initWithFrame:CGRectMake(kStockKLineScrollViewLeftGap, kStockKLineScrollViewTopGap, self.width - kStockKLineScrollViewLeftGap - kStockKLineScrollViewRightGap, self.height - kStockKLineScrollViewTopGap - kStockKLineScrollViewBottomGap)];
    self.scrollView.delegate = self;
    self.scrollView.stockLineType = YFStockLineTypeKLine;
    [self addSubview:self.scrollView];
    
    // 缩放
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(event_pinchAction:)];
    pinch.delegate = self;
    [self.scrollView addGestureRecognizer:pinch];
    
    // 长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(event_longPressAction:)];
    longPress.minimumPressDuration = 0.2f;
    [self.scrollView addGestureRecognizer:longPress];
    
    self.pinchGesture = pinch;
    self.longPressGesture = longPress;
}

- (void)createKLineView_VolumeView {
    
    // k线视图、volume视图、time视图 都是加到 scrollView 上
    CGFloat KlineViewVolumeViewTotalHeight = self.scrollView.height - kStockTimeViewHeight - kStockBottomBarHeight;
    CGFloat KlineViewHeight = KlineViewVolumeViewTotalHeight * (1 - [YFStock_Variable KlineVolumeViewHeightRadio]);
    CGFloat volumeViewHeight = KlineViewVolumeViewTotalHeight - KlineViewHeight;
    
    self.KLineView = [[YFStock_KLineView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.width, KlineViewHeight)];
    self.KLineView.backgroundColor = kClearColor;
    [self.scrollView addSubview:self.KLineView];
    
    self.bottomView = [[YFStock_KLineBottomView alloc] initWithFrame:CGRectMake(0, self.scrollView.height - volumeViewHeight, self.scrollView.width, volumeViewHeight)];
    self.bottomView.backgroundColor = kClearColor;
    [self.scrollView addSubview:self.bottomView];
}

- (void)createTimeView {
    
    self.timeView = [[YFStock_TimeView alloc] initWithFrame:CGRectMake(self.KLineView.x, self.KLineView.maxY, self.KLineView.width, 15)]; // height ktimeviewheight
    self.timeView.backgroundColor = kClearColor;
    [self.scrollView addSubview:self.timeView];
}

- (void)createRightValueLabels {
    
    [self.KLineRightValueLabels removeAllObjects];
    [self.bottomRightValueLabels removeAllObjects];
    
    // KLine
    // 添加到self上
    CGFloat unitHeight = (self.KLineView.height - 2 * kStockKLineScrollViewInsideTopBottomPadding) / [YFStock_Variable KLineRowCount];
    CGFloat labelH = 16;
    CGFloat y = self.scrollView.y - labelH * 0.5 + kStockPartLineHeight + kStockKLineScrollViewInsideTopBottomPadding;
    for (int i = 0; i < [YFStock_Variable KLineRowCount] + 1; i ++) {
        
        UILabel *label = [UILabel new];
        CGFloat labelW = 60;
        label.frame = CGRectMake(self.width - labelW - 2, y, labelW, labelH);
        label.font = kFont_9;
        label.textColor = kCustomRGBColor(103, 103, 103, 1.0f);
        label.textAlignment = NSTextAlignmentRight;
        [self addSubview:label];
        
        y += unitHeight;
        
        // label加到label数组里，以后要取出来用的
        [self.KLineRightValueLabels addObject:label];
    }
    
    // Bottom
    for (int i = 0; i < 2; i ++) {
        
        UILabel *label = [UILabel new];
        CGFloat labelW = 60;
        label.font = kFont_9;
        label.textColor = kCustomRGBColor(103, 103, 103, 1.0f);
        label.textAlignment = NSTextAlignmentRight;
        [self addSubview:label];
        
        if (i == 0) {
            
            label.frame = CGRectMake(self.width - labelW - 2, self.bottomView.y + kStockKLineScrollViewTopGap, labelW, labelH);
        } else if (i == 1) {
            
            label.frame = CGRectMake(self.width - labelW - 2, self.bottomView.y + kStockKLineScrollViewTopGap + self.bottomView.height - labelH, labelW, labelH);
        } else {
            
            
        }
        
        [self.bottomRightValueLabels addObject:label];
    }
}

- (void)createShowMALabel {
    
    self.showMALabel = [UILabel new];
    self.showMALabel.frame = CGRectMake(5, self.scrollView.y, self.width, kStockKLineScrollViewInsideTopBottomPadding);
    self.showMALabel.font = kFont_9;
    [self addSubview:self.showMALabel];
}

- (void)createBottomBar {
    
    self.bottomBar = [[YFStock_TopBar alloc] initWithFrame:CGRectMake(0, self.timeView.maxY + kStockKLineScrollViewTopGap, self.width, kStockBottomBarHeight) titles:@[ @"MACD", @"KDJ", @"RSI", @"ARBR", @"OBV", @"WR", @"EMV", @"DMA", @"CCI" ] topBarSelectedIndex:0];
    self.bottomBar.delegate = self;
    [self addSubview:self.bottomBar];
}

#pragma mark - 重绘
- (void)reDrawWithAllKLineModels:(NSArray<YFStock_KLineModel *> *)allKLineModels {
    
    self.allKLineModels = allKLineModels;
    
    [self updateScrollViewContentWidth];
    [self updateKLineViewAndVolumeViewAndTimeViewFrame];
    
    [self setNeedsDisplay];
    
    if (self.allKLineModels.count > 0) { // scrollView滚动到头
        
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentSize.width - self.scrollView.width, self.scrollView.contentOffset.y);
    }
}

- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    // security
    if (self.allKLineModels.count > 0) {
        
        if (!_maskView || _maskView.isHidden) { // 不是 长按 等状态
            
            // 更新需要绘制的模型
            [self updateDrawKLineModels];
            
            // 回调或者说是通知主线程刷新
            // 更新背景线（还是调动drawrect方法，但是对整体性能影响不大！！！！）
            [self.scrollView drawWithDataHandler:self.dataHandler KLineViewHeight:self.KLineView.height bottomViewY:self.bottomView.y];
            
            // 绘制K线上部分
            [self.KLineView drawWithDataHandler:self.dataHandler];
            
            // 绘制底部线条
            [self.bottomView drawWithDataHandler:self.dataHandler bottomBarSelectedIndex:self.bottomBarIndex];
            
            // 绘制左边的数值
            [self drawRightDesc];
            
            // 绘制时间
            [self.timeView drawWithDataHandler:self.dataHandler];
            
            // 绘制左上角展示MA数值的Label
            [self drawShowMALabelTextWithSelectedKLineModel:self.dataHandler.drawKLineModels.lastObject];
        }
    }
}

- (void)drawRightDesc {
    
    // KLine
    // K线原始单位高度
    CGFloat unitValue = (self.dataHandler.maxKLineValue - self.dataHandler.minKLineValue) / [YFStock_Variable KLineRowCount];
    // 便利赋值
    for (int i = 0; i < [YFStock_Variable KLineRowCount] + 1; i++) {
        
        NSString *text = [NSString stringWithFormat:@"%.2f",self.dataHandler.maxKLineValue - unitValue * i];
        UILabel *label = self.KLineRightValueLabels[i];
        label.text = text;
    }
    
    // Bottom
    // MACD
    //    CGFloat MACDUintValue = (self.dataHandler.MACDMaxValue - self.dataHandler.MACDMinValue) / (self.bottomRightValueLabels.count - 1);
    //    for (int i = 0; i < self.bottomRightValueLabels.count; i ++) {
    //
    //        NSString *text = [NSString stringWithFormat:@"%.2f",self.dataHandler.MACDMaxValue - MACDUintValue * i];
    //        UILabel *label = self.bottomRightValueLabels[i];
    //        label.text = text;
    //    }
    
    // MACD
    CGFloat KDJUintValue = (self.dataHandler.KDJMaxValue - self.dataHandler.KDJMinValue) / (self.bottomRightValueLabels.count - 1);
    for (int i = 0; i < self.bottomRightValueLabels.count; i ++) {
        
        NSString *text = [NSString stringWithFormat:@"%.2f",self.dataHandler.KDJMaxValue - KDJUintValue * i];
        UILabel *label = self.bottomRightValueLabels[i];
        label.text = text;
    }
}

- (void)drawShowMALabelTextWithSelectedKLineModel:(YFStock_KLineModel *)selectedKLineModel {
    
    NSString *MA5Str = [NSString stringWithFormat:@"MA5:%.2f  ", selectedKLineModel.MA_5.floatValue];
    NSString *MA10Str = [NSString stringWithFormat:@"MA10:%.2f  ", selectedKLineModel.MA_10.floatValue];
    NSString *MA20Str = [NSString stringWithFormat:@"MA20:%.2f  ", selectedKLineModel.MA_20.floatValue];
    
    NSString *MAStr = [NSString stringWithFormat:@"%@%@%@", MA5Str, MA10Str, MA20Str];
    
    NSMutableAttributedString *MAAttrStrM = [[NSMutableAttributedString alloc] initWithString:MAStr];
    [MAAttrStrM addAttributes:@{ NSForegroundColorAttributeName : kStockMA5LineColor } range:NSMakeRange(0, MA5Str.length)];
    [MAAttrStrM addAttributes:@{ NSForegroundColorAttributeName : kStockMA10LineColor } range:NSMakeRange(MA5Str.length - 1, MA10Str.length)];
    [MAAttrStrM addAttributes:@{ NSForegroundColorAttributeName : kStockMA20LineColor } range:NSMakeRange(MA5Str.length + MA10Str.length - 1, MA20Str.length)];
    
    self.showMALabel.attributedText = MAAttrStrM;
}

#pragma mark - 更新需要绘制的模型数组
- (void)updateDrawKLineModels {
    
    // 数组初始下标
    NSInteger startIndex = [self startIndex];
    
    // 可见范围内需要绘制K线的个数
    NSInteger drawKLineCount = self.scrollView.width / ([YFStock_Variable KLineWidth] + [YFStock_Variable KLineGap]);
    
    // 截取数组长度
    NSInteger length = startIndex + drawKLineCount > self.allKLineModels.count ? self.allKLineModels.count - startIndex : drawKLineCount + 3;
    
    if (length > self.allKLineModels.count - startIndex) {
        
        length = self.allKLineModels.count - startIndex;
    }
    
    // 截取当前区域需要绘制的数组
    NSArray *drawKLineModels = [self.allKLineModels subarrayWithRange:NSMakeRange(startIndex, length)];
    
    // 处理此数组
    [self.dataHandler handleKLineModelDatasWithDrawKlineModelArray:drawKLineModels pointStartX:[self xPosition] KLineViewHeight:self.KLineView.height volumeViewHeight:self.bottomView.height];
}

#pragma mark - 获取数组startIndex/scrollView的xPosition
- (NSInteger)startIndex {
    
    // 数组startIndex = scrollView左边之前K线个数
    // 获取scrollView的 contentOffsetX值
    CGFloat offsetX = self.scrollView.contentOffset.x < 0 ? 0 : self.scrollView.contentOffset.x;
    
    // scrollView左边之前K线的个数
    NSInteger leftCount = ABS(offsetX / ([YFStock_Variable KLineWidth] + [YFStock_Variable KLineGap]));
    // security
    if (leftCount > self.allKLineModels.count - 1) {
        
        leftCount = self.allKLineModels.count - 1;
    }
    return leftCount;
}

- (NSInteger)xPosition {
    
    // 返回值类型为整数类型[scrollView左侧之前K线个数]
    NSInteger leftCount = [self startIndex];
    // startXPosition
    CGFloat startXPosition = leftCount * ([YFStock_Variable KLineWidth] + [YFStock_Variable KLineGap]);
    return startXPosition + [YFStock_Variable KLineWidth] * 0.5f;
}

#pragma mark - 更新contentSize和frame
- (CGFloat)updateScrollViewContentWidth {
    
    // 根据stockModels的个数和间隔和K线的宽度计算出self的宽度，并设置contentsize
    CGFloat kLineViewWidth = self.allKLineModels.count * [YFStock_Variable KLineWidth] + (self.allKLineModels.count - 1) * [YFStock_Variable KLineGap];
    
    if(kLineViewWidth < self.scrollView.width) {
        
        kLineViewWidth = self.scrollView.width;
    }
    
    // 更新scrollview的contentsize
    self.scrollView.contentSize = CGSizeMake(kLineViewWidth, self.scrollView.contentSize.height);
    
    return kLineViewWidth;
}

- (void)updateKLineViewAndVolumeViewAndTimeViewFrame {
    
    self.KLineView.frame = CGRectMake(self.KLineView.x, self.KLineView.y, self.scrollView.contentSize.width, self.KLineView.height);
    self.bottomView.frame = CGRectMake(self.bottomView.x, self.bottomView.y, self.scrollView.contentSize.width, self.bottomView.height);
    self.timeView.frame = CGRectMake(self.timeView.x, self.timeView.y, self.scrollView.contentSize.width, self.timeView.height);
}

#pragma mark - 长按、缩放事件
- (void)event_longPressAction:(UILongPressGestureRecognizer *)longPress {
    
    __block YFStock_KLineModel *selectedKLineModel;
    
    // 开始+数值改变状态
    if(UIGestureRecognizerStateChanged == longPress.state || UIGestureRecognizerStateBegan == longPress.state) {
        
        // 获取location
        CGPoint location = [longPress locationInView:self.scrollView];
        // security
        if (location.x < 0 || location.x > self.scrollView.contentSize.width) return;
        
        [self.dataHandler.drawKLineModels enumerateObjectsUsingBlock:^(YFStock_KLineModel *KLineModel, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CGPoint closePoint = KLineModel.closePricePositionPoint;
            CGFloat closePointX = closePoint.x;
            CGFloat touchPointX = location.x;
            int closeIntX = (int)closePointX;
            int touchIntX = (int)touchPointX;
            
            if (touchIntX == closeIntX || ABS(touchPointX - closePointX) <= ([YFStock_Variable KLineWidth] + [YFStock_Variable KLineGap]) * 0.5f) {
                
                selectedKLineModel = KLineModel;
            } else {
                
                if (touchPointX > self.dataHandler.drawKLineModels.lastObject.closePricePositionPoint.x) {
                    
                    selectedKLineModel = self.dataHandler.drawKLineModels.lastObject;
                }
            }
            
            // 显示十字线-重置十字线frame等
            self.maskView.hidden = NO;
            self.maskView.selectedKLineModel = selectedKLineModel;
            self.maskView.scrollView = self.scrollView;
            [self.maskView resetLineFrame];
            
            [self drawShowMALabelTextWithSelectedKLineModel:KLineModel];
        }];
    }
    
    // 结束、取消等状态
    if(longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateCancelled || longPress.state == UIGestureRecognizerStateFailed) {
        
        // 隐藏十字线
        self.maskView.hidden = YES;
        
        selectedKLineModel = nil;
        
        [self drawShowMALabelTextWithSelectedKLineModel:self.dataHandler.drawKLineModels.lastObject];
    }
    
    // 将选中的model传给stock，用于topbarmaskview的数据展示
    if (self.delegate && [self.delegate respondsToSelector:@selector(YFStockKLine:didSelectedKLineModel:)]) {
        
        [self.delegate YFStockKLine:self didSelectedKLineModel:selectedKLineModel];
    }
}

- (void)event_pinchAction:(UIPinchGestureRecognizer *)pinch {
        
    if (pinch.state == UIGestureRecognizerStateBegan) {
        
        self.longPressGesture.enabled = NO;
        self.scrollView.scrollEnabled = NO;
    }
    
    if (pinch.state == UIGestureRecognizerStateEnded) {
        
        self.longPressGesture.enabled = YES;
        self.scrollView.scrollEnabled = YES;
    }
    
    if(pinch.numberOfTouches == 2) {
        
        // 获取捏合中心点 -> 捏合中心点距离scrollviewcontent左侧的距离
        CGPoint p1 = [pinch locationOfTouch:0 inView:self.scrollView];
        CGPoint p2 = [pinch locationOfTouch:1 inView:self.scrollView];
        CGFloat centerX = (p1.x + p2.x) / 2;
        
        CGFloat twoTouchDistance = ABS(p1.x - p2.x);
        
        if (pinch.state == UIGestureRecognizerStateBegan || self.lastTowTouchDistance == -1) {
            
            self.lastTowTouchDistance = twoTouchDistance;
        }
        
        if (pinch.state == UIGestureRecognizerStateChanged) {
            
            CGFloat distanchChanged = twoTouchDistance - self.lastTowTouchDistance;
            
            distanchChanged /= 15;
            
            // 拿到中心点数据源的index  CGFloat!!!
            CGFloat oldLeftArrCount = ABS(centerX / ([YFStock_Variable KLineWidth] + [YFStock_Variable KLineGap]));
            
            // 缩放重绘
            CGFloat newLineWidth = 0;
            
            newLineWidth = [YFStock_Variable KLineWidth] + distanchChanged;
            
            [YFStock_Variable setKLineWidth:newLineWidth];
            
            // 计算更新宽度后捏合中心点距离klineView最左侧（x = 0）的距离
            CGFloat newLeftDistance = oldLeftArrCount * ([YFStock_Variable KLineWidth] + [YFStock_Variable KLineGap]);
            
            // 设置scrollview的contentoffset = (5) - (2);
            if (self.allKLineModels.count * [YFStock_Variable KLineWidth] + (self.allKLineModels.count - 1) * [YFStock_Variable KLineGap] > self.scrollView.bounds.size.width) {
                
                CGFloat newOffsetX = newLeftDistance - (centerX - self.scrollView.contentOffset.x);
                self.scrollView.contentOffset = CGPointMake(newOffsetX > 0 ? newOffsetX : 0 , self.scrollView.contentOffset.y);
            } else {
                
                self.scrollView.contentOffset = CGPointMake(0 , self.scrollView.contentOffset.y);
            }
            
            // 更新contentsize
            [self updateScrollViewContentWidth];
            [self updateKLineViewAndVolumeViewAndTimeViewFrame];
            
            // 间接调用重绘方法
            [self setNeedsDisplay];
            
            self.lastTowTouchDistance = twoTouchDistance;
        }
    } else {
        
        self.lastTowTouchDistance = -1;
    }
}

#pragma mark - 代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self setNeedsDisplay];
    
    //    if (self.scrollView.contentOffset.x <= 0) {
    //
    //        NSLog(@"滚动最左边了，需要请求新的数据");
    //
    //        // test
    //        CGFloat lastContentOffsetX = self.scrollView.contentOffset.x;
    //        CGFloat lastContentSizeWidth = self.scrollView.contentSize.width;
    //        NSMutableArray *tempArray = [self.allKLineModels mutableCopy];
    //        [tempArray addObjectsFromArray:self.allKLineModels];
    //        [self reDrawWithAllKLineModels:tempArray];
    //
    //        [self.scrollView setContentOffset:CGPointMake(lastContentOffsetX + (self.scrollView.contentSize.width - lastContentSizeWidth), self.scrollView.contentOffset.y)];
    //
    //        NSLog(@"tempArray.count = %ld", tempArray.count);
    //
    //    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

- (void)YFStock_TopBar:(YFStock_TopBar *)topBar didSelectedItemAtIndex:(NSInteger)index {
    
    self.bottomBarIndex = index;
    
    // redraw
    [self.bottomView drawWithDataHandler:self.dataHandler bottomBarSelectedIndex:self.bottomBarIndex];
}

#pragma mark - lazy loading
- (NSArray *)allKLineModels {
    
    if (_allKLineModels == nil) {
        
        _allKLineModels = [NSArray new];
    }
    return _allKLineModels;
}

- (NSMutableArray *)KLineRightValueLabels {
    
    if (_KLineRightValueLabels == nil) {
        
        _KLineRightValueLabels = [NSMutableArray new];
    }
    return _KLineRightValueLabels;
}

- (NSMutableArray *)bottomRightValueLabels {
    
    if (_bottomRightValueLabels == nil) {
        
        _bottomRightValueLabels = [NSMutableArray new];
    }
    return _bottomRightValueLabels;
}

- (UIView *)maskView {
    
    if (_maskView == nil) {
        
        _maskView = [[YFStock_KLineMaskView alloc] initWithFrame:self.scrollView.frame];
        [self addSubview:_maskView];
    }
    return _maskView;
}

- (YFStock_DataHandler *)dataHandler {
    
    if (_dataHandler == nil) {
        
        _dataHandler = [YFStock_DataHandler dataHandler];
    }
    return _dataHandler;
}

@end
