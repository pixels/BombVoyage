    //
//  MapModeViewCtrl.m
//  BombVoyage
//
//  Created by Karatsu Naoya on 10/10/02.
//  Copyright 2010 ajapax. All rights reserved.
//

#import "MapModeViewCtrl.h"
#import "BVGameViewCtrl.h"

@interface MapModeViewCtrl ()
@property (nonatomic, retain) EAGLContext *context;
@end

@implementation MapModeViewCtrl

@synthesize animating, context;

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

    game_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WINDOW_W, WINDOW_H)];
    [self.view addSubview:game_view];

    [self initMapView];

    [self initGameView];

    [self initToolbar];
}

- (void) initMapView {
    map_view = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, WINDOW_W, WINDOW_H)];
    map_view.zoomEnabled = NO;
    map_view.scrollEnabled = NO;
    [game_view addSubview:map_view];

    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    if ([locationManager locationServicesEnabled]) {
      locationManager.delegate = self;
      [locationManager startUpdatingLocation];
    } else {
    }
}

- (void) initGameView {
  NSLog(@"init game view");
  anime_view = [[MyGLBaseView alloc] initWithFrame:CGRectMake(0, 0, WINDOW_W, WINDOW_H)];
  [game_view addSubview:anime_view];

  anime_view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
  //[anime_view setBackgroundColor:[UIColor redColor]];

  EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];

  if (!aContext)
    NSLog(@"Failed to create ES context");
  else if (![EAGLContext setCurrentContext:aContext])
    NSLog(@"Failed to set ES context current");

  self.context = aContext;
  [aContext release];

  [(MyGLBaseView *)anime_view setContext:self.context];
  [(MyGLBaseView *)anime_view setFramebuffer];

  animating = FALSE;
  displayLinkSupported = FALSE;
  animationFrameInterval = 1;
  displayLink = nil;
  animationTimer = nil;

  // Use of CADisplayLink requires iOS version 3.1 or greater.
  // The NSTimer object is used as fallback when it isn't available.
  NSString *reqSysVer = @"3.1";
  NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
  if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
    displayLinkSupported = TRUE;
  }

  srand(time(NULL));
  game_core = new BVGameCore();

  [self startAnimation];
}

- (void)startAnimation
{
  NSLog(@"start animation");
  if (!animating)
  {
    if (displayLinkSupported)
    {
      /*
	 CADisplayLink is API new in iOS 3.1. Compiling against earlier versions will result in a warning, but can be dismissed if the system version runtime check for CADisplayLink exists in -awakeFromNib. The runtime check ensures this code will not be called in system versions earlier than 3.1.
	 */
      displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawFrame)];
      [displayLink setFrameInterval:animationFrameInterval];

      // The run loop will retain the display link on add.
      [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    else
      animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawFrame) userInfo:nil repeats:TRUE];

    animating = TRUE;
  }
}

- (void)stopAnimation
{
  if (animating)
  {
    if (displayLinkSupported)
    {
      [displayLink invalidate];
      displayLink = nil;
    }
    else
    {
      [animationTimer invalidate];
      animationTimer = nil;
    }

    animating = FALSE;
  }
}

- (void)drawFrame
{
  [(MyGLBaseView *)anime_view setFramebuffer];

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  // viewの座標系を変更(画面中心を原点として，幅2，高さ3にしている)
  glOrthof(-1.0f, 1.0f, -1.5f, 1.5f, 0.5f, -0.5f);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
  glClear(GL_COLOR_BUFFER_BIT);

  //drawSquare();

  game_core->update();

  game_core->draw();

  [(MyGLBaseView *)anime_view presentFramebuffer];
}

