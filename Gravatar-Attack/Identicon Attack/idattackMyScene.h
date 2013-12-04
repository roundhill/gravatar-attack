//
//  idattackMyScene.h
//  Identicon Attack
//

//  Copyright (c) 2013 Dan Roundhill. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "idattackViewController.h"

@interface idattackMyScene : SKScene

@property (nonatomic, weak) idattackViewController *viewController;

- (void)createNewGame;

@end
