//
//  MapModeViewCtrl.h
//  BombVoyage
//
//  Created by Karatsu Naoya on 10/10/02.
//  Copyright 2010 ajapax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MKMapView.h>
#import "MyGLBaseView.h"
#import "Define.h"

#import "BVGameCore.h"
#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "graphicUtil.h"

// Uniform index.
enum {
    UNIFORM_TRANSLATE,
    NUM_UNIFORMS
};
//GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
    NUM_ATTRIBUTES
};

@interface MapModeViewCtrl : UIViewController {
  UIView* game_view;
  MyGLBaseView* anime_view;
  MKMapView* map_view;
  UIToolbar* tool_bar;

  EAGLContext *context;
  GLuint program;

  BVGameCore* game_core;

  BOOL animating;
  BOOL displayLinkSupported;
  NSInteger animationFrameInterval;
  /*
     Use of the CADisplayLink class is the preferred method for controlling your animation timing.
     CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
     The NSTimer object is used only as fallback when running on a pre-3.1 device where CADisplayLink isn't available.
     */
  id displayLink;
  NSTimer *animationTimer;

  UIButton* bomb_button;
  UIButton* search_button;
  UIButton* disposal_button;
  UIButton* tool_button;

  UIPopoverController* searchToolsPopoverCtrl;
  UIPopoverController* bombToolsPopoverCtrl;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (void) initMapView;
- (void) initToolbar;
- (void) performSearch;
- (void) handleLongPressGesture:(UILongPressGestureRecognizer*) sender;

@end
