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

@implementation GameScene {
    
    //for update method
    NSTimeInterval _lastUpdateTimeInterval;
    NSTimeInterval _timeSinceLast;
    
    //screen size
    CGFloat screenHeight;
    CGFloat screenWidth;
    CGSize screenCell;
    
    //Main nodes
    SKSpriteNode *_player;
    SKSpriteNode *_wave;
    
    //background
    Background *_firstBackground;
    Background *_secondBackground;
    Background *_thirdBackground;
    
    //objects
    SKSpriteNode *_object1;
    SKSpriteNode *_object2;
    SKSpriteNode *_object3;
    SKSpriteNode *_object4;
    
    //GAME MECHANIC
    
    NSInteger _backgroundMoveSpeed; //было 250 //define the background move speed in pixels per frame.
    
    BOOL _gameIsOver;
    BOOL _youWin;
    
    NSInteger _kilometersRemain;
    SKLabelNode *_kilometersRemainLabel;
    
    NSInteger _speedometerInteger;
    SKLabelNode *_speedometerLabel;
    
    SKLabelNode *_gameOverLabel;
}

- (void)didMoveToView:(SKView *)view {
    
    _youWin = NO;
    
    //назначаем делегат для физики
    self.physicsWorld.contactDelegate = self;
    
    //Get screen size to use later
    screenWidth = view.bounds.size.width;
    screenHeight = view.bounds.size.height;
    NSLog(@"\n\nscreenWidth = %f \nscreenHeight = %f\n\n", screenWidth, screenHeight);
    
    screenCell = CGSizeMake(screenWidth/5, screenWidth/5);
    NSLog(@"screenCell = (%f, %f)", screenCell.width, screenCell.height);
    
    //назначаем скорость движения
    _backgroundMoveSpeed = 300;
    
    //add player
    [self addPlayer];
    
    //add wave
    [self addWave];
    
    //add backgrounds
    [self addBackgrounds];
    
    //add borders
    [self addBorders];
    
    //add objects
    [self addObjects];

    //add kilometers remain label
    [self addKilometersRemainLabel];
    
    //add speedometer
    [self addSpeedometer];
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
    
    //IF the KilometersRemain is 0 - YOU WIN
    if (_kilometersRemain > 0) {
        
    
    
    //IF THE GAME IS NOT OVER YET
    if (!_gameIsOver) {
        
    
    //BACKGROUND MOVEMENT
    
    //1st background movement
    [self enumerateChildNodesWithName:_firstBackground.name usingBlock:^(SKNode *node, BOOL *stop) {
        //calculation of background move speed
        node.position = CGPointMake(node.position.x, node.position.y - _backgroundMoveSpeed * _timeSinceLast);
        
        //if background moves completely off the screen - put it on the top of three background nodes
        if (node.position.y < -(screenHeight * 1.5)) {
            
            CGPoint topPosition = CGPointMake(_thirdBackground.position.x, _thirdBackground.position.y + _thirdBackground.size.height - 20);//пришлось отнимать по 10 чтобы не было видно стыков между каждыми 3мя картинками дороги
            node.position = topPosition;
            NSLog(@"\n\n FIRST NODE WAS PUT ON THE TOP!\n\n");
        }}];
    
    //2nd background movement
    [self enumerateChildNodesWithName:_secondBackground.name usingBlock:^(SKNode *node, BOOL *stop) {
        //calculation of background move speed
        node.position = CGPointMake(node.position.x, node.position.y - _backgroundMoveSpeed * _timeSinceLast);
        
        //if background moves completely off the screen - put it on the top of three background nodes
        if (node.position.y < -(screenHeight * 1.5)) {
            
            CGPoint topPosition = CGPointMake(_firstBackground.position.x, _firstBackground.position.y + _firstBackground.size.height - 20);//пришлось отнимать по 10 чтобы не было видно стыков между каждыми 3мя картинками дороги

            node.position = topPosition;
            NSLog(@"\n\n SECOND NODE WAS PUT ON THE TOP!\n\n");
            
 //!!!           //добавляем объекты на этот нод пока он не виден
            [self addObjectsOnBackgroundNode:_secondBackground];
        }}];

    //3rd background movement
    [self enumerateChildNodesWithName:_thirdBackground.name usingBlock:^(SKNode *node, BOOL *stop) {
        //calculation of background move speed
        node.position = CGPointMake(node.position.x, node.position.y - _backgroundMoveSpeed * _timeSinceLast);
        
        //if background moves completely off the screen - put it on the top of three background nodes
        if (node.position.y < -(screenHeight * 1.5)) {
            
            CGPoint topPosition = CGPointMake(_secondBackground.position.x, _secondBackground.position.y + _secondBackground.size.height - 20);//пришлось отнимать по 10 чтобы не было видно стыков между каждыми 3мя картинками дороги

            node.position = topPosition;
            NSLog(@"\n\n THIRD NODE WAS PUT ON THE TOP!\n\n");
            
 //!!!           //добавляем объекты на этот нод пока он не виден
            [self addObjectsOnBackgroundNode:_thirdBackground];
            
//Счетчик километров!
            
            [self decreaseKilometers];
            
//Увеличиваем скорость!!!
            
            [self increaseSpeed];
        }}];
    
    //NSLog(@"player's position = (%f, %f)", _player.position.x, _player.position.y);
    
    //Если Волна покраывает машину PLAYER'a волна накрывает весь экран
    
        CGFloat playerMinY = _player.position.y - _player.size.height / 2;
    if (playerMinY <= _wave.position.y) {
        NSLog(@"PLAYER MIN Y IS <= WAVE POSITION Y");
        
        [self gameOver];
    }
}//game over bool
    }else {
        
        _youWin = YES;
        [self waveMoveDown];
        [self playerMoveUp];
    }
}

