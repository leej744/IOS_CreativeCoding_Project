//
//  MyScene.m
//  soundpond
//
//  Created by Julie Lee on 4/5/14.
//  Copyright (c) 2014 Julie Lee. All rights reserved.
//
#define DEVICE_SIZE [[[[UIApplication sharedApplication] keyWindow] rootViewController].view convertRect:[[UIScreen mainScreen] bounds] fromView:nil].size

#import "MyScene.h"
#import "SKTAudio.h"
#import "GameOverScene.h"
#import "WinScene.h"

@import CoreMotion;

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
static const float WATER_MOVE_POINTS_PER_SEC = 120.0;
static const uint32_t obstacleCategory =  0x1 << 1;
static const float BG_VELOCITY = 50.0;
static const float OBJECT_VELOCITY = 50.0;
static const float LIVE = 3.0;

@interface MyScene()
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
    float _lives;
    float _bonuslives;

    CMMotionManager *_motionManager;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    CGPoint _velocity;
    CGPoint _lastTouchLocation;
    SKAction *_characterAnimation;
    SKAction *_FishAnimation;
    SKAction *_removetrain;
    SKAction *_waterCollisionSound;
    SKAction *_enemyCollisionSound;
    SKAction *_backgroundSound;
    BOOL _invincible;
    SKLabelNode *_scoreNode;
    SKLabelNode *_liveNode;

    float _score;
    BOOL _gameRunning;

    SKAction *_scoreChangeAction;
    SKAction *_liveChangeAction;

}
-(void) fishclass{
    _enemy =[SKSpriteNode spriteNodeWithImageNamed:@"fish01"];
    _enemy.name = @"enemy";
    _enemy.scale = 0.6;
    _enemy.zPosition = 2;
    _enemy.position = CGPointMake(
                                  self.size.width + _enemy.size.width/2,
                                  ScalarRandomRange(_enemy.size.height/2,
                                                    self.size.height-_enemy.size.height/2));
    [self addChild:_enemy];
    SKAction *appear = [SKAction scaleTo:0.9 duration:0.9];
    [_enemy runAction:
     [SKAction sequence:@[appear]]];
    //_enemy.zRotation = -M_PI / 16;
    
    
    SKAction *leftWiggle = [SKAction rotateByAngle:M_PI / 8
                                          duration:0.1];
    SKAction *rightWiggle = [leftWiggle reversedAction];
    SKAction *fullWiggle =[SKAction sequence:
                           @[leftWiggle, rightWiggle]];
    //SKAction *wiggleWait =
    //  [SKAction repeatAction:fullWiggle count:10];
    //SKAction *wait = [SKAction waitForDuration:10.0];
    
    SKAction *scaleUp = [SKAction scaleBy:0.8 duration:0.8];
    SKAction *scaleDown = [scaleUp reversedAction];
    SKAction *fullScale = [SKAction sequence:
                           @[scaleUp, scaleDown, scaleUp, scaleDown]];
    
    SKAction *group = [SKAction group:@[fullScale, fullWiggle]];
    SKAction *groupWait = [SKAction repeatAction:group count:6];
    
    SKAction *removeFromParent = [SKAction removeFromParent];
    [_enemy runAction:
    [SKAction sequence:@[appear, groupWait,
                         removeFromParent]]];
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .1;
    self.motionManager.gyroUpdateInterval = .2;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 [self outputAccelertionData:accelerometerData.acceleration];
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
    //adding airplane shadow
    /*
    _enemyShadow = [SKSpriteNode spriteNodeWithImageNamed:@"shadow"];
    _enemyShadow.scale = 0.6;
    _enemyShadow.zPosition = 1;
    _enemyShadow.position = CGPointMake(_enemy.xScale,_enemy.yScale);
    [_enemy addChild:_enemyShadow];
    
    //adding propeller animation
    _propeller = [SKSpriteNode spriteNodeWithImageNamed:@"PLANE PROPELLER 1"];
    _propeller.scale = 0.2;
    _propeller.position = CGPointMake(_enemy.xScale,_enemy.yScale+10);
    
    SKTexture *propeller1 = [SKTexture textureWithImageNamed:@"PLANE PROPELLER 1"];
    SKTexture *propeller2 = [SKTexture textureWithImageNamed:@"PLANE PROPELLER 2"];
    
    SKAction *spin = [SKAction animateWithTextures:@[propeller1,propeller2] timePerFrame:0.1];
    SKAction *spinForever = [SKAction repeatActionForever:spin];
    [_propeller runAction:spinForever];
    
    [_enemy addChild:_propeller];*/
        
}

//------------------------
//------------------------------------


