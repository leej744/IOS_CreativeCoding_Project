//
//  MyScene.m
//  PhysicsCat
//
//  Created by Julie Lee on 3/16/14.
//  Copyright (c) 2014 Julie Lee. All rights reserved.
//
#import "SKTAudio.h"
#import "MyScene.h"
#import "SKSpriteNode+DebugDraw.h"
#import "SKTUtils.h"
BOOL _isHooked;
SKSpriteNode *_hookBaseNode;
SKSpriteNode *_hookNode;
SKSpriteNode *_ropeNode;

typedef NS_OPTIONS(uint32_t, CNPhysicsCategory){
    CNPhysicsCategoryCat =1 << 0,
    CNPhysicsCategoryBlock =1 << 1,
    CNPhysicsCategoryBed =1 << 2,
    CNPhysicsCategoryEdge =1 <<3,
    CNPhysicsCategoryLabel =1 <<4,
    CNPhysicsCategorySpring =1 <<5,
};
@interface MyScene()<SKPhysicsContactDelegate>
@end
@implementation MyScene
{
    SKNode *_gameNode;
    SKSpriteNode *_catNode;
    SKSpriteNode *_bedNode;
    
    int _currentLevel;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    //1
    UITouch *touch =[touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //2
    [self.physicsWorld enumerateBodiesAtPoint:location usingBlock:^(SKPhysicsBody*body, BOOL *stop){
     //3
        if (body.categoryBitMask == CNPhysicsCategoryBlock){
            [body.node removeFromParent];
            *stop =YES;//4
            
            //5
            [self runAction:[SKAction playSoundFileNamed:@"pop.mp3" waitForCompletion:NO]];
        }
        if (body.categoryBitMask == CNPhysicsCategorySpring){
            SKSpriteNode *spring = (SKSpriteNode*)body.node;
            [body applyImpulse:CGVectorMake(0, 12) atPoint:CGPointMake(spring.size.width/2, spring.size.height)];
            [body.node runAction:[SKAction sequence:@[[SKAction waitForDuration:1],[SKAction removeFromParent]]]];
            *stop =YES;
        }
    }
     ];
}
-(void)didBeginContact:(SKPhysicsContact *)contact{
    uint32_t collision = (contact.bodyA.categoryBitMask|contact.bodyB.categoryBitMask);
    if (collision == (CNPhysicsCategoryCat|CNPhysicsCategoryBed))
    {
        [self win];
    }
    
    if (collision ==(CNPhysicsCategoryCat|CNPhysicsCategoryEdge)){
        [self lose];
        }
}
-(instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        [self initializeScene];
    }
    return self;
}

-(void) initializeScene{
    self.physicsBody=[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    SKSpriteNode*bg =[SKSpriteNode spriteNodeWithImageNamed:@"background"];
    bg.position=CGPointMake(self.size.width/2, self.size.height/2);
    [self addChild:bg];
    
    [self addCatBed];
    _gameNode =[SKNode node];
    [self addChild:_gameNode];
    
    _currentLevel =2;
    [self setupLevel:_currentLevel];
    
    //
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsWorld.contactDelegate =self;
    self.physicsBody.categoryBitMask = CNPhysicsCategoryEdge;
}

-(void)addCatBed{
    _bedNode=[SKSpriteNode spriteNodeWithImageNamed:@"cat_bed"];
    _bedNode.position = CGPointMake(270, 15);
    [self addChild:_bedNode];
    
    CGSize contactSize =CGSizeMake(40, 30);
    _bedNode.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:contactSize];
    _bedNode.physicsBody.dynamic=NO;
    //
    _bedNode.physicsBody.categoryBitMask=CNPhysicsCategoryBed;
    
}
-(void)addCatAtPosition:(CGPoint)pos{
    //add the cat in the level on its starting position
    _catNode =[SKSpriteNode spriteNodeWithImageNamed:@"cat_sleepy"];
    _catNode.position = pos;
    
    [_gameNode addChild:_catNode];
    
    CGSize contactSize = CGSizeMake(_catNode.size.width-40, _catNode.size.height-10);
    _catNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:contactSize];
    [_catNode attachDebugRectWithSize:contactSize];
    
    //
    _catNode.physicsBody.categoryBitMask = CNPhysicsCategoryCat;
    
    //
    _catNode.physicsBody.contactTestBitMask = CNPhysicsCategoryBed|CNPhysicsCategoryEdge;
    //add proper collision bitmask for the cat
    _catNode.physicsBody.collisionBitMask = CNPhysicsCategoryBlock | CNPhysicsCategoryEdge|CNPhysicsCategorySpring;
}

