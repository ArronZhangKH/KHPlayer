//
//  KHPlayer.m
//  KHPlayer
//
//  Created by qianfeng on 16/10/14.
//  Copyright © 2016年 Arron_zkh. All rights reserved.
//

#import "KHPlayer.h"
#import <AVFoundation/AVFoundation.h>

//按钮的宽和高
#define kButtonSize 30
//Label字体大小
#define kLabelFont 15
//loading View的宽和高
#define kLoadingBGView_Size 50
//按钮间的间距
#define kButtonSpace 50
//时间Label的外边距
#define kLabelSpace 10
//时间Label的宽度
#define kLabelWidth 50
//时间Lable的高度
#define kLabelHeight 20
//菊花的尺寸
#define kActivityView_Size 30


@interface KHPlayer ()
/** 快退按钮 */
@property (nonatomic, weak)  UIButton *backBtn;
/** 播放/暂停按钮 */
@property (nonatomic, weak)  UIButton *PlayOrPuaseBtn;
/** 快进按钮 */
@property (nonatomic, weak)  UIButton *forwardBtn;
/** 进度条 */
@property (nonatomic, weak)  UISlider *progressSlider;
/** 已播放的时间 */
@property (nonatomic, weak)  UILabel *leftTimeLabel;
/** 未播放的时间 */
@property (nonatomic, weak)  UILabel *rightTimeLabel;
/** 播放器 */
@property (nonatomic, strong)  AVPlayer *player;
/** 当前正在播放的曲目 */
@property (nonatomic, strong)  AVPlayerItem *currentItem;
/** 曲目的总时长 */
@property (nonatomic, assign)  NSTimeInterval duration;
/** 当前播放时间 */
@property (nonatomic, assign)  NSTimeInterval currentTime;
/** 缓冲View(菊花) */
@property (nonatomic, weak)  UIActivityIndicatorView *activityView;
/** 缓冲背景View */
@property (nonatomic, weak)  UIView *loadBgView;


@end

@implementation KHPlayer


#pragma mark - 播放相关
//添加在线播放的音频URL
- (void)setURLString:(NSString *)urlString{
    _urlString = urlString;
    
    if (self.currentItem) {
        [self.currentItem removeObserver:self forKeyPath:@"status"];
        [self.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [self.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        self.currentItem = nil;
        
    }
    if (self.player) {
        self.player = nil;
    }
    if (self.progressSlider) {
        self.progressSlider.value = 0;
    }
    
    //给playerItem添加KVO事件
    self.currentItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:urlString]];
    [self.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.currentItem];
    [self showLoadingView];
}


/*
 使用KVO监听播放状态
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"])
    {
        //准备播放
        if ([change[NSKeyValueChangeNewKey] integerValue] == AVPlayerItemStatusReadyToPlay)
        {
            self.duration = CMTimeGetSeconds(self.currentItem.duration);
            self.rightTimeLabel.text = [self timeFormatWithTimtInterval:_duration];
            [self updatePlayerProgress];
            [self hideLoadingView];
            [self enableButtons];
        }
        else if ([change[NSKeyValueChangeNewKey] integerValue] == AVPlayerItemStatusFailed)
        {
            [self showLoadingView];
            [self disableButtons];
            NSLog(@"播放失败");
        }
        else if ([change[NSKeyValueChangeNewKey] integerValue] == AVPlayerItemStatusUnknown)
        {
            [self showLoadingView];
            [self disableButtons];
            NSLog(@"未知错误");
        }
        
    }
    else if ([keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        if (self.currentItem.playbackBufferEmpty) {
            [self showLoadingView];
            self.progressSlider.value = 0;
            [self disableButtons];
        }
    }
    else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
        [self showLoadingView];
        
        if (self.currentItem.playbackLikelyToKeepUp) {
            [self hideLoadingView];
            [self enableButtons];
        }
    }
}


/*
 设置定时器,更新播放状态
 */
- (void)updatePlayerProgress{
    __weak typeof(self) weakSelf = self;
    [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
    //更新左右的时间Label, 修改进度条进度
        CGFloat currentTime = CMTimeGetSeconds(weakSelf.currentItem.currentTime);
        weakSelf.currentTime = currentTime;
        weakSelf.leftTimeLabel.text = [weakSelf timeFormatWithTimtInterval:currentTime];
        
        CGFloat leftTime = weakSelf.duration - currentTime;
        weakSelf.rightTimeLabel.text = [weakSelf timeFormatWithTimtInterval:leftTime];
        weakSelf.progressSlider.value = currentTime / weakSelf.duration;
    }];
}


/**
 开始播放
 */
- (void)play{
    if (self.player) {
        [self.player play];
        self.PlayOrPuaseBtn.selected = YES;
    }
}

