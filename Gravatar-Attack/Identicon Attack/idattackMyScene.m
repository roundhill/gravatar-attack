//
//  idattackMyScene.m
//  Identicon Attack
//
//  Created by Dan Roundhill on 12/3/13.
//  Copyright (c) 2013 Dan Roundhill. All rights reserved.
//

#import "idattackMyScene.h"
#import "VerticalParallaxNode.h"
@import AVFoundation;

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t enemyCategory          =  0x1 << 1;
static const uint32_t playerCategory         =  0x1 << 2;

@interface idattackMyScene () <SKPhysicsContactDelegate>
    @property (nonatomic) SKSpriteNode * player;
    @property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
    @property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
    @property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@end

@implementation idattackMyScene

VerticalParallaxNode *_parallaxNodeBackgrounds;
bool _isPlayerAlive;
NSArray *_asplodeFrames;
int lastMonster;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        _parallaxNodeBackgrounds = [[VerticalParallaxNode alloc] initWithBackground:@"starfield.png"
                                                                           size:CGSizeMake(self.frame.size.width, self.frame.size.height)
                                                           pointsPerSecondSpeed:40.0];
        _parallaxNodeBackgrounds.position = CGPointMake(0, 0);
        [self addChild:_parallaxNodeBackgrounds];
        
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
        //set up asplode atlas for use later
        NSMutableArray *frames = [NSMutableArray array];
        SKTextureAtlas *asplodeAtlas = [SKTextureAtlas atlasNamed:@"Asplode"];
        
        int numImages = asplodeAtlas.textureNames.count;
        for (int i=1; i <= numImages; i++) {
            NSString *textureName = [NSString stringWithFormat:@"asplode%d", i];
            SKTexture *temp = [asplodeAtlas textureNamed:textureName];
            [frames addObject:temp];
        }
        _asplodeFrames = frames;
        
        NSError *error;
        NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"theme" withExtension:@"caf"];
        self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        self.backgroundMusicPlayer.numberOfLoops = -1;
        [self.backgroundMusicPlayer prepareToPlay];
    }
    return self;
}

- (void)createNewGame {
    
    for (id object in self.children) {
        if ([object class] == [SKSpriteNode class]) {
            SKSpriteNode *node = (SKSpriteNode *)object;
            [node removeFromParent];
        }
    }
    
    self.player = [SKSpriteNode spriteNodeWithImageNamed:@"wp_logo"];
    self.player.size = CGSizeMake(72.0f, 72.0f);
    self.player.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/4);
    
    self.player.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.player.size.width/2];
    self.player.physicsBody.dynamic = YES;
    self.player.physicsBody.categoryBitMask = playerCategory;
    self.player.physicsBody.contactTestBitMask = enemyCategory;
    self.player.physicsBody.collisionBitMask = 0;
    self.player.physicsBody.usesPreciseCollisionDetection = YES;
    
    NSMutableArray *shipFrames = [NSMutableArray array];
    SKTextureAtlas *shipAtlas = [SKTextureAtlas atlasNamed:@"Ship"];
    
    int numShipImages = shipAtlas.textureNames.count;
    for (int i=1; i <= numShipImages / 2; i++) {
        NSString *textureName = [NSString stringWithFormat:@"ship%d", i];
        SKTexture *temp = [shipAtlas textureNamed:textureName];
        [shipFrames addObject:temp];
    }
    
    [self.player runAction:[SKAction repeatActionForever:
                            [SKAction animateWithTextures:shipFrames
                                             timePerFrame:0.1f
                                                   resize:NO
                                                  restore:YES]] withKey:@"shipAnimation"];
    
    _isPlayerAlive = YES;
    
    [self addChild:self.player];
    [self.backgroundMusicPlayer play];
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 0.5) {
        self.lastSpawnTimeInterval = 0;
        [self addEnemy];
        
        if (!_isPlayerAlive)
            return;
        // FIRE!!!
        SKSpriteNode * pewPewSprite = [SKSpriteNode spriteNodeWithImageNamed:@"pew"];
        pewPewSprite.position = self.player.position;
        
        pewPewSprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:pewPewSprite.size.width/2];
        pewPewSprite.physicsBody.dynamic = YES;
        pewPewSprite.physicsBody.categoryBitMask = projectileCategory;
        pewPewSprite.physicsBody.contactTestBitMask = enemyCategory;
        pewPewSprite.physicsBody.collisionBitMask = 0;
        pewPewSprite.physicsBody.usesPreciseCollisionDetection = YES;

        CGPoint endPewPoint = CGPointMake(self.player.position.x, self.frame.size.height + pewPewSprite.size.height);
        CGPoint offset = rwSub(endPewPoint, pewPewSprite.position);

        [self addChild:pewPewSprite];
        CGPoint direction = rwNormalize(offset);
        CGPoint shootAmount = rwMult(direction, 1000);
        CGPoint realDest = rwAdd(shootAmount, pewPewSprite.position);
        float velocity = 480.0/1.0;
        float realMoveDuration = self.size.height / velocity;
        SKAction * fireSound = [SKAction playSoundFileNamed:@"blaster.wav" waitForCompletion:NO];
        SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
        SKAction * actionMoveDone = [SKAction removeFromParent];
        [pewPewSprite runAction:[SKAction sequence:@[fireSound, actionMove, actionMoveDone]]];
    }
}

- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    [_parallaxNodeBackgrounds update:currentTime];
    
}

- (void)addEnemy {
    
    // Create sprite
    
    int r = (arc4random() % 6) + 1;
    
    SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithImageNamed:[NSString stringWithFormat:@"monster_%d", r]];
    enemy.size = CGSizeMake(40.0f, 40.0f);
    
    enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemy.size];
    enemy.physicsBody.dynamic = YES;
    enemy.physicsBody.categoryBitMask = enemyCategory;
    enemy.physicsBody.contactTestBitMask = projectileCategory;
    enemy.physicsBody.collisionBitMask = 0;
    
    // Determine where to spawn the monster along the Y axis
    int minX = enemy.size.height / 2;
    int maxX = self.frame.size.width - enemy.size.height / 2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    enemy.position = CGPointMake(actualX, self.frame.size.height+ enemy.size.width/2);
    [self addChild:enemy];
    
    // Determine speed of the monster
    int minDuration = 0.5;
    int maxDuration = 7.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(actualX, -enemy.size.width/2) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [enemy runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & enemyCategory) != 0)
    {
        [self projectile:(SKSpriteNode *) firstBody.node didCollideWithEnemy:(SKSpriteNode *) secondBody.node];
    } else if ((firstBody.categoryBitMask & enemyCategory) != 0 &&
               (secondBody.categoryBitMask & playerCategory) != 0) {
        [self enemy:(SKSpriteNode *) firstBody.node didCollideWithPlayer:(SKSpriteNode *) secondBody.node];
    }
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithEnemy:(SKSpriteNode *)enemy {
    NSLog(@"Hit");
    [projectile removeFromParent];
    [enemy removeFromParent];
    
    SKTexture *temp = _asplodeFrames[0];
    SKSpriteNode *asplode = [SKSpriteNode spriteNodeWithTexture:temp];
    asplode.size = CGSizeMake(100.0f, 100.0f);
    asplode.position = enemy.position;
    [self addChild:asplode];
    [self asplodeSomething:asplode];
    
}

-(void)asplodeSomething:(SKSpriteNode *)asplode {
    //This is our general runAction method to make our bear walk.
    [asplode runAction:[SKAction animateWithTextures:_asplodeFrames
                                       timePerFrame:0.02f
                                             resize:NO
                                              restore:NO] completion:^{
        [asplode removeFromParent];
        
    }];
    return;
}

- (void)enemy:(SKSpriteNode *)enemy didCollideWithPlayer:(SKSpriteNode *)player {
    // GAME OVER
    _isPlayerAlive = NO;
    NSLog(@"Hit Player");
    [enemy removeFromParent];
    [player removeFromParent];
    
    SKTexture *temp = _asplodeFrames[0];
    SKSpriteNode *asplode = [SKSpriteNode spriteNodeWithTexture:temp];
    SKAction * boomSound = [SKAction playSoundFileNamed:@"bigboom.wav" waitForCompletion:NO];
    [asplode runAction:[SKAction sequence:@[boomSound]]];
    asplode.size = CGSizeMake(200.0f, 200.0f);
    asplode.position = player.position;
    [self addChild:asplode];
    [self asplodeSomething:asplode];
    
    [_viewController showMenuView];
    [self.backgroundMusicPlayer stop];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        // spaceship tracks with finger
        CGPoint location = [touch locationInNode:self];
        self.player.position = location;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    
}

// Maths

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}

static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

@end
