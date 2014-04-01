//
//  GameOverScene.m
//  pond
//
//  Created by Julie Lee on 3/29/14.
//  Copyright (c) 2014 Julie Lee. All rights reserved.
//

#import "GameOverScene.h"
#import "MyScene.h"
#import "SKTAudio.h"

@implementation GameOverScene
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        [[SKTAudio sharedInstance] playBackgroundMusic:@"Lose.mp3"];

        // 1
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // 2
        NSString * message;
        message = @"Game Over";
        // 3
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        label.text = message;
        label.fontSize = 40;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:label];
        
        
        NSString * retrymessage;
        retrymessage = @"Replay Game";
        SKLabelNode *retryButton = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        retryButton.text = retrymessage;
        retryButton.fontColor = [SKColor blackColor];
        retryButton.position = CGPointMake(self.size.width/2, 50);
        retryButton.name = @"retry";
        [retryButton setScale:.5];
        
        [self addChild:retryButton];

        
    }
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"retry"]) {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        
        MyScene * scene = [MyScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition: reveal];

    }
}
@end
