//
//  XYZMyScene.m
//  PhysicsGame
//
//  Created by Julie Lee on 2/18/14.
//  Copyright (c) 2014 Julie Lee. All rights reserved.
//

#import "XYZMyScene.h"

//@interface Classname
//global variable -SKSpriteNode class name * object
@interface XYZMyScene()
@property SKSpriteNode* mySquare1;
@property SKSpriteNode* mySquare2;
@property SKSpriteNode* mySquare3;
@property SKSpriteNode* mySquare4;
@property SKSpriteNode* box;//when user touch the screen, box will appear- createBox
@property SKSpriteNode*ball2;//ball2- createBall


@property SKPhysicsJoint* boxJoint;

@property SKPhysicsJoint* myJoint1;
@property SKPhysicsJoint* myJoint2;
@property SKPhysicsJoint* myJoint3;
@property SKSpriteNode* mybar1;
@property SKSpriteNode* mybar2;

@end

static const uint32_t boxCategory   = 0x1 << 1; // series of box

@implementation XYZMyScene

-(void) ballclass{// I tried to draw a rainbow as a background but couldn't... this is smile face shape.
    NSLog(@"Entered ball");
    
    SKShapeNode *ball = [[SKShapeNode alloc] init];
    CGMutablePathRef myPath = CGPathCreateMutable();

    CGPathAddArc(myPath, NULL, 130,200, 80, 0, M_PI*2, YES);
    ball.path = myPath;
    ball.fillColor = [SKColor yellowColor];
    
    SKShapeNode *ball2 = [[SKShapeNode alloc] init];
    
    CGPathAddArc(myPath, NULL, 90,240, 10, 0, M_PI*2, YES);
    ball2.path = myPath;
    ball2.fillColor = [SKColor redColor];
    
    SKShapeNode *ball3 = [[SKShapeNode alloc] init];
    
    CGPathAddArc(myPath, NULL, 160,240, 10, 0, M_PI*2, YES);
    ball3.path = myPath;
    ball3.fillColor = [SKColor redColor];

    //SKShapeNode *_ball = [[SKShapeNode alloc] init];
    //CGRect ballFrame = CGRectMake(-25.0, -25.0, 50.0, 50.0);

 //   _ball setPath:[[UIBezierPath bezierPathWithOvalInRect:ballFrame].CGPath];
    [self addChild:ball];
    [self addChild:ball2];
    [self addChild:ball3];

}

-(void) spawnSquares{
    NSLog(@"Entered SpawnSquares");
    
//creat a class * object

    
    _mySquare1 = [[SKSpriteNode alloc]initWithColor:[SKColor redColor] size:CGSizeMake(20, 20)];
    [_mySquare1 setPosition:CGPointMake(200, 200)];
    
    _mySquare1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_mySquare1.size];
    [self addChild:_mySquare1];
    
    _mySquare2 = [[SKSpriteNode alloc]initWithColor:[SKColor orangeColor] size:CGSizeMake(20, 20)];
    [_mySquare2 setPosition:CGPointMake(230, 230)];
    
    _mySquare2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_mySquare2.size];
    [self addChild:_mySquare2];

    _mySquare3 = [[SKSpriteNode alloc]initWithColor:[SKColor yellowColor] size:CGSizeMake(20, 20)];
    [_mySquare3 setPosition:CGPointMake(260, 260)];
    
    _mySquare3.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_mySquare3.size];
    [self addChild:_mySquare3];
    
    _mySquare4 = [[SKSpriteNode alloc]initWithColor:[SKColor greenColor] size:CGSizeMake(20, 20)];
    [_mySquare4 setPosition:CGPointMake(290, 290)];
    
    _mySquare4.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_mySquare4.size];
    [self addChild:_mySquare4];
    [_mySquare1.physicsBody setRestitution:1.0];
    [_mySquare2.physicsBody setRestitution:1.0];
    [_mySquare3.physicsBody setRestitution:1.0];
    [_mySquare4.physicsBody setRestitution:1.0];
}

