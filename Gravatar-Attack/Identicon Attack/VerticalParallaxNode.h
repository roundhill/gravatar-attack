#import <SpriteKit/SpriteKit.h>

@interface VerticalParallaxNode : SKNode

- (instancetype)initWithBackground:(NSString *)file size:(CGSize)size pointsPerSecondSpeed:(float)pointsPerSecondSpeed;
- (instancetype)initWithBackgrounds:(NSArray *)files size:(CGSize)size pointsPerSecondSpeed:(float)pointsPerSecondSpeed;
- (void)update:(NSTimeInterval)currentTime;


@end
