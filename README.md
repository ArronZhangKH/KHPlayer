#KHPlayer
- a simply player for online audio

###[中文版本](https://github.com/ArronZhangKH/KHPlayer/blob/master/README-CD.md#khplayer)

###features
- small volume
- comprehensive functions, including playing back, pause, fast-forward, fast-backward 
- capable of changing the progress by dragging or clicking the progress slider


##Usage
1. Download and copy **KHPlayer** folder to your project directory
	- Note: if you want to use the original resource pictures, be sure to copy the pictures in the Assets to your project
	
2. Initialize **KHPlayer**, assign value for its frame, and add it to the current view

		 KHPlayer *player = [[KHPlayer alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 70, CGRectGetWidth(self.view.frame),70)];
 		[self.view addSubview:player];

3. Set up UI properties

		 [player setSliderThumbImage:[UIImage imageNamed:@"yinpinThumb"]];
		 [player enableMasksToBoundsOfSlider];
		 [player setBgColor:[UIColor whiteColor]];

4. Set URLString for the online audio you wanna play, and call the `play` method

		[player setURLString: kInterface1]; 
		[player play];


###Now you got a simply audio player like this:
![](http://upload-images.jianshu.io/upload_images/3007158-2b9f037ceebfb11e.gif?imageMogr2/auto-orient/strip)

###TO DO:
- add interfaces for local auidos
- Add a continuous playing function
