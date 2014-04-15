//
//  MyScene.m
//  pond
//
//  Created by Julie Lee on 3/29/14.
//  Copyright (c) 2014 Julie Lee. All rights reserved.
//

#import "MyScene.h"
#import "SKTAudio.h"
#import "GameOverScene.h"

@import AVFoundation;

AVAudioPlayer *_backgroundAudioPlayer;
//static const uint32_t fishCategory   = 0x1 << 1; // series of box


static inline CGPoint CGPointAdd(const CGPoint a,
                                 const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
    
}

static inline CGPoint CGPointSubtract(const CGPoint a,
                                      const CGPoint b)
{
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a,
                                            const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}

static inline CGFloat CGPointLength(const CGPoint a)
{
    return sqrtf(a.x * a.x + a.y * a.y);
}

static inline CGPoint CGPointNormalize(const CGPoint a)
{
    CGFloat length = CGPointLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

static inline CGFloat CGPointToAngle(const CGPoint a)
{
    return atan2f(a.y, a.x);
}

static inline CGFloat ScalarSign(CGFloat a)
{
    return a >= 0 ? 1 : -1;
}

// Returns shortest angle between two angles,
// between -M_PI and M_PI
static inline CGFloat ScalarShortestAngleBetween(
                                                 const CGFloat a, const CGFloat b)
{
    CGFloat difference = b - a;
    CGFloat angle = fmodf(difference, M_PI * 2);
    if (angle >= M_PI) {
        angle -= M_PI * 2;
    }
    else if (angle <= -M_PI) {
        angle += M_PI * 2;
    }
    return angle;
}

#define ARC4RANDOM_MAX      0x100000000
static inline CGFloat ScalarRandomRange(CGFloat min,
                                        CGFloat max)
{
    return floorf(((double)arc4random() / ARC4RANDOM_MAX) *
                  (max - min) + min);
}

static const float CHARACTER_MOVE_POINTS_PER_SEC = 120.0;
static const float CHARACTER_ROTATE_RADIANS_PER_SEC = 4 * M_PI;
static const float WATER_MOVE_POINTS_PER_SEC = 60.0;
static const uint32_t obstacleCategory =  0x1 << 1;
static const float BG_VELOCITY = 100.0;
static const float OBJECT_VELOCITY = 50.0;


@interface MyScene()
@property SKSpriteNode* enemy;
@property SKSpriteNode* fish;

@property SKSpriteNode* fishTail1;
@property SKSpriteNode* fishTail2;
@property SKSpriteNode* fishTail3;

@property SKPhysicsJoint* myJoint1;
@property SKPhysicsJoint* myJoint2;
@property SKPhysicsJoint* myJoint3;
@end

@implementation MyScene
{
    SKSpriteNode *_character;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    CGPoint _velocity;
    CGPoint _lastTouchLocation;
    SKAction *_characterAnimation;
    SKAction *_waterCollisionSound;
    SKAction *_enemyCollisionSound;
    SKAction *_backgroundSound;
    BOOL _invincible;
}
-(void) fishclass{
    _enemy =[SKSpriteNode spriteNodeWithImageNamed:@"enemy"];
    [_enemy setPosition:CGPointMake(200, 200)];
    _enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_enemy.size];
    [self addChild:_enemy];

    _fishTail1 =  [SKSpriteNode spriteNodeWithImageNamed:@"fishtail01"];
    [_fishTail1 setPosition:CGPointMake(210, 230)];
    _fishTail1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_fishTail1.size];
    [self addChild:_fishTail1];
    
    _fishTail2 =  [SKSpriteNode spriteNodeWithImageNamed:@"fishtail02"];
    [_fishTail2 setPosition:CGPointMake(210, 250)];
    _fishTail2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_fishTail2.size];
    [self addChild:_fishTail2];
    
    _fishTail3 =  [SKSpriteNode spriteNodeWithImageNamed:@"fishtail03"];
    [_fishTail3 setPosition:CGPointMake(210, 270)];
    _fishTail3.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_fishTail3.size];
    [self addChild:_fishTail3];
    
 //   [self addChild:_enemy];
    
    SKAction *actionMove =
    [SKAction moveToX:-_enemy.size.width/2 duration:2.0];
    SKAction *actionRemove = [SKAction removeFromParent];
    [_enemy runAction:
     [SKAction sequence:@[actionMove, actionRemove]]];
    [_fishTail1.physicsBody setDynamic:NO];
    [_fishTail2.physicsBody setDynamic:NO];
    [_fishTail3.physicsBody setDynamic:NO];
    [_enemy.physicsBody setDynamic:NO];
    
    //position
    _enemy.name = @"enemy";
    _enemy.position = CGPointMake(
                                  self.size.width + _enemy.size.width/2,
                                  ScalarRandomRange(_enemy.size.height/2,
                                                    self.size.height-_enemy.size.height/2));
    //gravity
    //[_fishBody.physicsBody setRestitution:1.0];
    //[_fishTail1.physicsBody setRestitution:1.0];
    //[_fishTail2.physicsBody setRestitution:1.0];
    //[_fishTail3.physicsBody setRestitution:1.0];
    
    //image
    
    /*
    SKSpriteNode *enemy =
    [SKSpriteNode spriteNodeWithImageNamed:@"enemy"];
    enemy.name = @"enemy";
    enemy.position = CGPointMake(
                                 self.size.width + enemy.size.width/2,
                                 ScalarRandomRange(enemy.size.height/2,
                                                   self.size.height-enemy.size.height/2));
    [self addChild:enemy];
    
    SKAction *actionMove =
    [SKAction moveToX:-enemy.size.width/2 duration:2.0];
    SKAction *actionRemove = [SKAction removeFromParent];
    [enemy runAction:
     [SKAction sequence:@[actionMove, actionRemove]]];*/

}
-(void)fishJoint{
    _myJoint1 =[SKPhysicsJointLimit jointWithBodyA:_enemy.physicsBody bodyB:_fishTail1.physicsBody anchorA:_enemy.position anchorB:_fishTail1.position];
    [self.physicsWorld addJoint:_myJoint1];
    
    _myJoint2 =[SKPhysicsJointLimit jointWithBodyA:_enemy.physicsBody bodyB:_fishTail2.physicsBody anchorA:_enemy.position anchorB:_fishTail2.position];
    [self.physicsWorld addJoint:_myJoint2];
    
    _myJoint3 =[SKPhysicsJointLimit jointWithBodyA:_enemy.physicsBody bodyB:_fishTail3.physicsBody anchorA:_enemy.position anchorB:_fishTail3.position];
    [self.physicsWorld addJoint:_myJoint3];
}

