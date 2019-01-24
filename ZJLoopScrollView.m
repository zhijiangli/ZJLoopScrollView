//
//  ZJLoopScrollView.m
//  OC_Project
//
//  Created by 小黎 on 2018/12/18.
//  Copyright © 2018年 ZJ. All rights reserved.
//

#import "ZJLoopScrollView.h"
@interface ZJLoopScrollView ()<UIScrollViewDelegate>
@property(nonatomic,strong) NSMutableArray <NSString*>* imageStrs;
@property(nonatomic,assign) NSInteger    currentIndex;
@property(nonatomic,weak) UIScrollView * scrollview;
@property(nonatomic,weak) UIImageView  * leftImgView;
@property(nonatomic,weak) UIImageView  * centerImgView;
@property(nonatomic,weak) UIImageView  * rightImgView;
@property(nonatomic,strong) dispatch_source_t timer;;
@property(nonatomic,copy) void(^didSelectSubviewAtIndexBlock)(NSInteger index);
@property(nonatomic,copy) void(^didEndDeceleratingAtIndexBlock)(NSInteger index);
@end
@implementation ZJLoopScrollView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setSubViews];
    }
    return self;
}
-(void)setSubViews{
    CGRect subframe = CGRectMake(0, 0, CGRectGetWidth([self frame]), CGRectGetHeight([self frame]));
    UIScrollView * scroll = [[UIScrollView alloc] initWithFrame:subframe];
    [scroll setBounces:false];
    [scroll setPagingEnabled:true];
    [scroll setShowsVerticalScrollIndicator:false];
    [scroll setShowsHorizontalScrollIndicator:false];
    [scroll setHidden:true];
    [self addSubview:scroll];
    [self setScrollview:scroll];
    
    for(int i=0;i<3;i++){
        CGRect subframe = CGRectMake(CGRectGetWidth([scroll frame])*i, 0, CGRectGetWidth([scroll frame]), CGRectGetHeight([scroll frame]));
        UIImageView * subview01 = [[UIImageView alloc] initWithFrame:subframe];
        [subview01 setContentMode:UIViewContentModeScaleAspectFit];
        CGFloat arcNum = arc4random_uniform(255)/255.0;
        UIColor * color = [UIColor colorWithRed:arcNum green:arcNum blue:arcNum alpha:1];
        [subview01 setBackgroundColor:color];
        [scroll addSubview:subview01];
        if(i==0){[self setLeftImgView:subview01];}
        if(i==1){[self setCenterImgView:subview01];}
        if(i==2){[self setRightImgView:subview01];}
    }
    [scroll bringSubviewToFront:[self leftImgView]];
    [scroll sendSubviewToBack:[self rightImgView]];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [self addGestureRecognizer:tap];
}
-(void)tapClick{
    if([self delegate] && [[self delegate] respondsToSelector:@selector(scrollView:didSelectSubviewAtIndex:)]){
        [[self delegate] scrollView:self didSelectSubviewAtIndex:[self currentIndex]];
    }
    if([self didSelectSubviewAtIndexBlock]){
        self.didSelectSubviewAtIndexBlock([self currentIndex]);
    }
}
-(void)refreshScrollImagesLayoutWithImageStrs:(NSArray*)imageStrs{
    if(imageStrs.count<1){return;}
    [[self scrollview] setHidden:false];
    [self setImageStrs:[NSMutableArray arrayWithArray:imageStrs]];
    [self setCurrentIndex:0];
    if([imageStrs count]==0){
        [[self scrollview] setDelegate:nil];
    }else if([imageStrs count] ==1){
        [[self scrollview] setDelegate:nil];
    }else{
        [[self scrollview] setDelegate:self];
        [[self scrollview] setContentSize:CGSizeMake(CGRectGetWidth([self frame])*3, 0)];
        [[self scrollview] setContentOffset:CGPointMake(CGRectGetWidth([self frame]), 0)];
    }
}
#pragma mark -  UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self refrshScrollImageViewAndCurrentIndex];
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self refrshScrollImageViewAndCurrentIndex];
}
//开始拖动的时候调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self cancelTimer];
}
//结束拖动时调用
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self openTimer];
}
#pragma mark -
-(void)refrshScrollImageViewAndCurrentIndex{
    [self handleSubImageViewOriginalFrame];
    // 计算索引
    CGFloat offetIndex = [[self scrollview] contentOffset].x/CGRectGetWidth([[self scrollview] frame]);
    if(offetIndex == 1){return;}
    if(offetIndex>1){// 右往左滑+1
        [self setCurrentIndex:[self currentIndex]+1];
        if([self currentIndex]>=[[self imageStrs] count]){
            // 确保索引范围
            [self setCurrentIndex:0];
        }
    }else if(offetIndex<1){// 左往右滑-1
        [self setCurrentIndex:[self currentIndex]-1];
        if([self currentIndex] <= -1){
            // 确保索引范围
            [self setCurrentIndex:[[self imageStrs] count]-1];
        }
    }
    // 更新UIImage
    [self refrshScrollImageViewForImage];
    // 保证中心位置
    [[self scrollview] setContentOffset:CGPointMake(CGRectGetWidth([[self scrollview] frame]), 0)];
    // 回调
    if([self didEndDeceleratingAtIndexBlock]){
        self.didEndDeceleratingAtIndexBlock([self currentIndex]);
    }
    if([self delegate] && [[self delegate] respondsToSelector:@selector(scrollView:didEndDeceleratingAtIndex:)]){
        [[self delegate] scrollView:self didEndDeceleratingAtIndex:[self currentIndex]];
    }
}
-(void)handleLeftImageViewWithIndex:(NSInteger)index{
    if(index<= -1){
        [self imageView:[self leftImgView] imageString:[[self imageStrs] lastObject]];
    }else if(index<=[[self imageStrs] count]-1){
        [self imageView:[self leftImgView] imageString:[[self imageStrs] objectAtIndex:index]];
    }
}
-(void)handleCenterImageViewWithIndex:(NSInteger)index{
    if(index<[[self imageStrs] count]){
        [self imageView:[self centerImgView] imageString:[[self imageStrs] objectAtIndex:index]];
    }
}
-(void)handleRightImageViewWithIndex:(NSInteger)index{
    if(index>=[[self imageStrs] count]){
        [self imageView:[self rightImgView] imageString:[[self imageStrs] firstObject]];
    }else if(index>=0){
        [self imageView:[self rightImgView] imageString:[[self imageStrs] objectAtIndex:index]];
    }
}
// 更新UIImage
- (void)refrshScrollImageViewForImage{
    [self handleLeftImageViewWithIndex:[self currentIndex]-1];
    [self handleCenterImageViewWithIndex:[self currentIndex]];
    [self handleRightImageViewWithIndex:[self currentIndex]+1];
}
-(void)imageView:(UIImageView*)imgView imageString:(NSString*)string{
    if([UIImage imageNamed:string]){ // 本地图片名称
        [imgView setImage:[UIImage imageNamed:string]];
    }else if([UIImage imageWithContentsOfFile:string]){// 本地图片路径
        //[imgView setImage:[UIImage imageWithContentsOfFile:string]];
    }else{ // 网络图片
        
    }
}
#pragma mark - ZJLoopScrollStyleZoom
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if([self scrollStyle] && [self scrollStyle] == ZJLoopScrollStyleZoom){
        [self handleSubImageViewFrameWith:[scrollView contentOffset].x];
    }
}
- (void)handleSubImageViewFrameWith:(CGFloat)offset{
    @autoreleasepool {
        CGSize size   = self.frame.size;
        CGFloat scale = 0.6;
        if(offset>CGRectGetWidth([self frame])){// 从右往左
            CGRect subFrame = CGRectMake(0, 0, size.width*scale, 0);
            CGPoint center  = CGPointMake(size.width*0.5+offset, size.height*0.5);
            subFrame.size.width += (offset-size.width*1.0)*(1-scale);
            subFrame.size.height = size.height*subFrame.size.width/size.width;
            [[self rightImgView] setFrame:subFrame];
            [[self rightImgView] setCenter:center];
            [[self leftImgView] setCenter:CGPointMake(size.width*0.5, size.height*0.5)];
        }else{                                 // 从左往右
            CGRect subFrame = CGRectMake(0, 0, size.width, size.height);
            CGPoint center  = CGPointMake(size.width*0.5+offset, size.height*0.5);
            subFrame.size.width -= (size.width-offset)*(1-scale);
            subFrame.size.height = size.height*subFrame.size.width/size.width;
            [[self centerImgView] setFrame:subFrame];
            [[self centerImgView] setCenter:center];
            [[self rightImgView] setCenter:CGPointMake(size.width*2.5, size.height*0.5)];
        }
    }
}
- (void)handleSubImageViewOriginalFrame{
    CGRect subframe   = [[self leftImgView] frame];
    subframe.origin.x = CGRectGetWidth([self frame])*0;
    [[self leftImgView] setFrame:subframe];
    subframe.origin.x = CGRectGetWidth([self frame])*1;
    [[self centerImgView] setFrame:subframe];
    subframe.origin.x = CGRectGetWidth([self frame])*2;
    [[self rightImgView] setFrame:subframe];
}
#pragma mark -
-(void)openTimer{
    if(self.timer != nil){return;}
    NSTimeInterval time = 2.0;
    // 获得队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    // 创建一个定时器(dispatch_source_t本质还是个OC对象)
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    // 何时开始执行第一个任务
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(time * NSEC_PER_SEC);
    dispatch_source_set_timer(self.timer, start, interval, 0);
    // 设置回调
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.timer, ^{
        if([weakSelf scrollDirection] == ZJLoopScrollDirectionLeftToRight){
            CGPoint offset = [[weakSelf scrollview] contentOffset];
            offset.x -= CGRectGetWidth([[weakSelf scrollview] frame]);
            [[weakSelf scrollview] setContentOffset:offset animated:true];
        }else if([weakSelf scrollDirection] == ZJLoopScrollDirectionRightToLeft){
            CGPoint offset = [[weakSelf scrollview] contentOffset];
            offset.x += CGRectGetWidth([[weakSelf scrollview] frame]);
            [[weakSelf scrollview] setContentOffset:offset animated:true];
        }else{
            [weakSelf cancelTimer];
        }
    });
    // 启动定时器
    dispatch_resume(self.timer);
}
/** 销毁定时器*/
-(void)cancelTimer{
    if(self.timer){
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
}
-(void)dealloc{
    [self cancelTimer];
}
#pragma mark  * * * * * * * * * * * * * * * * * * * * * * * * * * *
- (void)setScrollDirection:(ZJLoopScrollDirection)scrollDirection{
    _scrollDirection = scrollDirection;
    if([self imageStrs] && scrollDirection != ZJLoopScrollDirectionNone){
        [self openTimer];
    }
}
- (void)showImagesWithImageStrs:(NSArray<NSString*>*)imageStrs{
    [self refreshScrollImagesLayoutWithImageStrs:imageStrs];
    [self showDefaultCurrentIndex:[self currentIndex]];
    if([self scrollDirection] && [self scrollDirection] != ZJLoopScrollDirectionNone){
        [self openTimer];
    }else{
        [self cancelTimer];
    }
}
- (void)showDefaultCurrentIndex:(NSInteger)currentIndex{
    [self setCurrentIndex:currentIndex];
    [self refrshScrollImageViewForImage];
}
- (void)didSelectSubviewAtIndex:(void(^)(NSInteger index))block{
    [self didSelectSubviewAtIndex:block];
}
- (void)didEndDeceleratingAtIndex:(void(^)(NSInteger index))block{
    [self didEndDeceleratingAtIndex:block];
}
@end
