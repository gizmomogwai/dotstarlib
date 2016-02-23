#include "dotstarlib.h"

#include <iostream>
#include <chrono>
#include <thread>
#include <unistd.h>

int main(int argc, char** args) {
  try {
    if (argc != 2) {
      std::cout << "Usage: " << args[0] << " nrOfLeds" << std::endl;
      return 1;
    }
    uint32_t nrOfLeds = std::stoi(args[1]);
    DotStarStrip strip(nrOfLeds);
    int delta = 1;
    int g = 0;
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