//


//background
-(void)initalizingScrollingBackground
{
    for (int i = 0; i < 2; i++) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg"];
        bg.position = CGPointMake(i * bg.size.width, 0);
        bg.anchorPoint = CGPointZero;
        bg.name = @"bg";
        [self addChild:bg];
 
    }
}
//message

- (void)moveBg
{
    [self enumerateChildNodesWithName:@"bg" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode * bg = (SKSpriteNode *) node;
         CGPoint bgVelocity = CGPointMake(-BG_VELOCITY, 0);
         CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,_dt);
         bg.position = CGPointAdd(bg.position, amtToMove);
         
         //Checks if bg node is completely scrolled of the screen, if yes then put it at the end of the other node
         if (bg.position.x <= -bg.size.width)
         {
             bg.position = CGPointMake(bg.position.x + bg.size.width*2,
                                       bg.position.y);
         }
     }];
}
- (void)moveObstacle
{
    NSArray *nodes = self.children;//1
    
    for(SKNode * node in nodes){
        if (![node.name  isEqual: @"bg"] && ![node.name  isEqual: @"character"]) {
            SKSpriteNode *ob = (SKSpriteNode *) node;
            CGPoint obVelocity = CGPointMake(-OBJECT_VELOCITY, 0);
            CGPoint amtToMove = CGPointMultiplyScalar(obVelocity,_dt);
            
            ob.position = CGPointAdd(ob.position, amtToMove);
            if(ob.position.x < -100)
            {
                [ob removeFromParent];
            }
        }
    }
}
//music


