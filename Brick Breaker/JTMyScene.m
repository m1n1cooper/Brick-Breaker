//
//  JTMyScene.m
//  Brick Breaker
//
//  Created by James Topham on 12/06/2014.
//  Copyright (c) 2014 James Topham. All rights reserved.
//

#import "JTMyScene.h"
#import "JTBrick.h"

@interface JTMyScene()

@property (nonatomic) int lives;
@property (nonatomic) int currentLevel;

@end

@implementation JTMyScene
{
    SKSpriteNode *_paddle;
    CGPoint _touchLocation;
    CGFloat _ballSpeed;
    SKNode *_brickLayer;
    BOOL _ballReleased;
    BOOL _positionBall;
    NSArray *_hearts;
    SKLabelNode *_levelDisplay;

}

static const uint32_t kFinalLevelNumber = 4;

static const uint32_t kBallCategory   = 0x1 << 0;
static const uint32_t kPaddleCategory = 0x1 << 1;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
        background.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:background];
        
        SKSpriteNode *bar = [SKSpriteNode spriteNodeWithColor:[UIColor grayColor] size:CGSizeMake(self.size.width, 28)];
        bar.position = CGPointMake(0, size.height);
        bar.anchorPoint = CGPointMake(0, 1);
        [self addChild:bar];
        
        // Set contact delgate.
        self.physicsWorld.contactDelegate = self;
        
        // Turn off gravity.
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        
        // Setup edge.
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, -125, size.width, size.height + 100)];
        
        // Setup level display
        _levelDisplay = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
        _levelDisplay.fontColor = [SKColor whiteColor];
        _levelDisplay.fontSize = 15;
        _levelDisplay.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _levelDisplay.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        _levelDisplay.position = CGPointMake(10, -5);
        [bar addChild:_levelDisplay];
        
        
        // Setup brick layer.
        _brickLayer = [SKNode node];
        _brickLayer.position = CGPointMake(0, self.size.height - 32);
        [self addChild:_brickLayer];
        
        // Create positioning ball.
        SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"BallBlue"];
        ball.position = CGPointMake(0, _paddle.size.height);
        [_paddle addChild:ball];
        
        // Setup hearts. 26x22
        _hearts = @[[SKSpriteNode spriteNodeWithImageNamed:@"HeartFull"],
                    [SKSpriteNode spriteNodeWithImageNamed:@"HeartFull"],
                    [SKSpriteNode spriteNodeWithImageNamed:@"HeartFull"]];
        for (NSUInteger i = 0; i < _hearts.count; i++) {
            SKSpriteNode *heart = (SKSpriteNode*)[_hearts objectAtIndex:i];
            heart.position = CGPointMake(self.size.width - (16 + (29 * i)), self.size.height - 14);
            [self addChild:heart];
        }

        
        _paddle = [SKSpriteNode spriteNodeWithImageNamed:@"Paddle"]; // loads a paddle
        _paddle.position = CGPointMake(self.size.width/2, 90); // sets the paddle position
        _paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_paddle.size]; // gives the paddle a physics body
        _paddle.physicsBody.dynamic = NO; // paddle can be bounced off but will not be moved by other physic bodies
        _paddle.physicsBody.categoryBitMask = kPaddleCategory; // adds the paddle to a bitmask category
        [self addChild:_paddle];// adds paddle to the screen
        
        // Set initial values.
        _ballSpeed = 250.0;
        self.currentLevel = 1;
        [self loadLevel:self.currentLevel];
        [self newBall];
        self.lives = 3;

        
    }
    return self;
}

-(void)newBall
{
    [self enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) { // finds all balls on screen
        [node removeFromParent]; // removes any balls found on screen
    }];
    // Create positioning ball.
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"BallBlue"]; // loads a ball
    ball.position = CGPointMake(0, _paddle.size.height); // sets the position the ball gets placed at
    [_paddle addChild:ball]; // adds it to the screen on top of the paddle
    _ballReleased = NO; // makes the ball stay on the paddle until users touch is released
    _paddle.position = CGPointMake(self.size.width/2, _paddle.position.y); // sets paddle position to be center of the screen
}

-(void)setLives:(int)lives
{
    _lives = lives;
    for (NSUInteger i = 0; i < _hearts.count; i++) {
        SKSpriteNode *heart = (SKSpriteNode*)[_hearts objectAtIndex:i];
        if (lives > i) {
            heart.texture = [SKTexture textureWithImageNamed:@"HeartFull"];
        } else {
            heart.texture = [SKTexture textureWithImageNamed:@"HeartEmpty"];
        }
    }
}


