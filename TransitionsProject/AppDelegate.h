//
//  AppDelegate.h
//  TransitionsProject
//
//  Created by Ian Dundas on 07/01/2014.
//  Copyright (c) 2014 Ian Dundas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TransitionManager;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) TransitionManager *transitionManager;
@property (strong, nonatomic) UIWindow *window;

@end