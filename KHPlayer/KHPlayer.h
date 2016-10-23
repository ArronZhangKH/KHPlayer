//
//  KHPlayer.h
//  KHPlayer
//
//  Created by qianfeng on 16/10/14.
//  Copyright © 2016年 Arron_zkh. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KHPlayer : UIView

/** 播放器的背景颜色 */
@property (nonatomic, strong)  UIColor *bgColor;
/** 滑块的图标 */
@property (nonatomic, strong)  UIImage *sliderThumbImage;
/** 要播放的URL的String */
@property (nonatomic, copy)  NSString *urlString;



- (void)setURLString:(NSString *)urlString;

- (void)play;

- (void)pause;

- (void)enableMasksToBoundsOfSlider;

- (BOOL)buffering;


@end