#pragma mark - Add main nodes
- (void)addPlayer {

    CGSize playerSize = CGSizeMake(screenCell.width, screenCell.width * 2);
    //SKSpriteNode *player = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:playerSize];
    SKSpriteNode *player = [SKSpriteNode spriteNodeWithImageNamed:@"pickup.png"];
    
    player.anchorPoint = CGPointMake(0.5, 0.5);
    
    player.zPosition = 10;
    
    player.position = CGPointMake(screenWidth/2, screenHeight/2 - screenCell.height);
    
    player.name = @"player";
    
    player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:playerSize];
    player.physicsBody.affectedByGravity = NO;
    player.physicsBody.allowsRotation = NO;
    player.physicsBody.restitution = 0.0;
    player.physicsBody.friction = 0.0;
    player.physicsBody.dynamic = YES;
    
    player.physicsBody.categoryBitMask = playerCategory;
    player.physicsBody.contactTestBitMask = waveCategory;
    player.physicsBody.collisionBitMask = objectCategory | bordersCategory;

    //SKTexture *playerTexture = [SKTexture textureWithImageNamed:@"pickup.png"];
    //player.texture = playerTexture;
    
    _player = player;
    [self addChild:_player];
    NSLog(@"player node created");
}

- (void)addWave {

    //высота волна на экране в обычнеое время - screenCell.width
    
    CGSize waveSize = CGSizeMake(screenWidth, screenHeight);
    SKSpriteNode *wave = [SKSpriteNode spriteNodeWithColor:[SKColor blueColor] size:waveSize];
    
    SKTexture *waveTexture = [SKTexture textureWithImageNamed:@"volna1.png"];
    wave.texture = waveTexture;
    
    wave.anchorPoint = CGPointMake(0.5, 1);
    wave.zPosition = 11;
    wave.position = CGPointMake(screenWidth / 2, screenCell.height);
    
    wave.name = @"wave";
    
    wave.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:waveSize];
    wave.physicsBody.affectedByGravity = NO;
    wave.physicsBody.allowsRotation = NO;
    wave.physicsBody.restitution = 0.0;
    wave.physicsBody.friction = 0.0;
    wave.physicsBody.dynamic = YES;
    
    wave.physicsBody.categoryBitMask = waveCategory;
    wave.physicsBody.contactTestBitMask = playerCategory;
    wave.physicsBody.collisionBitMask = 0;
    
    _wave = wave;
    [self addChild:_wave];
    NSLog(@"wave node created");
    
    //ANIMATION OF WAVE
    
    // Running player animation
    SKTexture * runTexture1 = [SKTexture textureWithImageNamed:@"volna1.png"];
    SKTexture * runTexture2 = [SKTexture textureWithImageNamed:@"volna2.png"];
    SKTexture * runTexture3 = [SKTexture textureWithImageNamed:@"volna3.png"];
    
    NSArray * runTexture = @[runTexture1, runTexture2, runTexture3];
    
    SKAction *waveAnimationAction = [SKAction animateWithTextures:runTexture timePerFrame:0.1 resize:YES restore:NO];
    [_wave runAction:[SKAction repeatActionForever:waveAnimationAction]];
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