/**
 停止播放
 */
- (void)pause{
    if (self.player) {
        [self.player pause];
        self.PlayOrPuaseBtn.selected = NO;
    }
}

/**
 重置播放器
 */
- (void)resetPlayer{
    if (self.player) {
        self.progressSlider.value = 0.f;
        [self.player seekToTime:CMTimeMakeWithSeconds(0, self.currentItem.currentTime.timescale)];
        [self playOrPauseBtnDidClick];
    }
}

- (void)enableButtons{
    self.PlayOrPuaseBtn.enabled = YES;
    self.forwardBtn.enabled = YES;
    self.backBtn.enabled = YES;
    self.progressSlider.enabled = YES;
}

- (void)disableButtons{
    self.PlayOrPuaseBtn.enabled = NO;
    self.forwardBtn.enabled = NO;
    self.backBtn.enabled = NO;
    self.progressSlider.enabled = NO;
}


#pragma mark - 按钮响应事件
/*
 播放和暂停按钮
 */
- (void)playOrPauseBtnDidClick{
    self.PlayOrPuaseBtn.selected = !self.PlayOrPuaseBtn.isSelected;
    if (self.PlayOrPuaseBtn.isSelected) {
        [self play];
    }else{
        [self pause];
    }
}

/*
 快退事件
 */
- (void)backBtnDidClick{
    _currentTime -= 10;
    if (_currentTime < 0) {
        _currentTime = 0;
    }
    CMTime time = self.currentItem.currentTime;
    time.value = time.timescale * _currentTime;
    [self.currentItem seekToTime:time];
}


/*
 快进事件
 */
- (void)forwardBtnDidClick{
    _currentTime += 10;
    if (_currentTime > _duration) {
        _currentTime = _duration;
    }
    CMTime time = self.currentItem.currentTime;
    time.value = time.timescale * _currentTime;
    [self.currentItem seekToTime:time];
}

/*
 拖动进度条
 */
- (void)handleDragingOfSlider:(UISlider *)sender{
    NSTimeInterval currentTime = sender.value * _duration;
    CMTime time = self.currentItem.currentTime;
    time.value = time.timescale * currentTime;
    [self.currentItem seekToTime:time];
}

/*
 点击进度条
 */
- (void)updateSlider:(UITapGestureRecognizer *)sender{
    CGPoint point = [sender locationInView:self.progressSlider];
    CGFloat currentValue = (self.progressSlider.maximumValue - self.progressSlider.minimumValue) * (point.x / CGRectGetWidth(self.progressSlider.frame));
    [self.progressSlider setValue:currentValue animated:YES];
    [self.player seekToTime:CMTimeMakeWithSeconds(currentValue * _duration, self.currentItem.currentTime.timescale)];
}

#pragma mark - 其他

- (void)setBgColor:(UIColor *)bgColor{
    self.backgroundColor = bgColor;
}

- (void)setSliderThumbImage:(UIImage *)sliderThumbImage{
    [self.progressSlider setThumbImage:sliderThumbImage forState:UIControlStateNormal];
    [self.progressSlider setThumbImage:sliderThumbImage forState:UIControlStateHighlighted];
}

- (void)enableMasksToBoundsOfSlider{
    self.progressSlider.layer.masksToBounds = YES;
}

/*
 判断是否缓冲中
 */
- (BOOL)buffering{
    if (CMTimeGetSeconds(self.currentItem.currentTime) < [self getBufferTime]) {
        return NO;
    }else {
        return YES;
    }
}

/*
 获取缓冲好的时间
 */
- (NSTimeInterval)getBufferTime{
    NSArray *loadTimeRanges = [_currentItem loadedTimeRanges];
    CMTimeRange timeRange = [[loadTimeRanges firstObject] CMTimeRangeValue];
    NSTimeInterval start = CMTimeGetSeconds(timeRange.start);
    NSTimeInterval duration = CMTimeGetSeconds(timeRange.duration);
    return start + duration;
}


- (NSString *)timeFormatWithTimtInterval:(NSTimeInterval)duration{
    NSInteger min = duration / 60;
    NSInteger sec = (NSInteger)duration % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld",(long)min, (long)sec];
}

- (void)showLoadingView{
    self.loadBgView.hidden = NO;
    [self.activityView startAnimating];
}