-(void) squareBar{
    NSLog(@"obstacle");
    
    //creat a class * object
    _mybar1 = [[SKSpriteNode alloc]initWithColor:[SKColor whiteColor] size:CGSizeMake(70, 10)];
    [_mybar1 setPosition:CGPointMake(100, 300)];
    
    _mybar1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_mybar1.size];
    [self addChild:_mybar1];
    [_mybar1.physicsBody setDynamic:NO]; // effected by gravity
    
    _mybar2 = [[SKSpriteNode alloc]initWithColor:[SKColor whiteColor] size:CGSizeMake(70, 10)];
    [_mybar2 setPosition:CGPointMake(200, 120)];
    
    _mybar2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_mybar2.size];
    [self addChild:_mybar2];
    [_mybar2.physicsBody setDynamic:NO]; // effected by gravity

}


-(void)spawnJoint1{
    _myJoint1 =[SKPhysicsJointLimit jointWithBodyA:_mySquare1.physicsBody bodyB:_mySquare2.physicsBody anchorA:_mySquare1.position anchorB:_mySquare2.position];
    [self.physicsWorld addJoint:_myJoint1];
    
    _myJoint2 =[SKPhysicsJointLimit jointWithBodyA:_mySquare2.physicsBody bodyB:_mySquare3.physicsBody anchorA:_mySquare2.position anchorB:_mySquare3.position];
    [self.physicsWorld addJoint:_myJoint2];
    
    _myJoint3 =[SKPhysicsJointLimit jointWithBodyA:_mySquare3.physicsBody bodyB:_mySquare4.physicsBody anchorA:_mySquare3.position anchorB:_mySquare4.position];
    [self.physicsWorld addJoint:_myJoint3];
    

}


-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.scaleMode = SKSceneScaleModeAspectFit;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        [self.physicsBody setRestitution:1];
        [self ballclass];
        [self spawnSquares];
        [self spawnBackgroundWorld];
        [self spawnJoint1];

        [self squareBar];
    }
    return self;
}

-(void) spawnBackgroundWorld{
    NSLog(@"SpawnBackgroundWorld");
    self.backgroundColor = [SKColor blackColor];
    
    self.scaleMode = SKSceneScaleModeAspectFit;
    self.physicsBody= [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    [self.physicsBody setRestitution:0.5]; //bouncy
   // [_mybar1.physicsBody setDynamic:NO]; // effected by gravity

}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        [self addChild:[self createBox:location]];
        [_mySquare1 setPosition:location];
       // [_mySquare2 setPosition:_mySquare1];
        [_mySquare1.physicsBody setDynamic:NO]; // effected by gravity


    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        [_mySquare1 setPosition:location];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [_mySquare1.physicsBody setDynamic:YES];//effected by gravity

}
-(void)update:(CFTimeInterval)currentTime {
}

- (SKSpriteNode *)createBox:(CGPoint)location {
    SKSpriteNode *box = [[SKSpriteNode alloc]initWithColor:[SKColor colorWithRed:arc4random() % 256 / 256.0 green:arc4random() % 256 / 256.0 blue:arc4random() % 256 / 256.0 alpha:1.0]size:CGSizeMake(40, 40)];
    
    box.position = location;
    box.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(40, 40)];
    box.name = @"box";
    box.physicsBody.dynamic = YES;
    
    box.physicsBody.categoryBitMask = boxCategory;
    box.physicsBody.collisionBitMask = boxCategory ;
    box.physicsBody.contactTestBitMask = boxCategory ;

    return box;
}
/*
- (SKShapeNode *)createBall:(CGPoint)location {
    SKShapeNode *ball2 = [[SKShapeNode alloc] init];
    CGMutablePathRef myPath = CGPathCreateMutable();

    CGPathAddArc(myPath, NULL, 0,0, 15, 0, M_PI*2, YES);
    ball2.path = myPath;
    ball2.position=CGPointMake(500, 500);
    ball2.fillColor = [SKColor yellowColor];
    
    return ball2;
}*/ //fail......
@end
