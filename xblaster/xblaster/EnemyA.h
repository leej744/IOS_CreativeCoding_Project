//
//  EnemyA.h
//  XBlaster
//
//  Created by Julie Lee on 2/18/14.
//  Copyright (c) 2014 Julie Lee. All rights reserved.
//
#import "Entity.h"

@class AISteering;

@interface EnemyA : Entity {
  int         _score;
  int         _damageTakenPerShot;
  NSString    *_healthMeterText;
}

@property (strong,nonatomic) AISteering *aiSteering;

@end
