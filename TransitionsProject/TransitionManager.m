//
// Created by Ian Dundas on 07/01/2014.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "TransitionManager.h"
#import "ScreenViewController.h"

#define TIMING 1.5

@interface TransitionManager()
@property BOOL isPresenting;
@property BOOL isInteractive;
@property CGFloat previousLocationX;
@property CGFloat deltaXTotal;
@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;
@end

@implementation TransitionManager


#pragma mark UIPanGestureRecogniser Target:
#pragma mark ----------

- (void) panned: (UIPanGestureRecognizer *)recognizer{

    CGPoint location = [recognizer locationInView:self.transitionContext.containerView];
    CGPoint velocity = [recognizer velocityInView:self.transitionContext.containerView];

    CGFloat delta_x = location.x - _previousLocationX;
    CGFloat ratio = location.x / CGRectGetWidth(self.transitionContext.containerView.bounds);

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{

            [self setIsInteractive:true];// must be, as we're panning.

            if (velocity.x < 0){
                _deltaXTotal = CGRectGetWidth(self.transitionContext.containerView.bounds);

                NSLog(@"Presenting!");
                [self setIsPresenting:true];

                UIViewController *nextVC= [[ScreenViewController alloc] initWithNibName:nil bundle:nil];
                NSArray *colors= @[[UIColor redColor], [UIColor blueColor], [UIColor purpleColor], [UIColor brownColor], [UIColor yellowColor], [UIColor greenColor]];
                [nextVC.view setBackgroundColor: colors[self.navigationController.viewControllers.count]];
                [nextVC setTitle: [NSString stringWithFormat:@"VC: %i", self.navigationController.viewControllers.count]];

                [self.navigationController pushViewController:nextVC animated:YES];
            }
            else{
                _deltaXTotal = 0;

                NSLog(@"Dismissing!");
                [self setIsPresenting:false];

                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        }

        case UIGestureRecognizerStateChanged:{
            _deltaXTotal += delta_x;

            CGFloat newPercentage = ABS(_deltaXTotal /CGRectGetWidth(self.transitionContext.containerView.bounds));

            [self updateInteractiveTransition:1*newPercentage];
            break;
        }

        case UIGestureRecognizerStateEnded:
            if (self.isPresenting){
                if (ratio >= 0.70)
                    [self cancelInteractiveTransition];
                else
                    [self finishInteractiveTransition];//                [self finishInteraction];
            }
            else{
                if (ratio <= 0.30)
                    [self cancelInteractiveTransition];
                else
                    [self finishInteractiveTransition];//                [self finishInteraction];
            }
            break;

        default:
            [self cancelInteractiveTransition];
            break;
    }

    _previousLocationX= location.x;
}

#pragma mark UIViewControllerInteractiveTransitioning
#pragma mark ----------

- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    self.transitionContext = transitionContext;

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    CGRect endFrame = [[transitionContext containerView] bounds];

    if ([self isPresenting]){
        // The order of these matters – determines the view hierarchy order.
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];

        endFrame.origin.x += CGRectGetWidth(transitionContext.containerView.bounds);
        toViewController.view.frame = endFrame;
    }
    else {
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];

        endFrame.origin.x -= CGRectGetWidth(transitionContext.containerView.bounds);
        toViewController.view.frame = endFrame;
    }
}

#pragma mark UIPercentDrivenInteractiveTransition
#pragma mark ----------
- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    CGFloat pixelOffset= CGRectGetWidth([[transitionContext containerView] bounds]) * percentComplete;

    CGRect toFrame;
    CGRect fromFrame;

    if ([self isPresenting]){
        fromFrame=CGRectOffset([[transitionContext containerView] bounds], -pixelOffset, 0);
        toFrame = CGRectOffset(fromFrame, CGRectGetWidth([[transitionContext containerView] bounds]), 0);
    }
    else {
        fromFrame=CGRectOffset([[transitionContext containerView] bounds], pixelOffset, 0);
        toFrame = CGRectOffset(fromFrame, -CGRectGetWidth([[transitionContext containerView] bounds]), 0);
    }

    toViewController.view.frame = toFrame;
    fromViewController.view.frame= fromFrame;
}

- (void)finishInteractiveTransition {

    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    if ([self isPresenting])
    {
        CGRect endFrame = [[transitionContext containerView] bounds];

        [UIView animateWithDuration:TIMING animations:^{
            toViewController.view.frame = endFrame;
            fromViewController.view.frame = CGRectOffset(endFrame, -CGRectGetWidth([[transitionContext containerView] bounds]), 0);
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        CGRect endFrame = [[transitionContext containerView] bounds];

        [UIView animateWithDuration:TIMING animations:^{
            toViewController.view.frame = endFrame;
            fromViewController.view.frame = CGRectOffset(endFrame, CGRectGetWidth([[self.transitionContext containerView] bounds]), 0);;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    [self.transitionContext finishInteractiveTransition];
}

- (void)cancelInteractiveTransition {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    if ([self isPresenting])
    {
        CGRect endFrame = [[transitionContext containerView] bounds];

        [UIView animateWithDuration:TIMING animations:^{
            fromViewController.view.frame= endFrame;
            toViewController.view.frame = CGRectOffset(endFrame, CGRectGetWidth([[self.transitionContext containerView] bounds]), 0);
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:NO];
        }];
    }
    else {
        CGRect endFrame = [[transitionContext containerView] bounds];

        [UIView animateWithDuration:TIMING animations:^{
            fromViewController.view.frame = endFrame;
            toViewController.view.frame= CGRectOffset(endFrame, -CGRectGetWidth([[transitionContext containerView] bounds]), 0);
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:NO];
        }];
    }

    [self.transitionContext cancelInteractiveTransition];
}



#pragma mark UIViewControllerAnimatedTransitioning
#pragma mark -----------
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return TIMING;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.isInteractive){
        // do nothing..
    }
    else{
        // TODO: Implement automatic transitions here.
        NSLog(@"TODO: Implement automatic transitions");
    }
}

- (void)animationEnded:(BOOL)transitionCompleted {
    // Reset to our default state
    [self setIsInteractive:false];
    [self setIsPresenting:false];
    [self setTransitionContext:nil];
    [self setPreviousLocationX:0];
    [self setDeltaXTotal:0];
}


#pragma mark UIViewControllerTransitioningDelegate
#pragma mark --------
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return self.isInteractive? self : nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return self.isInteractive? self : nil;
}


#pragma mark UINavigationControllerDelegate
#pragma mark ----------
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    return self;
}
- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController {
    return self.isInteractive? self : nil;
}



@end