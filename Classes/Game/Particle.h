/*
 *  Particle.h
 *  BombVoyage
 *
 *  Created by Karatsu Naoya on 10/10/19.
 *  Copyright 2010 ajapax. All rights reserved.
 *
 */

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "graphicUtil.h"

class Particle {
  public:
    float x;
    float y;
    float size;
    bool activeFlag;
    float moveX;
    float moveY;
    int frameCount;
    int lifeSpan;

    Particle();
    void draw(GLuint texture);
    void update();
};