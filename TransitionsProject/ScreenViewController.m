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


    // Dev ---
    UILabel *devLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
    [devLabel setText:@"Here is some text"];
    [devLabel setTextColor:[UIColor redColor]];
    [devLabel setTextAlignment:NSTextAlignmentCenter];

    devLabel.center= self.view.center;
    [self.view addSubview:devLabel];
    // End Dev ---
}

-(void)dealloc{
    [self.panGesture removeTarget:self.navigationController.transitioningDelegate action:@selector(panned:)];
}

-(void) doNextTransition{
    UIViewController *nextVC= [[ScreenViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:nextVC animated:YES];
}

@end