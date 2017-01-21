//
//  GameScene.m
//  TsunamiGame
//
//  Created by Илья on 21.01.17.
//  Copyright © 2017 Ilya Biltuev. All rights reserved.
//

#import "GameScene.h"

//define the background move speed in pixels per frame.
static NSInteger backgroundMoveSpeed = 150;

@implementation GameScene {
    
    //screen size
    CGFloat screenHeight;
    CGFloat screenWidth;
    CGSize screenCell;
    
    //Main nodes
    SKSpriteNode *_player;
    SKSpriteNode *_wave;
    SKSpriteNode *_background;
    
    //background
    SKSpriteNode *_currentBackground;
    
    NSTimeInterval _lastUpdateTimeInterval;
    NSTimeInterval _timeSinceLast;

}

- (void)didMoveToView:(SKView *)view {
    
    //Get screen size to use later
    screenWidth = view.bounds.size.width;
    screenHeight = view.bounds.size.height;
    NSLog(@"\n\nscreenWidth = %f \nscreenHeight = %f\n\n", screenWidth, screenHeight);
    
    screenCell = CGSizeMake(screenWidth/5, screenWidth/5);
    NSLog(@"screenCell = (%f, %f)", screenCell.width, screenCell.height);
    
    //add player
    [self addPlayer];
    
    //add wave
    [self addWave];
    
    //add background
    [self addBackground];
}

#pragma mark - UPDATE METHOD
-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
    
    //calculation of time since last update to calculate the movement speed of background.
    _timeSinceLast = currentTime - _lastUpdateTimeInterval;
    _lastUpdateTimeInterval = currentTime;
    
    //if too much time passed since last update - sms, phone call etc.
    if (_timeSinceLast > 1) {
        _timeSinceLast = 1.0/ 60.0;
        _lastUpdateTimeInterval = currentTime;
    }
    
    //calculation of background move speed
    [self enumerateChildNodesWithName:_currentBackground.name usingBlock:^(SKNode *node, BOOL *stop) {
        node.position = CGPointMake(node.position.x, node.position.y - backgroundMoveSpeed * _timeSinceLast);
        
        //if background moves completely off the screen + extra 100 pixels -> remove that background from the parent node
        if (node.position.x < -(node.frame.size.width+100)) {
            [node removeFromParent];
        }}];
    
    //we create new background node and set it as background
    
    //Может создавать новый background когда старый фон ушел вниз на -1 по y ???
    
    if (_currentBackground.position.y < -500) {
        Background *newBackground = [Background generateNewBackground];
        newBackground.position = CGPointMake(0, _currentBackground.position.y + screenHeight);
        [self addChild:newBackground];
        _currentBackground = newBackground;
    }
}

#pragma mark - Add main nodes
- (void)addPlayer {

    CGSize playerSize = CGSizeMake(screenCell.width, screenCell.width * 2);
    SKSpriteNode *player = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:playerSize];
    
    player.anchorPoint = CGPointMake(0.5, 0.5);
    player.zPosition = 10;
    player.position = CGPointMake(screenWidth/2, screenHeight/2 - screenCell.height);
    
    _player = player;
    [self addChild:_player];
}

- (void)addWave {

    CGSize waveSize = CGSizeMake(screenWidth, screenCell.width);
    SKSpriteNode *wave = [SKSpriteNode spriteNodeWithColor:[SKColor blueColor] size:waveSize];
    
    wave.anchorPoint = CGPointMake(0,0);
    wave.zPosition = 11;
    wave.position = CGPointZero;
    
    _wave = wave;
    [self addChild:_wave];
}

- (void)addBackground {

    Background *background = [[Background alloc]initWithColor:[SKColor lightGrayColor] size:CGSizeMake(screenWidth, screenHeight)];
    
    background.anchorPoint = CGPointZero;
    background.zPosition = 1;
    background.position = CGPointZero;
    
    background.name = @"one background";
    
    _currentBackground = background;
    [self addChild:_currentBackground];
}

#pragma mark - TOUCHES

 - (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 
 for (UITouch *t in touches) {
     
     CGPoint touchPosition = [t locationInNode:self];
     NSLog(@"\n\ntouch position X: %f Y: %f\n\n", touchPosition.x, touchPosition.y);
     CGFloat centerX = screenWidth/2;
     
     if (touchPosition.x > centerX) {
         
         [self playerMoveRight];
     
     } else {
         
         [self playerMoveLeft];
     }
 }
 }


/*
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
 for (UITouch *t in touches) {[self touchMovedToPoint:[t locationInNode:self]];}
 }
 - (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
 for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
 }
 - (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
 for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
 }
 */

#pragma mark - Actions
-(void)playerMoveRight {

    NSTimeInterval moveRightDuration = 0.3;
    CGVector moveRightVector = CGVectorMake(screenCell.width, 0);
    SKAction *moveRightAction = [SKAction moveBy:moveRightVector duration:moveRightDuration];
    [_player runAction:moveRightAction];
}
-(void)playerMoveLeft {
    
    NSTimeInterval moveLeftDuration = 0.3;
    CGVector moveLeftVector = CGVectorMake(-screenCell.width, 0);
    SKAction *moveLeftAction = [SKAction moveBy:moveLeftVector duration:moveLeftDuration];
    [_player runAction:moveLeftAction];
}

@end
