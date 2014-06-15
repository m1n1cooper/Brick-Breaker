//
//  JTViewController.h
//  Brick Breaker
//

//  Copyright (c) 2014 James Topham. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>

@interface JTViewController : UIViewController <ADBannerViewDelegate>

@property (nonatomic) ADBannerView *bannerView;

@end
