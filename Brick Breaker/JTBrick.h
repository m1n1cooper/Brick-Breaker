//
//  JTBrick.h
//  Brick Breaker
//
//  Created by James Topham on 12/06/2014.
//  Copyright (c) 2014 James Topham. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum : NSUInteger {
    Green = 1,
    Blue = 2,
    Grey = 3,
    Red = 4,
    RedCracked = 5,
    Yellow = 6,
    Purple = 7,
    
} BrickType;

static const uint32_t kBrickCategory = 0x1 << 2;

@interface JTBrick : SKSpriteNode

@property (nonatomic) BrickType type;
@property (nonatomic) BOOL indestructible;
@property (nonatomic) BOOL spawnsExtraBall;
@property (nonatomic) BOOL spawnsExtraLife;

-(instancetype)initWithType:(BrickType)type;
-(void)hit;

@end