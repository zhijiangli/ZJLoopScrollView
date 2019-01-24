//
//  ZJLoopScrollView.h
//  OC_Project
//
//  Created by 小黎 on 2018/12/18.
//  Copyright © 2018年 ZJ. All rights reserved.
//

#import <UIKit/UIKit.h>
/** 方向*/
typedef enum : NSUInteger {
    // 不 自 动 循 环(即不开启定时器)
    ZJLoopScrollDirectionNone        = 0,
    // 从 右 往 左 自 动 循 环
    ZJLoopScrollDirectionRightToLeft = 1,
    // 从 左 往 右 自 动 循 环
    ZJLoopScrollDirectionLeftToRight = 2,
} ZJLoopScrollDirection;
/** 样式*/
typedef enum : NSUInteger {
    // 默 认 平 滑
    ZJLoopScrollStyleNone = 0,
    // 缩 放 动 画
    ZJLoopScrollStyleZoom = 1,
} ZJLoopScrollStyle;
/** 样式*/
@class ZJLoopScrollView;
@protocol ZJLoopScrollViewDelegate <NSObject>
@optional
/** 点击时当前显示*/
-(void)scrollView:(ZJLoopScrollView*)scrollView didSelectSubviewAtIndex:(NSInteger)index;
/** 停止时当前显示*/
-(void)scrollView:(ZJLoopScrollView*)scrollView didEndDeceleratingAtIndex:(NSInteger)index;
@end
/** 图片无限循环*/
@interface ZJLoopScrollView : UIView
@property(nonatomic,weak)   id<ZJLoopScrollViewDelegate> delegate;
@property(nonatomic,assign) ZJLoopScrollDirection scrollDirection;
@property(nonatomic,assign) ZJLoopScrollStyle     scrollStyle;
- (void)showImagesWithImageStrs:(NSArray<NSString*>*)imageStrs;
- (void)showDefaultCurrentIndex:(NSInteger)currentIndex;
/** 回调方法*/
- (void)didSelectSubviewAtIndex:(void(^)(NSInteger index))block;
- (void)didEndDeceleratingAtIndex:(void(^)(NSInteger index))block;
@end