- (void)addObjects {

    //создаем ноды объектов - препятствий и сохраняем в проперти
    
    //Объект1 - горизонтальная тачка
    CGSize object1Size = CGSizeMake(screenCell.width * 2, screenCell.height);
    //SKSpriteNode *object1 = [SKSpriteNode spriteNodeWithColor:[SKColor brownColor] size:object1Size];
    SKSpriteNode *object1 = [SKSpriteNode spriteNodeWithImageNamed:@"orangeCarSide.png"];
    
    object1.anchorPoint = CGPointMake(0.5, 0.5);
    object1.zPosition = 2;
    object1.position = CGPointMake(screenWidth/2, screenHeight/2);
    object1.name = @"object1";
    
    object1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:object1Size];
    object1.physicsBody.affectedByGravity = NO;
    object1.physicsBody.allowsRotation = NO;
    object1.physicsBody.restitution = 0.0;
    object1.physicsBody.friction = 0.0;
    object1.physicsBody.dynamic = YES;
    
    object1.physicsBody.categoryBitMask = objectCategory;
    object1.physicsBody.contactTestBitMask = waveCategory;
    object1.physicsBody.collisionBitMask = playerCategory | objectCategory | bordersCategory;
    
    _object1 = object1;
    
    //Объект2 - вертикальная тачка
    CGSize object2Size = CGSizeMake(screenCell.width, screenCell.height * 2);
    //SKSpriteNode *object2 = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:object2Size];
    SKSpriteNode *object2 = [SKSpriteNode spriteNodeWithImageNamed:@"ambulance.png"];
    
    object2.anchorPoint = CGPointMake(0.5, 0.5);
    object2.zPosition = 2;
    object2.position = CGPointMake(screenWidth/2, screenHeight/2);
    object2.name = @"object2";
    
    object2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:object2Size];
    object2.physicsBody.affectedByGravity = NO;
    object2.physicsBody.allowsRotation = NO;
    object2.physicsBody.restitution = 0.0;
    object2.physicsBody.friction = 0.0;
    object2.physicsBody.dynamic = YES;
    
    object2.physicsBody.categoryBitMask = objectCategory;
    object2.physicsBody.contactTestBitMask = waveCategory;
    object2.physicsBody.collisionBitMask = playerCategory | objectCategory | bordersCategory;
    
    _object2 = object2;
    
    //Объект3 - горизонтальная тачка
    CGSize object3Size = CGSizeMake(screenCell.width * 2, screenCell.height);
    //SKSpriteNode *object3 = [SKSpriteNode spriteNodeWithColor:[SKColor blackColor] size:object3Size];
    SKSpriteNode *object3 = [SKSpriteNode spriteNodeWithImageNamed:@"taxiSide.png"];
    
    object3.anchorPoint = CGPointMake(0.5, 0.5);
    object3.zPosition = 2;
    object3.position = CGPointMake(screenWidth/2, screenHeight/2);
    object3.name = @"object3";
    
    object3.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:object3Size];
    object3.physicsBody.affectedByGravity = NO;
    object3.physicsBody.allowsRotation = NO;
    object3.physicsBody.restitution = 0.0;
    object3.physicsBody.friction = 0.0;
    object3.physicsBody.dynamic = YES;
    
    object3.physicsBody.categoryBitMask = objectCategory;
    object3.physicsBody.contactTestBitMask = waveCategory;
    object3.physicsBody.collisionBitMask = playerCategory | objectCategory | bordersCategory;
    
    _object3 = object3;
    
    //Объект4 - вертикальная тачка
    CGSize object4Size = CGSizeMake(screenCell.width, screenCell.height * 2);
    //SKSpriteNode *object4 = [SKSpriteNode spriteNodeWithColor:[SKColor yellowColor] size:object4Size];
    SKSpriteNode *object4 = [SKSpriteNode spriteNodeWithImageNamed:@"police.png"];
    
    object4.anchorPoint = CGPointMake(0.5, 0.5);
    object4.zPosition = 2;
    object4.position = CGPointMake(screenWidth/2, screenHeight/2);
    object4.name = @"object4";
    
    object4.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:object4Size];
    object4.physicsBody.affectedByGravity = NO;
    object4.physicsBody.allowsRotation = NO;
    object4.physicsBody.restitution = 0.0;
    object4.physicsBody.friction = 0.0;
    object4.physicsBody.dynamic = YES;
    
    object4.physicsBody.categoryBitMask = objectCategory;
    object4.physicsBody.contactTestBitMask = waveCategory;
    object4.physicsBody.collisionBitMask = playerCategory | objectCategory | bordersCategory;
    
    _object4 = object4;

}

