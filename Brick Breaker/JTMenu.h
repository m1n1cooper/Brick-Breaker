//
//  JTMenu.h
//  Brick Breaker
//
//  Created by James Topham on 13/06/2014.
//  Copyright (c) 2014 James Topham. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface JTMenu : SKNode

@property (nonatomic) int levelNumber;

-(void)hide;
-(void)show;

@end