-(void)setupLevel:(int)levelNum{
    //load the plist file
    NSString *fileName=[NSString stringWithFormat:@"level%i",levelNum];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    NSDictionary *level = [NSDictionary dictionaryWithContentsOfFile:filePath];
    [self addCatAtPosition:CGPointFromString(level[@"catPosition"])];
    [self addBlocksFromArray:level[@"blocks"]];
    [[SKTAudio sharedInstance] playBackgroundMusic:@"bgMusic.mp3"];
    [self addSpringsFromArray:level[@"springs"]];
    if(level[@"hookPosition"]){
        [self addHookAtPosition:CGPointFromString(level[@"hookPosition"])];
    }
}
-(void)addBlocksFromArray:(NSArray*)blocks{
    //1
    for (NSDictionary *block in blocks){
        //2
    
        SKSpriteNode *blockSprite = [self addBlockWithRect:CGRectFromString(block[@"rect"])];
        blockSprite.physicsBody.categoryBitMask = CNPhysicsCategoryBlock;
        blockSprite.physicsBody.collisionBitMask = CNPhysicsCategoryBlock | CNPhysicsCategoryCat | CNPhysicsCategoryEdge;
        [_gameNode addChild:blockSprite];
        
    }
}
-(SKSpriteNode*)addBlockWithRect:(CGRect)blockRect{
    //3
    NSString *textureName = [NSString stringWithFormat:@"%.fx%.f.png",blockRect.size.width, blockRect.size.height];
    //4
    SKSpriteNode *blockSprite = [SKSpriteNode spriteNodeWithImageNamed:textureName];
    blockSprite.position = blockRect.origin;
    //5
    CGRect bodyRect =CGRectInset(blockRect, 2, 2);
    blockSprite.physicsBody= [SKPhysicsBody bodyWithRectangleOfSize:bodyRect.size];
    //6
    [blockSprite attachDebugRectWithSize:blockSprite.size];
    return blockSprite;
}
-(void)inGameMessage:(NSString*) text{
    SKLabelNode *label =[SKLabelNode labelNodeWithFontNamed:@"AvenirNext-Regular"];
    label.text =text;
    label.fontSize =64.0;
    label.color= [SKColor whiteColor];
    //2
    label.position =CGPointMake(self.frame.size.width/2, self.frame.size.height -10);
    label.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:10];
    label.physicsBody.collisionBitMask  = CNPhysicsCategoryEdge;
    label.physicsBody.categoryBitMask=CNPhysicsCategoryLabel;
    label.physicsBody.restitution =0.7;
    
    //3
    [_gameNode addChild:label];
    
    //4
    [label runAction:
     [SKAction sequence:@[
        [SKAction waitForDuration:3.0],
        [SKAction removeFromParent]]]];
    }
-(void)newGame{
    [_gameNode removeAllChildren];
    [self setupLevel:_currentLevel];
    [self inGameMessage:[NSString stringWithFormat:@"Level %i",_currentLevel]];
}
-(void)lose{
    //1
    _catNode.physicsBody.contactTestBitMask =0;
    [_catNode setTexture:[SKTexture textureWithImageNamed:@"cat_awake"]];
    
    //2
    [[SKTAudio sharedInstance] pauseBackgroundMusic];
    [self runAction:[SKAction playSoundFileNamed:@"lose.mp3" waitForCompletion:NO]];
    [self inGameMessage:@"Try Again..."];
    
    //3
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:5.0],
                                         [SKAction performSelector:@selector(newGame) onTarget:self]]]];
}
-(void)win{
    //1
    _catNode.physicsBody=nil;
    //2
    CGFloat curlY = _bedNode.position.y+_catNode.size.height/2;
    CGPoint curlPoint = CGPointMake(_bedNode.position.x, curlY);
    //3
    [_catNode runAction:[SKAction group:
                         @[[SKAction moveTo:curlPoint duration:0.66],
                           [SKAction rotateToAngle:0 duration:0.5]]]];
    [self inGameMessage:@"Good Job!"];
    //4
    [self runAction:[SKAction sequence:@[[SKAction waitForDuration:5.0], [SKAction performSelector:@selector(newGame) onTarget:self]]]];
    //5
    [_catNode runAction:
       [SKAction animateWithTextures:@[[SKTexture textureWithImageNamed:@"cat_curlup1"], [SKTexture textureWithImageNamed:@"cat_curlup2"], [SKTexture textureWithImageNamed:@"cat_curlup3"]] timePerFrame:0.25]];
    //6
    [[SKTAudio sharedInstance] pauseBackgroundMusic];
    [self runAction:[SKAction playSoundFileNamed:@"win.mp3" waitForCompletion:NO]];
    
}

//chapter10
-(void)didSimulatePhysics{
    if(_catNode.physicsBody.contactTestBitMask && fabs(_catNode.zRotation)>DegreesToRadians(25)){
        [self lose];
    }
}
-(void)addSpringsFromArray:(NSArray *)springs{
    for(NSDictionary *spring in springs){
        SKSpriteNode *springSprite =[SKSpriteNode spriteNodeWithImageNamed:@"spring"];
        springSprite.position = CGPointFromString(spring[@"position"]);
        
        springSprite.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:springSprite.size];
        springSprite.physicsBody.categoryBitMask=CNPhysicsCategorySpring;
        springSprite.physicsBody.collisionBitMask=CNPhysicsCategoryEdge|CNPhysicsCategoryBlock|CNPhysicsCategoryCat;
        
        [springSprite attachDebugRectWithSize:springSprite.size];
        [_gameNode addChild:springSprite];
        
    }
}
-(void)addHookAtPosition:(CGPoint)hookPosition{
    _hookBaseNode =nil;
    _hookNode =nil;
    _ropeNode =nil;
    
    _isHooked=NO;
    _hookBaseNode =[SKSpriteNode spriteNodeWithImageNamed:@"hook_base"];
    _hookBaseNode.position =CGPointMake(hookPosition.x, hookPosition.y-_hookBaseNode.size.height/2);
    _hookBaseNode.physicsBody=[SKPhysicsBody bodyWithRectangleOfSize:_hookBaseNode.size];
    [_gameNode addChild:_hookBaseNode];
}
@end