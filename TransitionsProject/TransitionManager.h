//
// Created by Ian Dundas on 07/01/2014.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TransitionManager : UIPercentDrivenInteractiveTransition<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

- (void) panned: (UIPanGestureRecognizer *)recognizer;
@end