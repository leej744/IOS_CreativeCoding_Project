//
//  Powerobject.h
//  soundpond
//
//  Created by Julie Lee on 4/6/14.
//  Copyright (c) 2014 Julie Lee. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

/**
 Used to identify game object types and is used for object contacts and collisions.
 */

typedef NS_OPTIONS(uint32_t, CollisionType) {
    CollisionTypeHealth      =1 << 3,
};

@interface GameObject : SKSpriteNode


@property (assign, nonatomic) CGPoint heading;
@property (assign, nonatomic) float health;
@property (assign, nonatomic) float maxHealth;

- (instancetype)initWithPosition:(CGPoint)position;

- (void)update:(CFTimeInterval)timeSpan;

- (void)configureCollisionBody;

- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact;

+ (SKTexture *)createTexture;


@end