-(BOOL)isLevelComplete
{
    // Look for remaining bricks that are not indestructible.
    for (SKNode *node in _brickLayer.children) {
        if ([node isKindOfClass:[JTBrick class]]) {
            if (!((JTBrick*)node).indestructible) {
                return NO;
            }
        }
    }
    // Couldn't find any non-indestructible bricks
    return YES;
}

-(void)setCurrentLevel:(int)currentLevel
{
    _currentLevel = currentLevel;
    _levelDisplay.text = [NSString stringWithFormat:@"Level %d", currentLevel];
    
}

-(SKSpriteNode*)createBallWithLocation:(CGPoint)position andVelocity:(CGVector)velocity
{
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"BallBlue"]; // loads a ball
    ball.name = @"ball"; // gives the ball a name
    ball.position = position; // sets the position of the ball
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.size.width/2]; // gives the ball a physics body
    ball.physicsBody.friction = 0.0; // stops ball from slowing down when bouning off the edges
    ball.physicsBody.linearDamping = 0.0; // stops ball from slowing down as it moves in the air
    ball.physicsBody.restitution = 1.0; // how much the ball bounces
    ball.physicsBody.velocity = velocity; // speed the ball moves
    ball.physicsBody.categoryBitMask = kBallCategory; // adds the ball to a bitMask category
    ball.physicsBody.contactTestBitMask = kPaddleCategory | kBrickCategory; // look for contacts between the categories
    [self addChild:ball]; // add the ball to the screen
    return ball;
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody;
    SKPhysicsBody *secondBody;
    if (contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask) { // Checks if bodyA category bit mask is greater than bodyB
        firstBody = contact.bodyB; // Sets the firstBody to be bodyB as it has a lower category bit mask than bodyA
        secondBody = contact.bodyA; // Sets the secondBody to be bodyA as it has a higher category bit mask than bodyB
    } else {
        firstBody = contact.bodyA; // Sets the firstBody to be bodyA as it has a lower category bit mask than bodyB
        secondBody = contact.bodyB; // Sets the secondBody to be bodyB as it has a higher category bit mask than bodyA
    }
    if (firstBody.categoryBitMask == kBallCategory && secondBody.categoryBitMask == kBrickCategory) {
        if (firstBody.categoryBitMask == kBallCategory && secondBody.categoryBitMask == kBrickCategory) {
            if ([secondBody.node respondsToSelector:@selector(hit)]) {
                [secondBody.node performSelector:@selector(hit)];
            }
        }
    }
    
    if (firstBody.categoryBitMask == kBallCategory && secondBody.categoryBitMask == kPaddleCategory) {
        if (firstBody.node.position.y > secondBody.node.position.y) {
            // Get contact point in paddle coordinates.
            CGPoint pointInPaddle = [secondBody.node convertPoint:contact.contactPoint fromNode:self];
            // Get contact position as a percentage of the paddle's width.
            CGFloat x = (pointInPaddle.x + secondBody.node.frame.size.width/2) / secondBody.node.frame.size.width;
            // Cap percentage and flip it from going from 1.0-0.0 to going from 0.0-1.0
            CGFloat multiplier = 1.0 - fmaxf(fminf(x, 1.0),0.0);
            // Calculate angle based on position in paddle, M_PI_2 is π/2 or 90 degrees, M_PI_4 is π/4 or 45 degrees
            CGFloat angle = (M_PI_2 * multiplier) /* Sets a 90 degree range */ + M_PI_4; // moves the range round by 45 degrees
            // Convert angle to vector.
            CGVector direction = CGVectorMake(cosf(angle) /* Gets the position on the x axis */, sinf(angle)); // Gets the position on the y axis
            // Set ball's velocity based on direction and speed.
            firstBody.velocity = CGVectorMake(direction.dx * _ballSpeed /* Takes balls x direction * by ball's speed */, direction.dy * _ballSpeed); // Takes balls y direction * by ball's speed
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    for (UITouch *touch in touches) {
        if (!_ballReleased) {
            _positionBall = YES;
        }
        _touchLocation = [touch locationInNode:self];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        // Calculate how far touch has moved on x axis.
        CGFloat xMovement = [touch locationInNode:self].x - _touchLocation.x;
        // Move paddle distance of touch.
        _paddle.position = CGPointMake(_paddle.position.x + xMovement, _paddle.position.y);
        
        CGFloat paddleMinX = -_paddle.size.width/4;
        CGFloat paddleMaxX = self.size.width + (_paddle.size.width/4);
        // Cap paddle's position so it remains on screen.
        if (_paddle.position.x < paddleMinX) {
            _paddle.position = CGPointMake(paddleMinX, _paddle.position.y);
        }
        if (_paddle.position.x > paddleMaxX) {
            _paddle.position = CGPointMake(paddleMaxX, _paddle.position.y);
        }
        
        _touchLocation = [touch locationInNode:self];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_positionBall) {
        _positionBall = NO;
        _ballReleased = YES;
        [_paddle removeAllChildren];
        [self createBallWithLocation:CGPointMake(_paddle.position.x, _paddle.position.y + _paddle.size.height) andVelocity:CGVectorMake(0, _ballSpeed)];
    }
}

-(void)didSimulatePhysics {
    [self enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.frame.origin.y + node.frame.size.height < 0) {
            // Ball gone off the bottom of the screen
            [node removeFromParent];
        }
    }];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if ([self isLevelComplete]) {
        self.currentLevel++;
        if (self.currentLevel > kFinalLevelNumber) {
            self.currentLevel = 1;
            self.lives = 3;
        }
        [self loadLevel:self.currentLevel];
        [self newBall];
    } else if (_ballReleased && !_positionBall && ![self childNodeWithName:@"ball"]) {
        // Lost all balls.
        self.lives--;
        if (self.lives < 0) {
            self.lives = 3;
            self.currentLevel = 1;
            [self loadLevel:self.currentLevel];
        }
        [self newBall];
    }
}

