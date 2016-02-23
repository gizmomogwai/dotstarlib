#include "dotstarlib.h"

#include <iostream>

int main(int argc, char** args) {
  if (argc != 2) {
    std::cout << "Usage: " << args[0] << " nrOfLeds" << std::endl;
    return 1;
  }
  uint32_t nrOfLeds = std::stoi(s);
  DotStarStrip strip(nrOfLeds);

  return 0;
}
