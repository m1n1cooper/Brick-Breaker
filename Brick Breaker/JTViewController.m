//
//  JTViewController.m
//  Brick Breaker
//
//  Created by James Topham on 12/06/2014.
//  Copyright (c) 2014 James Topham. All rights reserved.
//

#import "JTViewController.h"
#import "JTMyScene.h"

@implementation JTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
//    skView.showsFPS = YES;
//    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [JTMyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
    _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    _bannerView.frame = CGRectMake(0, self.view.frame.size.height - _bannerView.frame.size.height, self.view.frame.size.width, _bannerView.frame.size.height);
    _bannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    _bannerView.delegate = self;
    [self.view addSubview:_bannerView];
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - iAd Methods
- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    _bannerView.hidden = NO;
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    _bannerView.hidden = YES;
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
}

@end
