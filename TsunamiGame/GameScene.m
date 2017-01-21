//
//  GameScene.m
//  TsunamiGame
//
//  Created by Илья on 21.01.17.
//  Copyright © 2017 Ilya Biltuev. All rights reserved.
//

#import "GameScene.h"

//Physics bodies collisions and contact bitMasks
static const uint32_t playerCategory =  0x1 << 0;
static const uint32_t objectCategory =  0x1 << 1;
static const uint32_t waveCategory =  0x1 << 2;
static const uint32_t bordersCategory =  0x1 << 3;

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
    Background *_firstBackground;
    Background *_secondBackground;
    Background *_thirdBackground;
    
    NSTimeInterval _lastUpdateTimeInterval;
    NSTimeInterval _timeSinceLast;
}

- (void)didMoveToView:(SKView *)view {
    
    //назначаем делегат для физики
    self.physicsWorld.contactDelegate = self;
    
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
    
    //add backgrounds
    [self addBackgrounds];
    
    //add borders
    [self addBorders];
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
    
    //BACKGROUND MOVEMENT
    
    //1st background movement
    [self enumerateChildNodesWithName:_firstBackground.name usingBlock:^(SKNode *node, BOOL *stop) {
        //calculation of background move speed
        node.position = CGPointMake(node.position.x, node.position.y - backgroundMoveSpeed * _timeSinceLast);
        
        //if background moves completely off the screen - put it on the top of three background nodes
        if (node.position.y < -(screenHeight * 1.5)) {
            
            CGPoint topPosition = CGPointMake(_thirdBackground.position.x, _thirdBackground.position.y + _thirdBackground.size.height - 10);//пришлось отнимать по 10 чтобы не было видно стыков между каждыми 3мя картинками дороги
            node.position = topPosition;
            NSLog(@"\n\n FIRST NODE WAS PUT ON THE TOP!\n\n");
        }}];
    
    //2nd background movement
    [self enumerateChildNodesWithName:_secondBackground.name usingBlock:^(SKNode *node, BOOL *stop) {
        //calculation of background move speed
        node.position = CGPointMake(node.position.x, node.position.y - backgroundMoveSpeed * _timeSinceLast);
        
        //if background moves completely off the screen - put it on the top of three background nodes
        if (node.position.y < -(screenHeight * 1.5)) {
            
            CGPoint topPosition = CGPointMake(_firstBackground.position.x, _firstBackground.position.y + _firstBackground.size.height - 10);//пришлось отнимать по 10 чтобы не было видно стыков между каждыми 3мя картинками дороги

            node.position = topPosition;
            NSLog(@"\n\n SECOND NODE WAS PUT ON THE TOP!\n\n");
        }}];

    //3rd background movement
    [self enumerateChildNodesWithName:_thirdBackground.name usingBlock:^(SKNode *node, BOOL *stop) {
        //calculation of background move speed
        node.position = CGPointMake(node.position.x, node.position.y - backgroundMoveSpeed * _timeSinceLast);
        
        //if background moves completely off the screen - put it on the top of three background nodes
        if (node.position.y < -(screenHeight * 1.5)) {
            
            CGPoint topPosition = CGPointMake(_secondBackground.position.x, _secondBackground.position.y + _secondBackground.size.height - 10);//пришлось отнимать по 10 чтобы не было видно стыков между каждыми 3мя картинками дороги

            node.position = topPosition;
            NSLog(@"\n\n THIRD NODE WAS PUT ON THE TOP!\n\n");
        }}];
    
    //NSLog(@"player's position = (%f, %f)", _player.position.x, _player.position.y);
}

#pragma mark - Add main nodes
- (void)addPlayer {

    CGSize playerSize = CGSizeMake(screenCell.width, screenCell.width * 2);
    SKSpriteNode *player = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:playerSize];
    
    player.anchorPoint = CGPointMake(0.5, 0.5);
    player.zPosition = 10;
    player.position = CGPointMake(screenWidth/2, screenHeight/2 - screenCell.height);
    
    player.name = @"player";
    
    player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:player.size];
    player.physicsBody.affectedByGravity = NO;
    player.physicsBody.allowsRotation = NO;
    player.physicsBody.restitution = 0.0;
    player.physicsBody.friction = 0.0;
    player.physicsBody.dynamic = YES;
    
    player.physicsBody.categoryBitMask = playerCategory;
    //player.physicsBody.contactTestBitMask = fireballCategory;
    player.physicsBody.collisionBitMask = objectCategory | bordersCategory;
    
    _player = player;
    [self addChild:_player];
    NSLog(@"player node created");
}

- (void)addWave {

    CGSize waveSize = CGSizeMake(screenWidth, screenCell.width);
    SKSpriteNode *wave = [SKSpriteNode spriteNodeWithColor:[SKColor blueColor] size:waveSize];
    
    wave.anchorPoint = CGPointMake(0,0);
    wave.zPosition = 11;
    wave.position = CGPointZero;
    
    _wave = wave;
    [self addChild:_wave];
    NSLog(@"wave node created");
}

- (void)addBackgrounds {

    CGSize backgroundSize = CGSizeMake(screenWidth, screenHeight);
    
    //FIRST BACKGROUND
    Background *firstBackground = [Background generateNewBackground];
    firstBackground.size = backgroundSize;
    
    firstBackground.position = CGPointZero;
    firstBackground.name = @"first background";
    
    _firstBackground = firstBackground;
    [self addChild:_firstBackground];
    NSLog(@"first background node created");
    
    //SECOND BACKGROUND
    Background *secondBackground = [Background generateNewBackground];
    secondBackground.size = backgroundSize;
    
    secondBackground.position = CGPointMake(0, firstBackground.position.y + backgroundSize.height);
    secondBackground.name = @"second background";
    
    _secondBackground = secondBackground;
    [self addChild:_secondBackground];
    NSLog(@"second background node created");

    //THIRD BACKGROUND
    Background *thirdBackground = [Background generateNewBackground];
    thirdBackground.size = backgroundSize;
    
    thirdBackground.position = CGPointMake(0, secondBackground.position.y + backgroundSize.height);
    thirdBackground.name = @"third background";
    
    _thirdBackground = thirdBackground;
    [self addChild:_thirdBackground];
    NSLog(@"third background node created");
}

- (void)addBorders {

    CGFloat bottomForBorder = screenHeight * 3;
    CGFloat heightForBorder = screenHeight * 6;
    CGRect bordersRect = CGRectMake(0, - bottomForBorder, screenWidth, heightForBorder);
    SKPhysicsBody *borders = [SKPhysicsBody bodyWithEdgeLoopFromRect:bordersRect];
    
    borders.categoryBitMask = bordersCategory;
    borders.collisionBitMask = playerCategory | objectCategory;
    borders.contactTestBitMask = 0;

    self.physicsBody = borders;
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

#pragma mark - SKPhysicsContactDelegate
- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    SKNode *bodyANode = contact.bodyA.node;
    SKNode *bodyBNode = contact.bodyB.node;
    
    NSLog(@"Body A: %@  Body B: %@",bodyANode.name, bodyBNode.name);
    
    /*
    //fireball VS player
    if ([bodyANode.name isEqualToString:@"player"] && [bodyBNode.name isEqualToString:@"fireball"] ){
        
        [bodyANode removeFromParent];
        [bodyBNode removeFromParent];
        
        [self gameOver];
     */
    
    }


@end