- (void)addObjectsOnBackgroundNode: (SKSpriteNode *)spriteNode {

    //if there any child nodes on background node - remove all children from parent
    NSLog(@"Child nodes on 3rd background node: %lu",  (unsigned long)[spriteNode.children count]);
    if ([spriteNode.children count] > 0) {
        
        for (SKSpriteNode* node in spriteNode.children) {
            [node removeFromParent];
        }
        NSLog(@"Child nodes on 3rd background node: %lu",  (unsigned long)[spriteNode.children count]);
    }
    
    //Let's add new objects
    int randomNumber = arc4random_uniform(5);//будет рандомное значение 0, 1, 2, 3, 4
    NSLog(@"random number = %d", randomNumber);
    
    //For Second background
    if ([spriteNode.name isEqualToString:@"second background"]) {
        
        switch (randomNumber) {
            case 0:
                NSLog(@"case 0 - ШИРОКАЯ КОРИЧНЕВАЯ ПО ЦЕНТРУ");
                _object1.position = CGPointMake(screenWidth/2, screenHeight/2);
                [spriteNode addChild:_object1];
                break;
                
            case 1:
                NSLog(@"case 1 - ДЛИННАЯ ЗЕЛЁНАЯ В ЦЕНТРЕ");
                _object2.position = CGPointMake(screenWidth/2, screenHeight/2);
                [spriteNode addChild:_object2];
                break;
                
            case 2:
                NSLog(@"case 2 - ШИРОКАЯ КОРИЧНЕВАЯ СПРАВА ВНИЗУ, ДЛИННАЯ ЗЕЛЁНАЯ СЛЕВА ВВЕРХУ");
                _object1.position = CGPointMake(screenCell.width * 4, screenCell.height * 2.5);
                [spriteNode addChild:_object2];
            
                _object2.position = CGPointMake(screenCell.width / 2, screenHeight - screenCell.height * 3);
                [spriteNode addChild:_object1];
                break;
                
            case 3:
                NSLog(@"case 3 - ШИРОКАЯ КОРИЧНЕВАЯ СЛЕВА ВВЕРХУ, ДЛИННАЯ ЗЕЛЕНАЯ СПРАВА ВНИЗУ");
                _object1.position = CGPointMake(screenCell.width, screenHeight - screenCell.height * 2.5);
                [spriteNode addChild:_object1];
                
                _object2.position = CGPointMake(screenCell.width * 4.5, screenCell.height * 3);
                [spriteNode addChild:_object2];
                break;
                
            case 4:
                NSLog(@"case 4 - ШИРОКАЯ КОРИЧНЕВАЯ СЛЕВА ВНИЗУ, ДЛИННАЯ ЗЕЛЕНАЯ СПРАВА ВВЕРХУ");
                _object1.position = CGPointMake(screenCell.width, screenCell.height * 2.5);
                [spriteNode addChild:_object1];
                
                _object2.position = CGPointMake(screenCell.width * 4.5, screenHeight - screenCell.height * 3);
                [spriteNode addChild:_object2];
                break;
        }
        
        //For third background
    } else if ([spriteNode.name isEqualToString:@"third background"]) {
        
        switch (randomNumber) {
            case 0:
                NSLog(@"case 0 - horizontal in center");
                _object3.position = CGPointMake(screenWidth/2, screenHeight/2);
                [spriteNode addChild:_object3];
                break;
                
            case 1:
                NSLog(@"case 1 - vertical in center");
                _object4.position = CGPointMake(screenWidth/2, screenHeight/2);
                [spriteNode addChild:_object4];
                break;
                
            case 2:
                //ВРЕМЕННО
                NSLog(@"case 2");
                NSLog(@"case 1 - vertical in center");
                _object4.position = CGPointMake(screenWidth/2, screenHeight/2);
                [spriteNode addChild:_object4];
                break;
                
            case 3:
                //ВРЕМЕННО
                NSLog(@"case 3");
                NSLog(@"case 0 - horizontal in center");
                _object3.position = CGPointMake(screenWidth/2, screenHeight/2);
                [spriteNode addChild:_object3];
                break;
                
            case 4:
                //ВРЕМЕННО
                NSLog(@"case 4");
                _object3.position = CGPointMake(screenWidth * 3.5, screenHeight - screenCell.height/2);
                [spriteNode addChild:_object3];
                break;
        }
    } else {NSLog(@"!!! ERROR !!! Метод addObjectsOnBackgroundNode был вызван из странного места или в имени backgroundNode'a ошибка");}
    
}

