//
//  MyScene.h
//  soundpond
//

//  Copyright (c) 2014 Julie Lee. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <CoreMotion/CoreMotion.h>

@protocol ImageCaptureDelegate
- (void)requestImagePicker;
@end
@interface MyScene : SKScene<UIAccelerometerDelegate>{
    CGRect screenRect;
    CGFloat screenHeight;
    CGFloat screenWidth;
    double currentMaxAccelX;
    double currentMaxAccelY;

    CMMotionManager *motionManager;

}

@property (nonatomic, assign) id <ImageCaptureDelegate> delegate;
-(void)setPhotoTexture:(SKTexture *)texture;

@property (strong, nonatomic) CMMotionManager *motionManager;
@property SKSpriteNode *enemy;

@end
