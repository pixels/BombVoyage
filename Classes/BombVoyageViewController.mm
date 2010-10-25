//
//  BombVoyageViewController.m
//  BombVoyage
//
//  Created by Karatsu Naoya on 10/10/02.
//  Copyright 2010 ajapax. All rights reserved.
//

#import "BombVoyageViewController.h"
#import "AnimationNames.h"
#import "Define.h"
#import "EventNames.h"
#import "MainMenuViewCtrl.h"
#import "UnderConstViewCtrl.h"
#import "MapModeViewCtrl.h"
#import "BVLoginViewCtrl.h"

@implementation BombVoyageViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];

  [self.view setBackgroundColor:[UIColor redColor]];
  self.view.frame = CGRectMake(0, 0, WINDOW_W, WINDOW_H);

  if ([self needToLogin]) {
    ctrl = [[BVLoginViewCtrl alloc] init];
  } else {
    ctrl = [[MainMenuViewCtrl alloc] init];
  }
  [self.view addSubview:ctrl.view];

  downloader = [[BVDataDownloader alloc] init];

  NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
  [notificationCenter addObserver:self selector:@selector(onGoToMapModeButtonPushed:) name:GO_TO_NEXT_PAGE_EVENT object:nil];
  [notificationCenter addObserver:self selector:@selector(goToMainMenu) name:GO_TO_MAIN_MENU_EVENT object:nil];
  [notificationCenter addObserver:self selector:@selector(onSendLoginRequestButtonPushed:) name:SEND_LOGIN_REQUEST_EVENT object:nil];
  [notificationCenter addObserver:self selector:@selector(onReceiveReplyToLoginRequest:) name:RECEIVE_REPLY_TO_LOGIN_REQUEST_EVENT object:nil];
}

- (BOOL)needToLogin {
  return true;
}

- (void)onGoToMapModeButtonPushed:(UIButton *)sender {
  [self goToMapMode];
}

- (void)onReceiveReplyToLoginRequest:(NSNotification *)notification {
  [ctrl receiveReplyToLoginRequest:[notification userInfo]];
}

- (void)onSendLoginRequestButtonPushed:(NSNotification *)notification {
  [downloader sendLoginRequest:[NSString stringWithFormat:@"action=login&name=%@&pass=%@", [[notification userInfo] objectForKey:@"name"],[[notification userInfo] objectForKey:@"pass"]]];
}

- (void)onLoginButtonPushed:(UIButton *)sender {
  [downloader establishConnection];
}

- (void)goToLoginMode {
  UIViewController * login_mode_ctrl = [[MainMenuViewCtrl alloc] init];

  [self goToModeWithCtrl:login_mode_ctrl];
}

- (void)goToMainMenu {
  UIViewController * main_menu_ctrl = [[MainMenuViewCtrl alloc] init];

  [self goToModeWithCtrl:main_menu_ctrl];
}

- (void)goToMapMode {
  UIViewController * map_mode_ctrl = [[MapModeViewCtrl alloc] init];

  [self goToModeWithCtrl:map_mode_ctrl];
}

- (void)goToModeWithCtrl:(UIViewController *)target_ctrl {
[self.view insertSubview:target_ctrl.view belowSubview:ctrl.view];

[self initAnimation:GO_TO_MAIN_MENU_ANIM_ID duration:0.5f];

[target_ctrl.view setAlpha:0];
[ctrl.view setAlpha:1];
[ctrl viewWillDisappear:YES];
[target_ctrl.view setAlpha:1];
[ctrl.view setAlpha:0];
[ctrl viewDidDisappear:YES];
[UIView commitAnimations];

[ctrl release];
ctrl = target_ctrl;
}

- (void)goToUnderConst {
  NSLog(@"under const");
  UIViewController * under_const_ctrl = [[UnderConstViewCtrl alloc] init];

  [self.view insertSubview:under_const_ctrl.view belowSubview:ctrl.view];

  [self initAnimation:GO_TO_UNDER_CONST_ANIM_ID duration:0.5f];

  [under_const_ctrl.view setAlpha:0];
  [ctrl.view setAlpha:1];
  [ctrl viewWillDisappear:YES];
  [under_const_ctrl.view setAlpha:1];
  [ctrl.view setAlpha:0];
  [ctrl viewDidDisappear:YES];
  [UIView commitAnimations];

  [ctrl release];
  ctrl = [[MainMenuViewCtrl alloc] init];
}

- (void)initAnimation:(NSString *)animationID duration:(NSTimeInterval)duration {
  CGContextRef context = UIGraphicsGetCurrentContext();
  [UIView beginAnimations:animationID context:context];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
  [UIView setAnimationDuration:duration];
  [UIView setAnimationDelegate: self];
  [UIView setAnimationDidStopSelector:@selector(onAnimationEnd:finished:context:)];	
}

-(void)onAnimationEnd:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if ([animationID isEqualToString:GO_TO_MAIN_MENU_ANIM_ID]) {
	  NSLog(@"animation end");
	}
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
// Return YES for supported orientations
return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];

  // Release any cached data, images, etc that aren't in use.
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
  } else {
    return NO;
  }
  return YES;
}

- (void)viewDidUnload {
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)dealloc {
  [downloader release];
  [super dealloc];
}

@end
