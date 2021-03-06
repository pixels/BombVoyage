//
//  MyGLBaseView.h
//  BombVoyage
//
//  Created by Karatsu Naoya on 10/10/19.
//  Copyright 2010 ajapax. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface MyGLBaseView : UIView {
  @private
    EAGLContext *context;

  GLint framebufferWidth;
  GLint framebufferHeight;

  GLuint defaultFramebuffer, colorRenderbuffer;
}

@property (nonatomic, retain) EAGLContext *context;

@end
