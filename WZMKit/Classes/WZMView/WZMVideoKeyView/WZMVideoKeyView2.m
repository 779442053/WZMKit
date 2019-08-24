//
//  WZMVideoKeyView2.m
//  WZMKit_Example
//
//  Created by WangZhaomeng on 2019/8/20.
//  Copyright © 2019 wangzhaomeng. All rights reserved.
//

#import "WZMVideoKeyView2.h"
#import "UIView+wzmcate.h"
#import "UIImage+wzmcate.h"

@interface WZMVideoKeyView2 ()<UIScrollViewDelegate>

///进度
@property (nonatomic, strong) UIView *sliderView;
///关键帧
@property (nonatomic, strong) UIView *keysView;
@property (nonatomic, strong) UIImageView *keysImageView;
///灰度图
@property (nonatomic, strong) UIView *graysView;
@property (nonatomic, strong) UIImageView *graysImageView;
///视图
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIScrollView *contentView;

@end

@implementation WZMVideoKeyView2 {
    CGFloat _sliderX;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect bgRect = self.bounds;
        bgRect.origin.y = 5;
        bgRect.size.height -= 10;
        self.bgView = [[UIView alloc] initWithFrame:bgRect];
        self.bgView.clipsToBounds = YES;
        [self addSubview:self.bgView];
        
        self.contentView = [[UIScrollView alloc] initWithFrame:self.bgView.bounds];
        self.contentView.delegate = self;
        self.contentView.clipsToBounds = YES;
        [self.bgView addSubview:self.contentView];
        
        self.keysView = [[UIView alloc] init];
        self.keysView.clipsToBounds = YES;
        [self.contentView addSubview:self.keysView];
        
        self.keysImageView = [[UIImageView alloc] init];
        self.keysImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.keysView addSubview:self.keysImageView];
        
        self.graysView = [[UIView alloc] init];
        self.graysView.clipsToBounds = YES;
        [self.contentView addSubview:self.graysView];
        
        self.graysImageView = [[UIImageView alloc] init];
        self.graysImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.graysView addSubview:self.graysImageView];
        
        self.sliderView = [[UIView alloc] initWithFrame:CGRectMake((self.wzm_width-2)/2, 0, 2, self.wzm_height)];
        self.sliderView.backgroundColor = [UIColor whiteColor];
        self.sliderView.wzm_cornerRadius = 1;
        [self addSubview:self.sliderView];
        
        ///设置contentWidth
        self.contentWidth = self.contentView.wzm_width*3;
    }
    return self;
}

- (void)panGesture:(UIPanGestureRecognizer *)recognizer {
    CGFloat tx = [recognizer translationInView:self].x;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _sliderX = self.keysView.wzm_minX;
        [self didChangeType:WZMCommonStateWillChanged];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat x = _sliderX+tx;
        if (x < (-self.contentView.wzm_width/2)) x = (-self.contentView.wzm_width/2);
        if (x > self.contentView.wzm_width/2) x = self.contentView.wzm_width/2;
        self.value = ((self.contentView.wzm_width/2-x)/self.contentView.wzm_width);
        [self didChangeType:WZMCommonStateDidChanged];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateCancelled) {
        [self didChangeType:WZMCommonStateEndChanged];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _sliderX = self.keysView.wzm_minX;
    [self didChangeType:WZMCommonStateWillChanged];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat tx = offsetX+scrollView.wzm_width/2-self.keysView.wzm_minX;
    self.value = tx/self.keysView.wzm_width;
    [self didChangeType:WZMCommonStateDidChanged];
    
    NSLog(@"%@",@(self.value));
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self didChangeType:WZMCommonStateEndChanged];
}

- (void)didChangeType:(WZMCommonState)type {
    if ([self.delegate respondsToSelector:@selector(videoKeyView2:changeType:)]) {
        [self.delegate videoKeyView2:self changeType:type];
    }
}

- (void)setValue:(CGFloat)value {
    if (value < 0) {
        
        return;
    }
    if (value > 1) {
        
        return;
    }
    if (_value == value) return;
    _value = value;
    
    CGFloat x = self.keysView.wzm_minX;
    CGFloat tx = value*self.keysView.wzm_width;
    CGFloat tw = (1-value)*self.keysView.wzm_width;
    
    self.graysView.frame = CGRectMake(x+tx, self.graysView.wzm_minY, tw, self.graysView.wzm_height);
    self.graysImageView.wzm_minX = -tx;
}

- (void)setRadius:(CGFloat)radius {
    if (radius < 0) return;
    if (_radius == radius) return;
    _radius = radius;
    self.bgView.wzm_cornerRadius = radius;
    self.contentView.wzm_cornerRadius = radius;
    self.keysImageView.wzm_cornerRadius = radius;
    self.graysImageView.wzm_cornerRadius = radius;
}

- (void)setContentWidth:(CGFloat)contentWidth {
    if (_contentWidth == contentWidth) return;
    _contentWidth = contentWidth;
    
    self.contentView.contentSize = CGSizeMake(contentWidth, self.contentView.wzm_height);
    self.contentView.contentOffset = CGPointMake(0, 0);
    
    CGRect keyRect = CGRectMake(self.contentView.wzm_width/2, 0, contentWidth-self.contentView.wzm_width, self.contentView.wzm_height);
    self.keysView.frame = keyRect;
    self.keysImageView.frame = self.keysView.bounds;
    self.graysView.frame = keyRect;
    self.graysImageView.frame = self.graysView.bounds;
    
    if (self.superview) {
        [self loadKeyImages];
    }
}

- (void)setVideoUrl:(NSURL *)videoUrl {
    if ([_videoUrl.path isEqualToString:videoUrl.path]) return;
    _videoUrl = videoUrl;
    
    if (self.superview) {
        [self loadKeyImages];
    }
}

- (void)loadKeyImages {
    UIImage *fImage = [[UIImage wzm_getImagesByUrl:_videoUrl count:1] firstObject];
    CGFloat imageViewH = self.keysView.wzm_height;
    CGFloat imageViewW = fImage.size.width*imageViewH/fImage.size.height;
    CGFloat c = self.keysView.wzm_width/imageViewW;
    NSInteger count = (NSInteger)c;
    if (c > count) {
        count ++;
    }
    NSArray *images = [UIImage wzm_getImagesByUrl:self.videoUrl count:count];
    UIImage *keysImage = [UIImage wzm_getImageByImages:images type:WZMAddImageTypeHorizontal];
    UIImage *graysImage = [keysImage wzm_getGrayImage];
    
    self.keysImageView.image = keysImage;
    self.graysImageView.image = graysImage;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        if (_keysImageView.image == nil || self.graysImageView.image == nil) {
            [self loadKeyImages];
        }
    }
    [super willMoveToSuperview:newSuperview];
}

@end