- (void) initToolbar {
  tool_bar = [[UIToolbar alloc] init];
  tool_bar.barStyle = UIBarStyleDefault;
  tool_bar.frame = CGRectMake(0, 460 - 70, 320, 70);

  UILongPressGestureRecognizer* longPressGesture;

  search_button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, TOOL_BUTTON_WIDTH, TOOL_BUTTON_HEIGHT)];
  [search_button setBackgroundImage:[UIImage imageNamed:@"search_icon.png"] forState:UIControlStateNormal];
  [search_button addTarget:self action:@selector(performSearch) forControlEvents:UIControlEventTouchUpInside];
  longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
  [search_button addGestureRecognizer:longPressGesture];
  [longPressGesture release];
  UIBarButtonItem* search_button_item = [[UIBarButtonItem alloc] initWithCustomView:search_button];

  bomb_button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, TOOL_BUTTON_WIDTH, TOOL_BUTTON_HEIGHT)];
  [bomb_button setBackgroundImage:[UIImage imageNamed:@"bomb_icon.png"] forState:UIControlStateNormal];
  [bomb_button addTarget:self action:@selector(performSearch) forControlEvents:UIControlEventTouchUpInside];
  longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
  [bomb_button addGestureRecognizer:longPressGesture];
  [longPressGesture release];
  UIBarButtonItem* bomb_button_item = [[UIBarButtonItem alloc] initWithCustomView:bomb_button];

  disposal_button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, TOOL_BUTTON_WIDTH, TOOL_BUTTON_HEIGHT)];
  [disposal_button setBackgroundImage:[UIImage imageNamed:@"search_icon.png"] forState:UIControlStateNormal];
  [disposal_button addTarget:self action:@selector(performSearch) forControlEvents:UIControlEventTouchUpInside];
  UIBarButtonItem* disposal_button_item = [[UIBarButtonItem alloc] initWithCustomView:disposal_button];

  tool_button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, TOOL_BUTTON_WIDTH, TOOL_BUTTON_HEIGHT)];
  [tool_button setBackgroundImage:[UIImage imageNamed:@"bomb_icon.png"] forState:UIControlStateNormal];
  [tool_button addTarget:self action:@selector(performSearch) forControlEvents:UIControlEventTouchUpInside];
  UIBarButtonItem* tool_button_item = [[UIBarButtonItem alloc] initWithCustomView:tool_button];

  UIBarButtonItem* espaceFlexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
										  target:nil
										  action:nil];

  NSArray *elements = [NSArray arrayWithObjects:search_button_item, espaceFlexible, bomb_button_item, espaceFlexible, disposal_button_item, espaceFlexible, tool_button_item, nil];
  [search_button release];
  [bomb_button release];
  [disposal_button release];
  [tool_button release];

  [tool_bar setItems:elements animated:NO];
  [self.view addSubview:tool_bar];
}

- (void) handleLongPressGesture:(UILongPressGestureRecognizer*) sender {
  if (sender.view == bomb_button ) {
    NSLog(@"long press : bomb");
    if (!bombToolsPopoverCtrl) {
      UIImagePickerController *picker = [[UIImagePickerController alloc] init];
      bombToolsPopoverCtrl = [[UIPopoverController alloc] initWithContentViewController:picker];
      bombToolsPopoverCtrl.delegate = self;
      //[picker release];
    }
    if (!bombToolsPopoverCtrl.popoverVisible) {
      [bombToolsPopoverCtrl presentPopoverFromBarButtonItem:bomb_button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
  } else {
    NSLog(@"long press : search");
  }
}

- (void)locationManager:(CLLocationManager*)manager 
    didUpdateToLocation:(CLLocation*)newLocation 
	   fromLocation:(CLLocation*)oldLocation
{
  CLLocationCoordinate2D coordinate = newLocation.coordinate;
  [map_view setCenterCoordinate:coordinate animated:NO];
  NSLog(@"latitude %f", coordinate.latitude);
  NSLog(@"longitude %f", coordinate.longitude);

  MKCoordinateRegion zoom = map_view.region;
  zoom.span.latitudeDelta = 0.005;
  zoom.span.longitudeDelta = 0.005;
  [map_view setRegion:zoom animated:NO];
}

- (void)locationManager:(CLLocationManager*)manager didFailWithError:(NSError*)error {}

- (void) performSearch {
  CLLocationManager *locationManager = [[CLLocationManager alloc] init];
  if ([locationManager locationServicesEnabled]) {
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
  } else {
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

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [super dealloc];
}


@end
