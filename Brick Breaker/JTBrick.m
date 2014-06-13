//
//  JTBrick.m
//  Brick Breaker
//
//  Created by James Topham on 12/06/2014.
//  Copyright (c) 2014 James Topham. All rights reserved.
//

#import "JTBrick.h"

@implementation JTBrick
{
    SKAction *_brickSmashSound;
}

-(instancetype)initWithType:(BrickType)type
{
    switch (type) {
        case Green:
            self = [super initWithImageNamed:@"BrickGreen"];
            break;
        case Blue:
            self = [super initWithImageNamed:@"BrickBlue"];
            break;
        case Grey:
            self = [super initWithImageNamed:@"BrickGrey"];
            break;
        case Red:
            self = [super initWithImageNamed:@"BrickRed"];
            break;
        case RedCracked:
            self = [super initWithImageNamed:@"BrickRedCracked"];
            break;
        default:
            self = nil;
            break;
    }
    if (self) {
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.categoryBitMask = kBrickCategory;
        self.physicsBody.dynamic = NO;
        self.type = type;
        self.indestructible = (type == Grey);
        
        _brickSmashSound = [SKAction playSoundFileNamed:@"BrickSmash.caf" waitForCompletion:NO];
    }
    return self;
}

-(void)hit
{
    switch (self.type) {
        case Green:
            [self createGreenExplosion];
            [self runAction:_brickSmashSound];
            [self runAction:[SKAction removeFromParent]];
            break;
        case Blue:
            self.texture = [SKTexture textureWithImageNamed:@"BrickGreen"];
            self.type = Green;
            break;
        case Red:
            self.texture = [SKTexture textureWithImageNamed:@"BrickRedCracked"];
            self.type = RedCracked;
            break;
        case RedCracked:
            [self createRedExplosion];
            [self runAction:_brickSmashSound];
            [self runAction:[SKAction removeFromParent]];
            break;
        default:
            // Gray bricks are indestructible
            break;
    }
}

-(void)createGreenExplosion
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"BrickGreenExplosion" ofType:@"sks"];
    SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    explosion.position = self.position;
    [self.parent addChild:explosion];
    
    SKAction *removeExplosion = [SKAction sequence:@[[SKAction waitForDuration:explosion.particleLifetime + explosion.particleLifetimeRange],
                                                     [SKAction removeFromParent]]];
    [explosion runAction:removeExplosion];
}

-(void)createRedExplosion
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"BrickRedExplosion" ofType:@"sks"];
    SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    explosion.position = self.position;
    [self.parent addChild:explosion];
    
    SKAction *removeExplosion = [SKAction sequence:@[[SKAction waitForDuration:explosion.particleLifetime + explosion.particleLifetimeRange],
                                                     [SKAction removeFromParent]]];
    [explosion runAction:removeExplosion];
}

@end