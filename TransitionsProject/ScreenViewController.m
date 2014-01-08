//
// Created by Ian Dundas on 07/01/2014.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "ScreenViewController.h"
#import "TransitionManager.h"
#import "AppDelegate.h"
@interface ScreenViewController()
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@end

@implementation ScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Screen"];

    [self.navigationItem setRightBarButtonItem: [[UIBarButtonItem alloc]
                initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                     target:self
                                     action:@selector(doNextTransition)]
    ];

    self.panGesture= [[UIPanGestureRecognizer alloc]
            initWithTarget:[(AppDelegate*)[[UIApplication sharedApplication] delegate] transitionManager]
                    action:@selector(panned:)
    ];
    [self.view addGestureRecognizer:self.panGesture];
}

-(void)dealloc{
    [self.panGesture removeTarget:self.navigationController.transitioningDelegate action:@selector(panned:)];
}

-(void) doNextTransition{

//    if (!self.nextViewController){
//        self.nextViewController= [[ScreenViewController alloc] initWithNibName:nil bundle:nil];
//    }
//    UIViewController *nextVC= [[ScreenViewController alloc] initWithNibName:nil bundle:nil];
//    nextVC.transitioningDelegate=self.transitioningDelegate;
//
//    [self.navigationController pushViewController:nextVC animated:YES];
}

@end