//

//back----
-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        //

        //
        [self initalizingScrollingBackground];
        [self fishclass];
        [self fishJoint];
        //background image
        /*
        SKSpriteNode *bg1 =
        [SKSpriteNode spriteNodeWithImageNamed:@"background1"];
        bg1.position =
        CGPointMake(self.size.width/2, self.size.height/2);
        bg1.position =
        CGPointMake(self.size.width / 2, self.size.height / 2);
        bg1.anchorPoint = CGPointMake(0.5, 0.5); // same as default
        //bg.zRotation = M_PI / 8;
        [self addChild:bg1];
        CGSize mySize = bg1.size;
        NSLog(@"Size: %@", NSStringFromCGSize(mySize));
        */

        
        //add background music
        [[SKTAudio sharedInstance] playBackgroundMusic:@"bg1.mp3"];

        //add character
        _character = [SKSpriteNode spriteNodeWithImageNamed:@"character0"];
        _character.position = CGPointMake(100, 100);
        _character.zPosition = 100;
        [self addChild:_character];
        // 1
        NSMutableArray *textures =
        [NSMutableArray arrayWithCapacity:10];
        // 2
        for (int i = 1; i < 4; i++) {
            NSString *textureName =
            [NSString stringWithFormat:@"character%d", i];
            SKTexture *texture =
            [SKTexture textureWithImageNamed:textureName];
            [textures addObject:texture];
        }
        // 3
        for (int i = 4; i > 1; i--) {
            NSString *textureName =
            [NSString stringWithFormat:@"character%d", i];
            SKTexture *texture =
            [SKTexture textureWithImageNamed:textureName];
            [textures addObject:texture];
        }
        // 4
        _characterAnimation =
        [SKAction animateWithTextures:textures timePerFrame:0.6];
        // 5 edit
        [_character runAction:
         [SKAction repeatActionForever:_characterAnimation]];
        
        [_character setScale:1.0]; // SKNode method
        //
        _waterCollisionSound = [SKAction playSoundFileNamed:@"water6.mp3"
                                          waitForCompletion:NO];
        _enemyCollisionSound =
        [SKAction playSoundFileNamed:@"Lose.mp3"
                   waitForCompletion:NO];
        //
        
        [self runAction:[SKAction repeatActionForever:
                         [SKAction sequence:@[
                                              [SKAction performSelector:@selector(fishclass)
                                                               onTarget:self],
                                              [SKAction waitForDuration:1.2]]]]];
        
        [self runAction:[SKAction repeatActionForever:
                         [SKAction sequence:@[
                                              [SKAction performSelector:@selector(spawnwater)
                                                               onTarget:self],
                                              [SKAction waitForDuration:0.9]]]]];
        
    }
    return self;
}

//// Gesture recognizer example
//// Uncomment this, and comment the touchesBegan/Moved/Ended methods to test
//- (void)didMoveToView:(SKView *)view
//{
//  UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//  [self.view addGestureRecognizer:tapRecognizer];
//}
//
//- (void)handleTap:(UITapGestureRecognizer *)recognizer {
//  CGPoint touchLocation = [recognizer locationInView:self.view];
//  touchLocation = [self convertPointFromView:touchLocation];
//  [self moveZombieToward:touchLocation];
//}

- (void)update:(CFTimeInterval)currentTime{
//-(void)update:(CFTimeInterval)currentTime {
    
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else {
        _dt = 0;
    }
    
    _lastUpdateTime = currentTime;
    [self moveBg];

    //background

    //NSLog(@"%0.2f milliseconds since last update", _dt * 1000);
    
    CGPoint offset = CGPointSubtract(_lastTouchLocation, _character.position);
    float distance = CGPointLength(offset);
    if (distance < CHARACTER_MOVE_POINTS_PER_SEC * _dt) {
        _character.position = _lastTouchLocation;
        _velocity = CGPointZero;
        [self stopCharacterAnimation];
    } else {
        [self moveSprite:_character velocity:_velocity];
        [self boundsCheckPlayer];
        [self rotateSprite:_character toFace:_velocity rotateRadiansPerSec:CHARACTER_ROTATE_RADIANS_PER_SEC];
    }
    [self fishJoint];

    [self moveTrain];
    //[self checkCollisions];
}

