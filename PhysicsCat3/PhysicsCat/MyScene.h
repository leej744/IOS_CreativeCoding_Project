//
//  MyScene.h
//  PhysicsCat
//

//  Copyright (c) 2014 Julie Lee. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@protocol ImageCaptureDelegate
- (void)requestImagePicker;
@end

@interface MyScene : SKScene

@property (nonatomic, assign) id <ImageCaptureDelegate> delegate;
-(void)setPhotoTexture:(SKTexture *)texture;
@end