//background
-(void)initalizingScrollingBackground
{
   // _layerHudNode = [SKNode new];
    _lives=3;
    //setup HUD basics
    _lives = _lives+_bonuslives;
    _liveNode.text = [NSString stringWithFormat:@"Lives:%1.0f", _lives];
    
    screenRect = [[UIScreen mainScreen] bounds];
    screenHeight = screenRect.size.height;
    screenWidth = screenRect.size.width;

    for (int i = 0; i < 2; i++) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg"];
        bg.position = CGPointMake(i * bg.size.width, 0);
        bg.anchorPoint = CGPointZero;
        bg.name = @"bg";
        [self addChild:bg];
        
    }
    _liveNode = [SKLabelNode labelNodeWithFontNamed:@"helvetica"];
    _liveNode.fontSize = 18.0;

    _liveNode.text = @"Lives:";
    _liveNode.name = @"liveNode";
    _liveNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _liveNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _liveNode.zPosition = 5;

    _liveNode.position = CGPointMake(self.size.width-90, self.size.height - _liveNode.frame.size.height -2);
    
    [self addChild:_liveNode];
    
    _scoreNode = [SKLabelNode labelNodeWithFontNamed:@"helvetica"];
    _scoreNode.fontSize = 18.0;
    _scoreNode.zPosition = 5;

    _scoreNode.text = @"Score:0";
    _scoreNode.name = @"scoreNode";
    _scoreNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _scoreNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    
    _scoreNode.position = CGPointMake(6, self.size.height - _scoreNode.frame.size.height -2);
    
    [self addChild:_scoreNode];
    
    //shrink a bit as if the points were dropping in, then spring up with a bounce and settle at 1.0.
    _scoreChangeAction = [SKAction sequence:
                          @[[SKAction scaleXTo:.9 duration:0.1],
                            [SKAction scaleXTo:1.1 duration:0.1],
                            [SKAction scaleXTo:1.0 duration:0.1]]];
    
    _liveChangeAction = [SKAction sequence:
                          @[[SKAction scaleXTo:.9 duration:0.1],
                            [SKAction scaleXTo:1.1 duration:0.1],
                            [SKAction scaleXTo:1.0 duration:0.1]]];
    
    int hudHeight = 40;
    CGSize bgSize = CGSizeMake(self.size.width, hudHeight);
    SKColor *bgColor = [SKColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:0.70];
    SKSpriteNode *hudBackground = [SKSpriteNode spriteNodeWithColor:bgColor size:bgSize];
    hudBackground.zPosition = 2;
    
    hudBackground.position = CGPointMake(0, self.size.height - hudHeight);
    hudBackground.anchorPoint = CGPointZero;
    [self addChild:hudBackground];

}

- (void)increaseScoreBy:(float)amount
{
    _score += 1;
    _scoreNode.text = [NSString stringWithFormat:@"Score:%1.0f", _score];
}
- (void)increaselevelBy:(float)amount
{
    [self fishclass];
}
- (void)decreseLivesBy:(float)amount
{
    _lives -= 1;
    _liveNode.text = [NSString stringWithFormat:@"Lives:%1.0f", _lives];
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


//start----
-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        //
        _lives = _lives+_bonuslives;
        _liveNode.text = [NSString stringWithFormat:@"Lives:%1.0f", _lives];
        
        screenRect = [[UIScreen mainScreen] bounds];
        screenHeight = screenRect.size.height;
        screenWidth = screenRect.size.width;
        
        [self fishclass];
        

        
        [self initalizingScrollingBackground];
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

        _character.zPosition = 10;
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
        [SKAction playSoundFileNamed:@"pop.mp3"
                   waitForCompletion:NO];
        
#pragma mark - Setup the Accelerometer to move the ship
        _motionManager = [[CMMotionManager alloc] init];
        //------------//enemy
        

        
        [self runAction:[SKAction repeatActionForever:
                         [SKAction sequence:@[
                                              [SKAction performSelector:@selector(fishclass)
                                                               onTarget:self],
                                              [SKAction waitForDuration:3.0]]]]];
        
        [self runAction:[SKAction repeatActionForever:
                         [SKAction sequence:@[
                                              [SKAction performSelector:@selector(spawnwater)
                                                               onTarget:self],
                                              [SKAction waitForDuration:0.9]]]]];
        _gameRunning = YES;
        [self checkCollisions];

    }
    return self;
}
//accelertion
-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    currentMaxAccelX = 0;
    currentMaxAccelY = 0;

    if(fabs(acceleration.x) > fabs(currentMaxAccelX))
    {
        currentMaxAccelX = _motionManager.accelerometerData.acceleration.x;
    }
    if(fabs(_motionManager.accelerometerData.acceleration.y) > fabs(currentMaxAccelY))
    {
        currentMaxAccelY = _motionManager.accelerometerData.acceleration.y;
    }
    
    
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



