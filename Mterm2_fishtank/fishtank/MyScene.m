//
//  MyScene.m
//  fishtank
//
//  Created by Julie Lee on 3/28/14.
//  Copyright (c) 2014 Julie Lee. All rights reserved.
//

#import "MyScene.h"
#import "SKTAudio.h"
#import "Physics.h"

@implementation MyScene

-(void) didMoveToView:(SKView *)view
{
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    
    SKTexture *texture1 = [SKTexture textureWithImageNamed:@"ladybug01"];
    SKTexture *texture2 = [SKTexture textureWithImageNamed:@"ladybug02"];
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:texture1];
    sprite.position = CGPointMake(100, 100);
    sprite.name = @"ladybug";
    sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width * 0.5];
    sprite.physicsBody.affectedByGravity = NO;
    
    SKAction *walk = [SKAction animateWithTextures:@[texture1,texture2] timePerFrame:.2];
    [sprite runAction:[SKAction repeatActionForever:walk]];
    
    [self addChild:sprite];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint location = [[touches anyObject] locationInNode:self];
    
    NSArray *nodes = [self nodesAtPoint:location];
    
    if ([nodes count] == 0){
        // no sprite nodes tapped
        
        SKNode *ladybug = [self childNodeWithName:@"ladybug"];
        
        /* No physics
         SKAction *move = [SKAction moveTo:location duration:1.0f];
         [ladybug runAction:move];
         */
        
        double angle = atan2(location.y - ladybug.position.y,location.x-ladybug.position.x);
        
        // Physics
        
        [ladybug.physicsBody applyImpulse:CGVectorMake(20*cos(angle), 20*sin(angle))];
        
        [ladybug runAction:[SKAction rotateToAngle:angle duration:.1]];
    } else {
        // tapped on a ladybug
        [self runAction:[SKAction playSoundFileNamed:@"ladybug.wav" waitForCompletion:NO]];
        
        // load the particles
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ladybug" ofType:@"sks"];
        SKEmitterNode *particles = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        particles.position = location;
        [particles runAction:[SKAction sequence:@[[SKAction waitForDuration:.8],
                                                  [SKAction fadeAlphaTo:0 duration:.2],
                                                  [SKAction removeFromParent]]]];
        [self addChild:particles];
    }
}

@end
