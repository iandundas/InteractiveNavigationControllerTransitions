//
// Created by Ian Dundas on 07/01/2014.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "TransitionManager.h"
#import "ScreenViewController.h"

@interface TransitionManager()
@property BOOL isPresenting;
@property BOOL isInteractive;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation TransitionManager

//-(id)initWithSourceView:(UIView *)sourceView
-(id)init
{
    if (!(self = [super init])) return nil;

//    _sourceView= sourceView;

    [self setIsPresenting:true];//DELETE

    return self;
}

#pragma mark UIPanGestureRecogniser Target:
#pragma mark ----------

- (void) panned: (UIPanGestureRecognizer *)recognizer{

    CGPoint location = [recognizer locationInView:recognizer.view];
    CGPoint velocity = [recognizer velocityInView:recognizer.view];
    CGFloat ratio = location.x / CGRectGetWidth(recognizer.view.bounds);

    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            [self setIsInteractive:true];// must be, as we're panning.

            NSArray *colors= @[[UIColor redColor], [UIColor blueColor], [UIColor purpleColor], [UIColor brownColor], [UIColor yellowColor], [UIColor greenColor]];
            UIViewController *nextVC= [[ScreenViewController alloc] initWithNibName:nil bundle:nil];
            [nextVC.view setBackgroundColor: colors[self.navigationController.viewControllers.count]];
            [nextVC setTitle: [NSString stringWithFormat:@"VC: %i", self.navigationController.viewControllers.count]];

            [self.navigationController pushViewController:nextVC animated:YES];
            break;
        }

        case UIGestureRecognizerStateChanged:{
            NSLog(@"Ratio: %f", ratio);
            [self updateInteractiveTransition:ratio];

            break;
        }

        case UIGestureRecognizerStateEnded:
            if (ratio >= 0.70)
                [self cancelInteractiveTransition];
            else
                [self finishInteractiveTransition];//                [self finishInteraction];
            break;

        default:
            [self cancelInteractiveTransition];
            break;
    }
}

#pragma mark UIViewControllerInteractiveTransitioning
#pragma mark ----------

- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
    self.transitionContext = transitionContext;

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    CGRect endFrame = [[transitionContext containerView] bounds];

    if ([self isPresenting])
    {
        // The order of these matters – determines the view hierarchy order.
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];

        endFrame.origin.x += CGRectGetWidth([[transitionContext containerView] bounds]);
    }
    else {
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
    }

    NSLog(@"Starting frame: %@", NSStringFromCGRect(endFrame));
    toViewController.view.frame = endFrame;
}

#pragma mark UIPercentDrivenInteractiveTransition
#pragma mark ----------
- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    NSLog(@"Here10: PERCENTAGE: %f", percentComplete);
//    [super updateInteractiveTransition:percentComplete];

    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    // Presenting goes from 0...1 and dismissing goes from 1...0
    CGRect frame = CGRectOffset([[transitionContext containerView] bounds], 1.0 * CGRectGetWidth([[transitionContext containerView] bounds]) * percentComplete, 0);
//initial configuration:
//    CGRect frame = CGRectOffset([[transitionContext containerView] bounds], -CGRectGetWidth([[transitionContext containerView] bounds]) * (1.0f - percentComplete), 0);

    if ([self isPresenting])
    {
        toViewController.view.frame = frame;
        NSLog(@"Setting frame: %@", NSStringFromCGRect(frame));
    }
    else {
        fromViewController.view.frame = frame;
    }
}

- (void)finishInteractiveTransition {

    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;

    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    if ([self isPresenting])
    {
        CGRect endFrame = [[transitionContext containerView] bounds];

        [UIView animateWithDuration:0.5f animations:^{
            toViewController.view.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        CGRect endFrame = CGRectOffset([[transitionContext containerView] bounds], -CGRectGetWidth([[self.transitionContext containerView] bounds]), 0);

        [UIView animateWithDuration:0.5f animations:^{
            fromViewController.view.frame = endFrame;
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
        CGRect endFrame = CGRectOffset([[transitionContext containerView] bounds], CGRectGetWidth([[transitionContext containerView] bounds]), 0);

        [UIView animateWithDuration:0.5f animations:^{
            toViewController.view.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:NO];
        }];
    }
    else {
        CGRect endFrame = [[transitionContext containerView] bounds];

        [UIView animateWithDuration:0.5f animations:^{
            fromViewController.view.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:NO];
        }];
    }

    [self.transitionContext cancelInteractiveTransition];
}



#pragma mark UIViewControllerAnimatedTransitioning
#pragma mark -----------
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    NSLog(@"Here9");
    return 1.5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    NSLog(@"HERE8");
    if (self.isInteractive){
        // do nothing..
    }
    else{

    }
}

- (void)animationEnded:(BOOL)transitionCompleted {
    // Reset to our default state
    [self setIsInteractive:false];
//    [self setIsPresenting:false];
    [self setTransitionContext:nil];
}


#pragma mark UIViewControllerTransitioningDelegate
#pragma mark --------
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    NSLog(@"HERE1");
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    NSLog(@"HERE2");
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    NSLog(@"HERE3");
    return self.isInteractive? self : nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    NSLog(@"HERE4");
    return self.isInteractive? self : nil;
}


#pragma mark UINavigationControllerDelegate
#pragma mark ----------
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    NSLog(@"HERE5");
    return self;
}
- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController {
    NSLog(@"HERE6: %i", self.isInteractive);
    return self.isInteractive? self : nil;
}



@end