/*
 *  Particle.mm
 *  BombVoyage
 *
 *  Created by Karatsu Naoya on 10/10/19.
 *  Copyright 2010 ajapax. All rights reserved.
 *
 */

#include "Particle.h"

Particle::Particle() {
  this->x = 0.0f;
  this->y = 0.0f;
  this->size = 1.0f;
  this->activeFlag = false;
  this->frameCount = 0;
  this->lifeSpan = 100;
  this->moveX = 0.0f;
  this->moveY = 0.0f;
}

void Particle::draw(GLuint texture) {
  float lifePercentage = (float)frameCount / (float)lifeSpan;

  int alpha = 255 - (int)round(lifePercentage * 255.0f);
  drawTexture(x, y, size, size, texture, 255, 255, 255, alpha);
}

void Particle::update() {
  frameCount++;
  if(frameCount >= lifeSpan) activeFlag = false;

  x += moveX;
  y += moveY;
}