- (void)didEvaluateActions {
    [self checkCollisions];
}

- (void)moveSprite:(SKSpriteNode *)sprite
          velocity:(CGPoint)velocity
{
    // 1
    CGPoint amountToMove = CGPointMultiplyScalar(velocity, _dt);
    //NSLog(@"Amount to move: %@",
    //      NSStringFromCGPoint(amountToMove));
    
    // 2
    sprite.position = CGPointAdd(sprite.position, amountToMove);
}

- (void)moveCharacterToward:(CGPoint)location
{
    [self startCharacterAnimation];
    _lastTouchLocation = location;
    CGPoint offset = CGPointSubtract(location, _character.position);
    
    CGPoint direction = CGPointNormalize(offset);
    _velocity = CGPointMultiplyScalar(direction, CHARACTER_MOVE_POINTS_PER_SEC);
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
    CGPoint location = [touch locationInNode:self];
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self.scene];
    [self moveCharacterToward:touchLocation];
    [_character setPosition:location];
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self.scene];
    [self moveCharacterToward:touchLocation];
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        [_character setPosition:location];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self.scene];
    [self moveCharacterToward:touchLocation];
}

- (void)boundsCheckPlayer
{
    // 1
    CGPoint newPosition = _character.position;
    CGPoint newVelocity = _velocity;
    
    // 2
    CGPoint bottomLeft = CGPointZero;
    CGPoint topRight = CGPointMake(self.size.width,
                                   self.size.height);
    
    // 3
    if (newPosition.x <= bottomLeft.x) {
        newPosition.x = bottomLeft.x;
        newVelocity.x = -newVelocity.x;
    }
    if (newPosition.x >= topRight.x) {
        newPosition.x = topRight.x;
        newVelocity.x = -newVelocity.x;
    }
    if (newPosition.y <= bottomLeft.y) {
        newPosition.y = bottomLeft.y;
        newVelocity.y = -newVelocity.y;
    }
    if (newPosition.y >= topRight.y) {
        newPosition.y = topRight.y;
        newVelocity.y = -newVelocity.y;
    }
    
    // 4
    _character.position = newPosition;
    _velocity = newVelocity;
}

- (void)rotateSprite:(SKSpriteNode *)sprite
              toFace:(CGPoint)velocity
 rotateRadiansPerSec:(CGFloat)rotateRadiansPerSec
{
    float targetAngle = CGPointToAngle(velocity);
    float shortest = ScalarShortestAngleBetween(sprite.zRotation, targetAngle);
    float amtToRotate = rotateRadiansPerSec * _dt;
    if (ABS(shortest) < amtToRotate) {
        amtToRotate = ABS(shortest);
    }
    sprite.zRotation += ScalarSign(shortest) * amtToRotate;
}

- (void)startCharacterAnimation
{
    if (![_character actionForKey:@"animation"]) {
        [_character runAction:
         [SKAction repeatActionForever:_characterAnimation]
                      withKey:@"animation"];
    }
}

- (void)stopCharacterAnimation
{
    [_character removeActionForKey:@"animation"];
}

