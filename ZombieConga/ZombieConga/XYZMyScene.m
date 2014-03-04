//
//  XYZMyScene.m
//  ZombieConga
//
//  Created by Julie Lee on 2/4/14.
//  Copyright (c) 2014 Julie Lee. All rights reserved.
//

#import "XYZMyScene.h"

@implementation XYZMyScene
{
    SKSpriteNode *_zombie;
}
-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor whiteColor];
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        bg.position = CGPointMake(self.size.width/2, self.size.height/2);
        bg.anchorPoint = CGPointMake(0.5,0.5);//same as default
        
        struct CGPoint{
            CGFloat x;
            CGFloat y;
        };
        struct CGSize{
            CGFloat width;
            CGFloat Height;
        };
        
        //bg.zRotation =M_PI/8;
        
        [self addChild:bg];
        
        //Challenge: add zombie
        SKSpriteNode *zombie = [SKSpriteNode spriteNodeWithImageNamed:@"zombie1"];

        zombie.position = CGPointMake(100, 100);
        [self addChild:zombie];

        //Getting the Size of a Sprite
        CGSize mySize = bg.size;
        NSLog(@"Size: %@", NSStringFromCGSize(mySize));
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        
        sprite.position = location;
        
        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
        
        [sprite runAction:[SKAction repeatActionForever:action]];
        
        [self addChild:sprite];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
