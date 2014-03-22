//
//  SKSpriteNode+DebugDraw.h
//  PhysicsCat
//
//  Created by Julie Lee on 3/16/14.
//  Copyright (c) 2014 Julie Lee. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SKSpriteNode (DebugDraw)
-(void)attachDebugRectWithSize:(CGSize)s;
-(void)attachDebugFrameFromPath:(CGPathRef)bodyPath;

@end
