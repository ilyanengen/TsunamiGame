//
//  GameScene.m
//  TsunamiGame
//
//  Created by Илья on 21.01.17.
//  Copyright © 2017 Ilya Biltuev. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene {
    //SKShapeNode *_spinnyNode;
    
    CGFloat screenHeight;
    CGFloat screenWidth;
    CGSize screenCell;
    
    SKSpriteNode *_player;
    SKSpriteNode *_wave;
    SKSpriteNode *_background;
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
}


-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
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

#pragma mark - TOUCHES
/*
 - (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 // Run 'Pulse' action from 'Actions.sks'
 [_label runAction:[SKAction actionNamed:@"Pulse"] withKey:@"fadeInOut"];
 
 for (UITouch *t in touches) {[self touchDownAtPoint:[t locationInNode:self]];}
 }
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

@end