- (void)addKilometersRemainLabel {
    
    _kilometersRemain = 100;
    NSString *kilometersRemainString = [NSString stringWithFormat:@"%ld km", _kilometersRemain];
    
    SKLabelNode *kilometersRemainLabel = [SKLabelNode labelNodeWithFontNamed:@"San Francisco"];
    kilometersRemainLabel.text = kilometersRemainString;
    kilometersRemainLabel.fontColor = [SKColor whiteColor];
    kilometersRemainLabel.fontSize = 24;
    kilometersRemainLabel.zPosition = 100;
    kilometersRemainLabel.position = CGPointMake(screenWidth - screenCell.width, screenHeight - screenCell.height/2);
    _kilometersRemainLabel = kilometersRemainLabel;
    [self addChild:_kilometersRemainLabel];
}

- (void)addSpeedometer {

    _speedometerInteger = _backgroundMoveSpeed / 5;
    NSString *speedometerString = [NSString stringWithFormat:@"%ld km/h", _speedometerInteger];
    
    SKLabelNode *speedometerLabel = [SKLabelNode labelNodeWithFontNamed:@"San Francisco"];
    speedometerLabel.text = speedometerString;
    speedometerLabel.fontColor = [SKColor whiteColor];
    speedometerLabel.fontSize = 24;
    speedometerLabel.zPosition = 100;
    speedometerLabel.position = CGPointMake(screenWidth - screenCell.width, screenHeight - screenCell.height);
    _speedometerLabel = speedometerLabel;
    [self addChild:_speedometerLabel];

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

-(void)waveMoveUp {

    SKAction *waveMoveUpAction = [SKAction moveToY:screenHeight duration:1];
    [_wave runAction:waveMoveUpAction completion:^{
        
        [self addGameOverLabel];
    }];
}

-(void)waveMoveDown {

    SKAction *waveMoveDownAction = [SKAction moveToY:0 duration:2];
    [_wave runAction:waveMoveDownAction completion:^{
        
        NSLog(@"waveMoveDown");
    }];
}

-(void)playerMoveUp {

    SKAction *playerMoveUpAction = [SKAction moveToY:screenHeight + _player.size.height duration:1];
    [_wave runAction:playerMoveUpAction completion:^{
        NSLog(@"run playerMoveUpAction");
    }];
}

#pragma mark - SKPhysicsContactDelegate
- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    SKNode *bodyANode = contact.bodyA.node;
    SKNode *bodyBNode = contact.bodyB.node;
    
    NSLog(@"Body A: %@  Body B: %@",bodyANode.name, bodyBNode.name);
    
}

#pragma mark - GAME OVER
- (void)gameOver {
    
    NSLog(@"\n\nGAME OVER\n\n");
    _gameIsOver = YES;
    
    [self waveMoveUp];
    _speedometerLabel.hidden = YES;
    _kilometersRemainLabel.hidden = YES;

}

- (void)addGameOverLabel {

    NSString *gameOverString = @"GAME OVER";
    
    SKLabelNode *gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"San Francisco"];
    gameOverLabel.text = gameOverString;
    gameOverLabel.fontColor = [SKColor whiteColor];
    gameOverLabel.fontSize = 30;
    gameOverLabel.zPosition = 100;
    gameOverLabel.position = CGPointMake(screenWidth / 2, screenHeight / 2);
    _gameOverLabel = gameOverLabel;
    [self addChild:_gameOverLabel];
}

#pragma mark - GAME MECHANIC

-(void)decreaseKilometers {

    _kilometersRemain = _kilometersRemain - 1;
    _kilometersRemainLabel.text = [NSString stringWithFormat:@"%ld km", _kilometersRemain];
}

-(void)increaseSpeed {
    
    _backgroundMoveSpeed = _backgroundMoveSpeed + 10; //было 3
    _speedometerInteger = _backgroundMoveSpeed / 5;
    _speedometerLabel.text = [NSString stringWithFormat:@"%ld km/h", _speedometerInteger];
}


@end
