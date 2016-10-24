//
//  KHPlayer.h
//  KHPlayer
//
//  Created by qianfeng on 16/10/14.
//  Copyright © 2016年 Arron_zkh. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KHPlayer : UIView

/** 背景颜色 */
@property (nonatomic, strong)  UIColor *bgColor;
/** 进度条控制滑块的图片 */
@property (nonatomic, strong)  UIImage *sliderThumbImage;
/** urlString */
@property (nonatomic, copy)  NSString *urlString;


- (void)setURLString:(NSString *)urlString;

- (void)play;

- (void)pause;

- (void)enableMasksToBoundsOfSlider;



@end
