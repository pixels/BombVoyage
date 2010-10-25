//
//  BombVoyageViewController.h
//  BombVoyage
//
//  Created by Karatsu Naoya on 10/10/02.
//  Copyright 2010 ajapax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BVDataDownloader.h"

@interface BombVoyageViewController : UIViewController {
  UIViewController * ctrl;
  BVDataDownloader *downloader;
}

- (BOOL)needToLogin;
- (void)goToLoginMode;
- (void)goToMainMenu;
- (void)goToUnderConst;
- (void)goToMapMode;
- (void)goToModeWithCtrl:(UIViewController *)target_ctrl;
- (void)initAnimation:(NSString *)animationID duration:(NSTimeInterval)duration;
- (void)onAnimationEnd:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)onSendLoginRequestButtonPushed:(NSNotification *)notification;

@end

