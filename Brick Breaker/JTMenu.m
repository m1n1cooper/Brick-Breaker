//
//  JTMenu.m
//  Brick Breaker
//
//  Created by James Topham on 13/06/2014.
//  Copyright (c) 2014 James Topham. All rights reserved.
//

#import "JTMenu.h"

@implementation JTMenu
{
    SKSpriteNode *_menuPanel;
    SKLabelNode *_panelText;
    SKSpriteNode *_startButton;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        
        _menuPanel = [SKSpriteNode spriteNodeWithImageNamed:@"MenuPanel"];
        _menuPanel.position = CGPointZero;
        [self addChild:_menuPanel];
        
        _panelText = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
        _panelText.fontColor = [SKColor grayColor];
        _panelText.fontSize = 15;
        _panelText.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [_menuPanel addChild:_panelText];
        
        _startButton = [SKSpriteNode spriteNodeWithImageNamed:@"Start"];
        _startButton.name = @"Start Button";
        _startButton.position = CGPointMake(0, -((_menuPanel.size.height/2) + (_startButton.size.height/2) + 10));
        [self addChild:_startButton];
    }
    return self;
}

-(void)setLevelNumber:(int)levelNumber
{
    _levelNumber = levelNumber;
    _panelText.text = [NSString stringWithFormat:@"Level %d", levelNumber];
}

-(void)show
{
    SKAction *slideLeft = [SKAction moveByX:-260.0 y:0.0 duration:0.5];
    slideLeft.timingMode = SKActionTimingEaseOut;
    
    SKAction *slideRight = [SKAction moveByX:260.0 y:0.0 duration:0.5];
    slideRight.timingMode = SKActionTimingEaseOut;
    
    _menuPanel.position = CGPointMake(260, _menuPanel.position.y);
    _startButton.position = CGPointMake(-260, _startButton.position.y);
    
    [_menuPanel runAction:slideLeft];
    [_startButton runAction:slideRight];
    
    self.hidden = NO;
}

-(void)hide
{
    SKAction *slideLeft = [SKAction moveByX:-260.0 y:0.0 duration:0.5];
    slideLeft.timingMode = SKActionTimingEaseIn;
    
    SKAction *slideRight = [SKAction moveByX:260.0 y:0.0 duration:0.5];
    slideRight.timingMode = SKActionTimingEaseIn;
    
    _menuPanel.position = CGPointMake(0, _menuPanel.position.y);
    _startButton.position = CGPointMake(0, _startButton.position.y);
    
    [_menuPanel runAction:slideRight];
    [_startButton runAction:slideLeft completion:^{
        self.hidden = YES;
    }];
}

@end
