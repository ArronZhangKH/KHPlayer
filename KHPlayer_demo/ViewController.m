//
//  ViewController.m
//  KHPlayer
//
//  Created by qianfeng on 16/10/14.
//  Copyright © 2016年 Arron_zkh. All rights reserved.
//

#import "ViewController.h"
#import "KHPlayer.h"

#define kInterface1 @"http://img.owspace.com/F_lbg187532_1475550258.2699715.mp3"
#define kInterface2 @"http://img.owspace.com/F_guq226254_1475225218.3955587.mp3"
#define kInterface3 @"http://img.owspace.com/F_ans226254_1475644491.6466485.mp3"

@interface ViewController ()

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:self.view.bounds];
    iv.image = [UIImage imageNamed:@"02.jpg"];
    [self.view addSubview:iv];

    [self initKHPlayer];
}

- (void)initKHPlayer{
    KHPlayer *player = [[KHPlayer alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 70, CGRectGetWidth(self.view.frame),70)];
    [self.view addSubview:player];
    [player setSliderThumbImage:[UIImage imageNamed:@"yinpinThumb"]];
    [player enableMasksToBoundsOfSlider];
    [player setBgColor:[UIColor whiteColor]];
    [player setURLString: kInterface1];
    [player play];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
