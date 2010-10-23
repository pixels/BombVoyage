/*
 *  Bomb.mm
 *  BombVoyage
 *
 *  Created by Karatsu Naoya on 10/10/23.
 *  Copyright 2010 ajapax. All rights reserved.
 *
 */

#include "Bomb.h"

void Bomb::update() {
  frameCount++;

  size = 0.25 + 0.25 * (sinf(0.1 * frameCount) + 1) / 2;

  x += moveX;
  y += moveY;
}