- (void)spawnwater
{
    // 1
    SKSpriteNode *water =
    [SKSpriteNode spriteNodeWithImageNamed:@"water"];
    water.name = @"water";
    water.position = CGPointMake(
                                 ScalarRandomRange(0, self.size.width),
                                 ScalarRandomRange(0, self.size.height));
    water.xScale = 0;
    water.yScale = 0;
    [self addChild:water];
    
    // 2
    water.zRotation = -M_PI / 16;
    
    SKAction *appear = [SKAction scaleTo:0.5 duration:0.9];
    
    SKAction *leftWiggle = [SKAction rotateByAngle:M_PI / 8
                                          duration:0.5];
    SKAction *rightWiggle = [leftWiggle reversedAction];
    SKAction *fullWiggle =[SKAction sequence:
                           @[leftWiggle, rightWiggle]];
    //SKAction *wiggleWait =
    //  [SKAction repeatAction:fullWiggle count:10];
    //SKAction *wait = [SKAction waitForDuration:10.0];
    
    SKAction *scaleUp = [SKAction scaleBy:0.7 duration:0.3];
    SKAction *scaleDown = [scaleUp reversedAction];
    SKAction *fullScale = [SKAction sequence:
                           @[scaleUp, scaleDown, scaleUp, scaleDown]];
    
    SKAction *group = [SKAction group:@[fullScale, fullWiggle]];
    SKAction *groupWait = [SKAction repeatAction:group count:10];
    
    SKAction *disappear = [SKAction scaleTo:0.0 duration:0.5];
    SKAction *removeFromParent = [SKAction removeFromParent];
    [water runAction:
     [SKAction sequence:@[appear, groupWait, disappear,
                          removeFromParent]]];
}

- (void)checkCollisions
{
    [self enumerateChildNodesWithName:@"water"
                           usingBlock:^(SKNode *node, BOOL *stop){
                               SKSpriteNode *water = (SKSpriteNode *)node;
                               if (CGRectIntersectsRect(water.frame, _character.frame)) {
                                   //[water removeFromParent];
                                   [self runAction:_waterCollisionSound];
                                   water.name = @"train";
                                   //[water removeAllActions];
                                   [water setScale:0.4];
                                   water.zRotation = 0;
                                   [water runAction:[SKAction colorizeWithColor:[SKColor whiteColor] colorBlendFactor:1.0 duration:0.2]];
                               }
                           }];
    
    if (_invincible) return;
    
    [self enumerateChildNodesWithName:@"enemy"
                           usingBlock:^(SKNode *node, BOOL *stop){
                               SKSpriteNode *enemy = (SKSpriteNode *)node;
                               CGRect smallerFrame = CGRectInset(enemy.frame, 20, 20);
                               if (CGRectIntersectsRect(smallerFrame, _character.frame)) {
                                   //[enemy removeFromParent];
                                   //[self runAction:[SKAction playSoundFileNamed:@"enemy.mp3" waitForCompletion:NO]];
                                   [self runAction:_enemyCollisionSound];
                                   _invincible = YES;
                                   float blinkTimes = 3;
                                   float blinkDuration = 5.0;
                                   SKAction *blinkAction =
                                   [SKAction customActionWithDuration:blinkDuration
                                                          actionBlock:
                                    ^(SKNode *node, CGFloat elapsedTime) {
                                        float slice = blinkDuration / blinkTimes;
                                        float remainder = fmodf(elapsedTime, slice);
                                        node.hidden = remainder > slice / 2;
                                    }];
                                   SKAction *sequence = [SKAction sequence:@[blinkAction, [SKAction runBlock:^{
                                       _character.hidden = NO;
                                       _invincible = NO;
                                   }]]];
                                   [_character runAction:sequence];
                                   SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
                                   SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
                                   [self.view presentScene:gameOverScene transition: reveal];
                               }
                           }];
}

- (void)moveTrain
{
    __block CGPoint targetPosition = _character.position;
    [self enumerateChildNodesWithName:@"train"
                           usingBlock:^(SKNode *node, BOOL *stop){
                               if (!node.hasActions) {
                                   float actionDuration = 0.1;
                                   CGPoint offset = CGPointSubtract(targetPosition, node.position);
                                   CGPoint direction = CGPointNormalize(offset);
                                   CGPoint amountToMovePerSec = CGPointMultiplyScalar(direction, WATER_MOVE_POINTS_PER_SEC);
                                   CGPoint amountToMove = CGPointMultiplyScalar(amountToMovePerSec, actionDuration);
                                   SKAction *moveAction = [SKAction moveByX:amountToMove.x y:amountToMove.y duration:actionDuration];
                                   [node runAction:moveAction];
                               }
                               targetPosition = node.position;
                           }];
}

@end
