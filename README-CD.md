#KHPlayer
- 一个简单的在线音乐播放器
###[English Version](https://github.com/ArronZhangKH/KHPlayer#khplayer)
###特点
- 体量小
- 支持单首歌曲的播放,快进,快退
- 支持进度条的拖动以及点击


##使用方法
1. 下载并复制**KHPlayer**文件夹下的源代码到你的工程目录
	- 注意:如果想使用原资源图片, 一定要把Assets里的图片一起复制过去
2. 初始化**KHPlayer**, 赋值Frame, 并添加到当前视图中

		 KHPlayer *player = [[KHPlayer alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 70, CGRectGetWidth(self.view.frame),70)];
 		[self.view addSubview:player];

3. 设置相关的UI属性

		 [player setSliderThumbImage:[UIImage imageNamed:@"yinpinThumb"]];
		 [player enableMasksToBoundsOfSlider];
		 [player setBgColor:[UIColor whiteColor]];

4. 设置要播放的在线音频URL的String值, 并调用`play`方法进行播放

		[player setURLString: kInterface1]; 
		[player play];


###完成以上操作后得到的效果如下:  
![](http://upload-images.jianshu.io/upload_images/3007158-2b9f037ceebfb11e.gif?imageMogr2/auto-orient/strip)

###后续工作
- 添加播放本地音频的接口
- 添加连续播放多首歌的功能
