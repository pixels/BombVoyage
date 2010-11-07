/*
 *  Bomb.mm
 *  BombVoyage
 *
 *  Created by Karatsu Naoya on 10/10/23.
 *  Copyright 2010 ajapax. All rights reserved.
 *
 */

#include "Bomb.h"

Bomb::Bomb() : Particle() {
  for(int i=0; i<PARTICLE_COUNT; i++) {
    particle[i] = new Particle();
  }
  mode = BOMB_CD;
  modeStartFrame = frameCount;

  NSString *hitSoundFilePath = [[NSBundle mainBundle] pathForResource:@"blastSound" ofType:@"wav"];
  NSURL *hitSoundFileUrl = [NSURL fileURLWithPath:hitSoundFilePath];
  hitSound = [[AVAudioPlayer alloc] initWithContentsOfURL:hitSoundFileUrl error:nil];
  [hitSound prepareToPlay];
}

void Bomb::update() {
  frameCount++;

  if ( mode == BOMB_CD ) {
    if ( frameCount > 200 ) {
      blast();
    }

    size = 0.25 + 0.25 * (sinf(0.1 * frameCount) + 1) / 2;

    x += moveX;
    y += moveY;
  
  } else if ( mode == BOMB_BLASTING ) {
    if ( frameCount < 300 ) {
      float p_x = x + randF() -0.5f;
      float p_y = y + randF() -0.5f;
      float p_size = randF() * 0.7f;
      float p_moveX = 0.0f;
      float p_moveY = 0.0f;
      add(p_x, p_y, p_size, p_moveX, p_moveY);
    }

    int c = 0;
    for(int i=0; i<PARTICLE_COUNT; i++) {
      if(particle[i]->activeFlag == true) {
	c++;
	particle[i]->update();
      }
    }
    if (c == 0) {
      goOut();
    }
  }
}

void Bomb::blast() {
  mode = BOMB_BLASTING;
  modeStartFrame = frameCount;
}

void Bomb::goOut() {
  mode = BOMB_CD;
  activeFlag = false;
}

void Bomb::add(float x, float y, float size, float moveX, float moveY) {
  for(int i=0; i<PARTICLE_COUNT; i++) {
    if(particle[i]->activeFlag == false) {
      particle[i]->activeFlag = true;
      particle[i]->x = x;
      particle[i]->y = y;
      particle[i]->size = size;
      particle[i]->moveX = moveX;
      particle[i]->moveY = moveY;
      particle[i]->frameCount = 0;
      particle[i]->lifeSpan = PARTICLE_COUNT;

      if ( i % 10 == 0 ) {
	[hitSound setCurrentTime:0.0f];
	[hitSound play];
      }
      break;
    }
  }
}

