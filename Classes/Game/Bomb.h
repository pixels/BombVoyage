/*
 *  Bomb.h
 *  BombVoyage
 *
 *  Created by Karatsu Naoya on 10/10/23.
 *  Copyright 2010 ajapax. All rights reserved.
 *
 */

#import "Particle.h"
#import <AVFoundation/AVFoundation.h>

class Bomb : public Particle {
  public:
    Bomb();
    void add(float x, float y, float size, float moveX, float moveY);
    void update();
    void blast();
    void goOut();
    Particle* particle[PARTICLE_COUNT];
    int mode;
    int modeStartFrame;
    AVAudioPlayer* hitSound;
};
