//
//  WZMRecordAnimation.m
//  WZMChat
//
//  Created by WangZhaomeng on 2019/5/23.
//  Copyright © 2019 WangZhaomeng. All rights reserved.
//

#import "WZMRecordAnimation.h"
#import "WZMInputHelper.h"

@implementation WZMRecordAnimation {
    NSArray *_images;
    BOOL _isPause;
}

- (instancetype)init {
    if (self = [super initWithFrame:CGRectMake(([WZMInputHelper helper].screenW-120)/2, [WZMInputHelper helper].screenH/2-120, 120, 120)]) {
        self.animationDuration    = 0.2;
        self.animationRepeatCount = 0;
        _images = @[[WZMInputHelper otherImageNamed:@"wzm_voice_1"],
                    [WZMInputHelper otherImageNamed:@"wzm_voice_2"],
                    [WZMInputHelper otherImageNamed:@"wzm_voice_3"],
                    [WZMInputHelper otherImageNamed:@"wzm_voice_4"],
                    [WZMInputHelper otherImageNamed:@"wzm_voice_5"],
                    [WZMInputHelper otherImageNamed:@"wzm_voice_6"]];
        _isPause = YES;
    }
    return self;
}

- (void)showVoiceCancel {
    if (_isPause) return;
    _isPause = YES;
    [self stopAnimating];
    self.image = [WZMInputHelper otherImageNamed:@"voice_cancel"];
}

- (void)showVoiceShort {
    if (_isPause) return;
    _isPause = YES;
    [self stopAnimating];
    self.image = [WZMInputHelper otherImageNamed:@"voice_short"];
}

- (void)showVoiceAnimation {
    if (_isPause == NO) return;
    _isPause = NO;
    [self updateImages];
}

- (void)setVolume:(CGFloat)volume {
    if (_volume == volume) {
        if (self.isAnimating) return;
    }
    else {
        _volume = MIN(MAX(volume, 0.f),1.f);
    }
    [self updateImages];
}

- (void)updateImages {
    if (_isPause) return;
    if (_volume == 0) {
        [self stopAnimating];
        self.animationImages = nil;
        return;
    }
    if (_volume >= 0.8 ) {
        self.animationImages = @[_images[4],_images[5]];
    }
    else if (_volume >= 0.6 ) {
        self.animationImages = @[_images[3],_images[4]];
    }
    else if (_volume >= 0.4 ) {
        self.animationImages = @[_images[2],_images[3]];
    }
    else if (_volume >= 0.2) {
        self.animationImages = @[_images[1],_images[2]];
    }
    else {
        self.animationImages = @[_images[0],_images[1]];
    }
    [self startAnimating];
}

- (void)removeFromSuperview {
    _isPause = YES;
    self.image = nil;
    [self stopAnimating];
    self.animationImages = nil;
    [super removeFromSuperview];
}

@end
