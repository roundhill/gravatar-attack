#import "VerticalParallaxNode.h"


@implementation VerticalParallaxNode
{
    
    __block NSMutableArray *_backgrounds;
    NSInteger _numberOfImagesForBackground;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _deltaTime;
    float _pointsPerSecondSpeed;
    
}


- (instancetype)initWithBackground:(NSString *)file size:(CGSize)size pointsPerSecondSpeed:(float)pointsPerSecondSpeed
{
    // we add the file 3 times to avoid image flickering
    return [self initWithBackgrounds:@[file, file, file]
                                size:size
                pointsPerSecondSpeed:pointsPerSecondSpeed];
    
}

- (instancetype)initWithBackgrounds:(NSArray *)files size:(CGSize)size pointsPerSecondSpeed:(float)pointsPerSecondSpeed
{
    if (self = [super init])
    {
        _pointsPerSecondSpeed = pointsPerSecondSpeed;
        _numberOfImagesForBackground = [files count];
        _backgrounds = [NSMutableArray arrayWithCapacity:_numberOfImagesForBackground];
        [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:obj];
            node.size = size;
            node.anchorPoint = CGPointZero;
            node.position = CGPointMake(0.0, (idx == 0) ? 0.0 : size.height * idx);
            node.name = @"background";
            //NSLog(@"node.position = x=%f,y=%f",node.position.x,node.position.y);
            [_backgrounds addObject:node];
            [self addChild:node];
        }];
    }
    return self;
}


- (void)update:(NSTimeInterval)currentTime
{
    //To compute velocity we need delta time to multiply by points per second
    if (_lastUpdateTime) {
        _deltaTime = currentTime - _lastUpdateTime;
    } else {
        _deltaTime = 0;
    }
    _lastUpdateTime = currentTime;
    
    CGPoint bgVelocity = CGPointMake(0.0, -_pointsPerSecondSpeed);
    CGPoint amtToMove = CGPointMake(bgVelocity.x * _deltaTime, bgVelocity.y * _deltaTime);
    self.position = CGPointMake(self.position.x+amtToMove.x, self.position.y+amtToMove.y);
    SKNode *backgroundScreen = self.parent;
    
    [_backgrounds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKSpriteNode *bg = (SKSpriteNode *)obj;
        CGPoint bgScreenPos = [self convertPoint:bg.position
                                          toNode:backgroundScreen];
        if (bgScreenPos.y <= -bg.size.height)
        {
            bg.position = CGPointMake(bg.position.x, bg.position.y + (bg.size.height * _numberOfImagesForBackground));
        }
        
    }];
}

@end
