//
//  idattackViewController.m
//  Identicon Attack
//
//  Created by Dan Roundhill on 12/3/13.
//  Copyright (c) 2013 Dan Roundhill. All rights reserved.
//

#import "idattackViewController.h"
#import "idattackMyScene.h"


@implementation idattackViewController

UIView *_menuView;
idattackMyScene *_gameScene;

- (void)viewDidLoad
{
    [super viewDidLoad];

    /*// Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [idattackMyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];*/
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self showMenuView];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        //skView.showsFPS = YES;
        //skView.showsNodeCount = YES;
        
        // Create and configure the scene.
        _gameScene = [idattackMyScene sceneWithSize:skView.bounds.size];
        _gameScene.scaleMode = SKSceneScaleModeAspectFill;
        _gameScene.viewController = self;
        
        // Present the scene.
        [skView presentScene:_gameScene];
    }
}

- (void)showMenuView {
    if (_menuView == nil) {
        _menuView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, -self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
        [_menuView setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.65f]];
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        logo.frame = CGRectMake((_menuView.frame.size.width / 2) - (logo.frame.size.width / 2) , 60.0f, logo.frame.size.width, logo.frame.size.height);
        [_menuView addSubview:logo];
        
        UIButton *newGameButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 220.0f, _menuView.frame.size.width, 80.0f)];
        [newGameButton setTitle:@"NEW GAME" forState:UIControlStateNormal];
        [newGameButton setBackgroundColor:[UIColor colorWithRed:0.0f green:127.0f blue:0.0f alpha:0.1f]];
        [newGameButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.0f green:127.0f blue:0.0f alpha:0.1f]] forState:UIControlStateNormal];
        [newGameButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.0f green:127.0f blue:0.0f alpha:0.5f]] forState:UIControlStateNormal];
        
        [newGameButton addTarget:self action:@selector(newGame) forControlEvents:UIControlEventTouchUpInside];
        
        [_menuView addSubview:newGameButton];
        
        [self.view addSubview:_menuView];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    _menuView.frame = CGRectMake(_menuView.frame.origin.x, 0.0f, _menuView.frame.size.width, _menuView.frame.size.height);
    [UIView commitAnimations];
}

- (void)hideMenuView {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    _menuView.frame = CGRectMake(_menuView.frame.origin.x, -_menuView.frame.size.height, _menuView.frame.size.width, _menuView.frame.size.height);
    [UIView commitAnimations];
}

- (void)newGame {
    if (_gameScene != nil) {
        
        [self hideMenuView];
        
        [_gameScene createNewGame];
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
