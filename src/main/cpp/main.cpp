#include "dotstarlib.h"

#include <iostream>
#include <chrono>
#include <thread>
#include <unistd.h>
#include <time.h>

void off(DotStarStrip& strip) {
  for (int i=0; i<strip.size(); ++i) {
    strip.setPixel(i, 0x000000);
  }
  strip.refresh();
}
void on(DotStarStrip& strip) {
  for (int i=0; i<strip.size(); ++i) {
    strip.setPixel(i, 0x7f7f7f);
  }
  strip.refresh();
}
void fade(DotStarStrip& strip, int shift) {
  struct timespec ts = {0, 25000000};
  for (int i=0; i<255; ++i) {
    for (int j=0; j<strip.size(); ++j) {
      strip.setPixel(j, i << shift);
    }
    strip.refresh();
    
    ::nanosleep(&ts, nullptr);
  }
  for (int i=255; i>=0; --i) {
    for (int j=0; j<strip.size(); ++j) {
      strip.setPixel(j, i << shift);
    }
    strip.refresh();
    
    ::nanosleep(&ts, nullptr);
  }
}
int main(int argc, char** args) {
  try {
    if (argc != 2) {
      std::cout << "Usage: " << args[0] << " nrOfLeds" << std::endl;
      return 1;
    }
    uint32_t nrOfLeds = std::stoi(args[1]);
    DotStarStrip strip(nrOfLeds);
    off(strip);
    sleep(1);
    on(strip);
    sleep(1);
    off(strip);
    sleep(1);
    fade(strip, 16);    
    fade(strip, 0);
    fade(strip, 7);
    fade(strip, 8);
    fade(strip, 12);
    /*
    strip.setPixel(1, 0xff0000);
    strip.setPixel(2, 0xffff00);
    strip.setPixel(3, 0xffffff);
    strip.setPixel(4, 0x00ff00);
    strip.setPixel(5, 0x00ffff);
    strip.setPixel(6, 0xff00ff);
    strip.setPixel(7, 0x7f7fff);
    strip.setPixel(8, 0x7f7fff);
    strip.setPixel(10, 0x7f7fff);
    strip.setPixel(12, 0x7f7fff);
    strip.setPixel(14, 0x7f7fff);
    strip.setPixel(16, 0x7f7fff);
    strip.setPixel(18, 0x7f7fff);
    strip.refresh();
    */
    sleep(1);
    return 0;
    int delta = 1;
    int g = 0;
    int i2 = 0;
    int i1 = 0;
    int i = 0;
    while (true) {
      i2 = i1;
      i1 = i;
      ++i;
      if (i > nrOfLeds) {
	i = 0;
      }
      
      strip.setPixel(i2, 0x000000);
      strip.setPixel(i1, 0x7f007f);
      strip.setPixel(i, 0x007f00);
      strip.refresh();
      usleep(10000);
    }
    while (true) {
      g += delta;
      if (g == 255) {
        delta = -1;
      }
      if (g == 0) {
        delta = 1;
      }
      int32_t c = g << 8;
      for (int i=0; i<nrOfLeds; ++i) {
        strip.setPixel(i, c);
      }
      strip.refresh();
      std::this_thread::sleep_for(std::chrono::milliseconds(10));
    }
  } catch (Exception* e) {
    std::cout << e->getMessage() << std::endl;
    return 1;
  }
  return 0;
}
