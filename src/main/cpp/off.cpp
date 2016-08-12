#include "dotstarlib.h"

#include <iostream>
#include <chrono>
#include <thread>
#include <unistd.h>

void off(DotStarStrip& strip) {
  for (int i=0; i<strip.size(); ++i) {
    strip.setPixel(i, 0x000000);
  }
  strip.refresh();
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
  } catch (Exception* e) {
    std::cout << e->getMessage() << std::endl;
    return 1;
  }
  return 0;
}