-(void)loadLevel:(int)levelNumber
{
    [_brickLayer removeAllChildren];
    
    NSArray *level = nil;
    switch (levelNumber) {
        case 1:
            level = @[@[@1,@1,@1,@1,@1,@1],
                      @[@0,@1,@1,@1,@1,@0],
                      @[@0,@0,@0,@0,@0,@0],
                      @[@0,@0,@0,@0,@0,@0],
                      @[@0,@2,@2,@2,@2,@0]];
            break;
        case 2:
            level = @[@[@1,@1,@2,@2,@1,@1],
                      @[@2,@2,@0,@0,@2,@2],
                      @[@2,@0,@0,@0,@0,@2],
                      @[@0,@0,@1,@1,@0,@0],
                      @[@1,@0,@1,@1,@0,@1],
                      @[@1,@1,@3,@3,@1,@1]];
            break;
        case 3:
            level = @[@[@1,@0,@1,@1,@0,@1],
                      @[@1,@0,@1,@1,@0,@1],
                      @[@0,@0,@3,@3,@0,@0],
                      @[@2,@0,@0,@0,@0,@2],
                      @[@0,@0,@1,@1,@0,@0],
                      @[@3,@2,@1,@1,@2,@3]];
            break;
        case 4:
            level = @[@[@1,@2,@1,@1,@2,@1],
                      @[@2,@0,@2,@2,@0,@2],
                      @[@1,@2,@1,@1,@2,@1],
                      @[@1,@0,@2,@2,@0,@1],
                      @[@2,@1,@0,@0,@1,@2],
                      @[@4,@4,@3,@3,@4,@4]];
        default:
            break;
    }
    
    int row = 0;
    int col = 0;
    for (NSArray *rowBricks in level) {// starts a loop until all row's and coloum's are full
        col = 0;
        for (NSNumber *brickType in rowBricks) { // finds what types of bricks in the row
            if ([brickType intValue] > 0) { // makes sure there is a brick there
                JTBrick *brick = [[JTBrick alloc] initWithType:(BrickType)[brickType intValue]]; // loads a brick of the right type
                if (brick) { // checks if there is a brick to be loaded
                    brick.position = CGPointMake(2 + (brick.size.width/2) + ((brick.size.width + 3) * col)
                                                 , -(2 + (brick.size.height/2) + ((brick.size.height + 3) * row))); // sets the position of the brick
                    [_brickLayer addChild:brick]; // adds the brick to the brickLayer
                }
            }
            col++; // adds 1 to the coloum
        }
        row++; // adds 1 to the row
    }
    
}

@end