- (void)didEndContact:(SKPhysicsContact *)contact {
    
    //rotate our monkey back to zero after contact has ended...
    [_character runAction:[SKAction rotateToAngle:0 duration:.5]];
}
-(void)update:(CFTimeInterval)currentTime{
    //-(void)update:(CFTimeInterval)currentTime {
    
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else {
        _dt = 0;
    }

    _lastUpdateTime = currentTime;

    [self moveBg];
    
    //background
    float maxY = screenRect.size.width - _enemy.size.width/2;
    float minY = _enemy.size.width/2;
    
    float maxX = screenRect.size.height - _enemy.size.height/2;
    float minX = _enemy.size.height/2;
    
    float newY = 0;
    float newX = 0;
    
    if(_motionManager.accelerometerData.acceleration.x < -0.05){//right
        NSLog(@"left");
        newX = _motionManager.accelerometerData.acceleration.y*5;
        _enemy.texture = [SKTexture textureWithImageNamed:@"fish02"];
        _enemy.zRotation = M_PI * 8;
    }
    else if(_motionManager.accelerometerData.acceleration.x > 0.01){//left
        NSLog(@"right");
        newX = _motionManager.accelerometerData.acceleration.y * 5;
        _enemy.texture = [SKTexture textureWithImageNamed:@"fish03"];
        _enemy.zRotation = -M_PI * 8;
    }
    else{
        _enemy.texture = [SKTexture textureWithImageNamed:@"fish01"];
        _enemy.texture = [SKTexture textureWithImageNamed:@"fish03"];
        _enemy.texture = [SKTexture textureWithImageNamed:@"fish01"];
        _enemy.texture = [SKTexture textureWithImageNamed:@"fish02"];
    }
    
    if(_motionManager.accelerometerData.acceleration.y > 0.05){//right
        NSLog(@"up");
        
        newY = _motionManager.accelerometerData.acceleration.x*10;
        _enemy.texture = [SKTexture textureWithImageNamed:@"fish02"];
        _enemy.zRotation = -M_PI / 4;

    }
    else if(_motionManager.accelerometerData.acceleration.y < -0.05){//left
        NSLog(@"down");
        newY = _motionManager.accelerometerData.acceleration.x * 10;
        _enemy.texture = [SKTexture textureWithImageNamed:@"fish03"];
        _enemy.zRotation = M_PI / 4;

    }
    else{
        _enemy.texture = [SKTexture textureWithImageNamed:@"fish01"];
        _enemy.texture = [SKTexture textureWithImageNamed:@"fish03"];
        _enemy.texture = [SKTexture textureWithImageNamed:@"fish01"];
        _enemy.texture = [SKTexture textureWithImageNamed:@"fish02"];
    }
    
    //newY = 6.0 + currentMaxAccelY *10;
    newX = MIN(MAX(newX+_enemy.position.x,minX),maxX);
    newY = MIN(MAX(newY+_enemy.position.y,minY),maxY);
    
    _enemy.position = CGPointMake(newX, newY);
    /* NSLog(@"y: %f", newY);
     NSLog(@"x: %f", newX);
     
     NSLog(@"width: %f", screenRect.size.width);
     NSLog(@"height: %f", screenRect.size.height);*/
    NSLog(@"accelerometer [%.2f, %.2f, %.2f]",
          _motionManager.accelerometerData.acceleration.x,
          _motionManager.accelerometerData.acceleration.y,
          newX);
    
    CGPoint offset = CGPointSubtract(_lastTouchLocation, _character.position);
    float distance = CGPointLength(offset);
    if (distance < CHARACTER_MOVE_POINTS_PER_SEC * _dt) {
        _character.position = _lastTouchLocation;
        _velocity = CGPointZero;
        [self stopCharacterAnimation];
    } else {
        [self moveSprite:_character velocity:_velocity];

    }

    [self moveTrain];
    [self checkCollisions];

}
- (void)fishanimation {

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
                                          duration:0.1];
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
    SKAction *groupWait = [SKAction repeatAction:group count:1];
    
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
                                   [water removeAllActions];
                                   [water setScale:_score*0.1];
                                   water.zRotation = 0;
                                   [water runAction:[SKAction colorizeWithColor:[SKColor whiteColor] colorBlendFactor:1.0 duration:0.0007]];
                                   _score += 1;
                                   _liveNode.text = [NSString stringWithFormat:@"Lives:[%1.0f]", _lives];
                                   _scoreNode.text = [NSString stringWithFormat:@"Score:[%1.0f]", _score];
                                   if (_score>10) {
                                       _bonuslives+=1;
                                       [water removeFromParent];
                                       SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
                                       SKScene * winScene = [[WinScene alloc] initWithSize:self.size];
                                       [self.view presentScene:winScene transition: reveal];
                                       _gameRunning = NO;
                                       if (_lives==4) {
                                           [self fishclass];
                                           [self fishclass];
                                       }
                                       if (_lives==5) {
                                           [self fishclass];
                                           [self fishclass];
                                           [self fishclass];
                                       }
                                   }
                               }
                           }];
    
    if (_invincible) return;
    
    [self enumerateChildNodesWithName:@"enemy"
                           usingBlock:^(SKNode *node, BOOL *stop){
                               SKSpriteNode *enemy = (SKSpriteNode *)node;
                               CGRect smallerFrame = CGRectInset(enemy.frame, 1, 1);
                               CGRect smallerFrame2 = CGRectInset(_character.frame, 5, 5);

                               if (CGRectIntersectsRect(smallerFrame, smallerFrame2)) {                                   //[self runAction:[SKAction playSoundFileNamed:@"enemy.mp3" waitForCompletion:NO]];
                                   [self runAction:_enemyCollisionSound];
                                   //_invincible = YES;
                                   float blinkTimes = 3;
                                   float blinkDuration = 1.0;
                                   SKAction *blinkAction =
                                   [SKAction customActionWithDuration:blinkDuration
                                                          actionBlock:
                                    ^(SKNode *node, CGFloat elapsedTime) {
                                        float slice = blinkDuration / blinkTimes;
                                        float remainder = fmodf(elapsedTime, slice);
                                        node.hidden = remainder > slice / 2;
                                    }];
                                   _lives -= 1;
                                   _liveNode.text = [NSString stringWithFormat:@"lives:[%1.0f]", _lives];
                                   [self runAction:_removetrain];
                                   [_enemy setScale:1.2];
                                   _score=0;
                                   SKAction *appear = [SKAction scaleTo:0.5 duration:2.0];
                                   [_enemy runAction:
                                    [SKAction sequence:@[appear]]];
                                   SKAction *sequence = [SKAction sequence:@[blinkAction, [SKAction runBlock:^{
                                       _character.hidden = NO;
                                       //_invincible = NO;
                                   }]]];
                                   [enemy removeFromParent];
                                   [_enemy runAction:sequence];
                                   [self enumerateChildNodesWithName:@"water"
                                                          usingBlock:^(SKNode *node, BOOL *stop){
                                                              SKSpriteNode *water = (SKSpriteNode *)node;
                                                              [water removeFromParent];
                                                              [water removeAllActions];
                                                              [water removeFromParent];

                                                          }];
                                   [self enumerateChildNodesWithName:@"character"
                                                          usingBlock:^(SKNode *node, BOOL *stop){
                                                              SKSpriteNode *character = (SKSpriteNode *)node;
                                                              [character removeFromParent];
                                                              [character removeAllActions];
                                                          }];


                                   if (_lives<1) {
                                       [enemy removeFromParent];
                                       SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
                                       SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
                                       [self.view presentScene:gameOverScene transition: reveal];
                                       _gameRunning = NO;
                                   }
                               }
                           }];
   // if (_invincible==YES) return;
}

- (void)moveTrain
{
    __block CGPoint targetPosition = _character.position;
    [self enumerateChildNodesWithName:@"train"
                           usingBlock:^(SKNode *node, BOOL *stop){
                               if (!node.hasActions) {
                                   float actionDuration = 0.1;
                                   CGPoint offset = CGPointSubtract(targetPosition,node.position);
                                   CGPoint direction = CGPointNormalize(offset);
                                   CGPoint amountToMovePerSec = CGPointMultiplyScalar(direction, WATER_MOVE_POINTS_PER_SEC);
                                CGPoint amountToMove = CGPointMultiplyScalar(amountToMovePerSec, actionDuration);

                                   SKAction *moveAction = [SKAction moveByX:amountToMove.x y:amountToMove.y duration:0.1];
                                   [node runAction:moveAction];
                               }
                               targetPosition = node.position;
                           }];
}
- (void)removeTrain
{
    __block CGPoint targetPosition = _character.position;
    [self enumerateChildNodesWithName:@"train"
                           usingBlock:^(SKNode *node, BOOL *stop){
                               if (!node.hasActions) {
                                   [_character removeActionForKey:@"train"];
                                   [self removeActionForKey:@"train"];
                               }
                               targetPosition = node.position;
                           }];
}
@end
