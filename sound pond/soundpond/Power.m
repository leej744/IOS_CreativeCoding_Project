//
//  Power.m
//  soundpond
//
//  Created by Julie Lee on 4/6/14.
//  Copyright (c) 2014 Julie Lee. All rights reserved.
//

#import "Power.h"
#import "MyScene.h"

@implementation Power {
    float _heartHealth;
    SKAction *_healthSoundAction;
}

- (id)initWithPosition:(CGPoint)position withHeartHealth:(float)heartHealth {
    if(self = [super initWithPosition:position]) {
        self.name = @"Power";
        [self configureCollisionBody];
        _heartHealth = heartHealth;
        _healthSoundAction = [SKAction playSoundFileNamed:@"pop.mp3" waitForCompletion:NO];
    }
    
    return self;
    
}

- (id)initWithPosition:(CGPoint)position {
    
    return nil;
}

- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact*)contact
{
    /*
     When it collides with the monkey, the health will be increased and it will be removed from the scene.
     */
    if(contact.bodyA.categoryBitMask == CollisionTypeMonkey || contact.bodyB.categoryBitMask == CollisionTypeMonkey){
        
        [(MyScene *)self.scene increaseHealthBy:_heartHealth];
        [self runAction:_healthSoundAction completion:^(void) {
            [self removeAllActions];
            [self removeFromParent];
        }];
    }
}

-(void)configureCollisionBody {
    
    /*
     This heart will collide with the monkey, and will disappear.  This is accomplished by setting the contactTestBitMask to the monkey.  Physics do not need to be applied--set the collisionBitMask to 0.
     */
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:16.0f];
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.categoryBitMask = CollisionTypeHealth;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = CollisionTypeMonkey;
}

+ (SKTexture *)createTexture {
    
    static SKTexture *texture = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        texture = [SKTexture textureWithImageNamed:@"heart"];
        texture.filteringMode = SKTextureFilteringNearest;
    });
    
    return texture;
    
}

@end
