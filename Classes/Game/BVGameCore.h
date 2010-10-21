/*
 *  BVGameCore.h
 *  BombVoyage
 *
 *  Created by Karatsu Naoya on 10/10/20.
 *  Copyright 2010 ajapax. All rights reserved.
 *
 */

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <AVFoundation/AVFoundation.h>
#import "Particle.h"
#define PARTICLE_COUNT 100

class BVGameCore {
  private:
    Particle* particle[PARTICLE_COUNT];
    GLuint blastTexture;
    NSDictionary* dic;
    AVAudioPlayer* hitSound;
  public:
    BVGameCore();
    void loadTextures();
    void add(float x, float y, float size, float moveX, float moveY);
    void draw();
    void drawSplash();
    void update();
    void dealloc();
};
