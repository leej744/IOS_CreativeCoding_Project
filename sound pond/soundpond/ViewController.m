//
//  ViewController.m
//  soundpond
//
//  Created by Julie Lee on 4/5/14.
//  Copyright (c) 2014 Julie Lee. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"
@implementation ViewController {
    SKView *_skView;
    MyScene *_scene;
    CMMotionManager *_motionManager;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (!_skView) {
        _skView =
        [[SKView alloc] initWithFrame:self.view.bounds];
        MyScene *scene =
        [[MyScene alloc] initWithSize:_skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [_skView presentScene:scene];
        [self.view addSubview:_skView];
        [self.view sendSubviewToBack:_skView];
        
        _scene = scene;
        
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.accelerometerUpdateInterval = 0.05;
        [_motionManager startAccelerometerUpdates];
        _scene.motionManager = _motionManager;
        
    }
}
- (void)dealloc {
    [_motionManager stopAccelerometerUpdates];
    _motionManager = nil;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
