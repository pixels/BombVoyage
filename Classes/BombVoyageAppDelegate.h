//
//  BombVoyageAppDelegate.h
//  BombVoyage
//
//  Created by Karatsu Naoya on 10/10/02.
//  Copyright 2010 ajapax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BombVoyageViewController;

@interface BombVoyageAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    BombVoyageViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BombVoyageViewController *viewController;

@end

