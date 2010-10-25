    //
//  MainMenuViewCtrl.m
//  BombVoyage
//
//  Created by Karatsu Naoya on 10/10/02.
//  Copyright 2010 ajapax. All rights reserved.
//

#import "MainMenuViewCtrl.h"
#import "MessageText.h"
#import "EventNames.h"


@implementation MainMenuViewCtrl

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
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

  [self.view setBackgroundColor:[UIColor blueColor]];

  [self setButtonsMyself];
}

- (void)setButtonsMyself {
  goToMapModeButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
  [goToMapModeButton setTitle:GO_TO_MAP_MODE_MESSAGE forState:UIControlStateNormal];
  goToMapModeButton.enabled = true;
  [goToMapModeButton addTarget:self action:@selector(onGoToMapModeButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
  [goToMapModeButton setUserInteractionEnabled:YES];
  goToMapModeButton.frame = CGRectMake(0, 0, 150, 50);
  [self.view addSubview:goToMapModeButton];
  
  sendRequestButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
  [sendRequestButton setTitle:GO_TO_MAP_MODE_MESSAGE forState:UIControlStateNormal];
  sendRequestButton.enabled = true;
  [sendRequestButton addTarget:self action:@selector(onSendRequestButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
  [sendRequestButton setUserInteractionEnabled:YES];
  sendRequestButton.frame = CGRectMake(0, 100, 150, 50);
  //[self.view addSubview:sendRequestButton];

}

- (void)onGoToMapModeButtonPushed:(UIButton *)sender {
  [[NSNotificationCenter defaultCenter] postNotificationName:GO_TO_NEXT_PAGE_EVENT object:nil userInfo:nil];
}

- (void)onSendRequestButtonPushed:(UIButton *)sender {
  NSArray *keys = [[NSArray alloc] initWithObjects:@"name", @"pass", nil];
  NSArray *values = [[NSArray alloc] initWithObjects:@"karatsu", @"pixels", nil];
  NSDictionary *data = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
  [keys release];
  [values release];
  [[NSNotificationCenter defaultCenter] postNotificationName:SEND_REQUEST_EVENT
						      object:nil
						    userInfo:data];
  [data release];
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

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [super dealloc];
}


@end