- (void)hideLoadingView{
    self.loadBgView.hidden = YES;
    [self.activityView stopAnimating];
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize{
    //设置后台播放
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self enableBackgroundPlay];
    });
    
    //设置UI属性
    self.backgroundColor = [UIColor lightGrayColor];
    self.alpha = 0.8f;
    
    //设置UI控件
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat x1 = CGRectGetWidth(self.frame) / 2 - kButtonSize / 2;
    CGFloat y1 = CGRectGetHeight(self.frame) /2 - kButtonSize / 2;
    btn1.frame = CGRectMake(x1, y1, kButtonSize, kButtonSize);
    [self addSubview:btn1];
    self.PlayOrPuaseBtn = btn1;
    [self.PlayOrPuaseBtn setImage:[UIImage imageNamed:@"yinpinPlay_19x23_"] forState:UIControlStateNormal];
    [self.PlayOrPuaseBtn setImage:[UIImage imageNamed:@"yinpinPause_14x22_"] forState:UIControlStateSelected];
    [self.PlayOrPuaseBtn addTarget:self action:@selector(playOrPauseBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat x2 = x1 - kButtonSpace - kButtonSize;
    CGFloat y2 = y1;
    btn2.frame = CGRectMake(x2, y2, kButtonSize, kButtonSize);
    [self addSubview:btn2];
    self.backBtn = btn2;
    [self.backBtn setImage:[UIImage imageNamed:@"yinpinRW_28x18_"] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(backBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat x3 = x1 + kButtonSpace + kButtonSize;
    CGFloat y3 = y1;
    btn3.frame = CGRectMake(x3, y3, kButtonSize, kButtonSize);
    [self addSubview:btn3];
    self.forwardBtn = btn3;
    [self.forwardBtn setImage:[UIImage imageNamed:@"yinpinFF_27x18_"] forState:UIControlStateNormal];
    [self.forwardBtn addTarget:self action:@selector(forwardBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label1 = [[UILabel alloc] init];
    CGFloat x4 = kLabelSpace;
    CGFloat y4 = CGRectGetHeight(self.frame) / 2 - kLabelHeight / 2;
    label1.frame = CGRectMake(x4, y4, kLabelWidth, kLabelHeight);
    [self addSubview:label1];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.font = [UIFont systemFontOfSize:kLabelFont];
    label1.text = @"00:00";
    self.leftTimeLabel = label1;
    
    UILabel *label2 = [[UILabel alloc] init];
    CGFloat x5 = CGRectGetWidth(self.frame) - kLabelWidth - kLabelSpace;
    CGFloat y5 = y4;
    label2.frame = CGRectMake(x5, y5, kLabelWidth, kLabelHeight);
    [self addSubview:label2];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.font = [UIFont systemFontOfSize:kLabelFont];
    label2.text = @"00:00";
    self.rightTimeLabel = label2;
    
    UISlider *slider = [[UISlider alloc] init];
    slider.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 10);
    [slider setMaximumTrackTintColor:[UIColor clearColor]];
    [slider setMinimumTrackTintColor:[UIColor clearColor]];
    slider.maximumValue = 1.f;
    slider.minimumValue = 0.f;
    slider.value = 0.f;
    [slider addTarget:self action:@selector(handleDragingOfSlider:) forControlEvents:UIControlEventValueChanged];
    UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateSlider:)];
    [slider addGestureRecognizer:tapGesturer];
    [self addSubview:slider];
    self.progressSlider = slider;
    
    UIView *bgView = [[UIView alloc] init];
    CGFloat x6 = CGRectGetWidth(self.frame) / 2 - kLoadingBGView_Size / 2;
    CGFloat y6 = -100;
    bgView.frame = CGRectMake(x6, y6, kLoadingBGView_Size, kLoadingBGView_Size);
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.7f;
    [self addSubview:bgView];
    bgView.layer.cornerRadius = 5;
    bgView.clipsToBounds = YES;
    self.loadBgView = bgView;
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGFloat x7 = CGRectGetWidth(bgView.frame) / 2 - kActivityView_Size / 2;
    CGFloat y7 = CGRectGetHeight(bgView.frame) / 2 - kActivityView_Size / 2;
    activityView.frame = CGRectMake(x7, y7, kActivityView_Size, kActivityView_Size);
    [bgView addSubview:activityView];
    self.activityView = activityView;
    [activityView startAnimating];

    //添加KVO事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPlayer) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterOrLeaveForeground) name:UIApplicationDidEnterBackgroundNotification object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterOrLeaveForeground) name:UIApplicationWillEnterForegroundNotification object:_player];
}

- (void)enableBackgroundPlay{
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)appEnterOrLeaveForeground{
    if(self.PlayOrPuaseBtn.isSelected){
        [self play];
    }else{
        [self pause];
    }
}


- (void)dealloc{
    [self.currentItem removeObserver:self forKeyPath:@"status"];
    [self.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:AVPlayerItemDidPlayToEndTimeNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIApplicationWillEnterForegroundNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIApplicationDidEnterBackgroundNotification];
    
    self.player = nil;
    self.currentItem = nil;
}



@end
