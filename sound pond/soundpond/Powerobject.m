//
//  Powerobject.m
//  soundpond
//
//  Created by Julie Lee on 4/6/14.
//  Copyright (c) 2014 Julie Lee. All rights reserved.
//

#import "Powerobject.h"

@implementation GameObject {
    float _health;
}

- (instancetype) initWithPosition:(CGPoint)position {
    
    if(self = [super init]) {
        
        //All game play objects will instanciate with at lease these basic properties.
        _heading = CGPointZero;
        self.position = position;
        
        self.texture = [[self class] createTexture];
        self.size = self.texture.size;
    }
    
    return self;
}

- (void)setHealth:(float)health {
    if(health > self.maxHealth) {
        _health = self.maxHealth;
    } else {
        _health = health;
    }
}

//to be overridden
- (void)update:(CFTimeInterval)timeSpan {}
- (void)configureCollisionBody {}
- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {}
+ (SKTexture *)createTexture {return nil;}
@end
